# Pack the Keep — Internal Test Release

**Current build identity:** `0.3.0-p1-internal` — P1 content and replayability slice

## Purpose

This package is an internal base-game test release, not a commercial demo or storefront build. Its purpose is to test whether Greywatch supports more than one viable strategic lens: choose the Castellan or Warden, select one of three authored scenarios, preview and reserve a limited pack offer, place units directly on either floor with a footprint preview, inspect rooms/pieces/enemies, read an escalating forecast, advance the wave, use Lockdown or Rally, inspect health and combat metrics, and recover after pressure.

## Included playable loop

The release starts in Greywatch Keep with The Castellan or The Warden, the four existing packs, and the current 12×8 two-floor keep. Preparation permits scenario selection, bounded pack opening, pack preview/reserve, direct grid placement, room assignment, and repair. The three scenarios—Gatehouse Lock, The Wrong Wall, and Open Yard Net—define different objectives, doctrine sequences, wave compositions, and seed-derived bounded variations. Battle presents Raiders, Sappers, Climbers, and the new Siege Beast with readable routes, targets, HP, doctrine colors, area-pressure impact, and causal damage reports. Results return the player to the repair interval after a Hold or Partial Breach.

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

The generated images are deliberately treated as first-pass concept-quality production assets. They establish palette, material language, silhouette, and hierarchy; they are not final animation-ready sprites or a complete tileset. The P1 dedicated Warden and Siege Beast image generation request was deferred after the daily image-generation quota was reached; this is recorded rather than represented as completed art.

## Test checklist

A tester should begin Preparation, compare The Castellan and The Warden profiles, select each of the three scenarios on fresh runs, read the objective, lesson, and seed variation, and verify that the same seed reproduces the same variation. Select a pack, read its cost, pieces, doctrine, solves/asks summary, and reserve it without granting its pieces. Select an available piece, arm map placement, move across both floors, confirm that valid footprints turn green and rejection states are red, then click a valid cell. Click a placed piece and a room to read the inspector. Start Gatehouse Lock, The Wrong Wall, and Open Yard Net in turn, advance one step at a time, use Lockdown or Rally once per wave, and inspect the escalating doctrine, Siege Beast area impact, enemy HP, room condition, unit health, aggregate metrics, and battle report. Save, reset to a new run, load the previous state, and confirm that malformed or future-version saves are rejected without destroying the current run. After a Hold or Partial Breach, use repair-interval actions and verify that the next wave remains blocked until the interval closes.

## Known boundaries

This release does not include final sprite animation, sound, controller navigation, accessibility settings, multiple simultaneous pack cards, a campaign map, direct enemy mouse targeting, or final dedicated Warden/Siege Beast art. The repository’s deterministic state and test suite remain the source of truth while presentation assets are iterated. The fallback “place at next slot” command remains available for deterministic smoke tests, but direct map placement and scenario selection are the intended P1 paths.
