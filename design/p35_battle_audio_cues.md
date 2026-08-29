# P35 Focused Battle-Loop Audio Cues

## Intent

One assault should have a short, coherent semantic sound language: warning, contact, defender response, hostile impact, breach, recovery, and terminal outcome. The cue layer should reinforce visible events without becoming another timing authority.

## Authority

`PackKeepState` owns every battle tick and result. `BattleAudioCueService` receives a completed presentation beat and emits generated tones only after the UI has observed authoritative state. It cannot schedule attacks, advance time, alter commands, or serialize into the run save.

## Cue contract

- `assault_start` → warning
- `contact` → low contact pulse
- `defender_response` → short high volley
- `hostile_impact` → low impact pair
- `breach` → descending structural warning
- `recovery` → repair confirmation
- `terminal_hold`, `terminal_partial_breach`, `terminal_collapse` → distinct outcome signatures

Pause, resume, ability, confirm, and error cues remain available as supporting interface signals. Mute and effects volume are applied at playback. Headless mode still records the semantic cue request for deterministic UI verification but creates no audio device.

## Acceptance

- Cue profiles and battle-beat mapping live outside `main.gd`.
- A complete battle loop has distinct semantic cue identities.
- Muted and zero-volume playback remain silent while exposing the last semantic cue in text.
- Audio generation remains offline and procedural.
- Cue selection, playback requests, mute, volume, and reduced-motion state do not mutate authoritative keep state.
- Existing display/audio preference migration and game-feel tests remain green.

