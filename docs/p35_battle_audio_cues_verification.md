# P35 Battle Audio Cue Verification

- Build: `0.22.1-battle-audio`
- Engine: Godot 4.7.2
- Scope: semantic and generated-audio inspection; this is not human playtest evidence

## Complete loop vocabulary

| Presentation beat | Cue | Generated contour |
|---|---|---|
| Assault start | Warning | 330 → 440 Hz |
| Contact | Contact | 160 Hz pulse |
| Defender response | Volley | 610 → 780 Hz |
| Hostile impact | Impact | 135 → 190 Hz |
| New breach | Breach | 280 → 205 → 145 Hz |
| Recovery | Repair | 390 → 520 Hz |
| Hold | Hold | 520 → 660 → 780 Hz |
| Partial breach | Partial breach | 360 → 250 Hz |
| Collapse | Collapse | 220 → 150 Hz |

The cue service is the single owner of profiles, semantic beat mapping, procedural tone generation, and playback-request evidence. `main.gd` reports already-observed presentation beats and retains the visible cue label.

## Accessibility and state boundary

- Mute and zero effects volume suppress playback while retaining the semantic cue identity.
- Reduced-motion mode shortens multi-tone output to one tone; it does not change simulation timing.
- Headless mode creates the cue service but no audio player or output device.
- Every cue request records whether it was muted, zero-volume, headless, or played.
- Cue lookup and playback requests leave the serialized keep, battle step, and battle clock unchanged.

Human recognition, comfort, mix balance, and preference remain pending structured playtest evidence.

