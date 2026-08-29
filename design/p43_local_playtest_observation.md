# P43 Local Playtest Observation

## Intent

Make visual comparison and human-session observation repeatable without adding network telemetry or confusing automated traces with human evidence.

## Player and observer contract

- Observation begins disabled on every launch.
- The player or observer explicitly enables one in-memory session from Settings.
- The session records only coarse interaction facts: time per screen, first action, pause count, threat-focus count, primary-action path, recovery choices, and terminal result.
- Nothing uploads automatically. Export is a separate explicit action to a documented local `user://` JSON file.
- Disabling observation stops collection but retains the current in-memory snapshot until restart or reset.

## Capture contract

- A graphical Godot script captures a fixed 1600×900 sequence for title, War Council, Preparation, each assault-ready state, each recovery lull, and terminal Results.
- Filenames and ordering are stable so before/after reviews can compare equivalent states.
- The harness drives existing public UI handlers and authoritative simulation commands; it does not introduce capture-only game rules.
- Headless execution exits with a clear message because the dummy renderer has no framebuffer.

## Non-goals

- No analytics SDK, identifiers, networking, background upload, or automatic evidence submission.
- No human success/failure conclusions from recorded counts.
- No run-save schema changes and no simulation changes.

## Acceptance evidence

- A deterministic service test verifies opt-in behavior, duration accounting, action counts, recovery choice, result recording, and snapshot isolation.
- A UI test verifies Settings opt-in/export controls and confirms observation never changes serialized keep state.
- The existing offline-boundary validator and full regression suite remain green.
