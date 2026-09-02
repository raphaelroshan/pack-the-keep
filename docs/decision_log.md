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

## ADR-025: Separate doctrine intent from enemy actors

**Decision:** Store doctrine composition and forecast meaning in individual JSON files while enemy files retain only the doctrine each actor currently serves.

**Reason:** A doctrine is a teaching and targeting policy, not an enemy stat block. Separating it allows future scenarios to reuse actors in different compositions without duplicating health, timing, or route data.

**Trade-off:** Scenario wave plans remain in simulation code for one more migration slice, so catalog validators must check their doctrine and enemy references at the boundary.

## ADR-026: Store each scenario with its bounded variations

**Decision:** Keep a scenario's identity, teaching sequence, wave plans, and seed-selected bounded variations in one validated JSON file.

**Reason:** Variations only have meaning relative to the scenario whose lesson they preserve. Co-locating them makes review and reference validation explicit without changing deterministic selection.

**Trade-off:** Scenario files contain nested wave and variation arrays, but remain small, independent, and easier to audit than one global scenario table.

## ADR-027: Authored events use validated typed effects

**Decision:** Store authored events as individual JSON definitions and execute them only through `PackKeepState.choose_event_option()`. Event requirements and effects use a small allowlist of typed operations; UI code renders previews and sends choice IDs but never applies consequences.

**Reason:** Events need to change resources and battle preparation without becoming arbitrary scripts or a second simulation authority. Preflighting the complete choice before mutation makes rejection atomic, deterministic, saveable, and testable.

**Trade-off:** The first event vocabulary is deliberately narrow and the first chain is linear. New operations require validator, simulation, migration, and regression coverage before authored content can use them.

## ADR-028: First progression unlock trades morale for information

**Decision:** Completing The Relief Road unlocks an optional `roadside_intelligence` run modifier. Equipping it reveals authored wave composition in forecasts and reduces starting morale by one; it does not increase combat output.

**Reason:** The first progression reward should add a planning decision and demonstrate persistent unlock state without introducing grind or making old content obsolete. Information has value across scenarios while the morale cost keeps the choice situational.

**Trade-off:** This is a ledger-style prototype rather than a regional map. It proves unlock, equip, reset, save migration, and forecast integration before a larger campaign surface is justified.

## ADR-029: Accessibility preferences are separate from run saves

**Decision:** Persist high contrast, feedback mute, battle speed, and reduced motion in a small versioned settings file owned by the UI layer. Do not include them in `PackKeepState` serialization.

**Reason:** These choices belong to the player and should survive runs, but they must not affect deterministic replay or save migration for the defense simulation.

**Trade-off:** Settings have their own validation and atomic-write path. Controller remapping and display scaling remain later P10 slices.

## ADR-030: Remapping preserves device paths and project defaults

**Decision:** Persist supported keyboard and controller overrides by named input action. Capturing a binding replaces only events from the captured device family, while reset reconstructs the project-defined defaults. UI scale is a preset applied through the root window and stored in the same presentation-only settings file.

**Reason:** Named actions already separate input intent from simulation commands. Preserving the other device family prevents a controller change from silently removing keyboard access, and project defaults remain the single recovery baseline.

**Trade-off:** The first remapping UI supports keys and controller buttons, not mouse buttons, chords, or analog-axis tuning. Those can be added without changing the command boundary.

## ADR-031: Display preferences retain a windowed fallback

**Decision:** Persist fullscreen separately from a bounded windowed-resolution preset. Entering fullscreen does not discard the preferred windowed size; returning to windowed mode reapplies it. Effects volume is stored as a presentation gain independent of mute.

**Reason:** A fullscreen toggle should be reversible and predictable, while a bounded preset list avoids invalid desktop dimensions. Separating mute from gain preserves a player's chosen listening level when sound is re-enabled.

**Trade-off:** The first pass does not expose monitor selection, VSync, music, or voice buses. It establishes a migration-safe settings shape for those later additions.

## ADR-032: Accessibility auto-pause occurs after an atomic step

**Decision:** Detect a new-wave threat or increased breach by comparing authoritative state immediately before and after a normal `advance_wave()` call, then pause only the presentation loop. Retain the complete core report and apply feed-length preferences only while formatting UI text.

**Reason:** Players gain time to inspect meaningful changes without introducing a partial tick, alternate combat path, or truncated replay history.

**Trade-off:** Auto-pause reacts after the triggering step, not before it, and the first-threat trigger fires once per wave. More granular categories can be added later without changing simulation authority.

## ADR-033: Prototype audio uses semantic cue IDs

**Decision:** Route UI feedback through stable semantic cue IDs backed by short procedural tone profiles. Display the latest cue in text and apply mute/volume only when generating samples.

**Reason:** Named cues make warning, contact, repair, ability, and outcomes distinguishable and testable before authored audio exists, while keeping the simulation independent from sound playback.

**Trade-off:** The tones are functional placeholders rather than final sound design. Authored assets can replace profiles later without changing gameplay callers or tests.

## ADR-034: Armor reduces each non-piercing response

**Decision:** Author armor on enemy definitions and an armor-counter tag on the same record. During stable per-piece response resolution, subtract armor from each contribution that lacks the named tag. Nearby ranged-support bonuses apply before armor and do not stack.

**Reason:** Per-contribution armor creates a legible question—many unfocused attacks can fail against formation protection while one specialized high-ground unit remains useful. Data fields keep the rule reusable for later enemies and counters.

**Trade-off:** Armor is flat and binary in this first slice. It does not degrade, change facing, or interact with projectile physics.

## ADR-035: Signal disruption changes forecast and arrival timing

**Decision:** Author optional enemy disruption profiles with a counter support modifier and bounded arrival-step delta. A disruption counter is active only when a living redundancy piece is linked on the same floor and within range of a living signal-coverage piece. Uncountered disruption obscures forecast target detail and applies the authored arrival delta; it never changes accessibility pause preferences.

**Reason:** Smoke should create a visible operational problem rather than an accuracy penalty or hidden randomness. Requiring a short signal chain makes shared pack infrastructure and placement matter while keeping the rule deterministic and reusable.

**Trade-off:** The first version models signal integrity as a binary link and does not simulate sight lines, wind, relay direction, or partial coverage.

## ADR-036: Protection is authored support that some enemies can pierce

**Decision:** Allow support profiles to author bounded room or adjacent-piece damage reduction. Room protection stacks because it consumes multiple placements; adjacent-piece guards use the strongest single effect. Enemies may explicitly ignore protection and target the highest-health piece in authored categories.

**Reason:** Shieldwall needs to make adjacency valuable without creating a second health system, while Shieldbreaker needs a deterministic way to expose the limits of one fortified line. Data fields keep both rules reusable and visible to validators.

**Trade-off:** Protection has no facing or activation timing. A protection-piercing enemy bypasses the complete supported reduction rather than degrading it gradually.

## ADR-037: Run modifiers are mutually exclusive data-driven rules

**Decision:** Keep one equipped modifier ID in persistent profile state and allow the Campaign Ledger to select any validated modifier or none. Hardened Vanguard authors a bounded `enemy_health_bonus` that is applied once when enemy runtime instances are created.

**Reason:** A second modifier should prove that progression is a real content boundary rather than a Roadside Intelligence special case. Mutual exclusivity keeps the pre-run choice legible, while wave-creation application makes the challenge deterministic and naturally saveable.

**Trade-off:** Modifiers cannot yet stack or express compound effects. New effect types still require explicit validator, simulation, presentation, migration, and regression support.

## ADR-038: Release artifacts must prove behavior after export

**Decision:** Run a bounded smoke harness against the exported Windows executable in both pull-request packaging and tagged release workflows. Use an isolated user profile, unreachable proxy endpoints, the real main scene, normal save/settings paths, and a structured report validated outside Godot.

**Reason:** Source tests and a successful export do not prove that an embedded project launches, resolves its writable data directory, includes required resources, or exits cleanly. Testing the artifact catches packaging failures at the boundary users receive.

**Trade-off:** The first packaged smoke is headless and does not validate GPU presentation, installer behavior, or storefront launchers. Those remain explicit later alpha gates.

## ADR-039: Save candidates load outside live state

**Decision:** Parse and validate primary and backup saves into fresh `PackKeepState` candidates. Replace the UI's live state only after a candidate succeeds, preferring primary and falling back to backup.

**Reason:** A malformed or future save must not partially mutate an active run, and an interrupted atomic replacement may leave the last valid state only in the backup slot. Candidate loading makes both guarantees explicit.

**Trade-off:** A recovered backup is not promoted automatically. It remains recoverable until the player performs the next explicit save.

## ADR-040: Packaged input smoke verifies mappings, not hardware

**Decision:** Exercise controller navigation, conflict-resolving remap, and UI-scale layout through injected Godot input events inside the exported Windows artifact, then validate their persisted representation externally.

