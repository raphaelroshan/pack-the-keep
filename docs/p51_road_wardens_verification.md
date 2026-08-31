# P51.3 Road Wardens Verification

**Build:** `0.33.0-road-wardens`

## Implemented evidence

- `road_wardens` opens Hook Guard and Stake Line as one coherent interception doctrine.
- `outrider` remains a unit hunter and contacts at tick two unless a living Stake Line is adjacent to one of its authored approach rooms when the wave starts.
- A prepared Stake Line delays contact by exactly one tick; Hook Guard then has enough deterministic responses to stop the isolated eight-health threat before contact.
- Crossbow Patrol plus Watch Banner stops the same threat on its original contact tick, while an open-lane Runner Pair remains a third direct counter.
- Effective arrival, momentum state, targets, and health survive schema-4 save/load without introducing a new save field.
- Eighteen focused runs cover both primary answers, all three commanders, three seeds, and wave-two save/resume parity.
- The full matrix covers twelve non-overwhelming scenarios, three commanders, and three seeds: 108 viable cases and 216 uninterrupted/resumed simulations.

## Automated verification

- `tests/test_p51_road_wardens.gd`
- `tests/test_p51_road_wardens_ui.gd`
- `tests/test_p12_alpha_scenario_matrix.gd`
- `tests/test_pack_catalog.gd`
- `tests/test_runtime_content_validator.py`
- `tools/validate_runtime_content.py`
- Complete `scripts/verify.sh`: PASS on Godot 4.7.2.
- Performance budget: PASS — 40 runs in 3980 ms and 120 large-text UI refreshes in 155 ms.

## Visual review contract

Reviewed real-renderer captures:

- `docs/visual_evidence/v0.33.0-road-wardens-review-2026-08-31/` — 1280×720 at 125% UI scale.
- `docs/visual_evidence/v0.33.0-road-wardens-2560x1440-review-2026-08-31/` — 2560×1440 at 150% UI scale.

Both sequences contain War Council, live-momentum and prepared-delay Preparation states, staged first contact, both Recovery intervals, and terminal Results. The scenario question, pack identities, Outrider marker, `Charge: DELAYED` state, health bars, target route, and battle controls remain readable without horizontal clipping.

## Remaining P51 work

P51 still requires the second teaching pack and isolated enemy family. Only after that pair passes independently should a combined challenge be authored.
