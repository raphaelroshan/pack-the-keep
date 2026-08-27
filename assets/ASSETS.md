# Greywatch visual asset manifest

The Greywatch kit is an original, first-pass 2D illustrated asset set generated for this private prototype. The visual target is a top-down orthographic medieval fortification with hand-inked silhouettes, charcoal and parchment neutrals, slate masonry, muted brass accents, and restrained red, amber, and violet semantics for enemy doctrines. PNGs are intentionally kept at manageable test-release sizes; they are not final animation sheets or a complete production tileset.

| File | Dimensions | Role | Integration status |
|---|---:|---|---|
| `greywatch_visual_reference.png` | 1280×720 | Internal art-direction reference showing the intended Greywatch presentation language | Reference only; retained to guide future asset work |
| `greywatch_background.png` | 1280×720 | Reusable Greywatch keep banner/background for the playable prototype | Integrated in `src/ui/main.gd` behind the command table |
| `castellan_portrait.png` | 512×512 | The Castellan’s commander identity and command-table portrait | Integrated in `src/ui/main.gd` |
| `pike_squad_icon.png` | 512×512 | Starter defender identity | Integrated in the defender asset strip in `src/ui/main.gd` |
| `repair_station_icon.png` | 512×512 | Repair facility identity | Integrated in the defender/facility asset strip in `src/ui/main.gd` |
| `fire_team_icon.png` | 512×512 | Fire Team identity for the pack/unit vocabulary | Integrated in the defender/facility asset strip in `src/ui/main.gd` |
| `scout_post_icon.png` | 512×512 | Scout Post identity for the pack/unit vocabulary | Integrated in the defender/facility asset strip in `src/ui/main.gd` |
| `narrow_gate_icon.png` | 512×512 | Starter keep-piece identity | Integrated in the defender/facility asset strip in `src/ui/main.gd` |
| `raider_icon.png` | 512×512 | Raider identity; direct gate-pressure doctrine | Integrated in the enemy asset strip in `src/ui/main.gd` |
| `sapper_icon.png` | 512×512 | Sapper identity; support-sabotage doctrine | Integrated in the enemy asset strip in `src/ui/main.gd` |
| `climber_icon.png` | 512×512 | Climber identity; upper-floor bypass doctrine | Integrated in the enemy asset strip in `src/ui/main.gd` |
| Procedural square fort renderer | N/A | Functional first-run map with thick walls, open courtyard, open gate, gate approach, upper wall walk, crenellations, towers, torches, and placement overlays | Integrated in `KeepCanvas`; deterministic pixel-board treatment, not final art |
| Top-down board art direction | N/A | Map-first composition, readable silhouettes, persistent overlays, and high-level pixel-board reference principles | Documented in `design/top_down_board_art_direction.md`; public reference image kept outside the repository |
| Warden profile treatment | N/A | P1 commander identity: Open Lanes, Rally, and Spread Thin | Integrated as readable profile text and a tinted shared portrait; dedicated portrait deferred until the next image-generation window |
| Siege Beast marker | N/A | P2 area-pressure identity and impact-radius telegraph | Integrated as an enlarged ember procedural marker with an `AREA` label and radius ring; dedicated icon deferred until the next image-generation window |
| Crossbow Watch treatment | N/A | P11 precision doctrine identity | Integrated as violet procedural Crossbow Patrol and Watch Banner glyphs; portrait references guide palette and silhouette only |
| Shield Guard marker | N/A | P11 armored-advance identity and armor telegraph | Integrated as a red procedural marker with a shield arc, `ARMOR 2` label, and numeric inspector value |
| Bell Guard treatment | N/A | P11 redundant-signal doctrine identity | Integrated as gold Bellkeepers and relay glyphs with explicit redundant/disrupted state text |
| Ash Slinger marker | N/A | P11 smoke-and-signal identity | Integrated as a gray procedural smoke marker with a `SMOKE` label and effective contact step |
| P2 feedback treatment | N/A | Functional readability and game-feel cues | Procedural room/piece bars, state labels, declared target lines, target outlines, and transient impact/recovery frame; no fabricated replacement art asset |
| `P2 feedback tones` | N/A | Optional battle/UI confirmation | Code-generated local tones through `AudioStreamGenerator`; no authored sound-effect files claimed |
| Generated pixel-art fort map | N/A | Future replacement for the functional square fort renderer | Attempted for the visual-fort slice, but image-generation quota was unavailable; no generated map file is claimed |

## Asset handling

The art is stored as regular repository source content because it is part of the playable prototype and each file remains below the repository’s policy size limit. Godot import metadata and runtime output remain ignored by `.gitignore`. No API keys, private saves, generated Godot metadata, or unreviewed third-party assets are part of this kit. The files should be treated as original generated project content with no third-party attribution currently required; that statement is a provenance note, not a legal license guarantee. The visual-fort and P11 teaching-pair treatments intentionally record the procedural renderer as a functional fallback rather than misrepresenting it as generated pixel art.
