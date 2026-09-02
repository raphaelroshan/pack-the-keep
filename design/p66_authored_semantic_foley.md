# P66 — Authored Semantic Foley

## Player-facing purpose

Give the keep a coherent original sound identity so warning, contact, response, impact, recovery, command, and terminal outcomes remain recognizable without relying on the temporary CC0 library. The palette should feel like restrained bell metal, bow string, stone, timber, and command signals rather than generic interface clicks.

## Data shape

`BattleAudioCueService` remains the presentation-only authority. Its existing semantic cue IDs, four-player pool, mute and effects-volume handling, and generated-tone fallback remain unchanged. Each cue points to one deterministic original mono WAV under `assets/audio/semantic/`, generated from documented oscillators, filtered deterministic noise, and amplitude envelopes by `tools/generate_authored_foley.py`.

Audio never enters `KeepState`, targeting, damage, timing, saves, or replay identity. The checked-in WAV files are runtime assets; the generator is provenance and reproducibility evidence.

## Acceptance criteria

1. All fourteen semantic cues resolve loadable original WAV assets with no active path under `assets/temporary/`.
2. Warning, contact, defender response, hostile impact, breach, recovery, ability, control, and terminal cues retain distinct paths and audible profiles.
3. The palette is mono PCM at 44.1 kHz, bounded to short one-shot cues, and normalized below clipping.
4. The existing four-player pool, mute, zero-volume, headless, and generated-tone fallback behavior remains intact.
5. The semantic snapshot identifies original authored samples and reports no temporary sample dependency.
6. Cue playback and inspection cannot mutate simulation state or replay identity.
7. Human listening approval remains pending and is not inferred from automated asset validation.

## Test cases

- Validate every cue path is unique, loadable, original, and outside the temporary asset tree.
- Parse each WAV header and assert mono 16-bit PCM, 44.1 kHz, non-empty bounded duration, and non-silent samples.
- Exercise sample playback, mute, zero volume, bounded pooling, and deliberate missing-sample fallback under the dummy driver.
- Compare serialized keep state, battle step, and battle clock before and after cue requests.
- Run the complete local, Linux, Windows, and packaged lifecycle gates.
