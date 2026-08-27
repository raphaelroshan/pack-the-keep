# Pack the Keep — Internal Test Release

**Current build identity:** `0.4.0-p2-internal` — P2 presentation and input slice

## Purpose

This package is an internal pre-alpha test release, not a commercial demo or storefront build. Its purpose is to test whether Greywatch supports more than one viable strategic lens and whether the battle now communicates decisions clearly: choose the Castellan or Warden, select one of three authored scenarios, preview and reserve a limited pack offer, place units directly on either floor with a footprint preview, inspect rooms/pieces/enemies, read an escalating forecast, pause or run the wave at three presentation speeds, advance manually, use Lockdown or Rally, inspect health and combat metrics, and recover after pressure.

## Included playable loop

The release starts in Greywatch Keep with The Castellan or The Warden, the four existing packs, and the current 12×8 two-floor keep. Preparation permits scenario selection, bounded pack opening, pack preview/reserve, direct grid placement, room assignment, and repair. The three scenarios—Gatehouse Lock, The Wrong Wall, and Open Yard Net—define different objectives, doctrine sequences, wave compositions, and seed-derived bounded variations. Battle presents Raiders, Sappers, Climbers, and the new Siege Beast with readable routes, targets, HP, explicit doctrine labels, room/piece condition bars, target lines, a Siege Beast `AREA` radius, transient impact/recovery framing, and causal damage reports. Results return the player to the repair interval after a Hold or Partial Breach. New invasions begin paused for inspection; Space pauses/resumes, `1`/`2`/`3` select 0.5×/1×/2×, `N` advances one step, `R` arms placement, Escape cancels placement, `M` mutes code-generated feedback tones, and `C` toggles high-contrast cues.

## Visual kit

| Asset or treatment | Use | Integration |
|---|---|---|
| `assets/greywatch_background.png` | In-game/title banner and Greywatch visual anchor | Loaded by `src/ui/main.gd` |
| `assets/castellan_portrait.png` | Commander identity in the command table | Loaded by `src/ui/main.gd` |
| `assets/pike_squad_icon.png` | Defender identity and asset strip | Loaded by `src/ui/main.gd` |
| `assets/repair_station_icon.png` | Defender identity and pack presentation | Loaded by `src/ui/main.gd` |
| `assets/fire_team_icon.png` | Defender identity and pack presentation | Loaded by `src/ui/main.gd` |
| `assets/scout_post_icon.png` | Defender identity and pack presentation | Loaded by `src/ui/main.gd` |
| `assets/narrow_gate_icon.png` | Starter keep-piece identity | Loaded by `src/ui/main.gd` |
| `assets/raider_icon.png` | Gate-pressure enemy identity and asset strip | Loaded by `src/ui/main.gd` |
| `assets/sapper_icon.png` | Support-sabotage enemy identity and asset strip | Loaded by `src/ui/main.gd` |
| `assets/climber_icon.png` | Upper-floor bypass enemy identity and asset strip | Loaded by `src/ui/main.gd` |
| Warden profile treatment | P1 commander identity and readable rule lens | Shared Castellan portrait tinted in UI; dedicated Warden portrait deferred to the next art-generation window |
| Siege Beast marker | Large-threat identity and area-pressure telegraph | Enlarged procedural map marker; dedicated icon deferred to the next art-generation window |
| `assets/greywatch_visual_reference.png` | Art-direction reference for future asset work | Reference only |

The generated images are deliberately treated as first-pass concept-quality production assets. They establish palette, material language, silhouette, and hierarchy; they are not final animation-ready sprites or a complete tileset. P2 adds functional procedural bars, labels, lines, rings, and transient framing rather than fabricated art assets. The dedicated Warden and Siege Beast image generation request remains deferred after the image-generation quota was reached; this is recorded rather than represented as completed art. P2 tones are generated in code through an optional local audio stream; no authored sound-effect files are claimed.

## Test checklist

A tester should begin Preparation, compare The Castellan and The Warden profiles, select each of the three scenarios on fresh runs, read the objective, lesson, and seed variation, and verify that the same seed reproduces the same variation. Select a pack, read its cost, pieces, doctrine, solves/asks summary, and reserve it without granting its pieces. Select an available piece, press `R` or use the arm control, move across both floors, confirm that valid footprints turn green and rejection states are red, then click a valid cell; press Escape to cancel. Click a placed piece and a room to read the inspector. Start Gatehouse Lock, The Wrong Wall, and Open Yard Net in turn, confirm each wave starts paused, test Space and `1`/`2`/`3`, advance with `N`, use Lockdown or Rally once per wave, and inspect the escalating doctrine, target line, Siege Beast area impact, enemy HP, room condition bars, explicit state words, unit health bars, aggregate metrics, transient cue frame, and battle report. Toggle `C` and verify that state remains understandable without relying on color; toggle `M` and verify that the interface remains usable. Save, reset to a new run, load the previous state, and confirm that malformed or future-version saves are rejected without destroying the current run. After a Hold or Partial Breach, use repair-interval actions and verify that the next wave remains blocked until the interval closes.

## Known boundaries

This release does not include final sprite animation sheets, an authored soundscape, controller navigation/remapping, user-persistent display scaling, multiple simultaneous pack cards, a campaign map, or direct enemy mouse targeting. It does include keyboard/mouse input, high-contrast cues, a scrollable command panel, code-generated optional feedback tones, and functional transient presentation cues. The repository’s deterministic state and test suite remain the source of truth while presentation assets are iterated. The fallback “place at next slot” command remains available for deterministic smoke tests, but direct map placement and scenario selection are the intended P2 paths.
