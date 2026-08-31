# P57 Combat Effect Readability

## Player-facing purpose

Resolved attacks should have a brief, directional visual punctuation that makes response, impact, and damage easier to follow at normal play distance. The effect must reinforce the existing health, target, and damage language rather than cover it.

## Presentation data

- Defender melee and ranged responses resolve separate temporary CC0 effect textures.
- Hostile melee, ranged, and demolition impacts resolve separate temporary CC0 effect textures.
- Effect profiles live in the board visual registry and expose source, path, size, tint, and temporary status.
- The board renderer caches effect textures and draws them only during the already-established response and impact beats.
- Missing textures retain the existing procedural impact marks.

## Acceptance criteria

- Defender melee and ranged hits are visually distinct at normal board distance.
- Hostile melee, ranged, and demolition hits use distinct effect profiles.
- Damage numbers, health trails, target lines, focus rings, and room/piece state remain legible above or alongside the effect.
- Effects remain short, restrained, and presentation-only.
- Reduced motion uses a compact static effect without travel-dependent scaling.
- Missing effect assets do not remove procedural projectile, slash, ring, or damage feedback.
- Pause, speed, manual-step, serialization, and replay keys remain unchanged.

## Test cases

- Assert every combat style resolves a loadable temporary effect texture.
- Assert defender ranged, defender melee, hostile ranged, hostile melee, and demolition mappings are distinct where their tactical meaning differs.
- Stage a deterministic exchange through the existing battle-beat test and verify the effect snapshot without changing serialized state.
- Capture defender response and hostile impact at 1600×900 and verify the effect does not obscure tactical overlays.
