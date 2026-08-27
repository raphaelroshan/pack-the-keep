# Pack the Keep — Visual Fort Initial Run

## Goal

The first run must be understandable without reading debug-like tables. The primary map surface is a square-shaped Greywatch fort: thick outer walls, an open courtyard, readable interior rooms, and an unmistakable open gate at the bottom. Placeholder enemies enter through that gate and advance into the fort. The player places defenders in keep rooms, the open courtyard, or on the walls, then watches the chosen position determine how the defender responds.

## Presentation model

The current generated concept art remains the visual palette anchor, but the daily image-generation quota is unavailable for a new dedicated fort-map asset. This slice therefore uses a deterministic procedural fort illustration inside `KeepCanvas` as a functional replacement, with an explicit future boundary to replace the renderer with generated pixel-art tiles. The procedural map is not presented as final art.

The ground map shows a square wall ring, corner towers, a bottom-center open gate, a gate approach lane, an open courtyard, and interior rooms. The secondary floor surface communicates wall deployment and upper-floor locations. Labels, hatch-like lines, zone names, unit silhouettes, health/ammunition counters, route arrows, and target lines make the state legible without relying on color alone.

## Placement zones

Every placed piece receives a deterministic placement zone: `wall`, `courtyard`, or `keep`. Ground-floor origins on the outer ring are `wall`; origins inside the central open rectangle are `courtyard`; remaining ground-floor cells are `keep`. Upper-floor pieces are `wall`. The zone is visible in the placement preview, piece inspector, and map label.

| Zone | Visual location | Initial combat meaning |
|---|---|---|
| Wall | Outer ring, towers, and upper floor | Long sightline and early response. Strong for ranged units and wall-specific skills. |
| Courtyard | Open square inside the wall ring | Shorter response distance and flexible interior defense. Strong for close defense and Raiders. |
| Keep | Interior rooms and support spaces | Protects named functions and enables support/repair behavior, but is not an exposed firing line. |

## Enemy movement and behavior

All placeholder attackers use the visible open gate approach in the initial visual run. Their authored doctrine still determines target priority: Raiders seek Gate and then the courtyard, Sappers seek support functions, Climbers seek upper/wall positions, and Siege Beasts pressure the perimeter and several rooms. The renderer interpolates each active marker along the gate-to-courtyard path using `wave_progress`; the simulation still resolves behavior and contact only at authoritative one-second steps.

## Defender response

Pike Squad is a melee defender. It does not use ammunition and is strongest on the wall near the gate or in the courtyard against Raiders. Fire Team and Fire Brazier are ranged defenders. They consume finite ammunition, are strongest from wall positions against Climbers and Siege Beasts, and can contribute from the courtyard with reduced or flexible response. Repair Station and Scout Post are support roles whose value is expressed through recovery and warning rather than direct attack. The existing commander, assignment, cooldown, health, and ammunition rules remain authoritative.

## Acceptance criteria

A tester should be able to launch the initial run, immediately identify the square fort, see the open gate, place a starter defender in a visibly named zone, start a wave, watch a placeholder attacker approach through the gate, and understand from the map and labels whether the defender is using melee, ranged, support, or fortification behavior. A zone change must affect the deterministic combat result or response text, while map presentation and movement remain independent of outcome authority.

## Deferred boundary

This slice does not claim a newly generated pixel-art map because image generation was unavailable at implementation time. It does deliver a functional, testable fort-shaped map renderer and keeps the art replacement boundary explicit. A future art pass can replace only the background/tiles while retaining zone geometry, hit-testing, labels, and authoritative simulation.
