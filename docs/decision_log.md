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

## ADR-008: Greywatch is the first battle, not a generic tower-defense map

**Decision:** Implement one authored two-floor keep named Greywatch Keep before adding procedural keep generation.

**Reason:** A fixed room graph makes Gate, Outer Wall, Inner Yard, Workshop, Supply Room, North Tower, and Old Chapel legible. It lets the first enemy doctrines teach different spatial questions without hiding the lesson in map noise.

**Trade-off:** Replay variety is lower in the first slice. The gain is that balance, screenshots, battle reports, and recovery paths can be tested against a stable layout.

## ADR-009: Enemy doctrines target functions, not nearest buildings

**Decision:** Raiders pressure the Gate, Sappers seek support rooms, and Climbers bypass the Gate toward upper-floor targets.

**Reason:** Each enemy asks a different layout question. Targeting a declared function makes the forecast readable and allows counters through unit choice, empty response space, floor coverage, and commander timing.

**Trade-off:** Enemy behavior is more authored than a nearest-target heuristic. The target-priority rule is deterministic: doctrine target, lowest condition, then stable ID order.

## ADR-010: Battle advances in inspectable steps

**Decision:** The first battle exposes forecast, approach, contact, intervention, and outcome phases and advances one step at a time in the prototype.

**Reason:** Pause and inspection are part of the strategic identity. The player must be able to read why a support room was hit and decide whether to spend Castellan Lockdown.

**Trade-off:** The first prototype is slower than a fully real-time defense. Speed controls and animation can be added later without changing the simulation commands.

## ADR-011: Partial breach is a playable result

**Decision:** One or two breached critical functions produce a recoverable partial breach; collapse requires three critical breaches or zero morale.

**Reason:** Players should learn from a damaged layout rather than losing after a long preparation phase. Materials, repairs, and the battle report make recovery a strategic continuation.

**Trade-off:** The first slice must make damaged states visually distinct and prevent repeated breach damage from falsely escalating the collapse counter.

## ADR-012: Recovery is a two-action authored interval

**Decision:** After a Hold or Partial Breach at Greywatch, open a named repair interval with exactly two actions. Allow room repair, piece repair, specialist assignment, assignment clearing, and early closure. Collapse skips the interval.

**Reason:** Recovery should be meaningful but bounded. Two actions create a short priority puzzle that can be authored, tested, and explained without turning between-wave play into a second construction game.

**Trade-off:** Players cannot repair every damaged room or freely reconfigure the keep after every wave. The restriction preserves consequence and makes “repair the Gate versus assign the Scout Post” a real decision.

## ADR-013: Assignments are role commitments

**Decision:** Each active unit has one specialist room: Pike Squad → Gate, Repair Station → Workshop, Fire Team → Inner Yard, and Scout Post → North Tower. Assignment is made only during the repair interval, costs one action, must match the unit’s floor and room, and persists into the next wave.

**Reason:** Room assignment gives the two-floor keep a human staffing layer without adding individual worker simulation. It makes the authored rooms mechanically legible and changes the next battle’s causal report.

**Trade-off:** An assigned unit cannot be reassigned in the middle of combat. The player must forecast which function deserves a specialist and accept the opportunity cost of committing it there.

## ADR-014: Availability follows preparation choices

**Decision:** Pike Squad and Narrow Gate are starter pieces. Opening a coherent pack unlocks its pieces, with two openings in the first Preparation and one opening in later Preparations. Packs are unavailable during combat and repair intervals.

**Reason:** The player should decide which defensive functions become available before seeing the next doctrine. This preserves pack identity and creates a bounded preparation choice without rarity, duplicates, or an oversized collection layer.

**Trade-off:** A player cannot access every unit in a single early defense. The restriction makes missing a Fire Team or Scout Post a consequence that can be answered in the next Preparation rather than an arbitrary deck-building failure.

## ADR-015: Track state, not log text

**Decision:** Store unit and enemy health as runtime fields and update compact aggregate combat metrics at the moment each attack, repair, disable, breach, or defeat resolves. Keep logs for explanation, not accounting.

**Reason:** Reconstructing combat from strings is fragile and expensive. Stable instance IDs plus small counters let the UI, save system, and tests answer what attacked, how much damage was dealt, who was disabled, and which enemy was stopped without parsing presentation output.

**Trade-off:** The state schema is slightly wider and save migrations must preserve new fields. The gain is deterministic reporting, efficient updates, and a clean boundary between simulation and presentation.

## ADR-016: Unit availability follows preparation choices

**Decision:** Pike Squad and Narrow Gate are starter pieces. Opening a coherent pack during Preparation unlocks its pieces, with two openings in the first Preparation and one in later Preparations. Packs cannot be opened during combat or the repair interval.

