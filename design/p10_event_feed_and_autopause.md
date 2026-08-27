# P10 — Event Feed Retention and Threat Auto-Pause

## Intent

Let players choose how much causal history stays visible and optionally stop real-time presentation at the first new threat in each wave or when a breach increases. Both controls remain presentation preferences over the same deterministic one-second simulation steps.

## Behavior

- Event-feed retention cycles through the newest 4, 8, 16, or 32 authoritative report entries.
- Filtering changes only `log_label`; `PackKeepState.battle_report` remains complete and saveable.
- Auto-pause is off by default.
- When enabled during real-time play, the UI pauses after resolving the step that introduces the first enemy of a wave or increases breach.
- Manual stepping is unchanged, and auto-pause never rolls back, skips, or partially resolves a step.
- Settings schema 4 loads schema 1–3 files with a four-line feed and auto-pause off.

## Acceptance criteria

- Feed controls expose their current line count in text and persist immediately.
- The visible feed contains exactly the bounded newest entries in newest-first order.
- A new UI instance restores retention and auto-pause preferences.
- An auto-paused step produces byte-for-byte the same authoritative state as one direct deterministic step from the same seed and commands.
- Starting a new run allows the first new threat to trigger again.
- Existing pause, speed, controller, display, save, and replay tests remain green.

## Non-goals

- No typewriter text speed, event search, exported logs, or per-threat-category filter in this slice.
- No simulation rule may branch on the auto-pause or retention preferences.
