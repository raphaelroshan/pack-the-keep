# P51.2 Twinwatch Bastion Verification

**Build:** `0.32.0-twinwatch`

## Implemented evidence

- `twinwatch_bastion` supplies a third data-driven room graph and a cold ridge/two-bastion visual treatment without changing placement geometry or stable room identities.
- `paired_bastions` is inactive until both the West Gatehouse and East Arsenal have an adjacent living combat defender.
- Active paired watch reduces room damage by exactly one. Removing or disabling either anchor defender removes the benefit immediately.
- Twinwatch repairs cost seven materials and restore twenty-five condition, creating a middle-depth recovery choice between Greywatch and Ash Ford.
- `the_divided_bell` teaches the identity through three authored phases and names Shieldwall and Runner Network as distinct answers.
- Eighteen focused runs cover both answers, all three commanders, three seeds, and wave-two save/resume parity.
- The full matrix covers eleven non-overwhelming scenarios, three commanders, and three seeds: 99 viable cases and 198 uninterrupted/resumed simulations.

## Automated verification

- `tests/test_p51_twinwatch_identity.gd`
- `tests/test_p51_twinwatch_ui.gd`
- `tests/test_p12_alpha_scenario_matrix.gd`
- `tests/test_pack_catalog.gd`
- `tools/validate_runtime_content.py`
- Complete `scripts/verify.sh`: PASS on Godot 4.7.2.
- Performance budget: PASS — 40 runs in 2193 ms and 120 large-text UI refreshes in 122 ms.

## Visual review contract

Reviewed real-renderer captures:

- `docs/visual_evidence/v0.32.0-twinwatch-review-2026-08-31/` — 1280×720 at 125% UI scale.
- `docs/visual_evidence/v0.32.0-twinwatch-2560x1440-review-2026-08-31/` — 2560×1440 at 150% UI scale.

Both sequences contain War Council, one-post and two-post Preparation states, staged first contact, both Recovery intervals, and terminal Results. The two bastion masses, narrow center link, anchor outlines, inactive/active badge, room condition bars, and battle routes remain readable. The spatial badge uses its own centered plate so it does not collide with room identity text.

## Remaining P51 work

P51 still requires two teaching packs and two enemy families. Each pack/enemy question must ship through an isolated scenario before any combined challenge.
