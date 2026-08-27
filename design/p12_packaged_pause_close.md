# P12 — Packaged Pause and Close Smoke

## Intent

Prove that the exported battle begins inspectably paused, honors the persisted controller pause binding, permits deterministic manual stepping while paused, and tears down the real main scene cleanly.

## Acceptance criteria

- Starting through the UI stages an active wave on the Battle screen in paused state.
- Calling the presentation process while paused does not advance authoritative battle state.
- The packaged remapped controller event resumes and pauses the battle through the named action.
- A manual step advances exactly once while presentation remains paused.
- The main scene frees before the packaged process exits zero.

**Trade-off:** CI verifies Godot's close/teardown path headlessly, not operating-system window chrome or forced process termination.
