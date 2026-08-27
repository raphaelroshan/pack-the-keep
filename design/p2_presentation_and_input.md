# Pack the Keep — P2 Presentation and Input Contract

## Purpose

P2 turns the deterministic Greywatch slice into a clearer strategic interface without moving authority into the renderer. Every presentation cue must be derived from `PackKeepState`; pausing, speed selection, input method, and accessibility settings may change timing or display but must not change battle outcomes.

## Battle feedback

Battle uses an explicit paused/running state and three readable speeds. Manual single-step remains available for inspection. When auto-advance is running, each timer tick resolves one or more deterministic simulation steps according to the selected speed. A player can pause before a contact, intervention, breach, new enemy, or commander ability decision.

The keep canvas communicates state with a short non-blocking flash: amber for forecast/contact, red for room or piece damage and breach pressure, green for repair/recovery, and pale blue for a defeated enemy or successful counter. The current event text and causal report remain visible so the flash is reinforcement rather than a source of truth.

## Input and accessibility

Keyboard shortcuts are additive to the existing mouse controls: Space toggles pause, `1`/`2`/`3` select half/normal/double speed, `N` advances one manual step, `R` arms the selected piece for placement, Escape cancels placement, and `F` focuses the active battle report. Buttons remain keyboard focusable and the selected control is visibly outlined. A high-contrast cue mode uses shape and text labels in addition to color. The minimum supported display target remains 1280×720 with wrapped labels and a scrollable command table.

## Audio

Three short original local feedback tones are used sparingly: a neutral UI click, a low battle impact, and a two-note repair/success cue. Audio is presentation-only and may be disabled through the P2 mute toggle. No music, platform SDK, or external audio dependency is introduced in this slice.

## Acceptance criteria

A tester can start a wave, pause it, select half/normal/double speed, resume it, and use manual single-step without changing the deterministic report. A room or piece selection remains inspectable during pause. Damage, breach, defeat, repair, and successful intervention produce distinct text, shape, color, or tone cues. Keyboard shortcuts perform the same explicit commands as their mouse equivalents. The high-contrast mode remains understandable without relying on color alone. The 1280×720 preparation and battle screens render without clipped controls, and the release gate includes parser, deterministic, UI smoke, input, and scene-launch checks.

## Deliberate exclusions

P2 does not add controller remapping, Steam/Epic APIs, platform achievements, final animation sheets, a complete soundscape, or a second simulation authority. Those remain later release work.