**Reason:** Source tests alone do not prove that input-map resources and settings serialization survive export. Injected events make the package gate deterministic while still traversing the real UI handlers.

**Trade-off:** This verifies mappings and layout logic without claiming physical-controller, analog, or GPU coverage.

## ADR-041: Packaged pause smoke separates presentation from simulation

**Decision:** In the exported artifact, start battle through the UI, prove paused presentation cannot advance the keep, toggle pause through the remapped named action, and resolve one explicit manual step before teardown.

**Reason:** Pause is a core strategic and accessibility promise. Testing it after export confirms that input, UI state, and deterministic simulation remain correctly separated in the shipped boundary.

**Trade-off:** Headless teardown verifies a clean Godot scene/process path, not forced termination or desktop window-manager behavior.

## ADR-042: Reinstall continuity is profile-owned

**Decision:** Relocate the exported single-file executable and relaunch it against the same isolated profile. Require the new install location to restore the previous run and presentation settings.

**Reason:** Saves and preferences belong to the user profile, not the installation directory. A relocation test catches accidental executable-relative persistence before installer/storefront work begins.

**Trade-off:** This models a portable reinstall and does not yet validate a signed installer, registry cleanup, or storefront-specific uninstall semantics.

## ADR-043: Headless validation does not initialize audio playback

**Decision:** Preserve semantic cue IDs and profiles in headless mode, but do not create or play an `AudioStreamGenerator` when no display/audio presentation is active.

**Reason:** Headless tests validate cue meaning rather than sound output, and Godot 4.4.1 can crash during Windows shutdown while releasing unnecessary audio playback resources.

**Trade-off:** Actual sample generation remains covered by interactive builds and manual audio checks, while headless automation covers the presentation-independent cue contract.

## ADR-044: Alpha readiness has a machine-readable evidence index

**Decision:** Maintain one versioned P12 checklist that maps every required hardening item to repository evidence and validate it both statically and against the combined Windows packaged-smoke report.

**Reason:** A green collection of unrelated jobs is weaker than an explicit requirement-to-evidence map. The checklist makes omissions, stale versions, and missing artifacts fail before a candidate is presented for human review.

**Trade-off:** Automated readiness remains `candidate` status. Human playtesting, signing, storefront review, and release approval stay outside this gate.

## ADR-045: Presentation settings recover through validated candidates

**Decision:** Load presentation settings from a validated primary candidate, then fall back to the backup candidate when the primary is missing, malformed, or uses an unsupported schema. Temporary files are never promoted during load.

**Reason:** Settings use the same atomic primary/temp/backup replacement shape as run saves. A close between renaming the primary to backup and committing the temporary file must not discard accessibility, scale, display, audio, or remapping preferences.

**Trade-off:** Invalid individual fields inside an otherwise supported settings document still fall back to their documented defaults. A recovered backup is not promoted until a later explicit preference save.

## ADR-046: Alpha viability is an all-scenario deterministic matrix

**Decision:** Run one documented viable baseline through every authored scenario for both commanders and three fixed seeds. Execute each case once uninterrupted and once through a fresh-state save/load checkpoint, require byte-identical checkpoint and terminal serialization, three completed waves, a non-collapse outcome, closed final recovery/event state, and the canonical replay key.

**Reason:** Isolated mechanic tests can remain green while an older scenario becomes unwinnable, a final event remains unresolved, a commander-specific path drifts, or persistence changes the continuation. A compact cross-product gate catches those release-wide regressions locally without depending on hosted CI.

**Trade-off:** The matrix proves only that a known answer remains viable and deterministic. It does not establish that all layouts are balanced, that partial breaches feel fair, or that the human alpha playtest is complete.

## ADR-047: Save payloads are preflighted before candidate mutation

**Decision:** Validate top-level scalar types and the nested shape and catalog identity of pieces, rooms, enemies, assignments, metrics, logs, and wave history before copying any saved field into `KeepState`.

**Reason:** Candidate isolation protects the live UI state, but malformed nested data could still trigger script errors or produce a candidate that looked successful while containing unknown gameplay objects. A single preflight boundary makes rejection explicit and keeps backup fallback reliable.

**Trade-off:** Save validation is stricter and adds maintenance when the runtime schema grows. Missing fields remain compatible for older schemas, while present fields must be structurally valid.

## ADR-048: Authored events may invoke bounded recovery commands

**Decision:** Allow validated event effects to invoke one authoritative room-repair or piece-assignment command as the complete effect of a choice. Event eligibility remains data-driven, while `KeepState` performs the same preview and mutation used by ordinary recovery controls.

**Reason:** Greywatch events should change a visible operational decision without duplicating repair costs, adjacency rules, assignment limits, or stable instance selection in UI or scenario-specific code.

**Trade-off:** Recovery-command effects cannot be mixed with other event effects in one choice. Richer multi-effect transactions remain deferred until they can preserve atomic validation without creating a second recovery rules engine.

## ADR-049: Event history has one bounded read projection

**Decision:** Keep complete event history authoritative in `KeepState`, but expose Ledger and Results through one read-only newest-first projection capped to five entries. Run flags are sorted by stable ID and retain explicit boolean values.

**Reason:** Players need a compact account of recent consequences in both existing surfaces, and both views should agree without duplicating sorting, title lookup, or truncation rules in presentation code.

**Trade-off:** Older events remain in saved state and reports but are omitted from the compact UI projection. A searchable cross-run archive remains outside this slice.

## ADR-050: Terminal event triggers may name several authored waves

**Decision:** Event trigger `wave` accepts either one integer or a bounded non-empty array of unique wave indices. The Wrong Wall conclusion uses `[1, 2, 3]` so the same resource-free report can resolve a normal finish or an early collapse.

**Reason:** Collapse ends the authored sequence immediately and skips recovery. A terminal report should explain that outcome without requiring duplicate event definitions or pretending the player reached wave three.

**Trade-off:** Multi-wave triggers remain explicit authored lists, not wildcard scheduling. Validation rejects empty, duplicate, or out-of-range arrays.

## ADR-051: Character arcs use explicit choice flags and authored variants

**Decision:** Event choices may set validated boolean flags only after their typed effects succeed. A future event may require any named flag and may provide commander-specific setup and labels while preserving identical underlying choices and effects.

**Reason:** Mara's arc needs earlier operational decisions to change a later conversation without introducing hidden reputation arithmetic or duplicating events for each commander.

**Trade-off:** Variants alter framing, not combat math. More complex relationship thresholds and branching dialogue remain deferred.

## ADR-052: Rare occurrence selection uses a named deterministic seed slot

**Decision:** A rare authored event may declare a bounded modulus and eligible slots. `KeepState` derives the slot from the run seed plus scenario, the event's named selection stream, and wave; it never consumes global or presentation randomness.

**Reason:** Rare events must replay reliably and vary across known seeds without introducing a general weighted scheduler before the event system needs one.

**Trade-off:** The first occurrence has a fixed one-in-three cadence and flag-only consequences. Weighted pools and combat-changing rare effects remain deferred; bounded cooldown metadata is introduced separately in ADR-054.

## ADR-053: Event-card presentation is a stateless component

**Decision:** Extract authored-event label and button construction into `AuthoredEventPanel`. It accepts an event read model and emits only a stable choice ID; `main.gd` remains responsible for invoking `KeepState` commands.

**Reason:** Event breadth increased enough that construction and rendering obscured the main controller. A narrow component boundary lowers maintenance cost without moving gameplay authority or redesigning the interface.

**Trade-off:** Compatibility aliases remain in `main.gd` for current tests and neighboring UI code. Further panel extraction should remove those only through a separately tested migration.

## ADR-054: Event scheduling is explicit, bounded, and schema-checked

**Decision:** Require every runtime event to declare a stable selection stream, repeat policy, cooldown, and maximum occurrence count. Keep the machine-readable contract in `content/event_schema.json`, mirror it in both validators, derive repeat eligibility from authoritative event history, and use `active_slice.event_ids` as the canonical manifest inventory.

**Reason:** Implicit once-only behavior hid scheduling assumptions in control flow and made content drift difficult to diagnose. Closed choice/effect payloads and explicit graph checks now reject typos, unknown links, cycles, cross-scenario chains, unbounded repetition, and missing manifest entries before gameplay mutation.

**Trade-off:** The current runtime supports only `once_per_run` and bounded `repeat_after_cooldown`; weighted pools and broader campaign scheduling remain deferred. Adding an operation or policy now requires coordinated schema, offline-validator, runtime-validator, and negative-fixture changes.

## ADR-055: Packaged persistence uses a five-phase lifecycle gate

**Decision:** Expand the Windows packaged smoke artifact to include clean-install, relocated-reinstall, stale-backup, missing-profile, and schema-upgrade reports. Keep profile/install setup in the Python runner and application-state assertions in the Godot smoke adapter.

