# P51.1 Quartermaster Verification

**Build:** `0.31.0-quartermaster`

## Implemented evidence

- War Council exposes a third commander card for the Quartermaster through the existing selection and controller-focus path.
- Preparation previews the authoritative first-pack discount as `Measured Stores`, including base cost, discount, and effective cost before purchase.
- The first pack opened in each Preparation receives exactly a two-material discount; later openings use authored cost.
- A surviving Supply Cache releases seven materials for the Quartermaster and five for other commanders.
- Resupply is disabled with a reason until at least one living defender is missing health or ammunition. It restores at most two of each, costs one command point, and is limited to once per assault.
- Save schema 4 remains unchanged. The optional `resupply_used` field defaults safely for older saves and round-trips current mid-assault state.
- The all-scenario matrix now covers ten non-overwhelming scenarios, three commanders, and three seeds: 90 viable cases and 180 uninterrupted/resumed simulations.
- First Watch remains locked to the Castellan. The existing P16 human-session matrix remains an explicitly separate two-commander cohort until a new cohort is scheduled.

## Automated verification

- `tests/test_p51_quartermaster.gd`
- `tests/test_p51_quartermaster_ui.gd`
- `tests/test_pack_catalog.gd`
- `tests/test_p38_war_council_choice_cards.gd`
- `tests/test_p12_alpha_scenario_matrix.gd`
- `tools/validate_runtime_content.py`

## Visual review contract

At 1280×720 and 2560×1440, inspect the Quartermaster War Council card, discounted pack offer, and Battle ability state. The shared portrait remains a tinted placeholder; no dedicated Quartermaster portrait or final-art claim is made in this slice.

Captured evidence:

- `docs/visual_evidence/v0.31.0-quartermaster-review-2026-08-31/` — 1280×720 at 125% UI scale, including the dedicated `03b_pack_offer.png` discount view.
- `docs/visual_evidence/v0.31.0-quartermaster-2560x1440-review-2026-08-31/` — 2560×1440 at 150% UI scale.

Review result: the third commander identity, strategic question, limitation, effective pack price, keep-first Preparation layout, and unavailable Resupply state remain readable. Narrow and large-text layouts intentionally scroll; the primary commit and assault actions stay ahead of optional detail. The 1280×720 pack-offer capture shows the full pricing explanation and action without horizontal clipping.

## Remaining P51 work

P51 still requires one new defensive identity, two teaching packs, and two enemy families, each introduced through an isolated scenario before combination.
