# Pack the Keep — Latest Main Test Report

## Build and verification

| Field | Result |
|---|---|
| Branch tested | `feat/k7-replay-mastery-summary` before merge to `main` |
| Build | `v0.29.0-replay-mastery` |
| Engine | Godot 4.7.2 |
| Visual test display | 1600×900 local graphical renderer |
| Automated verification | PASS: complete `scripts/verify.sh` suite |
| Runtime content | PASS: 2 keeps, 17 pieces, 9 packs, 8 enemies, 9 doctrines, 11 scenarios |
| Scenario matrix | PASS: 60 viable cases and 120 uninterrupted/resumed simulations |
| Human playtest gate | PENDING: no human observations inferred from automation |

## K7 evidence

The existing seeded scenario variation is now visible before commitment. Terminal Results compares that pressure with placed or opened defense families, recovery investment, opened packs, and the first uncovered doctrine that offers a useful replay experiment.

Focused verification covers deterministic seed projection, applicable room-pressure wording, doctrine-family coverage, recovery-action accounting, first-uncovered-doctrine guidance, save/load parity, normal-flow War Council entry, terminal Results, large text, high contrast, and reduced motion.

The 1600×900 screenshots in `/tmp/pack-the-keep-k7` show Thin Command directly above **Enter Keep** and a terminal debrief where seed pressure, 2/3 doctrine fit, 1/4 recovery commitment, and Crossbow Watch remain readable beside the damaged keep.

## Findings

The replay summary explains why a successful defense is still worth revisiting without adding rarity, grind, permanent power, or a new save field. It reuses authored doctrine counter families and existing variation state instead of inventing a second authority.

No automated regression or deterministic divergence was found. The known release limitation remains unchanged: the build is an internal pre-alpha candidate and has no completed human-session evidence.

## Next roadmap step

K8 should consolidate the existing accessibility, persistence, controller, audio, clean-install, migration, performance, provenance, rollback, and known-limitation evidence into one honest private-alpha gate. Human sessions and owner approval remain separate and pending.
