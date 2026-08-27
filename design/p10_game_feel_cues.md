# P10 — Semantic Feedback Cues

## Intent

Replace the single generic beep with a small procedural cue vocabulary that helps players distinguish warning, contact, repair, ability, success, and terminal outcomes without moving timing or outcomes out of the simulation.

## Behavior

- Cue profiles are stable IDs with bounded frequency/duration sequences.
- Warning, contact, confirmation, repair, commander ability, blocked action, pause/resume, Hold, Partial Breach, and Collapse use distinct profiles.
- The most recent cue name remains visible as text, so information is not audio-only.
- Mute prevents sample generation while preserving visible cue state.
- Effects volume multiplies sample amplitude and never changes cue timing or gameplay state.
- Reduced motion continues to suppress board flashes independently from audio cues.

## Acceptance criteria

- Every wired cue resolves to a non-empty validated profile.
- Hold, Partial Breach, and Collapse have distinct terminal profiles.
- Repair and commander ability commands expose distinct cues on success; blocked commands use the error cue.
- Muted cue dispatch updates the visible cue label without writing audio samples.
- Cue dispatch leaves serialized authoritative state unchanged beyond the command that triggered it.
- Existing sound, accessibility, auto-pause, and deterministic replay tests remain green.

## Non-goals

- No imported music, voice, licensed sound library, spatial audio, or dynamic mixing in this slice.
- Procedural tones remain an honest accessibility-aware prototype layer pending authored sound assets.
