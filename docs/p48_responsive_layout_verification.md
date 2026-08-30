# P48 — Responsive layout verification

- Build: `0.25.5-responsive-layout`
- Scope: War Council, Preparation, window fitting, UI-scale breakpoints, controller focus, and repeatable visual capture
- Authority: presentation only; no `PackKeepState`, content, combat, resource, placement, replay, or save-schema changes

## Implemented contract

- Windowed presets fit and center inside the active screen usable rectangle while preserving aspect ratio and never enlarging the requested size.
- Layout selection uses window width after UI scaling. A normal 1600×900 view retains the two-column composition; constrained effective widths stack the main surface above the command rail.
- War Council places its commit action before the choice cards so it remains reachable at 1280×720 and large text. Choice cards and the Preparation brief stack only at the tighter compact threshold.
- Narrow large-text navigation removes decorative phase tabs but retains current-screen identity and Settings.
- Controller focus starts on **Enter Keep** in War Council and the legal **Ready Defense** action in Preparation. Page scrolling moves only enough to reveal the focused setup action, while Preparation opens at the board-first strategic summary.
- The vertical-slice capture harness accepts explicit width, height, and UI-scale index and records those values in its manifest.

## Focused verification

```text
godot --headless --path . --script tests/test_p38_war_council_choice_cards.gd
P38 War Council choice cards: PASS

godot --headless --path . --script tests/test_p40_preparation_command_hierarchy.gd
P40 preparation command hierarchy: PASS

godot --headless --path . --script tests/test_p48_responsive_layout.gd
P48 responsive layout: PASS
```

The P48 test covers proportional window fitting, 1600×900 at 100%, 1280×720 at 100%, 1280×720 at 150%, 1600×900 at 125%, horizontal containment, compact navigation, primary-action focus, Preparation scroll origin, and serialized-state invariance.

## Visual verification

The graphical harness produced complete nine-screen flows at 1280×720 with 150% UI scale and at 1600×900 with 100% UI scale. War Council and Preparation were inspected directly. The normal layout retains its main/rail split; the large-text layout has no horizontal clipping, keeps **Enter Keep** visible through focused scrolling, and opens Preparation on the strategic brief with the assault action reachable. Capture manifests mark the evidence as automated and `human_evidence: false`.

## Remaining boundary

The narrow fallback intentionally uses vertical scrolling. P49 should improve the keep-first visual hierarchy and authored board surfaces without reintroducing horizontal overflow or hiding required controls.
