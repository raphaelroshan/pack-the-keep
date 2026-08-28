# Pack the Keep — Internal Test Release

**Current build identity:** `0.15.1-regional-consequence` — P15 connects completed defenses to one bounded Low Mill consequence; P12 human approval remains pending

## Purpose

This package is an internal pre-alpha test release, not a commercial demo or storefront build. Its purpose is to test whether Greywatch and Ash Ford support distinct strategic lenses and whether the battle communicates decisions clearly: choose the Castellan or Warden, select one of nine authored scenarios, preview and reserve a limited pack offer, place units directly on either floor with a footprint preview, inspect rooms/pieces/enemies, read an escalating forecast, pause or run the wave at three presentation speeds, advance manually, use Lockdown or Rally, inspect health, armor, signal state, protection, and combat metrics, and recover after pressure.

## v0.11.0 Crossbow Watch additions

P11 begins content breadth with one isolated teaching pair. Crossbow Watch adds an upper-wall Crossbow Patrol whose `armor_piercing` tag ignores authored armor and a non-attacking Watch Banner that grants one non-stacking damage to a nearby ranged defender on the same floor. Shield Guard introduces visible armor 2 under the Shielded Advance doctrine. Red Banner Road isolates that interaction before combining armor with Raiders, Sappers, and a Climber over three waves.

The visual treatment uses violet procedural defender glyphs and a red Shield Guard marker with a shield arc and `ARMOR 2` label. Supplied portrait references informed palette and silhouette only; no reference image or new generated bitmap is included.

## v0.11.1 Bell Guard additions

Bell Guard reuses Signal Beacon and adds Bellkeepers as a non-attacking support unit. A living same-floor link within four cells preserves authored forecast detail and contact timing against the Ash Slinger. Without the link, Smoke and Signal obscures the likely target and advances Ash Slinger contact from step three to step two. Ash at the Bell isolates that interaction before combining smoke with a Climber, Sapper, and Raider.

The visual treatment uses gold bell/relay glyphs, a gray smoke marker, `SMOKE` board text, and explicit `DISRUPTED` or `RELAYED` labels. The mechanic never changes accessibility auto-pause preferences.

## v0.11.2 Shieldwall additions

Shield Wardens provide one non-stacking point of protection to an adjacent piece, while Emergency Shutters reduce ordinary damage to an adjacent room by two. Shieldbreaker targets the living frontline or fortification with the highest maximum health and explicitly ignores adjacent protection and Breakaway Barricades. The Splintered Gate isolates this limit before combining the breaker with gate, armor, and sabotage pressure.

## v0.11.3 Three Bells at Dusk additions

Three Bells at Dusk combines Shield Guards, Ash Slingers, and Shieldbreakers over three waves without adding a scenario-only combat rule. Deterministic coverage exercises Crossbow Watch + Bell Guard and Shieldwall + Bell Guard for both commanders, preserving the two-pack preparation limit and verifying that multiple P11 status labels remain readable together.

## v0.11.4 Challenge Ledger additions

The Campaign Ledger now selects one authored modifier or none. The existing Roadside Intelligence trade-off is unchanged. Hardened Vanguard adds two current and maximum health when each enemy wave instance is created, grants no reward, and persists naturally through active-wave saves. Completing The Relief Road unlocks both choices.

## v0.12.0 Packaged smoke additions

Pull-request and tagged-release Windows exports now launch under an isolated profile with unreachable network proxies. The artifact runs the real main scene, loads the runtime catalog, reaches deterministic battle step one, writes and validates run/settings files beneath that profile, frees the scene, and emits a structured smoke report before returning success.

## v0.12.1 Save recovery additions

Loading validates the primary save in a fresh keep-state candidate and falls back to the backup for missing, malformed, future, or otherwise invalid primary data. If neither candidate is valid, the active run remains unchanged. Legacy migration and backup recovery are named explicitly in the UI event feed.

## v0.12.2 Packaged input and scaling additions

