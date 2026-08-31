# P56 Tactile Audio Feedback

## Player-facing purpose

The keep should sound inhabited and each major battle beat should be recognizable without turning combat into continuous noise. Existing semantic cues gain short temporary CC0 samples while preserving their visible labels and synthesized fallback.

## Presentation data

- Each semantic cue may reference one temporary Kenney Interface Sounds or RPG Audio sample.
- A bounded four-player pool allows nearby response and impact sounds without creating unbounded audio nodes.
- Missing or unloadable samples fall back to the existing generated tones.
- Cue IDs, battle-beat mappings, mute, effects volume, and visible feedback remain stable.
- Audio playback remains presentation-only and never participates in targeting, timing, damage, saves, or replay keys.

## Acceptance criteria

- Assault warning, contact, defender response, hostile impact, breach, recovery, ability, error, pause/resume, and terminal outcomes resolve distinct short samples.
- The cue service creates no output device in headless mode and no more than four sample players when output is enabled.
- Muted and zero-volume requests produce no sample or tone playback.
- Missing sample resources use the generated-tone fallback without losing the semantic cue.
- Effects volume controls sample gain as well as generated tones.
- The semantic snapshot exposes temporary CC0 provenance, sample paths, pool size, and the last playback mode.
- Calling cues does not mutate authoritative keep state or advance battle time.

## Test cases

- Assert every battle-loop cue has a loadable sample with CC0 temporary provenance.
- Assert contact, defender response, hostile impact, breach, and terminal outcomes retain distinct sample paths.
- Enable output under the dummy audio driver and assert the pool is bounded at four players.
- Exercise sample playback, mute, zero volume, and a deliberately missing sample fallback.
- Compare serialized keep state, battle step, and battle clock before and after cue requests.
