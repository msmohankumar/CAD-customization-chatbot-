import NXOpen
import NXOpen.Features
from NXOpen import Point3d

def main():
    the_session = NXOpen.Session.GetSession()
    work_part = the_session.Parts.Work
    the_session.SetUndoMark(NXOpen.Session.MarkVisibility.Visible, "Create Cylinder")
    
    cylinder_builder = work_part.Features.CreateCylinderBuilder(None)
    try:
        cylinder_builder.BooleanOption.Type = NXOpen.GeometricUtilities.BooleanOperation.BooleanType.Create
        cylinder_builder.Diameter.RightHandSide = "50"
        cylinder_builder.Height.RightHandSide = "100"
        cylinder_builder.Origin = Point3d(0.0, 0.0, 0.0)
        feature = cylinder_builder.Commit()
    finally:
        cylinder_builder.Destroy()

if __name__ == '__main__':
    main()