The exported Windows smoke now verifies controller navigation defaults, all gameplay controller paths, conflict-resolving remap of battle pause, 125% stacked layout, and schema-4 persistence of both scale and bindings.

## v0.12.3 Packaged pause and close additions

The Windows artifact now proves battle begins paused, paused presentation cannot advance simulation, the persisted controller binding toggles pause/resume, a manual step advances exactly once, and the main scene tears down before a zero process exit.

## v0.12.4 Clean reinstall additions

CI copies the embedded Windows executable to a fresh install directory and launches that relocated copy against the same isolated profile. The reinstalled build must restore active battle step one, 125% scale, and the remapped pause binding; the uploaded smoke artifact records both phases.

## v0.12.5 Alpha readiness audit

The repository now carries a versioned checklist for all eleven P12 hardening requirements. Source CI verifies unique implemented entries and durable evidence paths; Windows packaging validates the combined lifecycle report. Passing remains candidate evidence, not automatic release approval.

## v0.12.6 Persistence recovery

Presentation settings now use the same validated primary/backup candidate discipline as run saves. A malformed or missing primary can recover the last valid backup, a valid primary outranks a stranded temporary file, and a temporary file alone restores documented defaults rather than being promoted.

## v0.12.7 Alpha scenario matrix

Local headless verification now runs a documented viable baseline for every combination of nine authored scenarios, both commanders, and three seeds. Each of the 54 cases runs twice, producing 108 simulations that must serialize identically, resolve all three waves without collapse, close final recovery and event state, and retain the canonical replay key. This is deterministic viability evidence only; human playtest and presentation approval remain pending.

## v0.12.8 Scenario resume matrix

The second execution of every alpha scenario case now crosses a save/load boundary in a fresh `KeepState`. Seeds distribute checkpoints across wave-one setup, first recovery before event resolution, and wave-two setup. Each checkpoint must round-trip byte-for-byte, and its resumed terminal state must match the uninterrupted run exactly.

## v0.12.9 Save integrity validation

Run-save loading now preflights scalar types, nested piece/room/enemy/history shapes, catalog IDs, metrics, and assignment references before assigning any candidate state. Nested primary corruption is rejected cleanly and can fall back to a valid backup without script errors or partial mutation; JSON-decoded position data and legacy schema defaults remain supported.

## v0.13.0 Workshop recovery event

Gatehouse Lock now opens **The Workshop Can Wait** after wave two when sabotage leaves the Workshop at 70 condition or lower and Feint and Flank is next. The player may spend eight materials and one recovery action to repair the Workshop, or commit a valid placed Repair Station for one action. Both choices reuse the existing authoritative recovery commands, block ordinary recovery until resolved, persist through save/load, and appear in the existing Results event history.

## v0.13.1 Event Ledger

The existing Campaign Ledger now includes the five most recent authored-event consequences in newest-first order plus stable, explicit run flags. Results uses the same bounded read model, including an omission count when older entries exist. Reading either surface, refreshing it, or changing presentation-only contrast settings leaves serialized keep state unchanged.

## v0.13.2 The Wrong Wall chain

The Wrong Wall now carries a preparation warning, a wave-one Workshop recovery decision, and a terminal consequence report. Players may explicitly decline the warning, preserve scarce resources when Workshop repair is unavailable, or spend the normal eight materials and one recovery action to repair it. The conclusion event can open after normal completion or early collapse, and an active recovery choice round-trips through save/load.

## v0.13.3 Mara's Second Door

Repairing the Workshop or trusting its Repair Station now records one of two visible Mara Venn arc flags. At Gatehouse Lock's conclusion, Mara proposes a second service door only after one of those choices; Castellan and Warden receive distinct compact-structure and response-lane framing. Opening or refusing the route records the third explicit flag, with no hidden relationship score or combat bonus.

## v0.13.4 Old Drain occurrence

Open Yard Net now has one deterministic rare occurrence after wave two. A stable named seed stream selects one of three slots, so identical seeds replay exactly and three consecutive matrix seeds demonstrate both selected and unselected outcomes. Sealing or marking the drain changes only explicit visible flags and preserves every existing defensive counter.

