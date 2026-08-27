# P11 Crossbow Watch Visual Verification

## Capture

- Runtime: Godot 4.7.2 on macOS, 1280×720 window.
- Screen: Battle, Red Banner Road wave one paused after one deterministic step.
- Layout: Crossbow Patrol and Watch Banner on the upper wall; Shield Guard focused on the gate road.

## Observations

- Violet piece fills and distinct crossbow/banner glyphs separate the new firing line from existing defenders without relying on imported art.
- The focused Shield Guard uses a red marker, shield arc, `ARMOR 2` board label, and numeric armor in the inspector.
- Forecast, enemy roster, and response preview all name Shielded Advance and `crossbow_patrol` consistently.
- The fort, routes, authoritative status, and pause controls remain visible at the target resolution.
- The supplied portrait references informed the violet-versus-red palette and disciplined silhouettes only; no external reference image was copied into the repository.

## Result

PASS — the teaching pair is distinguishable in the existing procedural board and its armor counter remains readable without color alone.
