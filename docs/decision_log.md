# Pack the Keep — Decision Log

## ADR-001: Godot 4.x for Windows desktop

**Decision:** Use Godot 4.x with GDScript-first gameplay for the Steam and Epic Games Store release.

**Reason:** The game is 2D-oriented, grid-based, and simulation-heavy. A text-readable project structure, straightforward headless execution, and low engine overhead are well suited to agent-first development.

**Trade-off:** Steamworks and Epic integrations may require GDExtension modules or small native adapters. Keep these behind platform interfaces and outside the keep simulation.

## ADR-002: Grid-first keep architecture

**Decision:** Use an explicit snapped grid and small footprint graph for the vertical slice.

**Reason:** The core product promise is spatial doctrine: players need to see why a pack and commander work together inside a keep. A grid makes placement, overlap, selection, balance, and deterministic testing clear.

**Trade-off:** The first version will not support fully destructible physics or arbitrary freeform construction. Those features are deferred until the compact keep is already fun.

## ADR-003: Packs are coherent doctrines, not collectible clutter

**Decision:** Each pack contains a small bundle of pieces and a visible strategic identity.

**Reason:** The project is inspired by pack, card, and tower-defense hybrids but must avoid rarity systems, duplicate inventory management, and percentage soup. Packs should change how the player thinks about the keep.

**Trade-off:** Content production requires stronger pack identity and combination testing. A larger number of weaker items is explicitly not the target.

## ADR-004: Commanders are rule lenses

**Decision:** Commanders alter preferred layouts, abilities, and limitations rather than merely providing larger bonuses.

**Reason:** A commander is commercially useful only if selecting one creates a different play pattern. This also supports replayability without requiring dozens of systems.

**Trade-off:** Commander balance is more complex than stat tuning, so every commander needs separate solo playtests and a combination matrix.

## ADR-005: Deterministic seeds before procedural variety

**Decision:** Pack offers, wave composition, doctrine variation, and damage outcomes accept reproducible seeds.

**Reason:** Agents and designers must be able to replay a failure, detect unwinnable pack offers, and write regression tests.

**Trade-off:** Later randomization must preserve meaningful agency through reserve, redraw, scouting, or other mitigation.

## ADR-006: Recovery is a core mechanic

**Decision:** Partial breach, repair, and adaptation are first-class outcomes.

**Reason:** Reviews of defense hybrids repeatedly identify death spirals, dominant openings, opaque mechanics, and unfair randomness as reasons players abandon otherwise compelling games.

**Trade-off:** Tension must come from opportunity cost, changing pressure, and damaged keep state rather than save deletion or irreversible campaign loss.

## ADR-007: Solo balance first

**Decision:** Balance all campaign scenarios for one player before adding co-op or online features.

**Reason:** The target is a premium single-player game, and direct-control defense games often become unfair when solo players inherit layouts or pacing designed for co-op.

**Trade-off:** Some late-game scenarios may be less spectacular than co-op-first designs, but the core experience will be coherent and easier to polish.
