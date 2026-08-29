# P47 — Self-contained playtest release verification

- Build: `0.25.4-playtest-release-kit`
- Scope: tag-triggered release packaging only; no simulation, save, input, or UI behavior changed.

## Automated contract

- The release workflow exports and smoke-tests the exact Windows executable.
- It generates `playtest-build.json`, `PLAYTEST_README.md`, and all four unfilled matrix templates from that executable and the P16 protocol.
- The publication command attaches those files together with the executable, smoke report, release manifest, and exact source archive.
- `tests/test_release_identity.py` protects the required generators, publication assets, and generation order.

## Human boundary

The templates contain no observed result. Their presence proves only that the cohort is ready to distribute for controlled testing. Human observers must execute all four matrix combinations and record every required signal before the owner can approve an alpha.
