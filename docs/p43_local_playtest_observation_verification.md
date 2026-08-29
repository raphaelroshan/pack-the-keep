# P43 Local Playtest Observation Verification

- Build: `0.25.0-local-playtest-observer`
- Scope: opt-in local observation and repeatable visual capture
- Authoritative simulation changes: none

## Automated evidence

- `tests/test_p43_local_playtest_observer.gd` verifies disabled-by-default collection, deterministic duration accounting, first-action and coarse interaction counts, snapshot isolation, explicit local export, privacy markers, and run-state invariance.
- `tools/validate_offline_boundary.py` continues to reject direct network clients in gameplay code.
- Existing simulation, save, tutorial, input, scaling, and packaged-readiness tests remain in `scripts/verify.sh`.

## Visual evidence

`tools/capture_vertical_slice.gd` was run with the normal Godot renderer at 1600×900. It produced nine ordered screenshots—Title, War Council, Preparation, three assault-ready states, two recovery lulls, and terminal Results—plus `capture-manifest.json`. Title, first Recovery, and terminal Results were visually inspected.

## Human evidence

Recorded counts are observation aids only. They do not establish comprehension, enjoyment, pacing quality, or release approval. No human session is claimed by this slice.
