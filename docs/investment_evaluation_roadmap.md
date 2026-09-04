# Pack the Keep — Investment-Evaluation Roadmap

## Purpose

The next milestone is not another isolated commander, pack, or enemy. It is a **full creative vertical** that demonstrates the complete fantasy: choose a commander and keep, pack a coherent defense, read the invasion, watch the defense resolve, make an emergency decision, recover from damage, and understand what changed.

The game should present as an original top-down fortress-defense game inspired by the accessibility and immediacy of compact auto-battlers. Its identity comes from physical room layout, pack doctrine, two-floor defense, readable enemy questions, and deliberate recovery—not from a large card collection or raw unit count.

## Verified baseline

The current main branch contains a playable Early Access candidate with a polished menu → War Council → Preparation → real-time Battle → Recovery → Results loop. It includes four commanders, three keeps, fifteen packs, twenty-nine pieces, twelve enemy types, fourteen doctrines, twenty scenarios, fourteen events, deterministic variation, authored actors, semantic audio, combat VFX, recovery feedback, persistence, input/accessibility support, and packaged lifecycle gates. The automated verification suite passes.

The current investment risk is not lack of systems. It is **whether the breadth is visibly and mechanically differentiated enough to justify continued investment**. Greywatch is the clearest anchor. The next work must prove that another keep and commander create a different spatial question rather than adding content that only changes labels or numbers.

## Definition of the full creative vertical

A reviewer must be able to start a fresh run and complete: title → commander/keep choice → doctrine pack selection → visible placement plan → forecast → live auto-battle → pause/inspection → one emergency intervention → hold, breach, or collapse → recovery choice → terminal Results with causal explanation and replay suggestion.

The vertical must include one visually authored keep, two clearly different commander lenses, at least four packs that produce visibly different layouts, four enemy questions with readable counters, one recovery dilemma, one named scenario, one failure-forward consequence, strong preparation and battle audio, and an authored final debrief. The player must be able to understand what the build is trying to solve before pressing Begin Assault.

## Skeletal Early Access floor

The Early Access candidate should contain three distinct keeps, four commanders, fifteen to eighteen packs, twenty-four to thirty defensive pieces, twelve to fourteen enemy families, twenty to twenty-four scenarios, fourteen to eighteen events, and at least twelve viable commander/keep openings. At least two keeps must alter the preferred placement geometry; at least two commanders must alter the preferred intervention or resource pattern; and every enemy family must pose a distinct defensive question with at least two understandable counters.

Later keeps may reuse the core rendering system, temporary art kit, room-label language, audio buses, and battle grammar. They may not be cosmetic reskins. Each keep must add one spatial rule, one pressure curve, one recovery trade-off, one signature threat or doctrine, and one scenario where the keep’s identity matters.

## Ordered implementation gates

| Gate | Player-facing deliverable | Required evidence |
|---|---|---|
| **PTK-I1 — Creative vertical lock** | Greywatch becomes a complete, visually coherent, tutorial-safe showcase from War Council through Results. | Normal-flow capture, deterministic three-wave run, save/resume at Preparation/Battle/Recovery/Results, and controller/large-text/reduced-motion checks. |
| **PTK-I2 — Second keep** | A second keep changes room connectivity, preferred placement, and recovery priorities. | Keep manifest, two viable seeded plans, isolated teaching scenario, combination scenario, and screenshots at 1280×720 and 1600×900. |
| **PTK-I3 — Commander and pack expression** | A second commander lens and four additional packs create different opening decisions, not stat inflation. | Balance matrix, pack/commander interaction tests, forecast explanation, and replay comparison. |
| **PTK-I4 — Enemy question breadth** | Six to eight additional enemy families or doctrines are introduced through readable counters and staged teaching encounters. | Enemy counter matrix, deterministic scenario fixtures, pause/speed/reduced-motion coverage, and battle evidence. |
| **PTK-I5 — Campaign loop** | A player can complete multiple scenarios, recover, unlock or reserve packs, see consequences, and start a new keep without grind. | Campaign save migration, clean-reset flow, scenario progression test, failure-forward result, and terminal report. |
| **PTK-I6 — Early Access hardening** | The game supports repeatable 30–90 minute defense sessions with reliable saves, settings, package behavior, known limitations, and an honest content boundary. | Full verification, seeded balance matrix, packaged launch/recovery tests, input/scaling checks, and release manifest. |

## Content authoring rule

Every pack, piece, enemy, commander, keep, event, and scenario must state the tactical question it introduces, the physical or resource trade-off it creates, its visible counters, its failure consequence, and the reason it is not interchangeable with existing content. A new enemy that only has more health is not new content. A new keep that only changes colors is not a new keep.

