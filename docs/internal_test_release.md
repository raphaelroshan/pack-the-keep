# Pack the Keep — Internal Test Release

## Purpose

This package is an internal base-game test release, not a commercial demo or storefront build. Its purpose is to let a tester judge whether the Greywatch loop is understandable and visually coherent: choose the Castellan, open a limited pack offer, place units, read an enemy forecast, advance the wave, inspect health and combat metrics, and use the authored repair interval.

## Included playable loop

The release starts in Greywatch Keep with The Castellan, Pike Squad, Narrow Gate, and the current 12×8 two-floor keep. Preparation permits bounded pack opening, spatial placement, room assignment, and repair. Battle presents Raider, Sapper, and Climber actors with readable routes, targets, HP, doctrine colors, and causal damage reports. Results return the player to the repair interval after a Hold or Partial Breach.

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

A tester should begin Preparation, confirm that unavailable units are disabled, open at most two packs, place the starter and unlocked units across both floors, start each of the three invasion doctrines, advance one step at a time, and inspect the enemy HP, room condition, unit health, aggregate combat metrics, and battle report. After a Hold or Partial Breach, the tester should use both repair-interval actions and verify that the next wave remains blocked until the interval closes.

## Known boundaries

This release does not include final sprite animation, sound, controller navigation, a real Windows export preset, Steam or Epic services, accessibility settings, a complete pack-offer screen, or a campaign map. The repository’s deterministic state and test suite remain the source of truth while presentation assets are iterated.