**Reason:** A successful reinstall proves only one persistence path. Release candidates also need evidence that absent profiles retain defaults, valid primaries outrank stale backups, legacy schema-3 data migrates and rewrites cleanly, and presentation settings do not alter deterministic simulation state.

**Trade-off:** CI now launches the exported executable several additional times. Signed installer, registry, shortcut, storefront, and forced-termination behavior still require explicit human or later release validation.

## ADR-056: Scenarios select data-driven defensive identities

**Decision:** Add runtime keep definitions as a validated content type. A scenario names one `keep_id`; `KeepState` derives room geometry, labels, graph, recovery profile, visual profile, and spatial rule from that keep while preserving stable functional room IDs for existing enemy and piece references. Ash Ford's marked causeway reduces room damage by one only while no ground-floor defender footprint occupies it.

**Reason:** P15 needs a genuinely different defensive identity without duplicating enemies, inventing scenario-only UI authority, or forcing every existing room reference through a migration. Scenario-owned keep selection keeps the defense loop isolated and deterministic while making layout and recovery meaningfully different.

**Trade-off:** Both current keeps share the same nine semantic room IDs, so wholly different future functions will require scoped aliases or broader content-reference validation. The second keep remains an isolated scenario; regional travel, economy, and faction systems stay deferred to the next bounded slice.

## ADR-057: Regional consequence is one authored state projection

**Decision:** Represent Low Mill and Miller's Road as one validated runtime region definition. At terminal scenario closure, `KeepState` selects one authored consequence from the run outcome and the lower condition of Gate and Supply Room. The state persists, appears in Ledger and Results, and may contribute zero to three materials exactly once when the next scenario is selected.

**Reason:** P15 needs proof that a keep defense can cause something legible beyond its walls before a map or campaign economy is justified. Named anchors make the cause inspectable, and one-shot support makes the consequence operational without creating a stockpile or hidden reputation score.

**Trade-off:** Low Mill has no player-selected regional action and only one route. The contribution is intentionally small, non-negative, and consumed on scenario selection; travel, shops, settlement inventories, relationship trees, and procedural regional scheduling remain out of scope.

## ADR-058: Human playtest evidence stays human-authored

**Decision:** Define P16 playtest coverage as privacy-light JSON session records generated empty, completed only by a human observer, validated against the exact build identity and four-case commander/modifier matrix, and stored as durable repository evidence. The running title screen displays the same pre-alpha build identity.

**Reason:** Automated simulations prove determinism and known-path viability but cannot establish comprehension, trust, readability, or replay motivation. Explicit records make observations reproducible without allowing CI to impersonate a tester or silently turn readiness into approval.

**Trade-off:** A green validator can report that the matrix is structurally complete, but the `human_playtest` gate and `release_ready` flag remain pending until the owner reviews the evidence. External recruitment, recordings, public distribution, signing, and storefront work remain outside this slice.

## ADR-059: Repeated playtest findings use stable issue keys

**Decision:** Require each finding to carry a stable snake-case issue key. Deterministic summary tooling groups matching keys across records and promotes a task candidate only after the same key appears in at least two sessions, retaining every human-authored summary and suggested action.

**Reason:** The roadmap asks repeated observations to become small reversible work. Stable keys distinguish repetition from coincidental wording while keeping automation limited to counting and presentation.

**Trade-off:** Observers must classify the same problem consistently. The summary can surface evidence but cannot decide product priority, rewrite the finding, create an external ticket, or approve release.

## ADR-060: Playtest matrices are artifact cohorts

**Decision:** Bind every P16 session record to one 40-character source revision and one packaged executable name, byte size, and SHA-256 digest. Count a completed commander/modifier matrix only within a single revision-and-digest cohort.

**Reason:** A version label alone does not prove which binary a person tested, and combining sessions from different fixes can make an untested candidate appear covered. Content-addressed provenance keeps feedback reproducible and the final matrix honest.

**Trade-off:** Rebuilding after a fix starts a new artifact cohort, so the four-case matrix may need to be repeated. The stronger evidence is worth that cost before any owner-approved alpha release.

## ADR-061: CI artifacts carry their own playtest manifest

**Decision:** Generate `playtest-build.json` in the Windows packaging job and upload it beside the executable. Session generation must consume that manifest and independently verify the selected executable's filename, size, SHA-256 digest, build version, source revision, CI run ID, and non-release status.

**Reason:** Manually copying provenance into a session record is error-prone. A self-identifying bundle makes the safe path the easy path and lets testers prove exactly which candidate they observed.

**Trade-off:** A rebuilt or renamed executable invalidates the bundled manifest and requires regenerating it. This is intentional: modified binaries must not inherit evidence from the original CI artifact.

## ADR-062: Packaged candidates carry a generated observer brief

**Decision:** Generate `PLAYTEST_README.md` inside every Windows release-candidate artifact after validating the executable against `playtest-build.json`. The brief repeats exact provenance, all protocol-owned observation prompts, privacy limits, the human-only completion rule, and the pending owner-approval boundary.

**Reason:** A provenance manifest proves which binary is present but does not make a downloaded candidate operational for an observer who is not browsing the repository. Generating the brief from the same protocol and manifest prevents instructions from drifting away from the tested build.

**Trade-off:** The brief is deliberately read-only guidance, not a questionnaire or automatic result collector. Session JSON remains the durable evidence, and CI still cannot populate observations, recruit testers, or approve distribution.

## ADR-063: Packaged candidates include unfilled matrix templates

**Decision:** Generate one JSON template for every required commander/modifier combination after verifying the packaged executable. Bind each template to the exact build provenance, keep all observations `not_tested`, and leave every human-owned identity, environment, result, finding, summary, and completion field blank.

**Reason:** Requiring observers to reconstruct the evidence schema creates avoidable transcription errors and makes the four-case matrix harder to execute from a downloaded artifact. Pre-building only the machine-owned structure makes the workflow portable without pretending that a session occurred.

**Trade-off:** Templates intentionally fail evidence validation until a human fills their blank fields and performs the observations. They cannot count toward matrix coverage merely because CI generated them.

## ADR-064: The playtest launch journey uses contextual screens

**Decision:** Separate the title, briefing, preparation, battle, recovery/report, and settings concerns. The title offers guided, custom, saved-run, and settings routes; the briefing owns commander/scenario/modifier selection; the board screens show only phase-relevant command groups; and navigation disables phases that authoritative state has not reached.

**Reason:** The previous single command rail exposed setup, placement, combat, recovery, persistence, and accessibility controls together. It proved functionality but made the first action hard to read and allowed presentation-only screen jumps that did not correspond to the run state.

**Trade-off:** Some controls now require entering their dedicated screen, and the command rail remains scrollable for narrow windows. The clearer hierarchy is preferred over keeping every prototype action simultaneously visible.

## ADR-065: Defenders commit to one deterministic target per combat step

**Decision:** Resolve defender fire before enemy contact in stable piece-instance order. Each ready defender may engage at most one living enemy per combat step, selected by contact urgency, arrival timing, effective counter damage, enemy pressure, remaining health, and stable wave slot. A read-only response preview exposes the next planned engagement for inspection without reserving or mutating a target.

**Reason:** The previous enemy-first loop allowed every defender to attack every compatible enemy during the same one-second step. Larger waves therefore multiplied defender actions and ranged ammunition use, obscuring the meaning of focus, timing, and coherent counter coverage. One commitment per defender makes mixed waves a real allocation problem while preserving deterministic pause-and-inspect play.

**Trade-off:** Multi-enemy waves become more demanding and some historical balance fixtures may need explicit layout adjustments. Target choice remains automatic in this slice; direct focus-fire commands, movement, projectile travel, and a general threat-scoring resource are deferred until playtest evidence justifies them.

## ADR-066: Combat runs continuously over deterministic assault phases

**Decision:** Start Battle in real-time playback, interpolate enemy motion from the fractional authoritative clock, and present brief defender engagement traces at each resolved tick. Keep the deterministic one-second resolver and authored scenario group boundaries, but describe those boundaries to the player as assault phases and recovery lulls rather than requiring a primary advance-step interaction. Add a 2560×1440 window preset and default new windowed installs to 1600×900.

**Reason:** The step-first presentation made a real-time simulation read like a turn-based wave prototype. Continuous motion and automatic playback make pressure legible as an unfolding siege while retaining pause, speed, manual-step, replay, and save guarantees. A larger default window and explicit 1440p option let the fort occupy an appropriate desktop canvas.

**Trade-off:** Combat still resolves on deterministic one-second ticks beneath the interpolation, and recovery still separates authored pressure phases. Fully continuous damage, projectile physics, and removal of all internal wave terminology would widen simulation and migration risk without improving the current vertical-slice test proportionally.

## ADR-067: Combat impact is presentation derived from authoritative state deltas

