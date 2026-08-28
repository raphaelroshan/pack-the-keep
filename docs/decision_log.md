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
