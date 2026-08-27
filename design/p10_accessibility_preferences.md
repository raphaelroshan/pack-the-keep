# P10 — Persistent Accessibility Preferences

## Intent

High contrast, feedback audio, battle speed, and reduced motion should behave as player preferences rather than run state. They persist across launches, never enter a keep save, and never alter deterministic combat outcomes.

## Behavior

- High contrast persists its existing text/shape-heavy board cues.
- Feedback audio mute persists without changing event timing.
- Battle speed persists at 0.5×, 1×, or 2× and remains presentation-only.
- Reduced motion disables transient board flashes while leaving damage, targeting, timing steps, and reports unchanged.
- Malformed or future-version preference files fall back to defaults without affecting the current run.

## Storage

Preferences use `user://pack_the_keep_settings.json`; this slice introduced schema version 1, which the later controller/scaling slice migrates to schema 2. Writes use a temporary file followed by atomic replacement. The save contains only presentation fields and is deliberately separate from `PackKeepState.serialize()`.

## Acceptance criteria

- Every toggle immediately updates visible controls and writes a valid settings file.
- A new UI instance restores the saved values.
- Reduced motion suppresses transient feedback duration.
- Changing preferences leaves serialized simulation state byte-for-byte unchanged.
- Invalid types and future schema versions restore documented defaults.
- Existing keyboard and button paths remain functional.

## Non-goals

- No controller remapping, localization, screen-reader integration, or arbitrary scale slider in this slice.
- No accessibility preference may change authoritative outcomes.