**Decision:** Animate defender exchanges according to each piece's data-driven melee or ranged style, telegraph the final approach second, and derive room or piece impact marks from authoritative before/after state around a resolved tick. Keep projectile travel, hit reaction, labels, and audio entirely presentation-only.

**Reason:** Continuous movement alone made the battle flow better but each deterministic tick still read as a brief line overlay. Travelling ranged marks, compact melee lunges, enemy reactions, and explicit structural impacts let a tester follow the causal exchange without reading the event feed after every second.

**Trade-off:** Effects visualize already-resolved outcomes and are not collision simulations. Net before/after target damage may visually combine simultaneous pressure and automatic repair into one value; the event feed remains the detailed authority.

## ADR-068: The board footer exposes deterministic assault cadence

**Decision:** Replace the single battle progress bar with a six-segment timeline that fills the current fractional tick, places stable enemy initials at authored arrival ticks, and names the next unresolved contact. Keep the timeline read-only and inside the existing board footer.

**Reason:** Real-time movement and impact feedback clarified moment-to-moment action but did not show the overall cadence. A compact timeline lets players anticipate attention spikes and understand why speed controls matter without adding another panel or exposing internal scheduling data as a command surface.

**Trade-off:** The footer explicitly reveals the six-tick vertical-slice structure and authored arrival timing. That clarity is preferred for the current tactical puzzle; a future variable-duration scenario format would need to provide its own declared tick count.

## ADR-069: Threat focus follows urgency without issuing combat orders

**Decision:** Automatically focus the highest-priority living enemy when Battle begins, preserve any living player-selected focus, and hand off only when focus becomes invalid or defeated. Use contact state, authored arrival, enemy damage, and stable index for presentation priority. Timeline arrival markers and map markers share the same focus pathway.

**Reason:** A live assault opened with an empty response panel and forced the player to find a small moving marker before the central tactical explanation became useful. Automatic focus makes the inspector immediately informative, while deterministic handoff prevents it from going stale as enemies fall.

**Trade-off:** Automatic focus can draw attention toward one threat even when the player is watching another part of the keep. Preserving any living manual selection avoids fighting the player, and focus remains strictly observational rather than a focus-fire command.

## ADR-070: Threat hover details share one read-only projection

**Decision:** Use one tooltip projection for living enemy markers on both the fort and the assault timeline. Build it from authoritative enemy inspection plus the data-driven counter piece name, and mirror the map's double-outline focus language on the selected timeline marker.

**Reason:** The timeline made attack cadence readable, but its initials still required a click or a trip to the command rail before a player could identify the threat. Matching hover details let the player compare timing, route, health, and counter without interrupting live observation or changing their deliberate focus.

**Trade-off:** Native hover tooltips are compact and desktop-oriented; controller users still rely on focus cycling and the response card. A persistent or controller-specific tooltip surface remains deferred until human playtests show that the existing focused inspector is insufficient.

## ADR-071: The battle board reserves a separate approach apron

**Decision:** Increase the board's logical height and place the assault timeline below a reserved gate-approach apron. Keep fort geometry, enemy interpolation paths, hit testing, and deterministic arrival timing unchanged.

**Reason:** At the default desktop scale, ground-route threat markers and their `ARMOR`, `SMOKE`, or `FOCUSED` annotations occupied the same vertical band as timeline ticks. A small scroll-safe height increase restores the distinction between battlefield state and pacing information.

**Trade-off:** The battle page is slightly taller and may require a little more vertical scrolling at 1280×720. This is preferable to scaling down the tactical board or hiding threat annotations, and all required controls remain within the existing scroll container.

## ADR-072: Occupied rooms yield text priority to defenders

**Decision:** Fit board labels by measured width and suppress a room's name and numeric state text when a placed defender overlaps it. Preserve the room boundary and condition bar, and keep complete room and defender information in the inspector.

**Reason:** Rendering both label layers in the same small grid cells made the tactical board look like a debug overlay, especially with multi-word defenders. The defender is the actionable foreground object, while the room's shape and condition bar still communicate the underlying structure.

**Trade-off:** An occupied room no longer displays its full name directly on the board. Players can click it for full details, and unoccupied rooms retain fitted labels; a future authored art pass may provide stronger iconographic room identity.

## ADR-073: Most attackers clear defenders before rooms

**Decision:** Add a required data-driven `target_mode` to every enemy. Raiders, Climbers, Ash Slingers, Shield Guards, and Shieldbreakers deterministically hunt living defensive pieces, while Sappers and Siege Beasts retain explicit structure-destruction behavior. Unit hunters may use authored category, floor, and health preferences but never fall through to a room. Resolved damage subtracts directly from piece health. If all placed defensive pieces are disabled, the wave resolves as a recoverable partial breach.

**Reason:** The previous model made most attackers repeatedly damage rooms, so defenders read as passive damage sources rather than combatants holding a keep. Unit-first pressure makes health, counter coverage, retargeting, melee attacks, and projectiles causally legible, while specialist demolition roles preserve the strategic need to protect rooms.

**Trade-off:** Existing layouts take more piece damage and some automated scenario outcomes become harsher. The current implementation keeps authored routes and deterministic one-second resolution; movement AI, collision projectiles, continuous damage, and player-issued focus fire remain deferred.

## ADR-074: Enemy cadence is projected, not separately simulated

**Decision:** Derive each active enemy's next strike tick and fractional cadence progress from its data-driven attack interval, authored arrival, authoritative battle step, and existing fractional clock. Expose that read model to matching tooltips, the focused response card, and a presentation-only cadence meter above the enemy health bar.

**Reason:** Slower demolition and heavy attacks improved balance but were invisible between impacts. A shared projection lets the player see when pressure will land without adding a second timer, new save state, or a player-issued interrupt system.

**Trade-off:** The cadence meter anticipates deterministic tick resolution rather than physical wind-up animation. It does not represent stun, haste, or interruption; those mechanics remain deferred until the compact battle is validated by human playtests.

## ADR-075: Stable combat target IDs stay internal

**Decision:** Keep enemy targets serialized as stable room or piece instance IDs, but resolve those IDs through one read-only target projection before presenting them. The projection supplies a friendly name plus HP for pieces, condition/state for rooms, and explicit approach or no-target language.

**Reason:** Raw values such as `repair_station_1` are useful for deterministic state and tests but break the illustrated siege presentation. A shared projection keeps the inspector, response card, and tooltips consistent without duplicating target rules in the UI.

**Trade-off:** Multiple copies of the same defender currently share the same display name. Persistent nicknames or player-managed numbering remain out of scope; the stable ID remains available in the read model for diagnostics.

## ADR-076: Enemy role controls impact presentation, not damage authority

**Decision:** Require every enemy definition to declare `melee`, `ranged`, or `demolition` as its attack style. Capture the due attacker's style alongside the existing before/after target snapshot, then draw a compact lunge and slash, hostile projectile, or heavy strike and double ring after the deterministic tick resolves. Use `HP` for defender damage and `STRUCTURE` for room condition damage.

**Reason:** Unit-first targeting and visible cadence made enemy intent legible, but every successful enemy attack still used the same generic red line and room-oriented label. Distinct motion now makes Raider, Ash Slinger, and Sapper pressure recognizable at normal play distance without adding another HUD panel.

**Trade-off:** The effects visualize already-resolved state deltas and do not simulate collision, dodging, knockback, or sub-tick damage. When multiple enemies damage one target in the same tick, the displayed value remains the authoritative net loss and uses the first stable due source for its style.

## ADR-077: Wind-ups derive from the existing cadence clock

**Decision:** Show a role-specific pre-strike warning after 55 percent of a contacted enemy's current attack interval has elapsed. Derive the warning from `enemy_attack_timing()`, the current target, and the enemy's presentation style; do not create a second timer or reserve an attack in UI state.

**Reason:** Distinct impacts explain what just happened, but players also need a brief visual chance to interpret incoming pressure before health changes. Reusing the existing cadence projection keeps pause, speed, save/load, and deterministic strike timing aligned.

**Trade-off:** The warning is intentionally short and schematic. It improves anticipation without promising reaction mechanics such as parries or interrupts; those remain out of scope until human testing shows the battle benefits from another command layer.

## ADR-078: Damage reactions retain transient before-and-after values

**Decision:** Add the authoritative target value immediately before and after a resolved tick to each transient impact projection. Use that interval to draw a short recent-loss segment on the target health bar, a role-colored outline, and a small visual-only recoil for defender pieces. Rooms never move, and reduced motion suppresses recoil.

**Reason:** Floating damage text identifies the amount, but the player's eye still has to find the changed bar and infer which object absorbed it. Keeping the previous value for the lifetime of the existing impact effect makes health loss spatially explicit without adding permanent UI.

**Trade-off:** Room feedback shows net condition loss after same-tick mitigation or repair, matching the authoritative final state rather than reconstructing every intermediate operation. Recoil is illustrative and never affects targeting, placement, or saved coordinates.