## Combat and feel requirements

Real-time presentation may be dramatic, but the player must be able to pause, inspect, predict, and understand the result. Every meaningful assault should make forecast, approach, target, wind-up, response, impact, consequence, and settle legible. Audio and VFX must reinforce those beats without owning state. Reduced motion must preserve the same information in a shorter form.

Recovery is part of the game, not a failure screen. A hold, breach, or collapse should explain what failed, what remains valuable, and what the player can sacrifice or repair. The terminal Results screen should tell a causal story and suggest a concrete replay experiment.

## What not to build yet

Do not add multiplayer, rarity tiers, monetization, an enormous pack catalogue, procedural narrative, live-service progression, or platform services before PTK-I1 through PTK-I3 pass. Do not add more enemies until existing enemy families create distinct counter decisions. Do not let the game become a build-order puzzle where one commander or pack is objectively correct.

## Agent task contract

Each task must be one player-facing defense question, keep simulation must remain authoritative, presentation must consume read-only state, and the task must include scenario fixtures, deterministic tests, save boundaries, accessibility/input coverage, and a screenshot at the current version. The final report must list changed files, exact commands, player-facing result, evidence paths, known limitations, and exactly one next task.

The active sequence is **PTK-I1 Creative vertical**, **PTK-I2 Second keep**, **PTK-I3 Commander/pack expression**, **PTK-I4 Enemy question breadth**, **PTK-I5 Campaign loop**, and **PTK-I6 Early Access hardening**. Human testing can later calibrate difficulty and comprehension but is not a prerequisite for these implementation gates.

## Decision

The investment target is a compact fortress-defense game with one excellent keep and enough mechanically distinct adjacent content to prove continuation. We prefer three keeps with real spatial identities over a dozen reskinned maps, and a small set of readable enemy questions over a large list of stat variants.


## 2026-09-03 review checkpoint — preparation gate

The current `0.59.0-gpt56-packet-completion` main build passes the full automated suite, including Early Access campaign, campaign UI, playtest readiness, real-time auto-battle, recovery, accessibility, controller, scaling, save-boundary, audio, and packaging checks. The title and War Council now communicate a credible product proposition.

The 1280×720 War Council reaches a genuine Build & Assign decision, but the preparation surface is vertically dense. The primary action remains visible while the selected commander, selected doctrine, forecast, and board context compete for attention and require scrolling. Therefore **PTK-I1 is not complete for investment-evaluation scope**. The next agent must make the fortress and the selected plan simultaneously legible, without removing tactical detail or reducing the simulation to a static presentation.

After PTK-I1, execute PTK-I2: a second keep that changes room connectivity, preferred placement, invasion pressure, repair priority, and recovery trade-offs. Do not count a color swap, larger roster, or stat-only enemy as campaign breadth. The dated evidence is in `docs/latest_review_2026-09-03.md` and `docs/visual_evidence/v0.59.0-gpt56-packet-completion-review-2026-09-03/`.

## 2026-09-03 execution checkpoint — board-first gate complete

Build `0.60.0-board-first-preparation` closes the mandatory preparation finding. At 1280×720, Preparation now uses a phase-specific two-column composition that keeps the current question, visible answer, compact plan/risk, Ready Defense action, complete two-floor fortress, and selected pack in the first viewport. War Council retains its deliberate stacked briefing, while 150% large text retains the full stacked placement rationale.

Fresh Greywatch and Ash Ford captures re-prove PTK-I1 and PTK-I2 at 1280×720, with complete 1600×900 flow sequences preserving intervention, recovery, and causal Results. Runtime rules remain unchanged. See `docs/p72_board_first_preparation_verification.md`.

## 2026-09-03 execution checkpoint — battle-first follow-up complete

Build `0.61.0-battle-first-assault` carries the same board-first hierarchy into active combat. At 1280×720, the complete tactical board and contact timeline remain beside battle state, pause/resume, commander intervention, and focused-threat inspection. Repeated main-column instructions and the duplicate pause action are removed in the normal wide composition; First Watch and large-text layouts retain their explicit primary-action fallbacks.

Fresh Greywatch and Ash Ford captures preserve the complete three-phase flow at both supported review resolutions. Combat rules, targets, timing, damage, save state, and the P16 human-evidence boundary remain unchanged. See `docs/p73_battle_first_assault_verification.md`.

## 2026-09-03 execution checkpoint — board-first recovery complete

