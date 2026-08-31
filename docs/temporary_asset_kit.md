# Pack the Keep — Temporary Asset Kit

**Status:** Testing-only breadth kit  
**Build target:** Current private alpha branch  
**Purpose:** Give AI agents usable temporary defenders, enemies, rooms, VFX, audio, and animation ingredients while Greywatch’s final authored art is developed.

## Included sources

| Source | Repository path | License | Intended use | Deficiency note |
|---|---|---|---|---|
| Kenney Tiny Dungeon | `assets/temporary/kenney/tiny-dungeon/` | CC0; proof in `assets/temporary/kenney/LICENSE-tiny-dungeon.txt` | Temporary rooms, corridors, doors, floors, walls, and approach geometry | Warm cute 16×16 dungeon art does not match Greywatch’s intended fortress material language. Use for room-layout and path testing. |
| Kenney Tiny Battle | `assets/temporary/kenney/tiny-battle/` | CC0; proof in `assets/temporary/kenney/LICENSE-tiny-battle.txt` | Temporary defender/enemy silhouettes, flags, markers, and combat placeholders | Toy-like units are not final commander, pack, or enemy identities. Use to test targeting, animation timing, and readable counters. |
| Kenney Interface Sounds | `assets/temporary/kenney/interface-sounds/` | CC0; proof in `assets/temporary/kenney/LICENSE-interface-sounds.txt` | Selection, placement, confirmation, cancel, error, wave, and results feedback | Generic clicks do not provide Greywatch’s wood, stone, metal, or command identity. |
| Kenney RPG Audio | `assets/temporary/kenney/rpg-audio/` | CC0; proof in `assets/temporary/kenney/LICENSE-rpg-audio.txt` | Footsteps, cloth, doors, weapon, book, and material foley | Fantasy-RPG foley is useful but not a finished keep-defense soundscape. |
| Kenney Particle Pack | `assets/temporary/kenney/particle-pack/` | CC0; proof in `assets/temporary/kenney/LICENSE-particle-pack.txt` | Dust, smoke, sparks, slash, scorch, fire, muzzle, and impact placeholders | Generic effect sprites need palette tinting and authored timing; do not use them as the final combat language. |

## Safe usage pattern in Godot

Use imported resources through `ResourceLoader` or `load`:

```gdscript
var room_texture: Texture2D = load("res://assets/temporary/kenney/tiny-dungeon/tilemap.png")
var unit_texture: Texture2D = load("res://assets/temporary/kenney/tiny-battle/tilemap.png")
var place_sound: AudioStream = load("res://assets/temporary/kenney/interface-sounds/confirmation_001.ogg")
var impact_texture: Texture2D = load("res://assets/temporary/kenney/particle-pack/spark_01.png")
```

For a quick animated placeholder, create `AnimatedSprite2D` or `SpriteFrames` from a related set of `smoke_`, `spark_`, `slash_`, or `fire_` frames. Keep the animation on the presentation side. It may show an attack wind-up or impact, but it must not decide damage, targeting, ammunition, timing, or recovery outcomes.

Use interface sounds for placement confirmation, invalid placement, selected-room changes, wave start, and Results. Use `doorOpen`, `doorClose`, `creak`, `cloth`, or `footstep` sounds from RPG Audio for temporary room and movement context. Route combat impacts and warnings through the existing combat/world bus rather than starting a new audio architecture.

## Pack-specific application

Use Tiny Dungeon tiles to replace empty or overly abstract room backgrounds during preparation and recovery. The board geometry and placement legality remain authoritative and must not be inferred from the visual pack. If the tile art makes the keep look like a generic dungeon, mark the screenshot and report as **temporary layout filler**.

Use Tiny Battle units as visually distinct placeholders for defenders and enemies. Assign each role a palette tint and silhouette scale so the player can still answer: what is this unit, what can it reach, what is it defending, and what counter does the enemy require? Do not use a new sprite to conceal an unresolved teaching question.

Use Particle Pack effects to stage attack wind-up, impact, repair sparks, dust, smoke, and ammunition discharge. Limit screen shake, flashes, and particle density so the keep remains readable. A particle may reinforce an authoritative event only after the event has been resolved.

## Animation recipes for the agent

The downloaded packs contain static tiles and effect frames rather than a bespoke Greywatch animation library. Agents should create deterministic temporary motion using:

1. A two- or three-frame smoke or spark sequence for an attack impact or repair station.
2. A short scale/flash sequence for placement confirmation and invalid placement feedback.
3. A subtle unit bob or recoil on a confirmed attack, with timing driven by the resolved combat event.
4. A door-open/door-close state animation for the keep entrance, without changing path availability unless the authoritative state changes it.
5. A slow damage-smoke loop for a damaged room, stopped and restarted from the room’s actual condition.

The agent must test pause, manual-step, speed changes, reduced motion, and deterministic replay. The same combat seed and command sequence must produce the same authoritative results regardless of visual animation rate.

## Replacement priority

Replace the Tiny Dungeon room art with a Greywatch-specific authored tile language first. Next replace Tiny Battle silhouettes for the commander, core defender roles, and the first signature enemy family. Finally replace generic particle sheets with a restrained palette of dust, stone chips, sparks, bloodless impact marks, arrows, smoke, and alarm cues that are legible at the supported zoom.

A modest custom commission for the Greywatch keep silhouette and two or three enemy families is more valuable than purchasing a large generic unit bundle. The current kit is deliberately useful for testing spatial readability, combat timing, and edge cases rather than for Kickstarter-final screenshots.

## Provenance

The upstream pages are [Tiny Dungeon](https://kenney.nl/assets/tiny-dungeon), [Tiny Battle](https://kenney.nl/assets/tiny-battle), [Interface Sounds](https://kenney.nl/assets/interface-sounds), [RPG Audio](https://kenney.nl/assets/rpg-audio), and [Particle Pack](https://kenney.nl/assets/particle-pack). The local license files are the authoritative copies used for this temporary kit. Keep this document with the assets and do not redistribute raw source packages as a standalone asset bundle.