## ADR-079: Defender-wipe collapse is an explicit scenario contract

**Decision:** Preserve the recoverable partial-breach result when all defenders are disabled in existing teaching scenarios, but allow an authored scenario to opt into an immediate terminal collapse with `collapse_on_defender_wipe`. The Last Bell uses that rule and advertises it in the scenario briefing.

**Reason:** A strong vertical slice needs a genuine loss state that can be reached through normal combat, while the existing teaching scenarios still benefit from letting players inspect and repair a failed line. A scenario-level rule makes the difference intentional, testable, and visible before play.

**Trade-off:** Scenario authors must decide whether a defender wipe is recoverable or terminal. The default remains recoverable for save compatibility, and the P12 viability matrix continues to cover the original nine non-collapse baselines while the stress scenario has its own deterministic collapse test.

## ADR-080: First Watch is a strict presentation-owned tutorial

**Decision:** Add a versioned `TutorialDirector` that sequences a skippable three-phase Gatehouse Lock lesson through existing UI commands. The director may gate commands, focus controls and board targets, and store progress in a separate tutorial file, but every placement, attack, repair, assignment, and ability still resolves through `PackKeepState`. Capture an authoritative snapshot at the start of each assault phase and restore it when the tutorial ends in collapse.

**Reason:** The vertical slice exposed its systems but expected a new player to infer their order and meaning from a dense command rail. First Watch now teaches the real game from menu to victory: fortress purpose, resources, placement, enemy roles, live pause-and-inspect combat, recovery trade-offs, assignments, and commander timing.

**Trade-off:** The tutorial intentionally prescribes one safe opening and pauses each new assault phase for analysis. It is optional, remains replayable from the main menu, and does not introduce a second simulation, tutorial-only combat rules, or a campaign progression dependency.

## ADR-081: Terminal Results uses a dedicated presentation-only debrief

**Decision:** Replace the ordinary command rail at a completed scenario with a dedicated `TerminalDebriefPanel`. Keep the final fortress board visible beside it, derive outcome, resources, wave history, causal explanation, persistent damage, consequences, and replay advice from existing authoritative read models, and route replay, save, and menu actions through existing handlers.

**Reason:** Reusing inter-wave recovery presentation made a finished defense feel like another maintenance interval. A dedicated composition gives completion emotional and visual weight while retaining the damaged keep as evidence for the report.

**Trade-off:** Detailed causal and fortress information scrolls inside the debrief so the replay action can remain fixed and visible. At 125% scale the keep and debrief stack vertically. No new result state is serialized, and unresolved terminal events continue to use their existing event flow until completion.

## ADR-082: Preparation states the question, visible answer, and open weakness

**Decision:** Add a compact `PreparationBriefPanel` above the primary assault action in ordinary Preparation. Derive its current question, visible answer, and first open weakness from existing forecast, scenario, layout-summary, and placed-piece read models. Hide the generic guidance text and suppress the panel during First Watch, which retains its authored objective card.

**Reason:** Preparation exposed all relevant information, but the player had to synthesize doctrine, placement, and warnings from several dense command-rail sections. A stable three-part summary makes the decision legible at the moment of commitment while keeping the fortress as the main visual surface.

**Trade-off:** The visible answer deliberately describes coverage rather than evaluating win probability, and the open weakness reports only the first deterministic warning. Full pack, comparison, and placement detail remains in the command rail. The panel adds no validation, scoring, simulation, or save authority.

## ADR-083: Board identity uses a central procedural visual registry

**Decision:** Move floor, room, defender-family, enemy-family, and render-layer visual tokens into `BoardVisualRegistry`. Keep the current data-driven geometry and `KeepCanvas` hit-testing, but draw distinct ground and upper structures, critical-room markers, dark defender role cards, and shape-coded enemy silhouettes from those tokens.

**Reason:** The board already communicated detailed state, yet large areas and actors shared similar rectangular or circular treatments. A stable visual grammar makes structure and role readable before labels while keeping the current procedural fallback replaceable by future authored assets.

**Trade-off:** These remain code-drawn placeholders, not final art. Enemy initials and labels stay as redundant accessibility cues, and the registry owns presentation tokens only; it cannot influence placement, routes, targeting, health, timing, or serialization.

## ADR-084: Battle audio is a semantic presentation service

**Decision:** Extract generated tone profiles and playback into `BattleAudioCueService`. Map assault start, contact, defender response, hostile impact, breach, recovery, and terminal outcomes to stable cue IDs after the UI observes authoritative state. Keep mute, effects volume, reduced-motion minimization, headless evidence, and the visible last-cue label at the presentation boundary.

**Reason:** The prototype already had useful tones, but their profiles and event meaning were embedded in the main UI controller. A dedicated service creates one complete and testable battle-loop vocabulary without making sound a second combat clock.

**Trade-off:** Cues remain synthesized placeholders rather than authored sound effects or music. Reduced motion selects a minimal one-tone sequence as a conservative sensory setting. The service records requests for tests but never schedules a tick, command, target, or saved field.

## ADR-085: Assault readiness is derived presentation state at tick zero

**Decision:** Create the authoritative assault immediately through `PackKeepState.start_wave()`, then pause presentation at tick zero for phase one and for later phases that change doctrine or introduce an enemy family. Use the existing pause/resume action as **Sound the Bell**, block manual stepping until acknowledged, and re-derive readiness from scenario data when loading an active tick-zero save.

**Reason:** Continuous real-time combat was already the correct identity, but immediately advancing while the screen changed could hide first contact and make later doctrine shifts feel arbitrary. A bounded ready beat preserves the live battle while giving the player one clear moment to read the board.

**Trade-off:** The ready flag is intentionally not serialized, so loading any active tick-zero wave reconstructs the warning even if the player had manually paused before the first tick. First Watch retains its stricter authored pause steps, and unchanged doctrine/roster transitions remain eligible to continue live.

## ADR-086: Inter-wave Recovery gets a dedicated presentation-only brief

**Decision:** Add a `RecoveryBriefPanel` above the persistent fortress during active inter-wave recovery. Derive what changed, why it matters, next pressure, action/material budget, first priority, and trade-off from wave history, damage state, and `recovery_advice()`. Keep exact recovery commands and validation in the existing command-rail cards.

**Reason:** The action cards were mechanically clear but required the player to infer the phase outcome and next-wave stakes from separate long reports. A compact hierarchy frames the two-action sacrifice before the player evaluates individual buttons.

**Trade-off:** The priority is advisory and selects only one visible damaged room or defender. It does not reorder, auto-select, or execute actions. Terminal Results, authored-event gating, and all recovery costs remain unchanged.

## ADR-087: The War Council presents choices before controls

**Decision:** Replace the main-column selected-loadout paragraph with a dedicated presentation-only `WarCouncilChoicePanel`. Show commander identity, strength, intervention, limitation, and first question beside scenario identity, objective, teaching question, authored pressure arc, risk, and fixed commitments. Route card navigation through the existing option metadata and selection handlers, and retain the dropdowns as an advanced fallback.

**Reason:** The briefing contained the right information but made the player assemble it from a compact paragraph and a long command rail. Two stable cards make the run-defining contrast readable before the fortress appears and give mouse, keyboard, and controller users an obvious browsing path.

**Trade-off:** The main setup screen becomes taller and may scroll at small windows or large UI scales. Cards therefore stack at 125% scale, while the detailed scenario preview and fallback selectors remain available in the command rail. No card field is serialized or allowed to select content during render.

## ADR-088: Pack offers expose doctrine before purchase

**Decision:** Replace the raw-first pack selector and prose preview with a dedicated `PackOfferPanel` at the top of Preparation commands. Project the selected pack's doctrine, contents, costs, strength, weakness, spatial demand, question, opening budget, and availability state, while routing Open and Reserve through existing handlers and retaining the dropdown as an advanced fallback.

**Reason:** Packs are the game's signature strategic commitment, but the previous interface presented them like a debug catalogue. A single card makes the sacrifice and board demand visible before materials are spent and clearly distinguishes browsing from committing.

**Trade-off:** The command rail card is taller than the former selector. Its information replaces rather than duplicates the old preview, and it remains scrollable at large scale. State labels are derived from `pack_preview()` and current tutorial context; only `PackKeepState` may grant, reserve, price, or reject a pack.

## ADR-089: Preparation uses a three-stage command hierarchy

**Decision:** Order Preparation around numbered pack choice, defender placement/inspection, and assault commitment. Move piece selection beside floor and placement actions, suppress the decorative mixed icon strip, and collapse the pack catalogue, invasion doctrine selector, and full layout lens behind an explicit Advanced control.

**Reason:** All necessary commands existed, but the rail interleaved high-frequency decisions with diagnostic selectors and repeated visual references. The new hierarchy makes the next meaningful verb visible while leaving the fortress and answer-quality brief as the primary surface.

