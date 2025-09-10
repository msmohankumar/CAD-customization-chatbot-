# inspect_chamfer_builder.py
import NXOpen, traceback

def main():
    the_session = NXOpen.Session.GetSession()
    work_part = the_session.Parts.Work
    lw = the_session.ListingWindow
    lw.Open()
    lw.WriteLine("=== inspect_chamfer_builder START ===")
    try:
        cb = work_part.Features.CreateChamferBuilder(None)
        lw.WriteLine("Created ChamferBuilder object: {}".format(type(cb)))
        members = dir(cb)
        lw.WriteLine("ChamferBuilder members count: {}".format(len(members)))
        # Print each member on its own line (Listing Window)
        for m in members:
            try:
                lw.WriteLine(m)
            except Exception:
                pass

        # Also print a few common introspection hints: callable or attribute
        lw.WriteLine("---- callability / type hints ----")
        for m in members:
            try:
                attr = getattr(cb, m)
                kind = "callable" if callable(attr) else type(attr).__name__
                lw.WriteLine("{:40} : {}".format(m, kind))
            except Exception:
                # ignore attributes that throw on getattr
                pass

        # Clean up
        try:
            cb.Destroy()
        except Exception:
            pass

    except Exception as e:
        lw.WriteLine("Exception while inspecting ChamferBuilder:")
        lw.WriteLine(traceback.format_exc())
    finally:
        lw.WriteLine("=== inspect_chamfer_builder END ===")
        lw.Close()

if __name__ == "__main__":
    main()