**Reason:** The player should choose which defensive functions become available before committing to the next doctrine. This preserves pack identity and creates a bounded preparation decision without rarity, duplicate collection, or a separate deckbuilding game.

**Trade-off:** A player cannot use every unit in the first defense. The missing function is a legible consequence that can be addressed in a later Preparation rather than an invisible random failure.

## ADR-017: Track combat state directly, not from logs

**Decision:** Store health and attribution fields on each unit and enemy instance, and update a compact aggregate metrics dictionary when attacks, repairs, damage, disables, breaches, or defeats resolve. Logs remain explanatory output, not accounting state.

**Reason:** Parsing battle text is fragile and makes UI, save/load, and tests depend on presentation wording. Stable IDs and direct counters provide efficient updates and deterministic inspection.

**Trade-off:** The save schema is wider and requires migration discipline. In return, the game can answer what attacked, how much damage was dealt, who was disabled, which enemy was stopped, and how much recovery was spent.

## ADR-018: Recovery cards render authoritative action previews

**Decision:** Expose read-only recovery-action previews from `PackKeepState` and render them as explicit UI cards for room repair, piece repair, assignment, and assignment clearing. The existing commands remain the only mutation path.

**Reason:** Recovery is the next major player decision, but generic buttons hide costs, benefits, trade-offs, and rejection reasons. A shared authoritative preview keeps the interface explanatory without creating a second copy of legality rules in `main.gd`.

**Trade-off:** The simulation API gains presentation-neutral preview metadata and must keep it synchronized with command behavior. Tests therefore verify that previews do not mutate state and that commands reject whenever their matching preview is blocked.

## ADR-019: Results are derived from authoritative state

**Decision:** Build the P5 causal report from wave-history fields and current keep state. Store each wave's principal pressure as structured history and derive successes, failures, final condition, and one replay experiment without parsing event-log prose.

**Reason:** The final screen should teach why a defense worked or failed while remaining deterministic, testable, and independent from wording in the event feed.

**Trade-off:** The first report uses compact rule-based observations rather than authored narrative variants. Richer prose can be added later as data, but it must continue to resolve from stable state and identifiers.

## ADR-020: Compare commander lenses over one immutable layout

**Decision:** Derive a shared layout summary and show Castellan and Warden interpretations over the same placed pieces. Comparison is read-only and does not switch the active commander or simulate alternate outcomes.

**Reason:** Commander differentiation is easier to understand when the player can see how one fort creates different opportunities and risks under each doctrine.

**Trade-off:** The comparison reports spatial evidence rather than a numeric power score. It deliberately avoids promising a winner before the authored wave actually tests the layout.

## ADR-021: Load active pack definitions through a validated catalog

**Decision:** Move the four active pack definitions into individual JSON files under `data/packs/` and load them through a small `ContentCatalog`. `PackKeepState` keeps ownership of pack commands and receives an immutable copy of validated definitions.

**Reason:** Pack content is the first bounded proof of the P6 data architecture. Separate files provide stable review boundaries and allow future content to be added without expanding the core simulation script.

**Trade-off:** Startup now includes deterministic local file parsing and validation. Missing or malformed pack data is treated as a development error and leaves the catalog unavailable rather than silently substituting different gameplay.

## ADR-022: Load commander definitions through the content catalog

**Decision:** Store Castellan and Warden definitions in separate JSON files and expose them through the same state-owned catalog used for packs.

**Reason:** Commander identity, starting resources, and ability descriptions are authored content. Externalizing them removes another hard-coded content family while preserving the simulation's command boundary.

**Trade-off:** The core now depends on valid local commander data during initialization. Catalog and parity tests must block malformed definitions before release.

## ADR-023: Normalize authored piece records at the catalog boundary

**Decision:** Store each defensive piece as structured JSON, then normalize its footprint, attack profile, support profile, and assignment rule into the compact runtime shape consumed by `PackKeepState`.

**Reason:** Authored data should describe a piece coherently without forcing the simulation and UI to parse arrays or duplicate schema knowledge. A single normalization boundary preserves existing deterministic rules while making future content diffable and independently validatable.

**Trade-off:** The catalog owns a small conversion layer between authored and runtime fields. Tests must lock both the source schema and the normalized behavior so the two representations cannot drift.

## ADR-024: Keep enemy actors data-driven and doctrine-neutral

**Decision:** Store base enemy actors in individual JSON files while leaving doctrine composition and scenario sequencing in their existing authoritative structures until their own migrations.

**Reason:** Enemy health, contact damage, routes, targets, and telegraphs are authored content, but moving doctrines at the same time would widen the behavior-preservation risk. The split also allows one enemy definition to participate in several future doctrines.

**Trade-off:** Enemy records temporarily reference doctrine IDs that are still declared in simulation code. Validators enforce that bridge until doctrine files replace it.