**Trade-off:** Advanced information now requires one disclosure action. It remains keyboard/controller accessible and preserves exact state, costs, and command paths; tutorial-required actions never depend on opening the Advanced panel.

## ADR-090: Tactical inspection shares one presentation hierarchy

**Decision:** Render room, defender, and enemy inspection through one `InspectionPanel` with identity, numeric condition, tactical purpose, contextual next action, and retained detail. Re-read the selected authoritative object on refresh and resolve counter IDs to player-facing names.

**Reason:** The old inspector was accurate but read as an unstructured debug paragraph and changed shape between subject types. A stable hierarchy makes selection useful during Preparation, live Battle, and Recovery without inventing new actions.

**Trade-off:** The detailed legacy readout remains at the bottom for mechanical depth and regression compatibility, making the card taller. Explicit selection scrolls it into view; automatic enemy focus intentionally does not, so assault controls remain stable at phase start.

## ADR-091: Battle defaults to command priorities, not timing diagnostics

**Decision:** Lead the Battle rail with a live state summary, the existing pause/resume command, commander intervention, and focused-threat inspection. Place deterministic single-step, presentation speed, and the fallback threat selector inside a collapsed **Tactical controls** disclosure. Keep keyboard/controller bindings and command handlers unchanged.

**Reason:** The former flat stack gave debug-like timing tools the same visual weight as the decisions that define the assault. The new order communicates what is happening and what the player can meaningfully do while preserving exact access to expert controls.

**Trade-off:** Manual stepping and speed changes require one extra disclosure click for mouse users. Their shortcuts remain immediate, the disclosure is presentation-only, and First Watch now focuses the visible threat action rather than a hidden fallback selector.

## ADR-092: Playtest observation is explicit, local, and non-authoritative

**Decision:** Add a session-only `LocalPlaytestObserver` that begins disabled, accepts coarse presentation events only after explicit opt-in, and writes JSON only after an explicit local export. Add a graphical nine-screen capture harness with stable filenames and a manifest.

**Reason:** The roadmap requires before/after visual evidence and basic behavior counts, but the game must remain offline-first and must not silently collect or overstate evidence. A small presentation service gives observers useful context without touching `PackKeepState` or replacing the structured P16 human protocol.

**Trade-off:** Observation must be enabled again after every launch and the export is deliberately manual. This produces less data than automatic analytics, but keeps consent and provenance obvious and prevents automated counts from being mistaken for human findings.

## ADR-093: Battle presentation consumes one read-only snapshot

**Decision:** Move Battle rail projection into `BattlePresentationSnapshot`, covering phase/readiness state, time-control labels, commander ability availability, focused-threat identity, and response-preview text. `main.gd` applies the returned fields and retains its existing command handlers.

**Reason:** Battle presentation had become a cluster of direct reads spread across refresh helpers. One explicit snapshot makes the display deterministic, testable, and easier to extract into a dedicated panel without weakening simulation ownership.

**Trade-off:** The snapshot still depends on several established `PackKeepState` read-model methods and produces player-facing strings rather than a fully theme-agnostic schema. This is an incremental boundary, not a broad UI rewrite.

## ADR-094: Presentation diagnostics require an explicit debug launch

**Decision:** Add a top-level `PresentationAuditOverlay` only when the existing `--debug-ui` argument is present. Track named major UI regions, current focus ownership, viewport size, and full-rectangle clipping while ignoring all pointer and keyboard input.

**Reason:** Stable screenshots need a fast way to distinguish intended scrolling from accidental clipping and to verify controller focus without adding persistent debug labels to the player experience.

**Trade-off:** The audit reports geometric clipping, not semantic severity, so deliberately scrollable content can appear in the count. It remains a development aid and is excluded entirely from ordinary launches.

## ADR-095: Back navigation confirms unsaved run abandonment

**Decision:** Route Escape/controller-back through one screen-aware handler. Cancel input rebinding or active placement first, close an open confirmation second, return directly from Settings and War Council, and require an in-game confirmation before resetting changed gameplay state. Derive dirty state by comparing serialized `PackKeepState` with the signature captured after a successful save or load.

**Reason:** The prior Escape binding was only a placement cancel, and leaving a developed defense had no consistent language about unsaved progress. The new flow makes consequences explicit without platform-specific dialogs or a new save format.

**Trade-off:** Serialized comparison is broader than a hand-maintained dirty flag and may treat any authoritative difference as unsaved. That conservative behavior is intentional; presentation changes never trigger it, and the existing save file is never deleted by discard navigation.

## ADR-096: Tagged prereleases are self-contained playtest cohorts

**Decision:** Regenerate the P16 executable provenance manifest, observer brief, and four unfilled matrix templates inside the tag-triggered Windows release workflow, then publish them beside the executable, packaged smoke report, release manifest, and exact source archive.

**Reason:** The ordinary CI artifact already contained the complete observer kit, but the durable GitHub prerelease exposed only the executable and generic manifests. Separating the instructions and templates from the tagged binary made it too easy to test an unproven combination or lose the cohort when short-lived CI artifacts expired.

**Trade-off:** Tagged releases contain several small JSON assets rather than one minimal download. They remain intentionally marked pre-alpha, every template remains invalid human evidence until completed by an observer, and automation still cannot set `release_ready` or approve distribution.

## ADR-097: Responsive composition follows effective width

**Decision:** Fit windowed launch sizes inside the active screen usable rectangle and center them. Derive gameplay layout breakpoints from physical window width divided by the selected UI scale. Keep 1600×900 at 100% in the authored two-column composition, stack the main surface above the command rail when effective width is constrained, stack choice cards at the compact threshold, and hide only decorative phase navigation at large text while retaining Settings. Put the War Council commit action before its potentially tall cards and keep Preparation focused on its strategic brief and assault action.

**Reason:** The fixed 1600×900 launch and logical-width-only breakpoint allowed the right rail to sit outside a 1280×720 display and caused enlarged text to behave like extra content rather than reduced usable space. Effective width captures both constraints, while a stable single-column fallback keeps every required action reachable without changing the game flow.

**Trade-off:** Narrow and 150%+ layouts require vertical scrolling, and War Council may scroll enough to expose the focused commit action rather than preserving its decorative header. The layout remains presentation-only; window size, focus, stacking, and capture settings never enter `PackKeepState` or affect deterministic outcomes.

## ADR-098: Authored fortress texture remains subordinate to tactical geometry

**Decision:** Reuse `assets/greywatch_background.png` as two restrained material source regions—stone work yard for the ground floor and timber wall walk for the upper floor—beneath the existing deterministic board renderer. Keep room rectangles, walls, connections, pieces, threats, health bars, placement guides, target lines, and focus layers procedural and authoritative. Project the selected room or defender into an on-board outline and one-line plate containing identity, condition, purpose, and next action.

**Reason:** Greywatch already had a strong authored reference asset, but the playable board reduced it to a menu banner and presented the fortress as mostly flat colored rectangles. Sampling the existing art as material preserves provenance and visual identity while avoiding a replacement image whose painted geometry could disagree with gameplay. The selection plate keeps the current decision tied to the fort instead of forcing the player to reconstruct it from the command rail.

**Trade-off:** The material is intentionally subtle and does not make every painted architectural detail interactive. High contrast reduces its opacity further. Ash Ford keeps its existing river renderer until a dedicated authored source exists, and the hybrid renderer remains a vertical-slice treatment rather than a final production tileset.

## ADR-099: Major screens consume deterministic read-only snapshots

**Decision:** Give War Council, Preparation, Battle, Recovery, and terminal Results a stateless presentation snapshot builder. Each builder reads authoritative state and explicit presentation context, then returns plain dictionaries and player-facing strings. `main.gd` retains signals, commands, focus, visibility, navigation, and scrolling; panels remain render-only.

**Reason:** Screen composition and wording had accumulated as direct state reads inside the main UI controller. The completed snapshot boundary makes each major chapter deterministic, independently testable, and safer to animate or restructure without weakening `PackKeepState` ownership.

**Trade-off:** Some player-facing formatting is duplicated from older helpers, and `main.gd` remains responsible for applying view models to controls. This is intentionally narrower than a scene rewrite: no snapshot is serialized, no command path moves, and no simulation or replay behavior changes.

## ADR-100: Combat ticks play back as an eight-beat presentation sentence

**Decision:** Derive Forecast, Approach, Target Lock, and Wind-up from the current authoritative battle state, then stage each already-resolved tick as Defender Response, Hostile Impact, Consequence, and Settle. Scale the presentation window inversely with battle speed and replace travel/recoil with a short static consequence under reduced motion.

**Reason:** Real-time movement, target lines, projectiles, melee lunges, health trails, and damage labels existed, but simultaneous playback made cause and effect difficult to parse. A compact board badge and ordered effect windows make the same deterministic exchange legible without adding player commands or delaying simulation.

