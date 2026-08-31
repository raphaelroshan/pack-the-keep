# P53 Alpha Flow Hardening Verification

**Build:** `0.38.0-alpha-hardened`

## Implemented contract

- One test drives Main Menu → War Council → Preparation → all three Twilight assaults → both recovery boundaries → terminal Results.
- The journey runs at 2560×1440 with 150% UI scale, high contrast, reduced motion, and muted effects.
- Controller-first focus is asserted at setup, assault readiness, the authored route decision, and terminal replay.
- Ordinary Recovery and the open Twilight Crossroads decision are both saved and restored through isolated atomic files.
- Muted audio retains visible semantic warning and terminal-hold cues.
- Terminal Results retains seeded pressure, preparation focus, selected branch, forgone preparation, and a visible replay action.
- Existing K8 performance, package provenance, clean-install, migration, and forced-close evidence remains authoritative.

## Automated evidence

- `tests/test_p53_alpha_flow_hardening.gd`
- `tests/test_p48_responsive_layout.gd`
- `tests/test_p46_navigation_safety.gd`
- `tests/test_p35_battle_audio_cues.gd`
- `tests/test_p12_save_recovery.gd`
- `tests/test_k8_performance_budget.gd`
- `scripts/verify.sh`

## Remaining human evidence

P16 observation, physical-controller coverage, Windows GPU presentation, listening review, signing, and storefront approval remain pending and are not inferred from this automated gate.
