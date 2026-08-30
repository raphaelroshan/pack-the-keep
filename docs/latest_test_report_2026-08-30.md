# Pack the Keep — Latest Main Test Report

## Build and verification

| Field | Result |
|---|---|
| Branch tested | `feat/forced-close-recovery` before merge to `main` |
| Build | `v0.30.1-forced-close-recovery` |
| Engine | Godot 4.7.2 |
| Visual test display | 1600×900 local graphical renderer |
| Automated verification | PASS: complete `scripts/verify.sh` suite |
| Runtime content | PASS: 2 keeps, 17 pieces, 9 packs, 8 enemies, 9 doctrines, 11 scenarios |
| Scenario matrix | PASS: 60 viable cases and 120 uninterrupted/resumed simulations |
| Human playtest gate | PENDING: no human observations inferred from automation |

## P54 evidence

The Windows lifecycle now externally terminates the packaged process after it flushes valid backups and deliberately strands malformed primary run/settings files. Relaunching the same relocated executable and profile must restore both backups and rewrite valid current-schema primaries.

Focused verification covers the termination coordinator, packaged smoke schema 3, run/settings recovery fields, validator rejection of missing evidence, and the existing lifecycle matrix. The tagged Windows workflow is the authoritative end-to-end kill/relaunch evidence.

P54 changes no player-facing composition, so the reviewed K7 War Council and Results captures remain the current visual baseline.

## Findings

The automated K1–K8 roadmap and deterministic forced-close fixture are complete without changing simulation authority or save schemas. Human comprehension, physical controllers, broad Windows GPUs, audio listening, varied real-world forced-close timing, signing, and storefront launch remain pending.

No automated regression or deterministic divergence was found. The known release limitation remains unchanged: the build is an internal pre-alpha candidate and has no completed human-session evidence.

## Next roadmap step

When the owner wants observational evidence, run the four-session P16 private-alpha cohort against one tagged artifact and record only direct human findings. No further automated roadmap item is currently open.