**Trade-off:** The board presents a short visual replay immediately after an atomic tick, so the label describes presentation order rather than a second simulation phase. At high speed the window is intentionally compressed; at reduced motion it becomes static. No beat state is serialized or included in replay identity.

## ADR-101: Recovery names sacrifice; Results leads with cause

**Decision:** Extend the Recovery snapshot with a concrete remaining-action sacrifice and render it beside the first priority and trade-off. Extend the terminal Results snapshot with a concise decisive-pattern summary and place that causal section before the detailed assault timeline.

**Reason:** Recovery already exposed exact actions, while Results already contained complete evidence, but their highest-value questions were not visually first. Recovery should make the constrained choice explicit; Results should explain the outcome before asking the player to parse chronology.

**Trade-off:** The recommendation remains advisory and may not match every player strategy. The complete action cards and timeline remain available immediately below, and neither summary selects an action, changes a report, or enters persistence.

## ADR-102: Standard Cutters make assignments a visible liability

**Decision:** Add one K6 enemy family, the Standard Cutter, whose deterministic unit-hunter targeting prefers any living assigned specialist before the lowest-condition precision, support, or control unit. Teach it in The Cut Standard with Crossbow Watch precision interception and Fallback Convoy mobile reserve as separate viable answers.

**Reason:** Assignments previously offered benefits without an enemy that directly tested their exposure. This slice turns the command anchor into a readable risk while preserving the established rule that ordinary attackers clear defenders and only explicit demolition specialists target rooms.

**Trade-off:** Assigned-first targeting adds one optional enemy data field and a narrow targeting branch. The Cutter does not introduce a stun, aura, or new persistent status; its recovery consequence remains ordinary defender damage and the existing two-action repair trade-off.

## ADR-103: Replay mastery summarizes existing authority

**Decision:** Preview the already-selected deterministic scenario variation in War Council, then derive a terminal mastery summary from that variation, placed or opened defense families, authored doctrine counter families, recovery history, and opened packs. When a doctrine remains uncovered, point the replay experiment at its first declared counter family.

**Reason:** Variation, pack composition, and recovery investment already shape a run, but they were separated across setup, combat, and chronology. One read-only comparison makes replay intent concrete without adding rewards, rarity, permanent power, or another game-state subsystem.

**Trade-off:** Doctrine fit is a declared-family comparison, not a claim that the build was optimal or that every placed piece contributed. The complete causal report remains available, and the summary never changes pack ownership, combat, persistence, or replay identity.

## ADR-104: Private-alpha readiness is an enforceable non-release gate

**Decision:** Add one version-bound K8 manifest covering ten automated or documented readiness areas, conservative simulation/UI budgets, packaged lifecycle requirements, known limitations, and the exact seven human gates that remain pending. CI and tagged release workflows validate it, but all release/public-alpha/storefront flags stay false.

**Reason:** The underlying hardening existed across many tests and documents, making it difficult to tell whether the roadmap was complete or whether a future change silently weakened a required area. A single gate makes the evidence auditable without treating automation as human approval.

**Trade-off:** The performance test proves bounded headless workloads, not universal frame pacing, and packaged automation cannot replace physical controllers, broad Windows GPU review, listening tests, forced-close observation, signing, or storefront checks. Those limitations are explicit and remain outside the automated completion claim.

## ADR-105: Forced-close recovery crosses a real process boundary

**Decision:** Extend packaged smoke to flush valid run/settings backups, strand malformed primaries, publish a readiness sentinel, and wait. The external Python runner kills that Windows process, relaunches the same relocated executable and profile, requires backup restoration, and rewrites valid current-schema primaries.

**Reason:** In-process malformed-file tests and clean shutdown do not prove that recovery survives an abrupt executable termination. Coordinating the kill outside Godot tests the persistence boundary while keeping the fixture deterministic and auditable.

**Trade-off:** The fixture deliberately chooses the interrupted-file shape and termination moment. It does not emulate every antivirus, filesystem, power-loss, or physical-device condition, so the broader human forced-close checklist remains pending.

## ADR-106: The Quartermaster prices and restores reserves through commander profiles

**Decision:** Add the Quartermaster as the first P51 commander lens. Their authored passive profile discounts only the first pack opened in each Preparation and increases the first surviving Supply Cache payout. Their authored Resupply profile restores bounded health and ammunition to living defenders once per assault. `PackKeepState` remains the sole authority for cost, recovery, mutation, command-point spending, and save state.

**Reason:** The design framework already identifies reserve and repair economics as the next distinct commander question. Existing pack-opening, Supply Cache, finite-ammunition, health, recovery, and commander-ability rules can express that question without adding another progression track or combat exception.

**Trade-off:** The Quartermaster deliberately has a weaker immediate reserve and gains value over multiple decisions, so very short scenarios may make the lens feel less forgiving. The first P51 slice therefore extends deterministic coverage before adding any new keep, pack, or enemy family, and the existing P16 human cohort remains scoped to its original two commanders until a new cohort is scheduled.

## ADR-107: Twinwatch makes two staffed posts a keep-owned spatial rule

**Decision:** Add Twinwatch Bastion with the `paired_bastions` spatial rule. The rule becomes active only while both authored anchor rooms have an adjacent living combat defender, and it reuses the established keep-level one-point room-damage reduction boundary.

**Reason:** P51 requires a third defensive identity whose layout question is not another compact core or empty lane. Two separated staffed anchors create a visible split-defense problem while preserving stable room IDs, deterministic targeting, existing placement legality, and the current damage pipeline.

**Trade-off:** The benefit applies to all room damage while both posts are staffed rather than simulating per-route communication. That bounded abstraction stays readable on the compact board and turns off immediately when either post is lost; route-specific logistics remain out of scope.

## ADR-108: Breakthrough momentum is fixed when an assault starts

**Decision:** Add the Road Wardens teaching pack and the Outrider unit-hunter family. An Outrider normally contacts on its authored early tick; at wave creation, a living Stake Line adjacent to one of the enemy's authored route rooms delays that contact by exactly one tick. The resulting effective arrival and `momentum_delayed` state are stored on the enemy instance, inspected and saved like existing signal timing.

**Reason:** P51 needs a new isolated question that is neither armor, signal redundancy, static protection, nor assigned-specialist hunting. A one-tick preparation check creates a legible tempo choice: buy space for delay plus modest repeated damage, or concentrate enough precision/mobile response to stop the charge on its original timing.

**Trade-off:** The Stake Line checks authored target-room adjacency rather than simulating a moving trap collision, and it does not update after the wave begins. This keeps timing deterministic and understandable, avoids mid-wave placement exceptions, and leaves freeform movement, stun stacking, and pathfinding outside the vertical slice.

## ADR-109: Concealment gates attack styles, not target existence

**Decision:** Add Lantern Watch and the Gloam Knife family. At wave creation, a living Lantern Post adjacent to one of the enemy's authored route rooms records that concealed threats are revealed. When unrevealed, the enemy remains targetable but its data-driven concealment profile blocks ranged defender damage; melee response remains unchanged. The resulting `concealment_revealed` state is inspected and saved with the enemy instance.

**Reason:** P51 needs a second isolated question distinct from armor, timing, static protection, and assignment exposure. Making the threat targetable but invalid for one attack style keeps the rule visible in response previews and gives the player a clear choice between spending upper-wall space on route light or accepting close-contact risk.

**Trade-off:** Reveal is fixed at wave start and checks authored room adjacency rather than dynamic sight cones or fog of war. This preserves deterministic replays and avoids accuracy rolls, stealth movement, or mid-wave detection state while still creating a new spatial doctrine.

## ADR-110: Combined challenges compose proven rules before adding systems

**Decision:** Complete P51 with The Twilight Road, a three-phase scenario that presents Outrider momentum alone, Gloam Knife concealment alone, and both together in the final phase. Preserve two full-run plans: Road Wardens plus Lantern Watch and Crossbow Watch plus Runner Network.

**Reason:** Each new question now has an isolated teaching scenario and deterministic alternatives. Combining them tests whether the player can maintain two forms of readiness without hiding a new rule inside the escalation.

**Trade-off:** The scenario adds one doctrine label and authored composition but no new enemy, pack, state field, reward, or recovery mechanic. Broader replay variation remains deferred to P52 so this milestone can prove composition quality cleanly.

## ADR-111: Twilight recovery prepares one route for one assault

**Decision:** After The Twilight Road's second phase, require one authored recovery choice that spends one action to prepare either the fast road or the unlit stair. Store the selection as a one-shot event flag, apply it while constructing every matching enemy in the final wave, then mark it spent while preserving the ordinary per-enemy momentum and concealment fields.

