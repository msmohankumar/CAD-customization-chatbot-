# Block123x32x43_withRadius.py
# NXOpen Python Journal
# Creates a block (123 x 32 x 43) and adds radius to all edges

import NXOpen

def main():
    # Get NX session, work part, and listing window
    the_session = NXOpen.Session.GetSession()
    work_part = the_session.Parts.Work
    lw = the_session.ListingWindow
    lw.Open()
    lw.WriteLine("=== Create Block + Radius ===")

    # -------------------------
    # Step 1: Create the Block
    # -------------------------
    null_feature = None
    block_builder = work_part.Features.CreateBlockFeatureBuilder(null_feature)

    origin = NXOpen.Point3d(0.0, 0.0, 0.0)
    block_builder.SetOriginAndLengths(origin, "123", "32", "43")

    block_feature = block_builder.CommitFeature()
    lw.WriteLine("Block created: {}".format(block_feature.JournalIdentifier))
    block_builder.Destroy()

    # -------------------------
    # Step 2: Add Edge Radius
    # -------------------------
    radius_value = "5"   # <-- change this value if you want a different radius

    # Create Edge Blend Builder
    edge_blend_builder = work_part.Features.CreateEdgeBlendBuilder(null_feature)

    # Select edges of the block body
    body = block_feature.GetBodies()[0]
    sc_collector = work_part.ScCollectors.CreateCollector()
    sc_rule_options = work_part.ScRuleFactory.CreateRuleOptions()
    sc_rule_options.SetSelectedFromInactive(False)

    edge_body_rule = work_part.ScRuleFactory.CreateRuleEdgeBody(body, sc_rule_options)
    sc_collector.ReplaceRules([edge_body_rule], False)

    # Assign radius to edges
    edge_blend_builder.AddChainset(sc_collector, radius_value)

    # Commit radius feature
    blend_feature = edge_blend_builder.CommitFeature()
    lw.WriteLine("Radius applied: {}".format(blend_feature.JournalIdentifier))
    edge_blend_builder.Destroy()

    lw.Close()

if __name__ == '__main__':
    main()