## v0.14.0 Authored event panel extraction

The event card now lives in a dedicated presentation-only component that owns its labels, two-choice rendering, blocked reasons, and stable choice-ID signal. The main controller still obtains event read models from `KeepState` and dispatches every choice back through the authoritative command boundary. Existing UI handles and visual behavior remain compatible.

## v0.14.1 Event authoring safety

Every runtime event now declares a stable deterministic stream, repeat policy, cooldown, and occurrence bound. A machine-readable event schema is checked against both the offline validator and Godot catalog contract. Validation rejects incomplete choice records, negative requirement thresholds, missing or extra typed-effect fields, unknown or cross-scenario follow-ups, follow-up cycles, chain-order drift, and bidirectional manifest drift. Runtime scheduling derives repeat eligibility from authoritative event history and keeps legacy resolved IDs unique for save compatibility.

## v0.14.2 Packaged lifecycle safety

The Windows release-candidate smoke now runs five isolated lifecycle phases: clean install, relocated reinstall, stale-backup precedence, missing profile, and schema-3 upgrade. The runner prepares filesystem fixtures outside the executable, while the packaged Godot adapter verifies profile discovery, primary-over-backup selection, legacy migration and schema-4 rewrite, documented defaults, unchanged authoritative state during presentation-setting operations, offline guards, and clean shutdown.

## v0.15.0 Second defensive identity

Ash Ford Redoubt adds a distinct room graph, river-board presentation, and an explicit clear-causeway rule: leaving the marked ground cells free reduces incoming room damage by one. Ash Ford Crossing teaches Runner Network plus Field Engineers, while its five-material repairs restore only twenty condition, creating a distributed shallow-repair problem distinct from Greywatch's eight-material deep repairs. Keep topology, room labels, recovery profile, and spatial rules are runtime content; save/load derives the active keep from the selected scenario.

## v0.15.1 Low Mill regional consequence

Terminal defenses now produce one authored Low Mill report from the Gate and Supply Room conditions. Miller's Road can remain open, become contested, or close; the council correspondingly commits grain, guards its stores, or turns inward. Open and contested outcomes persist a one-shot three- or one-material contribution to the next selected scenario. Ledger and Results show the same read-only state, while save validation rejects unknown or content-mismatched regional records. No map, shop, stockpile, reputation score, or procedural regional system is introduced.

## v0.8.2 testability additions

Preparation now displays a numbered first-battle guide that recommends the authoritative starter arrangement and explains what to read before starting. The command table includes **Use recommended starter layout**, which places Pike Squad and Narrow Gate at fixed, readable ground-floor origins through the same validated placement API used by direct map placement; it is a recommendation, not a forced opening build. During battle, the left panel presents the latest four authoritative battle-report lines in a newest-first **Combat Event Feed**. Results present a **Causal Result** panel with outcome, breach, morale, defeated enemies, room damage, piece damage, and a plain-language interpretation of what to test next. Guidance changes between preparation, battle, and results while the fort remains visible.

## v0.10.0 Greywatch vertical-slice additions

P4 turns the three-wave combat loop into a replayable vertical slice. Each resolved wave is recorded in a compact scenario scorecard with doctrine, outcome, defeated enemies, room damage, piece damage, and recovery actions used. Results also name the next doctrine and provide an advisory recovery target; the advice never performs authoritative actions for the player.

Preparation now shows a commander-specific layout lens with ground, upper, wall, and courtyard counts. A selected piece may be removed during Preparation without refund so testers can re-place it and compare compact Castellan layouts with open-lane Warden layouts. Removal remains blocked during Battle and recovery.

## v0.9.0 multi-wave additions

The authored scenarios now run as multi-wave sequences. Gatehouse Lock uses three escalating waves: Gate Assault, Distributed Sabotage, and Feint and Flank. Each wave begins paused so the tester can inspect its forecast and composition. When a wave resolves, the existing two-action repair interval remains available. Closing that interval starts the next authored wave automatically and returns to Battle paused for inspection. The final wave enters terminal Results and no fourth wave is started.

