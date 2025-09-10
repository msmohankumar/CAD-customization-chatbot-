# NXOpen Python: Create persistent sketch on WCS XY with 100x50 rectangle (NX 2007 compatible)
# Adapted from provided VB.NET code for reliability: uses CreateSketchInPlaceBuilder2, explicit origin/CSYS, and update.

import NXOpen

def main():
    the_session = NXOpen.Session.GetSession()
    work_part = the_session.Parts.Work

    try:
        # Ensure modeling environment
        if the_session.ApplicationName != "UG_APP_MODELING":
            the_session.ApplicationSwitchImmediate("UG_APP_MODELING")

        # Create coordinate system (WCS equivalent)
        origin = NXOpen.Point3d(0.0, 0.0, 0.0)
        x_dir = NXOpen.Vector3d(1.0, 0.0, 0.0)
        y_dir = NXOpen.Vector3d(0.0, 1.0, 0.0)
        csys = work_part.CoordinateSystems.CreateCoordinateSystem(origin, x_dir, y_dir)

        # Create origin point
        origin_point = work_part.Points.CreatePoint(origin)

        # Create sketch builder (from VB: CreateSketchInPlaceBuilder2)
        sketch_builder = work_part.Sketches.CreateSketchInPlaceBuilder2(NXOpen.Sketch.Null)
        sketch_builder.Csystem = csys
        sketch_builder.SketchOrigin = origin_point

        # Commit to create sketch
        sketch = sketch_builder.Commit()
        sketch_builder.Destroy()

        # Set visible layer
        sketch.Layer = 1

        # Add rectangle geometry (100x50 centered)
        half_width = 50.0
        half_height = 25.0
        p1 = NXOpen.Point3d(-half_width, -half_height, 0.0)
        p2 = NXOpen.Point3d(half_width, -half_height, 0.0)
        p3 = NXOpen.Point3d(half_width, half_height, 0.0)
        p4 = NXOpen.Point3d(-half_width, half_height, 0.0)

        l1 = work_part.Curves.CreateLine(p1, p2)
        l2 = work_part.Curves.CreateLine(p2, p3)
        l3 = work_part.Curves.CreateLine(p3, p4)
        l4 = work_part.Curves.CreateLine(p4, p1)

        for line in [l1, l2, l3, l4]:
            line.Layer = 1
            sketch.AddGeometry(line, NXOpen.Sketch.InferConstraintsOption.InferNoConstraints)

        # Update to finalize (from VB: ActiveSketch.Update)
        sketch.Update()

        # Force model update for visibility
        mark_id = the_session.SetUndoMark(NXOpen.Session.MarkVisibility.Visible, "Update Model")
        the_session.UpdateManager.DoUpdate(mark_id)

        # Fit view
        the_session.DisplayManager.NewPartView.Fit()

        print("Persistent sketch created on layer 1. Check Part Navigator.")

    except Exception as ex:
        print("Error: " + str(ex))

if __name__ == "__main__":
    main()