Build `0.62.0-board-first-recovery` keeps ordinary inter-wave Recovery beside the damaged fortress at 1280×720. The causal brief selects its highest damaged priority on entry without spending an action, legality-sorted cards place the resulting useful repair first, and duplicate main-column continuation copy is removed. Blocking authored events, tutorial actions, terminal Results, and large-text fallbacks retain their dedicated flows.

Fresh Greywatch and Ash Ford evidence covers the complete three-phase loop at 1280×720 and 1600×900. Recovery costs, repair values, action budgets, assignments, events, and save state remain authoritative and unchanged. See `docs/p74_board_first_recovery_verification.md`.

## 2026-09-04 execution checkpoint — board-first terminal Results complete

Build `0.63.0-board-first-results` closes the remaining 1280×720 phase-flow gap. Terminal Results now keeps the final fortress beside its outcome, causal summary, and dominant replay action instead of placing the debrief below the fold. The debrief compacts safely inside its own rail, while 150% large text retains the established stacked composition.

Fresh Greywatch and Ash Ford evidence covers the complete loop at 1280×720 and 1600×900. Outcomes, phase history, fortress state, replay recommendations, campaign consequences, and save state remain authoritative and unchanged. See `docs/p75_board_first_terminal_results_verification.md`.

## 2026-09-04 execution checkpoint — player-facing language complete

Build `0.64.0-player-facing-language` removes development vocabulary from normal play. Scenario cards now name the actual pressure and defensive demand, combat and tutorial guidance describe observable actions, event titles remain distinct in history, and the pre-alpha title keeps its honest boundary without advertising the test harness.

A dedicated validator protects player-facing data, high-visibility UI phrases, event-title uniqueness, and compact event setup copy. Fresh Greywatch and Ash Ford evidence covers the complete loop at 1280×720 and 1600×900. IDs, costs, effects, target rules, outcomes, saves, and deterministic ordering remain unchanged. See `docs/p76_player_facing_language_verification.md`.


## 2026-09-04 repeat-test checkpoint — PTK-I1 evidence refresh

The current `0.64.0-player-facing-language` main build passes the complete automated suite. The repeat visual run confirms that the board-first and player-facing-language work is visible: the title is authored and legible, War Council presents a real commander/defense choice, and Fortress/Build & Assign shows the two-floor boards, current question, visible answer, open weakness, first plan, accepted risk, and selected Pike Line doctrine.

The investment-quality gate is not yet closed. At 1280×720, the preparation rail remains dense and scroll-dependent even though the main action and board are available. The next agent must execute **PTK-GPT56-1B**: preserve the current board-first composition while making the fortress, tactical question, selected answer, commander/doctrine, forecast, placement plan, and Begin Assault action simultaneously legible; then prove a deterministic three-wave Greywatch run through pause/inspection, one intervention, damage, Recovery, and causal Results. Do not add the second keep until this complete creative vertical is re-proven at 1280×720 and 1600×900.

Evidence is recorded in `docs/latest_review_2026-09-04.md` and `docs/visual_evidence/v0.64.0-player-facing-language-review-2026-09-04/`.

## 2026-09-04 execution checkpoint — PTK-GPT56-1B complete

Build `0.65.0-preparation-first-viewport` closes the repeat-review preparation finding. At 1280×720, the fortress, tactical question, visible answer, accepted weakness, Ready Defense action, commander and pack doctrine, invasion forecast, compact pack answer, and first-plan command now remain visible together without initial page or rail scrolling. The plan transition is explicit: an empty keep offers the existing first-plan command, while a completed opening reads as state rather than a redundant action.

Expanding Advanced restores the full pack question, limitation, spatial demand, and trade-off, while 1600×900 keeps the full card by default. Fresh Greywatch and Ash Ford sequences cover both plan states and the complete three-phase loop; deterministic openings, intervention, damage, Recovery, causal Results, save state, and simulation authority remain unchanged. See `docs/p77_preparation_first_viewport_verification.md`.

## 2026-09-04 execution checkpoint — choice-first War Council complete

Build `0.66.0-choice-first-war-council` closes the next first-viewport hierarchy gap. At 1280×720, the complete commander and defense choice now fits with pairing, seeded pressure, preparation focus, and Enter Keep. Each compact card retains the facts needed to choose—doctrine, intervention, trade-off, keep rule, opening, pressure, objective, and risk—while repeated secondary explanation returns in wider and large-text layouts.

Fresh Greywatch and Ash Ford full-flow captures plus a long-form Twilight Road setup capture verify the composition. Selection, content, combat, save state, controller focus, and all completed roadmap gates remain unchanged. See `docs/p78_war_council_first_viewport_verification.md`.
