# AddChamferToExisting_robust.py
# Robust attempt to apply chamfer to the first solid body using the same collector/rule pattern as the radius script.
# It will try multiple option-setting approaches and log details to the Listing Window.

import NXOpen
import traceback

CHAMFER = "5"   # change value (string) if you want a different chamfer

def make_edge_collector_for_body(work_part, body):
    sc_col = work_part.ScCollectors.CreateCollector()
    sc_opts = work_part.ScRuleFactory.CreateRuleOptions()
    try:
        sc_opts.SetSelectedFromInactive(False)
    except Exception:
        pass
    try:
        edge_rule = work_part.ScRuleFactory.CreateRuleEdgeBody(body, sc_opts)
        sc_col.ReplaceRules([edge_rule], False)
    except Exception:
        # fallback: add edges directly if rule not available
        try:
            edges = list(body.GetEdges())
            sc_col.ReplaceObjects(edges, False)
        except Exception:
            pass
    return sc_col

def try_commit_chamfer(work_part, sc_collector, first_off, second_off, set_option_func, lw):
    """
    Attempt to create a ChamferBuilder, set collector, offsets, call set_option_func(builder),
    validate+commit and return (success_bool, message, feature_or_none).
    """
    try:
        cb = work_part.Features.CreateChamferBuilder(None)
    except Exception as e:
        return False, "CreateChamferBuilder failed: {}".format(e), None

    try:
        # Attach collector (do this before offsets where possible)
        try:
            cb.SmartCollector = sc_collector
        except Exception as ex:
            lw.WriteLine(" - warning: setting SmartCollector raised: {}".format(ex))

        # Set offsets
        try:
            cb.FirstOffset = first_off
            cb.SecondOffset = second_off
        except Exception as ex:
            lw.WriteLine(" - warning: setting offsets raised: {}".format(ex))

        # Set option via supplied function (could be no-op)
        try:
            set_option_func(cb)
        except Exception as ex:
            lw.WriteLine(" - option setter raised: {}".format(ex))

        # Validate if available
        try:
            if hasattr(cb, "Validate"):
                cb.Validate()
        except Exception as ex:
            lw.WriteLine(" - Validate() raised: {}".format(ex))

        # Try commit
        try:
            feat = cb.CommitFeature()
            return True, "Commit succeeded: {}".format(getattr(feat, "JournalIdentifier", "<no id>")), feat
        except Exception as ex:
            return False, "Commit failed: {}".format(ex), None

    finally:
        try:
            cb.Destroy()
        except Exception:
            pass

def main():
    sess = NXOpen.Session.GetSession()
    work_part = sess.Parts.Work
    lw = sess.ListingWindow
    lw.Open()
    lw.WriteLine("=== AddChamferToExisting_robust START ===")

    try:
        # find first solid body
        body = None
        for b in work_part.Bodies:
            # some NX versions have IsSolidBody as callable or property
            try:
                ok = getattr(b, "IsSolidBody")
                if callable(ok):
                    is_solid = ok()
                else:
                    is_solid = bool(ok)
            except Exception:
                # assume it's a solid if no attribute
                is_solid = True
            if is_solid:
                body = b
                break

        if body is None:
            lw.WriteLine("? No solid body found in the active part. Create one and retry.")
            return

        lw.WriteLine("Found body: {}".format(getattr(body, "Name", "<no-name>")))

        sc_col = make_edge_collector_for_body(work_part, body)
        lw.WriteLine("Collector prepared for body.")

        # We'll try a series of "option setters". Each is a function that accepts a builder and sets an option.
        option_setters = []

        # 0) No option set (let builder defaults)
        option_setters.append(("no_option", lambda cb: None))

        # 1) Try numeric option values (0..6)
        def make_numeric_setter(v):
            def s(cb):
                try:
                    cb.Option = v
                except Exception:
                    # try ChamferOption attribute
                    try:
                        cb.ChamferOption = v
                    except Exception:
                        # try Method and OffsetMethod
                        try:
                            cb.Method = v
                        except Exception:
                            try:
                                cb.OffsetMethod = v
                            except Exception:
                                raise
            return s
        for num in range(0, 6):
            option_setters.append(("Option = {}".format(num), make_numeric_setter(num)))

        # 2) Try some common string names (some wrappers accept names)
        def make_string_setter(name):
            def s(cb):
                # try setting attribute to the string
                for attr in ("Option", "ChamferOption", "Method", "OffsetMethod"):
                    try:
                        setattr(cb, attr, name)
                        return
                    except Exception:
                        pass
                # try properties that contain 'Option' or 'Method'
                raise Exception("string setter could not set any recognized property")
            return s
        for name in ("SymmetricOffset", "symmetric", "DistanceDistance", "TwoOffsets", "OffsetAndAngle"):
            option_setters.append(("Option string '{}'".format(name), make_string_setter(name)))

        # 3) Try to find numeric-like enum via introspection: try attributes on builder type that look like enum members
        # We'll collect attribute names from a fresh builder for hints
        try:
            probe_cb = work_part.Features.CreateChamferBuilder(None)
            members = dir(probe_cb)
            probe_names = [m for m in members if any(k in m.lower() for k in ("symmet", "offset", "two", "distance", "angle"))]
            probe_cb.Destroy()
            for nm in probe_names:
                # attempt to use attribute value as option (if attribute holds an int/enum)
                def make_probe_setter(attrname):
                    def s(cb):
                        try:
                            val = getattr(cb, attrname)
                            # try assigning same val back to Option/ChamferOption
                            try:
                                cb.Option = val
                                return
                            except Exception:
                                try:
                                    cb.ChamferOption = val
                                    return
                                except Exception:
                                    pass
                        except Exception:
                            raise
                    return s
                option_setters.append(("probe_by_attr {}".format(nm), make_probe_setter(nm)))
        except Exception:
            pass

        # Try each setter by creating a new builder each time (commit on success)
        success = False
        for label, setter in option_setters:
            lw.WriteLine("Trying option-setter: {}".format(label))
            # define local function to pass to try_commit_chamfer
            success_flag, msg, feat = try_commit_chamfer(work_part, sc_col, CHAMFER, CHAMFER, setter, lw)
            lw.WriteLine(" -> result: {}".format(msg))
            if success_flag:
                lw.WriteLine("? Chamfer applied successfully using setter: {}".format(label))
                success = True
                break

        if not success:
            lw.WriteLine("? All attempts failed. See above messages. Next steps:")
            lw.WriteLine(" - paste the Listing Window output here (I will use it to craft an exact single-line fix), or")
            lw.WriteLine(" - I can provide a UF (low-level) chamfer implementation as fallback if you want that now.")
    except Exception as e:
        lw.WriteLine("Fatal exception: {}".format(e))
        lw.WriteLine(traceback.format_exc())
    finally:
        lw.WriteLine("=== AddChamferToExisting_robust END ===")
        lw.Close()

if __name__ == "__main__":
    main()
