# P12 — Packaged Controller and Scaling Smoke

## Intent

Extend the Windows artifact gate beyond launch and persistence. The exported build must retain controller navigation, accept a conflict-resolving controller remap, apply the 125% stacked layout, and persist both choices without touching authoritative run state.

## Acceptance criteria

- Exported UI navigation exposes controller accept and directional paths.
- Every remappable gameplay action has a controller binding before customization.
- Rebinding battle pause to button 10 removes that conflict from placement arm while preserving usable actions.
- UI scale 125% applies a 1.25 content scale and stacks board/command columns.
- Settings schema 4 persists scale index 2 and the remapped controller button.
- The packaged report validates all observations outside Godot.

**Trade-off:** CI injects controller events instead of requiring physical hardware. Device enumeration, analog drift, and vendor-specific layouts remain manual alpha checks.
