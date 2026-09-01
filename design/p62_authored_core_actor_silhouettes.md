# P62 — Authored Core Actor Silhouettes

## Player-facing purpose

Make the vertical-slice defenders and signature enemies readable as Pack the Keep actors at normal board distance rather than borrowed placeholder tiles. Each silhouette must communicate one role through a bold shape at 13–20px while existing color, health, focus, target, cadence, and status overlays remain dominant.

## Presentation data

`BoardVisualRegistry` owns stable paths and provenance for four defender-role silhouettes and the Raider, Sapper, Climber, and Siege Beast. Extended enemy families retain their licensed temporary sprites until their own authored pass. Procedural role badges and enemy shapes remain the fallback and redundant accessibility layer.

No piece ID, enemy ID, combat style, targeting rule, timing value, damage value, room assignment, save field, or simulation command changes.

## Acceptance criteria

1. Formation, ranged, mobile-support, and signal defenders resolve distinct original vector silhouettes.
2. Raider, Sapper, Climber, and Siege Beast each resolve a distinct original vector silhouette.
3. Every authored source is transparent, text-free, designed on a 32×32 view box, and remains recognizable at the board renderer's 13–20px display range.
4. Extended enemy families retain the temporary CC0 fallback and report that provenance honestly.
5. Health bars, focus rings, target lines, cadence, status labels, high contrast, and procedural fallback remain intact.
6. Asset lookup and drawing remain presentation-only and do not mutate `KeepState`.

## Test cases

- Assert each defender role resolves the intended authored path and loads.
- Assert each core enemy resolves a distinct authored path and loads.
- Assert an extended enemy still resolves a loadable temporary fallback.
- Assert board snapshots expose both authored-core and remaining-temporary provenance.
- Capture Preparation and a staged Battle exchange at 1600×900 and inspect the silhouettes at actual play scale.