**Reason:** P52 needs replay variation that changes a concrete build and recovery decision without permanent power or hidden randomness. A player can now pair Road Wardens with Crossbow Watch and use lamp oil, or pair Lantern Watch with Runner Network and use road stakes, while the earlier complete plans remain valid.

**Trade-off:** A fully prepared Road Wardens plus Lantern Watch layout can make either event effect redundant, though the action cost remains real. This is acceptable as a deliberate over-preparation option; terminal mastery should make the redundancy legible in the next P52 slice rather than adding a stronger stacking bonus.

## ADR-112: Route-choice mastery is derived from event history

**Decision:** Derive an optional Twilight recovery-branch summary from the persisted event-history choice and opened pack names. Terminal Results names the selected preparation, forgone route, complementary/redundant/adaptive fit, and opposite-branch replay experiment inside the existing mastery composition.

**Reason:** The recovery choice changes combat, but a terminal player needs the game to connect that action to the build that covered the other route. Reusing event history makes the causal link durable and replayable without another campaign flag or reward system.

**Trade-off:** Build-fit language compares authored pack identities, not every individual placement or attack contribution. It therefore describes the strategic plan rather than claiming optimal execution; the detailed timeline and damage report remain available below it.

## ADR-113: Seeded Twilight pressure changes disclosed composition

**Decision:** Let each stable The Twilight Road variation author the exact final-wave enemy list and a short preparation focus. Standard Bell stays balanced, Fading Light becomes Gloam-heavy, and Long Twilight becomes Outrider-heavy. War Council and Results derive the same player-facing summary, while wave creation rederives the roster from the persisted variation ID.

**Reason:** Earlier variation changed resources and room pressure but did not materially change what the player prepared for. A disclosed 2/2, 1/3, or 3/1 composition makes the seed alter the visible route emphasis while preserving the existing packs, recovery branches, deterministic combat, and two viable mixed answers.

**Trade-off:** The variation changes only the final authored phase and remains bounded to four existing enemies. It does not add hidden stats, procedural wave generation, stronger event bonuses, or a forced counter; the preparation focus is advisory and the exact roster remains the authoritative evidence.

## ADR-114: Core actors use original small-scale vector silhouettes

**Decision:** Replace Tiny Battle tiles for all active defender roles and the Raider, Sapper, Climber, and Siege Beast with original text-free SVG silhouettes designed on a 32×32 view box. Keep the existing role card, enemy shape, health, focus, target, cadence, and status grammar around each asset. Extended enemy families retain the licensed temporary fallback until their own bounded pass.

**Reason:** The temporary tiles proved that actor imagery helps, but their toy-like style does not belong to Greywatch and larger inventory illustrations collapse at the 13–20px board scale. Purpose-built silhouettes can use fewer, stronger motifs and remain replaceable through the existing visual registry.

**Trade-off:** This is a deliberately compact role language rather than animated character art. Several defender pieces share a role silhouette, and six extended enemies remain temporary; names and procedural shapes continue to provide redundant identification. Texture lookup and drawing stay presentation-only and cannot change simulation state.

## ADR-115: Every current enemy owns a board-scale silhouette

**Decision:** Extend the original 32×32 actor set to Shield Guard, Ash Slinger, Shieldbreaker, Standard Cutter, Outrider, and Gloam Knife. Map all ten current enemy IDs directly to unique authored assets and use the procedural profile alone for unknown future IDs.

**Reason:** The P62 core set established a coherent Greywatch language, but later scenarios still crossed back into visibly borrowed art. Completing the finite current roster removes that inconsistency and lets armor, smoke, protection breaking, command hunting, momentum, and concealment begin with recognizable visual verbs.

**Trade-off:** The silhouettes remain static role marks rather than animation sheets, and some meaning still depends on the existing adjacent labels and overlays. Tiny Battle stays in the repository for provenance and historical evidence, but no current actor profile references it.

## ADR-116: Greywatch rooms use original functional silhouettes

**Decision:** Replace all seven active Tiny Dungeon room props with distinct original text-free SVG silhouettes designed on a 32×32 view box. Preserve the existing low-opacity upper-right placement and keep the inner yard, outer wall, and other keeps unaccented.

**Reason:** The temporary props established that a quiet functional cue improves room recognition, but their borrowed visual language remained visibly disconnected from the authored fortress and actor set. A bounded room-specific vocabulary removes that inconsistency without increasing board density.

**Trade-off:** These silhouettes communicate room family rather than detailed interior furnishing, and only Greywatch receives them in this pass. Labels remain the redundant accessible identifier, while other keeps keep their distinct surfaces and fitted labels until their own authored accent sets are justified.

## ADR-117: Combat consequence uses one authored effect vocabulary

**Decision:** Replace the five active combat, two room-state, and one repair Particle Pack textures with eight original text-free SVG marks designed on a 48×48 view box. Preserve the existing event mapping, tint, opacity, timing, reduced-motion behavior, texture cache, and procedural fallback.

**Reason:** The temporary set proved the effect density and cadence, but its mixed sprite language no longer matches the authored actors, rooms, and fortress. A compact directional vocabulary closes that visual inconsistency while leaving exact damage and targets to the established tactical overlays.

**Trade-off:** These are static marks rather than animation sheets or particle emitters. Variation comes from existing timing, scale, tint, projectile, slash, recoil, ring, and damage-number layers; a future animation pass can replace the same registry paths without changing simulation authority.

## ADR-118: Early Access progress is an explicit non-release gate

**Decision:** Record the approved breadth floor, exact current content inventory, ordered PTK-EA milestone states, and PTK-EA-1 evidence in `content/early_access_progress.json`. Validate that ledger in local verification and CI, and keep `early_access_ready` false until later milestones meet their own acceptance contracts.

**Reason:** The Early Access strategy adds a multi-release breadth plan whose prose can drift from runtime content. A small machine-readable gate makes Greywatch's completed anchor auditable and prevents existing keeps or partial systems from being misrepresented as the full commercial floor.

**Trade-off:** The gate proves evidence presence, catalog counts, and milestone honesty; it does not prove enjoyment or replace the linked gameplay tests and visual review. Future content slices must update both runtime data and the inventory ledger, adding modest release bookkeeping in exchange for explicit scope control.

## ADR-119: Early Access breadth composes bounded existing rules

**Decision:** Complete PTK-EA-2 through PTK-EA-5 with five additional scenarios, four two-piece packs, two enemy families, four authored events, and one commander lens. Rehome five existing specialist scenarios to the keeps whose spatial questions they now teach, keeping the active scenario inventory at twenty rather than exceeding the approved 20–24 range.

**Reason:** The existing catalog already contains several late Greywatch encounters whose road, signal, command-anchor, and upper-route questions are stronger demonstrations of Ash Ford or Twinwatch. Reusing those complete encounters preserves their mechanics while letting new content fill genuinely missing questions instead of inflating the catalog.

**Trade-off:** Historical scenario names remain stable while their keep context changes. Regression fixtures must therefore validate the new keep-owned geometry and placements rather than assuming every pre-Early-Access scenario belongs to Greywatch.

## ADR-120: The Marshal makes assignments a commander resource

**Decision:** Add the Marshal with an `assigned_command` passive that grants one response damage to assigned combat defenders and a once-per-assault `relief_order` that restores bounded health only to living, damaged assigned defenders.

**Reason:** The fourth commander needs a distinct strategic verb. Assignments already expose commitment, specialist value, and Standard Cutter risk; strengthening and rescuing those posts creates a readable command-network lens without inventing movement, aura simulation, or another resource.

**Trade-off:** The Marshal gains little before the first recovery assignment and can lose concentrated value to assignment hunters. This delayed payoff is intentional and distinct from the Quartermaster's broad reserve economy.

## ADR-121: Harriers select depleted specialists deterministically

**Decision:** Extend unit-hunter preference with `lowest_ammo_ratio`, using current ammunition divided by authored capacity, then condition and stable instance ID. Units without ammunition are ranked after ammunition users.

**Reason:** The Harrier should pressure an exhausted firing network rather than duplicate weakest-unit or assigned-unit hunting. Ammunition is already authoritative, visible, and saved, so the target rule creates new counterplay without adding hidden state.

**Trade-off:** The preference reads current ammunition at contact and may change after defender fire in the same tick. That ordering is deterministic and teaches the player that an emptied specialist becomes exposed.

## ADR-122: Automated Early Access readiness does not approve distribution

**Decision:** When PTK-EA-1 through PTK-EA-6 and every breadth floor pass, mark the machine ledger `candidate` and `early_access_ready: true` while retaining `owner_approval_required_for_distribution: true` and all P16 human observations as pending.

**Reason:** Agents can complete deterministic gameplay, accessibility, persistence, performance, packaging, and evidence requirements. They cannot truthfully perform human comprehension sessions or authorize commercial distribution.

**Trade-off:** The repository can become an automated Early Access candidate while still being explicitly blocked from public/storefront distribution until the owner approves it.
