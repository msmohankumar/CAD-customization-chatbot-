# -*- coding: utf-8 -*-
import NXOpen
from NXOpen.Features import BooleanFeature

def subtract_bodies_modify_target(work_part, target_body, tool_body):
    """
    Subtracts tool_body from target_body and modifies the original target.
    Target is NOT kept (Keep Target = False)
    """
    boolean_builder = work_part.Features.CreateBooleanBuilder(None)
    boolean_builder.CopyTargets = False     # Do not copy target (modify original)
    boolean_builder.CopyTools = False
    boolean_builder.RetainTarget = False    # Target will be modified
    boolean_builder.RetainTool = False
    boolean_builder.Target = target_body
    boolean_builder.Tool = tool_body
    boolean_builder.Operation = BooleanFeature.BooleanType.Subtract

    result_feature = boolean_builder.CommitFeature()
    boolean_builder.Destroy()
    return result_feature

def main():
    the_session = NXOpen.Session.GetSession()
    the_lw = the_session.ListingWindow
    the_part = the_session.Parts.Work

    the_lw.Open()

    if not the_part:
        the_lw.WriteFullline("? No active part found.")
        return

    # === Create Target Block ===
    block_builder1 = the_part.Features.CreateBlockFeatureBuilder(None)
    block_builder1.Type = block_builder1.Types.OriginAndEdgeLengths
    origin1 = NXOpen.Point3d(-50.0, -50.0, -25.0)
    block_builder1.SetOriginAndLengths(origin1, "100.0", "100.0", "50.0")
    block_feature1 = block_builder1.Commit()
    block_builder1.Destroy()
    block_feature1.SetName("Target Body")

    target_bodies = block_feature1.GetBodies()
    target_body = target_bodies[0]

    # === Create Tool Block to subtract ===
    block_builder2 = the_part.Features.CreateBlockFeatureBuilder(None)
    block_builder2.Type = block_builder2.Types.OriginAndEdgeLengths
    origin2 = NXOpen.Point3d(-40.0, -40.0, 0.0)
    block_builder2.SetOriginAndLengths(origin2, "80.0", "80.0", "50.0")
    block_feature2 = block_builder2.Commit()
    block_builder2.Destroy()
    block_feature2.SetName("Tool Body")

    tool_bodies = block_feature2.GetBodies()
    tool_body = tool_bodies[0]

    # === Subtract Tool Body from Target Body, modify target ===
    try:
        result_feature = subtract_bodies_modify_target(the_part, target_body, tool_body)
        if result_feature:
            the_lw.WriteFullline("? Subtract operation completed. Target modified, tool removed.")
        else:
            the_lw.WriteFullline("? Subtract operation returned no feature.")
    except Exception as e:
        the_lw.WriteFullline(f"? Error during subtraction: {e}")

    the_lw.WriteFullline("?? All operations completed.")

if __name__ == "__main__":
    main()
