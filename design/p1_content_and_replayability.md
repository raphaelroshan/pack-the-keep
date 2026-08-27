# Pack the Keep P1 content and replayability slice

## Purpose

P1 expands the P0 Greywatch foundation just enough to test whether Pack the Keep has a repeatable strategic identity. It adds a second commander, a large-threat enemy, three authored scenarios, and bounded variation while keeping the existing four packs, deterministic six-step battle, one keep, and solo scope.

## The Warden

The Warden is a cross-floor response commander rather than a stronger Castellan. Their starting materials are 52 and their starting morale is 7. Their passive, **Open Lanes**, gives placed pieces a response bonus when the layout preserves an empty adjacent cell and gives Scout Post/Signal Beacon coverage one extra cell. Their active ability, **Rally**, costs one command point, restores one morale up to the cap, and gives the next battle step a coordinated-response bonus that improves non-specialist defender damage and reduces one incoming room hit. Their limitation is **Spread Thin**: dense adjacent pieces do not receive the Castellan’s adjacency benefit, and the Warden cannot use Rally twice in the same wave.

The Warden should favor open-yard, cross-floor, signal-led layouts. Their distinctiveness is expressed through `layout_preference`, passive response checks, Rally, and lower materials—not through a flat damage multiplier.

## Siege Beast and area pressure

Siege Beast is a slow, durable area-pressure enemy. It arrives at step 3 through the outer approach, has high health, deals structural damage, and marks a target room plus adjacent rooms on contact. It can be defeated by concentrated counterplay, but a player may instead preserve the Workshop, Old Chapel, and response space and accept a scarred perimeter. The attack is deterministic: target selection uses the declared area-pressure target order and the run seed only selects among equally ranked valid targets.

## Scenario structure

The three authored Greywatch scenarios are:

| Scenario | Teaching purpose | Doctrine | Success pressure |
|---|---|---|---|
| `gatehouse_lock` | Teach concentration and direct placement | Gate Assault | Hold Gate or keep breach under control |
| `wrong_wall` | Teach support protection and recovery | Distributed Sabotage + Feint and Flank | Keep Workshop or North Tower functional |
| `open_yard_net` | Teach Warden space and area-pressure sacrifice | Area Pressure | Preserve Old Chapel and response space while facing Siege Beast |

Each scenario has an authored objective, a deterministic wave plan, a bounded material/morale modifier, and a report-facing lesson. Scenario selection occurs in Preparation. Scenario progression is a three-scenario test arc, not a full campaign map; a tester can replay any unlocked scenario from a new run.

## Bounded variation

Variation is seed-derived but intentionally narrow. It may alter one target priority, one enemy slot, or one material/morale modifier within an authored range. It must never alter the scenario objective, enemy doctrine, available pack IDs, or the meaning of a counter. The summary and save payload expose `run_seed`, `scenario_id`, `variation_id`, and the resolved variation values. The same seed, commander, scenario, packs, placement, and commands must produce the same report; different seeds may produce a readable alternate target or pressure value.

## P1 acceptance criteria

- The Warden can be selected, has readable passive/ability/limitation text, and produces a layout/response difference from the Castellan.
- Siege Beast is visible in the forecast and active enemy inspector, arrives at a declared step, targets an area, and damages multiple nearby rooms on contact.
- Each authored scenario has a distinct objective, forecast, wave composition, and success/failure lesson.
- Later waves escalate through additional enemy slots or mixed doctrines instead of repeating the first wave.
- At least two seeds produce distinct but fair variation, while repeated identical seeds produce identical state and reports.
- Existing P0 direct placement, pack reserve, inspection, save/load/reset, repair, assignment, and Castellan tests remain passing.
- A seeded balance harness reports outcomes across commanders, scenarios, and representative pack layouts without claiming final balance.
