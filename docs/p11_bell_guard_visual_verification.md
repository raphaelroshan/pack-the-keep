# P11 Bell Guard Visual Verification

## Capture

- Runtime: Godot 4.7.2 on macOS, 1280×720 window.
- Screen: Battle, Ash at the Bell wave one paused after one deterministic step.
- Layout: Pike Squad on the ground floor with Bellkeepers and Signal Beacon linked on the upper wall; Ash Slinger focused on the gate road.

## Observations

- Gold bell and relay glyphs make the two-piece signal chain distinct from direct-damage defenders.
- The Ash Slinger uses a gray smoke treatment, `SMOKE` board label, and stable `A` marker.
- Forecast and enemy roster explicitly show `Signal: REDUNDANT` / `signal RELAYED`; the inspector exposes contact step 3.
- Response preview names Bellkeepers rather than a raw content ID.
- Fort state, route, target, pause controls, and causal context remain visible at the target resolution.

## Result

PASS — the player can read smoke pressure, the intact relay, and preserved arrival timing without relying only on color.