The primary playtest action is now screen-aware during recovery: intermediate Results shows **CONTINUE — START WAVE 2/3** or **CONTINUE — START WAVE 3/3**, while terminal Results shows **RESTART QUICK PLAYTEST**.

## v0.8.6 playtest-refinement additions

The quick-playtest flow now has one authoritative primary action beside the fort. In Preparation it reads **RUN QUICK TEST — ONE BATTLE STEP**; in Battle it becomes **ADVANCE ONE STEP — INSPECT** and resolves exactly one additional paused step; in Results it becomes **RESTART QUICK PLAYTEST**. A status line gives the current step, pause state, and keyboard alternatives. The action is disabled in empty Preparation until a defender is available.

## v0.8.5 playtest-polish additions

The playtest now has one prominent primary action directly above the fort rather than requiring a tester to find the test command in the scrolling command table. The label changes with the current screen: **RUN QUICK TEST — ONE BATTLE STEP** in Preparation, **ADVANCE ONE STEP — INSPECT** in Battle, and **RESTART QUICK PLAYTEST** in Results. A compact status line reports the current step, pause state, and keyboard alternatives. Empty Preparation disables the action until at least one defender is present.

## v0.8.4 quick-playtest additions

The Title screen now has a clear **Start Game — Quick Playtest** button. It resets deterministic seed `3307`, selects Gatehouse Lock and Gate Assault, applies the existing recommended Pike Squad and Narrow Gate arrangement through the authoritative placement API, and opens Preparation with the fort already visible. **Open Empty Preparation** remains available for testing the unseeded setup path.

The command table now includes **Quick test: advance one battle step**. It starts the preset invasion and resolves one deterministic step, then leaves Battle paused so a tester can inspect the gate-entry route, enemy marker, target, defender overlays, placement boxes, and event text before using Space or N for more steps. Repeated activation during an active wave is blocked safely.

## v0.8.3 placement-box additions

The procedural fort now exposes a visible placement box in each authoritative room and upper-floor area. Empty boxes use a low-contrast warm `PLACE` outline; occupied boxes retain their slot outline beneath the placed piece. These boxes are aligned to the existing floor grid and are affordances only: the existing `keep_state.gd` footprint, overlap, materials, availability, and assignment validation remains authoritative. The ground courtyard, gate, keep rooms, upper wall walk, North Tower, and Old Chapel remain visible during preparation and combat.

The supplied fort image informed only the high-level composition of a centered stronghold with distinct rooms, wall sections, visible approaches, and side controls. It is not copied into the build and no exact external UI or asset is claimed.

## Included playable loop

The release starts in Greywatch Keep with The Castellan or The Warden, nine packs, and a map-first square-shaped Greywatch fort. The persistent gameplay board shows thick outer walls with crenellation blocks and corner towers, an open courtyard, an open gate, a gate-entry lane, interior keep rooms, and an upper wall walk. Placement and combat overlays are drawn on that board rather than replacing it. The battle is a real-time presentation of a deterministic auto-battle: enemies advance along named routes, resolve behavior targets at arrival, and attack on contact while defenders automatically counter according to role, floor, assignment, cooldown, ammunition, nearby support, armor tags, signal integrity, and adjacent protection. Preparation permits scenario selection, bounded pack opening, pack preview/reserve, direct grid placement, room assignment, and repair. Eight scenarios, including The Relief Road, Red Banner Road, Ash at the Bell, The Splintered Gate, and Three Bells at Dusk, define different objectives, doctrine sequences, wave compositions, and seed-derived bounded variations. Battle presents Raiders, Sappers, Climbers, Siege Beasts, Shield Guards, Ash Slingers, and Shieldbreakers with readable routes, targets, HP, armor, signal/protection state, explicit doctrine labels, room/piece condition bars, target lines, area/armor/smoke/break markers, transient impact/recovery framing, causal damage reports, and map-first focus selection. Clicking an active enemy marker selects it; Tab and Shift+Tab cycle active enemies; `E` focuses the current threat. A focused enemy receives a double outline, `FOCUSED` label, stronger target line, synchronized dropdown selection, and a paused response preview naming threat, target or approach state, counter family, and commander ability state. Results return the player to the repair interval after a Hold or Partial Breach. New invasions begin paused for inspection; Space pauses/resumes, `1`/`2`/`3` select 0.5×/1×/2×, `N` advances one step, `R` arms placement, Escape cancels placement, `M` mutes code-generated feedback tones, and `C` toggles high-contrast cues. Pike Squad is melee and uses no ammunition; Fire Team, Fire Brazier, and Crossbow Patrol are ranged and consume finite rounds; surviving ranged defenders reload when recovery closes.

