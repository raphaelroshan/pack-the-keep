# P49 — Keep-first visual finish verification

- Build: `0.26.0-keep-first-visual-finish`
- Scope: Greywatch authored surface treatment, selected room/defender board projection, accessibility, responsive visual evidence
- Authority: presentation only; no geometry, hit-test, placement, combat, resource, content, replay, or save-schema changes

## Implemented contract

- The existing `assets/greywatch_background.png` now supplies distinct stone-work-yard and timber-wall-walk source regions beneath the ground and upper tactical boards.
- Opaque procedural surfaces became restrained state-color overlays, while wall rings, rooms, connections, defenders, threats, health bars, placement guides, focus, and tutorial layers retain their exact coordinates and ordering.
- Clicking a room or defender adds a gold redundant outline and a compact on-board plate naming identity, condition, tactical purpose, and next action.
- High contrast reduces texture opacity and increases selection-outline width.
- Ash Ford remains on its river-specific procedural fallback until it has an authored asset with matching provenance.
- The capture harness can optionally select the starting Pike Squad with `--inspect-starting-defender`; the manifest records that choice.

## Focused verification

```text
godot --headless --path . --script tests/test_p34_board_visual_hierarchy.gd
P34 board visual hierarchy: PASS

godot --headless --path . --script tests/test_p48_responsive_layout.gd
P48 responsive layout: PASS

godot --headless --path . --script tests/test_p49_keep_first_visual_finish.gd
P49 keep-first visual finish: PASS
```

The P49 regression verifies texture assignment, distinct floor materials/source regions, exact board geometry, room and defender selection projection, identity/condition/purpose/next-action content, high-contrast noise reduction, stronger selection outlines, Ash Ford fallback behavior, and serialized-state invariance.

## Visual verification

Complete nine-screen flows were captured at 1600×900 and 1280×720. The 1600×900 selected-defender capture shows the authored masonry/timber treatment, Pike Squad outline, and board plate without hiding the Preparation brief, assault action, both floors, or command rail. The 1280×720 sequence preserves the P48 single-column fallback without horizontal clipping. Capture manifests mark all evidence as automated and `human_evidence: false`.

## Remaining boundary

This slice improves Greywatch only and deliberately keeps the tactical overlay stronger than the source art. K3 should now extract presentation snapshots and panels from `main.gd` before P50 expands battle/recovery pacing.
