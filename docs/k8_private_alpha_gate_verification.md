# K8 — Private-alpha gate verification

- Build: `0.30.0-private-alpha-gate`
- Scope: consolidated automated hardening contract; no gameplay change and no public-release claim

## Automated evidence

`tools/validate_k8_private_alpha.py` verifies ten required areas, exact build identity, repository-relative evidence, positive performance budgets, seven preserved human gates, and false release/public-alpha/storefront flags. Its packaged mode rechecks clean install, reinstall, offline launch, controller/remap/scaling, pause, migration, forced-close backup recovery, and clean close across packaged smoke schema 3.

`tests/test_k8_performance_budget.gd` resolves forty deterministic three-phase defenses and refreshes the 2560×1440 UI at 150% scale 120 times. In the complete local Godot 4.7.2 verification run the workloads completed in 2914 ms and 123 ms respectively against separate 10000 ms budgets. CI enforces the same conservative limits on Ubuntu and Windows.

The complete `scripts/verify.sh` run remains the release gate. Human observations, physical controller coverage, Windows GPU review, authored-audio mix review, forced-close recovery, signing, and storefront launch remain pending.