## Visual kit

| Asset or treatment | Use | Integration |
|---|---|---|
| `assets/greywatch_background.png` | In-game/title banner and Greywatch visual anchor | Loaded by `src/ui/main.gd` |
| `assets/castellan_portrait.png` | Commander identity in the command table | Loaded by `src/ui/main.gd` |
| `assets/pike_squad_icon.png` | Defender identity and asset strip | Loaded by `src/ui/main.gd` |
| `assets/repair_station_icon.png` | Defender identity and pack presentation | Loaded by `src/ui/main.gd` |
| `assets/fire_team_icon.png` | Defender identity and pack presentation | Loaded by `src/ui/main.gd` |
| `assets/scout_post_icon.png` | Defender identity and pack presentation | Loaded by `src/ui/main.gd` |
| `assets/narrow_gate_icon.png` | Starter keep-piece identity | Loaded by `src/ui/main.gd` |
| `assets/raider_icon.png` | Gate-pressure enemy identity and asset strip | Loaded by `src/ui/main.gd` |
| `assets/sapper_icon.png` | Support-sabotage enemy identity and asset strip | Loaded by `src/ui/main.gd` |
| `assets/climber_icon.png` | Upper-floor bypass enemy identity and asset strip | Loaded by `src/ui/main.gd` |
| Warden profile treatment | P1 commander identity and readable rule lens | Shared Castellan portrait tinted in UI; dedicated Warden portrait deferred to the next art-generation window |
| Siege Beast marker | Large-threat identity and area-pressure telegraph | Enlarged procedural map marker; dedicated icon deferred to the next art-generation window |
| Crossbow Watch treatment | P11 precision doctrine identity | Violet Crossbow Patrol and Watch Banner procedural glyphs |
| Shield Guard marker | P11 armored pressure and armor telegraph | Red marker, shield arc, `ARMOR 2` label, and numeric inspector value |
| Bell Guard treatment | P11 redundant-signal identity | Gold Bellkeepers and relay glyphs with explicit signal-state text |
| Ash Slinger marker | P11 smoke-and-signal pressure | Gray smoke circles, `SMOKE` label, and effective contact step |
| Shieldwall treatment | P11 anchored-defense identity | Steel-blue shield and shutter glyphs |
| Shieldbreaker marker | P11 protection-piercing pressure | Dark red hammer treatment, `BREAK` label, and explicit bypass text |
| `assets/greywatch_visual_reference.png` | Art-direction reference for future asset work | Reference only |

The generated images are deliberately treated as first-pass concept-quality production assets. They establish palette, material language, silhouette, and hierarchy; they are not final animation-ready sprites or a complete tileset. P2 and P3 add functional procedural bars, labels, lines, rings, focus outlines, response text, recovery rankings, and transient framing rather than fabricated art assets. The dedicated Warden and Siege Beast image generation request remains deferred after the image-generation quota was reached; this is recorded rather than represented as completed art. P2 tones are generated in code through an optional local audio stream; no authored sound-effect files are claimed. P3 adds only functional combat-readiness labels and the initial run adds ammo counters; the visual-fort slice adds a deterministic procedural square-fort renderer, gate approach, open-courtyard label, wall/keep/courtyard zone labels, and placeholder enemy movement; v0.8.2 adds guidance, a recommended layout command, a newest-first event feed, and a causal result panel; no newly generated map, projectile, or final animation assets are claimed because image generation was unavailable.

