# Pack the Keep — Internal Test Release

**Current build identity:** `0.2.0-p0-internal` — P0 alpha foundation

## Purpose

This package is an internal base-game test release, not a commercial demo or storefront build. Its purpose is to let a tester judge whether the Greywatch loop is understandable and visually coherent: choose the Castellan, preview and reserve a limited pack offer, place units directly on either floor with a footprint preview, inspect rooms/pieces/enemies, read an enemy forecast, advance the wave, inspect health and combat metrics, and use the authored repair interval.

## Included playable loop

The release starts in Greywatch Keep with The Castellan, Pike Squad, Narrow Gate, and the current 12×8 two-floor keep. Preparation permits bounded pack opening, pack preview/reserve, direct grid placement, spatial placement, room assignment, and repair. The map emits authoritative hover/click events: green footprints are valid, red footprints explain rejection, and clicks open room or piece inspection. Battle presents Raider, Sapper, and Climber actors with readable routes, targets, HP, doctrine colors, and causal damage reports. Results return the player to the repair interval after a Hold or Partial Breach.

## Visual kit

| Asset | Use | Integration |
|---|---|---|
| `assets/greywatch_background.png` | In-game/title banner and Greywatch visual anchor | Loaded by `src/ui/main.gd` |
| `assets/castellan_portrait.png` | Commander identity in the command table | Loaded by `src/ui/main.gd` |
| `assets/pike_squad_icon.png` | Defender identity and asset strip | Loaded by `src/ui/main.gd` |
| `assets/repair_station_icon.png` | Future unit card and pack presentation | Ready for use |
| `assets/fire_team_icon.png` | Future unit card and pack presentation | Ready for use |
| `assets/scout_post_icon.png` | Future unit card and pack presentation | Ready for use |
| `assets/narrow_gate_icon.png` | Starter keep-piece identity | Ready for use |
| `assets/raider_icon.png` | Gate-pressure enemy identity and asset strip | Loaded by `src/ui/main.gd` |
| `assets/sapper_icon.png` | Support-sabotage enemy identity and asset strip | Loaded by `src/ui/main.gd` |
| `assets/climber_icon.png` | Upper-floor bypass enemy identity and asset strip | Loaded by `src/ui/main.gd` |
| `assets/greywatch_visual_reference.png` | Art-direction reference for future asset work | Reference only |

The generated images are deliberately treated as first-pass concept-quality production assets. They establish palette, material language, silhouette, and hierarchy; they are not final animation-ready sprites or a complete tileset.

## Test checklist

A tester should begin Preparation, select a pack, read its cost, pieces, doctrine, solves/asks summary, and reserve it without granting its pieces. Select an available piece, arm map placement, move across both floors, confirm that valid footprints turn green and overlaps/out-of-bounds/unavailable pieces turn red, then click a valid cell. Click a placed piece and a room to read the inspector. Open at most two packs, start each of the three invasion doctrines, advance one step at a time, and inspect the enemy HP, room condition, unit health, aggregate combat metrics, and battle report. Save, reset to a new run, load the previous state, and confirm that a malformed or future-version save is rejected without destroying the current run. After a Hold or Partial Breach, use both repair-interval actions and verify that the next wave remains blocked until the interval closes.

## Known boundaries

This release does not include final sprite animation, sound, controller navigation, Steam or Epic services, accessibility settings, multiple simultaneous pack cards, a campaign map, or direct enemy mouse targeting. The repository’s deterministic state and test suite remain the source of truth while presentation assets are iterated. The fallback “place at next slot” command remains available for deterministic smoke tests, but direct map placement is the intended P0 path.
