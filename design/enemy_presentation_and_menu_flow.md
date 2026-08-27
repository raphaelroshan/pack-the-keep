# Pack the Keep — Enemy Presentation and Menu Flow

## Enemy actors

The first Pack the Keep slice now presents enemies as concrete, doctrine-driven actors rather than abstract wave progress.

| Enemy | Visual marker | Route shown | Player-facing state |
|---|---|---|---|
| Raider | Red circular marker | Gate Road | Health, route, Gate target, arrival step |
| Sapper | Amber circular marker | Service Lane | Health, route, support-room target, repair risk |
| Climber | Violet circular marker | North Tower Line | Health, bypass route, upper-floor landing target |

The map shows each active actor’s current health and keeps its marker aligned with the route described by the forecast. Defeated actors disappear from the active map and remain in the causal battle report. Their marker colors are intentionally semantic: red means immediate front pressure, amber means a support dependency is threatened, and violet means an upper-floor bypass.

The actor display does not invent new combat outcomes. It reads the deterministic `enemies` array from `PackKeepState`, so the health, target, defeat state, and timeline remain testable independently of presentation.

## Basic menu flow

The prototype now has four lightweight menu states:

| State | Purpose | Entry | Primary action |
|---|---|---|---|
| **Title** | Introduce Greywatch and the defense promise | Application start | Begin preparation |
| **Preparation** | Open packs, place pieces, repair, and assign rooms | Title or closed interval | Start invasion |
| **Battle** | Read forecast, enemy actors, and causal step results | Successful invasion start | Advance one battle step |
| **Results** | Read Hold, Partial Breach, or Collapse and choose recovery | Wave resolution | Repair, assign, or finish interval |

The menu is intentionally a state layer rather than a separate scene system. Buttons call `_set_screen`, while all authoritative game state remains in `PackKeepState`. This keeps menu navigation cheap to replace with proper scenes later and prevents UI navigation from becoming a second source of truth.

## Navigation rules

The Title screen hides preparation controls until the player begins. Starting a valid invasion automatically moves to Battle. Resolving a wave moves to Results. A successful repair interval closure returns to Preparation. The player may inspect any menu tab, but invalid commands still receive the same deterministic state-level failure reasons; selecting Battle does not bypass preparation, and selecting Results does not fabricate an outcome.

## Deliberate boundaries

This slice does not add animated sprites, pathfinding, unit selection by mouse, a pause menu, settings, or platform services. Colored markers and labels are a readability scaffold. They can be replaced with 2D actors and timeline animation after the enemy route and target rules have been playtested.