## Test checklist

A tester should begin Preparation, compare The Castellan and The Warden profiles, select each authored scenario on fresh runs, read the objective, lesson, and seed variation, and verify that the same seed reproduces the same variation. During Battle, click an active enemy marker and verify that the map focus, dropdown, inspector, response panel, double outline, `FOCUSED` label, target line, and `TARGET` label identify the same stable enemy. Select a pack, read its cost, pieces, doctrine, solves/asks summary, and reserve it without granting its pieces. For Red Banner Road, open Crossbow Watch, place Crossbow Patrol and Watch Banner on the upper wall within three cells, then confirm Shield Guard shows armor 2 and takes four damage from the supported patrol. Move the banner out of range on a fresh run and confirm the patrol deals three. Select an available piece, press `R` or use the arm control, move across both floors, confirm that valid footprints turn green and rejection states are red, then click a valid cell; press Escape to cancel. Click a placed piece and a room to read the inspector. Confirm each wave starts paused, test Space and `1`/`2`/`3`, advance with `N`, use Lockdown or Rally once per wave, and inspect the escalating doctrine, target line, area/armor markers, enemy HP, room condition bars, explicit state words, unit health bars, ammunition counters, ammo-spent metric, transient cue frame, and battle report. Let one invasion run automatically at 0.5×, 1×, and 2× and confirm that only presentation timing changes. Toggle `C` and verify that state remains understandable without relying on color; toggle `M` and verify that the interface remains usable. Test controller navigation and remapped inputs, focus cycling, selection while paused, and response preview opening without changing the serialized keep state. After a Hold or Partial Breach, verify that the recovery panel ranks critical/damaged rooms deterministically and that its advice does not bypass existing repair validation. Save, reset to a new run, load the previous state, and confirm that malformed or future-version saves are rejected without destroying the current run. After a Hold or Partial Breach, use repair-interval actions, verify that surviving ranged defenders reload when the interval closes, and verify that the next wave remains blocked until the interval closes. Repeat the same seed and command sequence and confirm the serialized outcome and combat metrics match.

## v0.8.2 acceptance checks

On a fresh run, enter Preparation and confirm the first-battle guide names the recommended starter layout. Use the recommendation and verify that Pike Squad appears in the courtyard and Narrow Gate is placed near the gate, then modify the arrangement if desired. Start the invasion and confirm the guide explains that the fort remains visible, the event feed shows the deterministic forecast, and a manual step adds newer causal lines above older ones. Let the wave resolve, confirm the screen switches to Results, and verify that the causal panel names outcome, breach, morale, defeated enemies, room damage, piece damage, and recovery advice. Refresh the guide and result panel without commands and confirm the serialized keep state remains unchanged.

## v0.10.0 acceptance checks

Start the quick playtest and confirm the Preparation panel exposes the current commander’s layout lens and a **Remove selected piece** action. Resolve wave 1. In Results, confirm the scorecard contains a W1 row, recovery advice names Distributed Sabotage and support-room coverage, and the primary action remains **CONTINUE — START WAVE 2/3**.

Use one repair or assignment action, then continue. Confirm wave 2 starts paused and the scorecard eventually records the recovery action count for wave 1. Resolve wave 2, continue into wave 3, and confirm the final Results screen contains W1, W2, and W3 rows, total defeated/room/piece damage, recovery actions used, and a deterministic replay key. Compare the Castellan’s compact layout lens with the Warden’s open-lane guidance in a fresh run. Remove and re-place a selected piece only during Preparation.

## v0.9.0 acceptance checks

Start the quick playtest and use the primary action to enter Battle. Advance until wave 1 resolves. Confirm Results identifies inter-wave recovery, the repair interval remains open, and the primary action offers **CONTINUE — START WAVE 2/3**. Use up to two repair or assignment actions if desired, then click Continue and verify wave 2 starts automatically, returns to paused Battle, and uses the Distributed Sabotage doctrine with a Sapper.

