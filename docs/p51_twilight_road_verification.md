# P51.5 Twilight Road Verification

**Build:** `0.35.0-twilight-road`

## Implemented contract

- The Twilight Road introduces one Outrider in phase one, one Gloam Knife in phase two, then combines two of each under Twilight Crossing in phase three.
- No new combat state was added: the scenario composes the existing wave-start momentum and concealment authorities.
- Road Wardens plus Lantern Watch form the prepared-route plan; Crossbow Watch plus Runner Network form the flexible-response plan.
- Both plans complete all three phases without collapse for all three commanders across three fixed seeds.
- Active-wave save/load preserves charge, visibility, targets, outcomes, and replay identity byte-for-byte.
- Four-threat approach and timeline marker spacing was widened, and the redundant bottom-edge impact label was removed to keep the combined battle readable.
- The full matrix covers fourteen non-overwhelming scenarios, three commanders, and three seeds: 126 viable cases and 252 uninterrupted/resumed simulations.

## Automated evidence

- `tests/test_p51_twilight_road.gd`
- `tests/test_p51_twilight_road_ui.gd`
- `tests/test_p12_alpha_scenario_matrix.gd`
- `tests/test_pack_catalog.gd`
- `scripts/verify.sh`

## Visual evidence

- `docs/visual_evidence/v0.35.0-twilight-road-review-2026-08-31/` — 1280×720 at 125% UI scale.
- `docs/visual_evidence/v0.35.0-twilight-road-2560x1440-review-2026-08-31/` — 2560×1440 at 150% UI scale.

Both captures include War Council, the completed two-floor prepared layout, isolated first and second pressures, the combined four-threat final phase, Recovery, and terminal Results. These are presentation inspections, not human evidence.