Resolve wave 2 and repeat the recovery transition. Confirm **CONTINUE — START WAVE 3/3** starts the Feint and Flank wave with a Climber. Resolve the final wave, confirm Results is terminal, and verify the action becomes **RESTART QUICK PLAYTEST** rather than starting a fourth wave. Confirm manual Start Invasion is still blocked while a wave is active and during recovery.

## v0.8.6 acceptance checks

From the quick-playtest Preparation screen, confirm that the primary action is directly above the fort and reads **RUN QUICK TEST — ONE BATTLE STEP**. Click it and verify Battle opens at Step 1, remains paused, and changes the action to **ADVANCE ONE STEP — INSPECT**. Click that action again and verify the step increments by one without starting real-time motion. Resolve the invasion and confirm the Results state presents **RESTART QUICK PLAYTEST**, which restores the deterministic preset. Open Empty Preparation and confirm the primary action is disabled until a defender is placed.

## v0.8.5 acceptance checks

From a fresh launch, confirm the Title screen remains sparse and presents **Start Game — Quick Playtest** as the main entry. Click it and verify that the single wide primary action appears directly above the fort in Preparation as **RUN QUICK TEST — ONE BATTLE STEP**, with a status line explaining that two starter pieces are placed.

Click the primary action. Verify that Battle opens at Step 1, the action changes to **ADVANCE ONE STEP — INSPECT**, and the status line confirms the battle is paused while naming the N and Space alternatives. Click the action once more and verify that the step increments without starting real-time motion. Resolve the wave and confirm the Results action becomes **RESTART QUICK PLAYTEST**.

## v0.8.4 acceptance checks

From a fresh launch, confirm the Title screen shows **Start Game — Quick Playtest**. Click it and verify Preparation opens with Gatehouse Lock active, Pike Squad and Narrow Gate already placed, and the fort board visible. Confirm that the preset remains editable and that the normal placement, focus, pause, and speed controls remain available.

Click **Quick test: advance one battle step**. Verify the screen changes to Battle, the invasion is active, exactly one deterministic step has advanced, and the battle is still paused. Confirm that the gate-entry route, enemy marker, target information, unit overlays, placement boxes, and event text remain visible. Use N or Space to continue, and verify the existing Results flow still appears after resolution.

## v0.8.3 acceptance checks

On a fresh preparation screen, verify that each visible ground room and upper-floor area has a placement box. Arm Pike Squad, Fire Team, Repair Station, or another available piece and move the cursor across the floor grids; confirm the normal valid/invalid preview still controls placement. Place a piece inside or near a visible box and confirm the box remains readable under the piece. Start a battle and verify the boxes do not replace the gate-entry path, enemy marker, target line, health bars, ammo counters, breach state, focus outline, or causal event text. Select a room or piece and confirm the placement-box layer is presentation-only by comparing serialized state before and after inspection.

## Known boundaries

This release does not include a newly generated pixel-art map asset; it uses the functional procedural pixel-board treatment described in `design/top_down_board_art_direction.md`. It also does not include final sprite animation sheets, an authored soundscape, multiple simultaneous pack cards, a campaign map, projectile physics, ammo resupply buildings, music/voice controls, or direct enemy retargeting. It does include keyboard and controller navigation, keyboard/controller remapping, persistent UI scaling and display choices, map enemy selection, focus cycling, high-contrast cues, reduced motion, a scrollable command panel, code-generated optional feedback tones, functional transient presentation cues, paused response previews, advisory recovery priorities, finite ranged ammunition, recovery reloads, the square-fort map renderer, named placement zones, visible gate-entry movement, and three P11 teaching pairs covering armor, signal disruption, and protection piercing. The repository’s deterministic state and test suite remain the source of truth while presentation assets are iterated. The fallback “place at next slot” command remains available for deterministic smoke tests, but direct map placement, scenario selection, and enemy focus are the intended paths.
