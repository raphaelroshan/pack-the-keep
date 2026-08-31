# Pack the Keep — Game-Quality Transformation Plan

**Audience:** GPT coding agents, art/UX agents, test agents, and the human owner
**Current baseline:** `0.42.0-combat-vfx`
**Current status:** P51 controlled content, P52 replayable mastery, P53 alpha-flow hardening, the post-verification K1 responsive pass, P55 temporary actor readability, P56 tactile audio feedback, and P57 combat effect readability are complete; human validation remains pending
**Primary objective:** Turn the existing deterministic fortress-defense systems into a coherent, attractive, immediately understandable game-quality private alpha without rewriting the simulation core.

**Implementation ledger:** P51.1 adds the Quartermaster reserve-economy commander lens. P51.2 adds Twinwatch Bastion's paired-post spatial rule and ridge visual identity. P51.3 adds Road Wardens versus Outriders as a prepared-delay teaching pair. P51.4 adds Lantern Watch versus Gloam Knives as a route-visibility teaching pair. P51.5 adds The Twilight Road, which teaches both questions separately and combines them with two viable plans, expanding the deterministic matrix to 126 cases/252 simulations. P52.1 adds Twilight Crossroads: one recovery action prepares either final-wave road stakes or stair lamps, supporting two additional mixed-pack answers while keeping the choice deterministic and one-shot. P52.2 carries that decision into terminal mastery, naming selected and forgone preparations, build fit, redundancy, and the opposite replay experiment. P52.3 turns all three stable Twilight seed variants into disclosed balanced, Gloam-heavy, or Outrider-heavy final compositions with a concise preparation emphasis repeated at Results. P53 composes the complete player journey under 2560×1440 large text, high contrast, reduced motion, muted semantic cues, controller focus, two file-backed save boundaries, responsive terminal Results, and the existing performance/package/failure-recovery gates. The post-verification K1 follow-up condenses War Council into run frame, explicit pairing, seed pressure, and focus; removes the redundant brief in stacked layouts; and carries the commander/defense/keep relationship plus concise authored question into Preparation. P55 uses licensed Tiny Battle actors beneath tactical overlays. P56 routes semantic cues through a bounded temporary CC0 sample pool with generated-tone fallback. P57 adds restrained Particle Pack response and impact textures beneath procedural marks, health trails, and damage labels. P32 gives terminal Results a dedicated debrief. P33 adds Preparation question/answer/weakness hierarchy. P34 adds board visual grammar. P35 centralizes semantic battle audio. P36 adds tick-zero readiness. P37 gives inter-wave Recovery a compact what-changed/why/next/action-budget/priority hierarchy. P38 replaces raw-first War Council selectors with commander and defense choice cards. P39 gives Preparation a complete pack doctrine offer card. P40 groups Preparation into three stages. P41 gives rooms, defenders, and threats one action-oriented inspection hierarchy without raw IDs. P42 centers Battle on live state, pause/resume, intervention, and threat focus. P43–P49 and K3–K8 complete the presentation, deterministic, packaging, and non-release gates; P54 proves packaged forced-close recovery. The automated roadmap is complete; human validation remains pending.

> **Central diagnosis:** Pack the Keep has enough mechanics for a real game loop. Its largest gap is not feature count. Its largest gap is presentation: the player must feel that they are preparing a fortress, watching a defense, making urgent but comprehensible interventions, recovering from damage, and learning from the result—not operating a debug panel surrounded by a board.

---

## 1. Non-negotiable direction

The next development period must be a **presentation and flow transformation**, not another broad mechanics expansion. The existing core already contains commanders, packs, two-floor placement, multiple scenarios, multi-wave assault, recovery, events, progression, accessibility settings, and packaged validation. Adding more units before improving the player’s understanding of those systems will increase complexity faster than it increases fun.

The intended game experience is:

```text
Choose a defensive identity
→ arrange a compact keep
→ understand the next pressure
→ commit to an assault
→ watch the fortress answer or fail
→ intervene when the causal problem is visible
→ repair under pressure
→ adapt for the next wave
→ finish with a meaningful debrief
→ replay with a changed layout, pack, or doctrine
```

The player should repeatedly think:

> **“I know what the keep is trying to do, I can see what threatens it, and I understand what my next choice will cost.”**

Everything in the roadmap should strengthen that sentence.

### 1.1 What must not happen

Do not solve the gap by adding a campaign map, dozens of new enemies, rarity tiers, procedural narrative, monetization, multiplayer, or a new combat engine. Do not replace the board with menus. Do not hide the simulation behind decorative animations. Do not allow an AI agent to claim that a feature is complete because a test passes while the feature remains unreadable in a normal player view.

The procedural board is currently an honest functional fallback. The visual pass should improve its hierarchy and asset treatment while preserving the existing geometry, overlays, placement coordinates, and authoritative state.

---

## 2. Current baseline and diagnosis

The current build has a strong systems foundation:

| Foundation | Current capability |
|---|---|
| Deterministic simulation | Seeded combat, scenarios, packs, pieces, recovery, events, progression, save/load, and replay-oriented outcomes. |
| Fortress identity | Ground floor, upper wall, rooms, placement boxes, defenders, dependencies, damage states, and a readable square keep silhouette. |
| Battle identity | Real-time assault, pause, manual step, speed controls, focus, target preview, next-hit explanation, counters, commander abilities, and wave sequencing. |
| Content breadth | Thirteen scenarios, ten packs, three commanders, three defensive identities, multiple defenders/enemies, authored events, event history, Mara arc, rare occurrence, and a regional consequence. |
| Onboarding | First Watch tutorial teaches setup, placement, threat inspection, recovery, and commander intervention through real commands. |
| Hardening | Settings, controller support, scaling, reduced motion, high contrast, local persistence, backup recovery, offline checks, packaged smoke, and Windows artifacts. |

The demo nevertheless feels prototype-like in five ways:

1. **The screen hierarchy is not yet game-like.** The command rail is information-rich but visually resembles a debug inspector. The most important action is not always separated from optional detail.
2. **The fortress has geometry but not yet a fully coherent visual language.** Rooms, enemies, defenders, damage, focus, and floor relationships are readable, but the player must interpret many lines, boxes, labels, and compact markers.
3. **The assault lacks enough authored staging.** The simulation is robust, but the player does not always receive a strong pre-contact beat, a readable impact beat, and a clear recovery beat.
4. **Results reuse recovery presentation.** Terminal Results can still look like an open recovery panel. A finished defense needs a dedicated debrief composition.
5. **The game has not yet been validated by enough human sessions.** Automated coverage proves consistency and safety; it does not establish pacing, emotional response, or whether players understand what to do.

---

## 3. Game-quality target

A game-quality private alpha does not require final art or a complete campaign. It does require a coherent first thirty minutes.

A new player should be able to:

1. Start a guided or quick run without wondering which mode is the real game.
2. Understand that packs are defensive doctrines, not ordinary loot cards.
3. Place at least two defenders and understand why their positions matter.
4. Read one forecast and identify the obvious counter.
5. Watch an assault without feeling that the board is idle or that the result is arbitrary.
6. Pause and inspect a threat without losing context.
7. Make one intervention and understand its cost.
8. Recover from wave damage using a real trade-off.
9. See the next wave’s changed demand.
10. Reach a result screen that explains what happened and proposes a credible replay experiment.

The target is not “more content.” The target is **a legible, authored, satisfying slice that makes the player want to run it again with a different keep**.

### 3.1 Quality gates

| Gate | Required evidence |
|---|---|
| First-minute gate | A new player reaches Preparation and understands the primary action without verbal coaching. |
| First-assault gate | The player can name the active threat, target, and at least one counter before the first meaningful impact. |
| Recovery gate | The player understands why a repair, assignment, or reserve choice is being made and what it gives up. |
| Completion gate | The player can explain why the keep held, breached, or collapsed using the result screen. |
| Replay gate | The player is offered a specific alternative layout, pack, commander, or intervention worth trying. |
| Presentation gate | Preparation, Battle, Recovery, and Results each have a distinct visual purpose and hierarchy. |
| Technical gate | The same commands still produce the same authoritative state and all existing tests remain valid. |

---

## 4. Target player flow

The game should have five visual chapters. They can remain screens in the current architecture, but each must have a distinct emotional and operational purpose.

### 4.1 Main Menu — “The keep is waiting”

The title screen should establish place, identity, and the first decision. It should not feel like a test harness.

**Required hierarchy:**

```text
fortress image / silhouette
Pack the Keep
one-sentence premise
New Game
Learn to Play / Continue / Skirmish / Settings
build status in small but honest text
```

The three current pillars—Choose, Build, Hold—are useful, but each should be accompanied by one concrete noun or visual cue. Avoid explaining every mechanic before the player starts.

**Agent tasks:**

- Keep New Game as the primary action.
- Keep Learn to Play visible but secondary.
- Show Continue only when a valid save exists, with clear loaded-run context.
- Retain the honest pre-alpha/build label without letting it dominate the composition.
- Add one short “What you do” sentence: “Arrange defenders, read the assault, and decide what survives the next wave.”
- Test focus order, controller selection, scaling, reduced motion, and save-state variants.

**Acceptance test:** A first-time tester can identify the intended first click in five seconds and can distinguish New Game from Skirmish.

### 4.2 War Council / Setup — “Choose what kind of defense this is”

Setup should introduce commander, scenario, and doctrine as a coherent commitment rather than unrelated dropdowns.

The screen should answer:

- Who is leading this defense?
- What kind of keep problem does the scenario create?
- What defensive identity does the selected pack/doctrine encourage?
- What is fixed for this run and what can still change?

**Required improvements:**

- Replace raw option controls with compact cards or rows showing identity, strength, limitation, and first teaching question.
- Show one small preview of the scenario’s wave arc, not every number.
- Explain commander differences through layout and response, not percentages alone.
- Make confirmation a commitment action: “Enter the keep.”
- Keep advanced details available behind an optional inspector.

**Acceptance test:** A tester can explain the difference between Castellan and Warden and can predict what the first scenario asks them to protect.

### 4.3 Preparation — “Build the answer”

Preparation is the heart of the game. The board must dominate, while the right rail supports rather than competes with it.

**Three-tier information hierarchy:**

| Tier | Content | Presentation |
|---|---|---|
| Immediate | Next threat, current objective, materials, morale, defenders, phase, primary action. | Large, above the fold. |
| Tactical | Selected pack, piece preview, placement validity, room/dependency state, forecast. | Visible beside or beneath the board. |
| Reference | Full pack catalog, detailed costs, historical notes, advanced explanations. | Scrollable secondary panel. |

**Required board changes:**

- Use a consistent ground/upper visual treatment, not merely two framed rectangles.
- Make room boundaries, exterior walls, gate, courtyard, and entry lane visually distinct.
- Use one clear visual grammar for ready, strained, disabled, breached, selected, valid placement, invalid placement, and threatened.
- Use larger, cleaner silhouettes for defenders and enemies; reserve text for the inspector.
- Show a ghosted placement footprint and the affected room/dependency before confirmation.
- Add an “answer quality” summary: “Strong against Gate Assault; weak if pressure spreads to the upper wall.”
- Keep the fort visible while the player scrolls the rail.

**Required preparation loop:**

```text
select pack
→ understand doctrine
→ select defender
→ preview footprint
→ place on board
→ inspect resulting dependency/layout
→ compare against forecast
→ commit assault
```

The player should never have to open three different panels to understand the consequence of one placement.

**Acceptance test:** A tester can place, move, or remove a defender, describe the resulting advantage and weakness, and begin the assault without reading raw debug text.

### 4.4 Battle — “Watch the machine answer”

Battle should be a small readable performance. The player should see threat approach, response, impact, and consequence as distinct beats.

**Battle beat structure:**

```text
forecast pulse
→ enemy enters the approach lane
→ target lock / warning
→ defender response
→ impact or counter
→ damage / status reaction
→ short settling beat
→ next pressure
```

The authoritative simulation remains step-based. Presentation can interpolate or stage the result around those steps without changing the result.

**Required battle feedback:**

- Threats have distinct silhouettes and attack signatures.
- Approach, contact, attack wind-up, impact, blocked, resisted, breach, retreat, and defeat are visually different.
- Target lines or lanes are readable but not visually noisy.
- A selected threat has a clear focus treatment that does not obscure the board.
- A selected defender shows its current assignment and next expected response.
- Impact effects are short, directional, and tied to the affected room or piece.
- The timeline communicates imminent pressure without becoming a second spreadsheet.
- Pause and manual step visibly freeze/advance the same world.
- Speed changes should not remove the player’s chance to understand the first contact.

**Important product decision:** The current normal path starts subsequent waves live after recovery. Before adding more content, decide whether this is the intended identity. Recommended behavior is: first wave starts in a short “ready” beat, subsequent waves start paused or with a two-second warning when a new doctrine or enemy family appears; quick-playtest may remain live only if its label makes that explicit.

**Acceptance test:** A tester can identify what is about to happen, pause before it, state the likely target, and recognize whether the result was a hit, counter, or breach.

### 4.5 Recovery and Results — “Decide what survives”

Recovery should feel like the emotional hinge of the game, not a collection of disabled buttons.

The recovery screen should first show:

```text
what changed
why it matters
what the next wave will test
how many actions remain
recommended priority
```

Then it can show repair room, repair piece, assign specialist, reload, or other options.

Terminal Results should be a separate composition:

```text
FINAL DEFENSE COMPLETE
wave timeline
key causal chain
fortress condition
materials/morale/resource outcome
what was saved or lost
replay experiment
PLAY AGAIN / REVIEW SETUP / RETURN TO MENU
```

Do not leave `RECOVERY ACTIONS` as the dominant title of the final screen. The player has finished; the interface must acknowledge completion before offering analysis.

**Acceptance test:** A tester can tell the difference between inter-wave recovery and final Results at a glance and can identify one specific replay experiment.

---

## 5. Visual transformation plan

The art direction should be **warm, tactile, compact, and legible** rather than photorealistic. The fortress should feel like a hand-built place under pressure: timber, stone, iron, canvas, smoke, ash, lantern light, worn floorboards, patched walls, and practical equipment.

The target is a 2D illustrated top-down strategy presentation with selective pixel or painterly texture. The board should not become a decorative diorama that makes placement difficult.

### 5.1 Visual grammar

Define a small palette and state language before generating or drawing many assets.

| State | Recommended treatment |
|---|---|
| Ready | Warm stone/wood, calm teal or pale green condition bar. |
| Selected | Gold or cream outline with a quiet inner glow. |
| Valid placement | Transparent green/teal footprint and a single confirmation accent. |
| Invalid placement | Red/amber footprint plus a short reason; do not flash the whole board. |
| Strained | Desaturated material, small amber stress marks, reduced but readable condition bar. |
| Disabled | Darkened silhouette, visible broken connector or smoke cue. |
| Breached | Red/ochre interior damage, missing wall/room edge, directional breach marker. |
| Enemy approach | Distinct silhouette plus movement marker; avoid tiny text as the only cue. |
| Enemy focus | White/cream ring or bracket, separate from defender selection. |
| Forecast | Blue/teal signal language, distinct from damage red and selection gold. |

Use shapes and labels in addition to color so the system remains color-safe.

### 5.2 Asset priorities

Do not commission a complete art set first. Build an asset ladder.

**Tier 1 — board identity:**

- Ground-floor wall ring.
- Upper wall walk.
- Gate and gate approach.
- Courtyard and room floors.
- Four corner towers.
- Workshop, Armory, Barracks, Gate, Inner Yard, and Old Chapel treatments.
- Damage overlays for room, wall, and piece states.

**Tier 2 — actor readability:**

- Raider silhouette.
- Sapper silhouette.
- Climber silhouette.
- Siege Beast silhouette.
- Pike Squad, Crossbow Watch, Bell Guard, Shieldwall, Fire Team silhouettes.
- Focus, approach, attack, impact, defeat, and retreat markers.

**Tier 3 — authored presentation:**

- Commander portraits or insignia.
- Pack cards and icons.
- Event illustrations for Workshop Can Wait, Wrong Wall, Mara arc, and Old Drain.
- Settlement badges for Ash Ford, Low Mill, and future nodes.

**Tier 4 — atmosphere:**

- Smoke, dust, sparks, rain, banners, lanterns, ash, and weather overlays.
- Small non-interactive background details that do not compete with the board.

Each asset must have a role, source/provenance note, scale, state variants, and a fallback treatment. AI-generated art must not introduce unreadable text, copied game assets, or inconsistent silhouettes.

### 5.3 Rendering implementation

Create a visual asset registry and keep board geometry data-driven. Avoid scattering texture paths and colors through `src/ui/main.gd`.

Recommended layers:

```text
background atmosphere
→ structural board
→ room/floor surfaces
→ placement zones
→ module/defender actors
→ enemies and routes
→ damage/status overlays
→ focus/selection
→ tactical labels
→ UI panels
```

The board renderer should consume a render snapshot derived from authoritative state. It should not query and mutate simulation fields during drawing.

### 5.4 Animation rules

Use animation to explain state transitions, not to decorate every action.

| Transition | Animation |
|---|---|
| Placement | Ghost footprint snaps to grid; accepted piece settles with a small weighty drop. |
| Enemy arrival | Actor enters along a visible lane with a short approach cue. |
| Target lock | Bracket or line resolves toward the target. |
| Attack wind-up | One readable anticipation beat; never longer than the player’s decision window requires. |
| Impact | Directional flash, shake on affected room only, debris/spark, condition update. |
| Breach | Room edge opens or darkens; warning persists after the flash. |
| Repair | Crew/hammer/lantern cue and visible condition restoration. |
| Wave transition | Short board settle, report card, then next forecast. |

All animations must respect reduced-motion settings and must not delay deterministic command availability unexpectedly.

### 5.5 Audio rules

Audio should make the keep feel inhabited and make combat states audible without becoming a soundtrack-first game.

Minimum audio set:

- Title/menu ambience.
- Preparation room tone: wood, cloth, distant wind, low fire.
- Placement confirm/reject.
- Forecast signal cue.
- Enemy approach cue per family.
- Target lock and attack wind-up.
- Impact by damage type.
- Repair and assignment cue.
- Breach alarm.
- Wave resolved.
- Final held, partial breach, and collapse stingers.
- Settings for feedback audio and master volume.

Use pooled one-shot players or a small audio service. Do not instantiate unbounded audio nodes per tick. Audio must be presentation-only and must not affect simulation timing.

---

## 6. UX architecture plan

The current runtime-built UI has become feature-rich enough that further additions should not continue to accumulate in one large file without boundaries.

### 6.1 Recommended panel ownership

| Component | Responsibility |
|---|---|
| `MainMenuPanel` | New Game, Continue, Learn to Play, Skirmish, Settings, build status. |
| `SetupPanel` | Commander, scenario, doctrine, run preview, commitment. |
| `PreparationPanel` | Packs, piece picker, placement, layout lens, forecast, primary assault. |
| `BattlePanel` | Pause, speed, manual step, focus, ability, threat/target/impact readout. |
| `RecoveryPanel` | Wave outcome, actions, repair, assignment, next-wave preview. |
| `ResultsPanel` | Inter-wave compact summary and terminal debrief. |
| `EventPanel` | Active event card, choices, requirements, effects, history link. |
| `SettingsPanel` | Display, audio, accessibility, controls, save preferences. |
| `KeepBoardView` | Pure board rendering and pointer hit-testing; no rules. |
| `FeedbackPresenter` | Cues, receipts, transient status, semantic events. |

Do not perform a big rewrite. Extract one panel at a time behind the existing handlers and tests. Preserve signal names and command calls while moving code.

### 6.2 State-driven presentation

Define a presentation snapshot with explicit sections:

```text
screen
phase
primary_action
objective
fortress_snapshot
forecast_snapshot
battle_snapshot
recovery_snapshot
event_snapshot
result_snapshot
input_snapshot
```

The UI should render from this snapshot and send commands back to the authoritative state. This makes visual testing and future UI redesign safer.

### 6.3 Primary action contract

Every screen should have one dominant action, one secondary escape/back action, and optional detail controls.

| Screen | Primary action |
|---|---|
| Main Menu | New Game or Continue, depending on save state. |
| Setup | Enter the keep. |
| Preparation | Begin Assault. |
| Battle live | Pause/Inspect. |
| Battle paused | Resume or Step Once, with one clearly selected default. |
| Recovery | Finish Recovery / Release Next Wave, after actions are considered. |
| Final Results | Review Setup / Play Again. |
| Event | Choose one valid option or explicitly decline. |

Agents must not add a new high-emphasis button without checking whether it displaces the screen’s current primary action.

---

## 7. Content and flow plan

The game needs more authored **presentation beats** before it needs many more systems. Existing mechanics should be arranged into a small, memorable first chapter.

### 7.1 First Watch should become the canonical demo

The First Watch tutorial should become the recommended first experience, not merely a test. It should have:

1. A short premise: Greywatch must hold a gate while the road closes.
2. One preparation decision.
3. One placement decision.
4. One forecast explanation.
5. One paused enemy inspection.
6. One real intervention.
7. One damaged defender repair.
8. One changed second wave.
9. One final threat.
10. One celebratory debrief and replay suggestion.

The tutorial should deliberately use the strongest visuals and the clearest composition. If First Watch is compelling, the rest of the demo benefits.

### 7.2 Scenario pacing template

Each scenario should be authored as:

```text
setup promise
→ teaching pressure
→ first consequence
→ recovery decision
→ escalation or twist
→ recovery decision
→ final commitment
→ causal debrief
```

Every wave should answer a different question. Do not make three waves that merely increase enemy health.

### 7.3 Content introduction order

Use this order for new content:

| Step | Content introduction |
|---|---|
| 1 | Show the threat or facility in a low-stakes forecast. |
| 2 | Give one obvious counter and one alternative counter. |
| 3 | Let the player see the counter work. |
| 4 | Present a trade-off where the obvious counter has a cost. |
| 5 | Combine the new question with one existing question. |
| 6 | Add it to a replayable scenario. |
| 7 | Only then use it in random occurrence or campaign consequences. |

### 7.4 Recommended next content

The next content slice should not be a new faction. Implement one of the following, in order:

1. A complete **Recovery Choice** event using the existing Workshop Can Wait infrastructure.
2. One **new pack family** that changes board geometry or assignments, not simply damage.
3. One **new enemy attack style** with a visible wind-up and a specific counter.
4. One **character development beat** that changes a practical preparation or recovery choice.
5. One small scenario that combines an existing teaching pair.

Each slice must include content definition, UI treatment, deterministic state tests, save/load, replay, visual capture, and a human playtest question.

---

## 8. Staged execution roadmap

### Phase 0 — Baseline lock and instrumentation

**Objective:** Make the current demo easy to measure before changing it.

**Tasks:**

- Fast-forward all agents to the current remote tip.
- Record the current title, setup, preparation, wave one, recovery, wave two, wave three, and terminal Results screenshots.
- Add a stable screen-state capture harness.
- Add playtest telemetry that stays local and opt-in: screen duration, first action, pause count, focus usage, primary action path, recovery action choice, and result type. Do not upload automatically.
- Add a debug-only presentation audit mode that can display layout bounds without appearing in the normal game.
- Record the current number of clicks, scrolls, and steps for First Watch and Quick Start.

**Exit criteria:** A before/after comparison can prove whether a UX change improved comprehension or merely changed layout.

### Phase 1 — Flow and hierarchy pass

**Objective:** Make the first run feel like a game rather than a systems dashboard.

**Tasks:**

- Make First Watch the canonical New Game path.
- Simplify Setup into commander, scenario, and commitment cards.
- Add a clear one-sentence objective at every screen.
- Establish one primary action per screen.
- Convert long raw status paragraphs into compact status chips plus expandable detail.
- Give terminal Results its own panel and layout.
- Add a consistent back/escape path and explicit unsaved-progress language.

**Exit criteria:** Five testers can reach Preparation, begin an assault, pause, recover, and identify the terminal replay action without agent coaching.

### Phase 2 — Board visual pass

**Objective:** Make the fortress itself communicate the game.

**Tasks:**

- Build the structural board layers and palette.
- Improve room and floor silhouettes.
- Add placement ghosting and affected-room highlighting.
- Replace compact actor text with readable silhouettes/icons.
- Improve damage state visuals and keep them persistent in Results.
- Ensure ground and upper floor remain legible at 100%, 125%, and the supported minimum window.

**Exit criteria:** A screenshot of Preparation or Battle communicates the two-floor fort and its active pressure without reading the entire command rail.

### Phase 3 — Battle game-feel pass

**Objective:** Make automatic combat feel intentional, consequential, and readable.

**Tasks:**

- Add approach, target-lock, wind-up, impact, breach, repair, and resolution cues.
- Add enemy-specific silhouettes and attack signatures.
- Add defender response cues.
- Add short, non-blocking audio cues.
- Tune camera/board emphasis without losing the full keep.
- Decide and document whether subsequent waves open paused or live.
- Ensure speed controls preserve readable first-contact moments.

**Exit criteria:** New testers can explain what happened in a battle without reading raw logs.

### Phase 4 — Recovery and Results pass

**Objective:** Make recovery the game’s emotional and strategic hinge.

**Tasks:**

- Add a compact top-of-panel “what changed / why / next threat” summary.
- Group repair, assignment, and reserve actions by purpose.
- Clearly distinguish available, unavailable, and already-solved actions.
- Show action budget persistently.
- Build a dedicated final debrief with wave timeline, causal chain, persistent damage, outcome, and replay experiment.
- Preserve the board as evidence of what happened.

**Exit criteria:** Testers can explain what they chose not to repair and why.

### Phase 5 — Content presentation pass

**Objective:** Make existing content feel authored rather than catalogued.

**Tasks:**

- Give each scenario a short premise, promise, and final question.
- Give each commander a visual identity and a one-line doctrine.
- Give each pack a strong icon, silhouette, one-sentence purpose, and one weakness.
- Give each enemy an approach/attack identity.
- Add event art or a strong location treatment for the implemented event chains.
- Use a consistent naming and copy-edit pass.

**Exit criteria:** Players remember at least one scenario, one commander difference, and one enemy behavior after a session.

### Phase 6 — First human-playtest alpha

**Objective:** Replace assumptions with observed player evidence.

**Tasks:**

- Recruit five internal testers with no walkthrough.
- Run First Watch, Quick Start, and one Skirmish.
- Observe without coaching for the first ten minutes.
- Ask testers to predict the next threat and explain the last failure.
- Measure time to first action, abandoned screens, ignored controls, mistaken actions, and replay intent.
- Fix the top three comprehension problems before adding new systems.

**Exit criteria:** The owner approves the build as a meaningful private alpha slice, not merely a technical demo.

### Phase 7 — Controlled content expansion

**Objective:** Add breadth without returning to prototype sprawl.

**Tasks:**

- Add one new recovery event.
- Add one new pack family.
- Add one new enemy attack style.
- Add one specialist character beat.
- Add one authored scenario combining the new questions.
- Re-run the full visual and deterministic matrix.

**Exit criteria:** New content creates new decisions while preserving the original flow and board readability.

### Phase 8 — Private alpha hardening

**Objective:** Make the demo reliable enough for repeated external internal testing.

**Tasks:**

- Clean install and upgrade validation.
- Save migration and backup behavior.
- Controller and scaling at supported resolutions.
- Pause, close, resume, and interrupted-save safety.
- Audio and reduced-motion settings.
- Artifact identity and release notes.
- Test build on a clean Windows machine/profile.
- Document known limitations honestly.

**Exit criteria:** A tester can install, play, close, resume, complete, and replay without developer intervention.

---

## 9. AI agent task protocol

Agents must work in narrow slices. Every prompt should include the player-facing objective, authoritative owner, files allowed to change, non-goals, acceptance criteria, and exact validation.

### 9.1 Prompt template

```text
Task:
Improve [one player-visible flow or feedback problem] in Pack the Keep.

Baseline:
Start from the current remote main and read AGENTS.md, README.md,
design/design_prompt.md, docs/agent_handoff_roadmap.md, and the relevant
visual verification document.

Player question:
What should the player understand or feel after this change?

Authoritative boundary:
Which state/command owns the rule? What must remain presentation-only?

Allowed files:
[List exact files or directories.]

Non-goals:
[List systems, assets, mechanics, and refactors explicitly excluded.]

Acceptance criteria:
1. [player-visible behavior]
2. [blocked/edge behavior]
3. [deterministic test]
4. [save/input/accessibility requirement]
5. [visual capture]

Verification:
[focused commands]
bash scripts/verify.sh

git diff --check

Report:
Intent, plan, files changed, exact verification result, screenshots,
known risks, and one bounded next task.
```

### 9.2 First ten recommended agent tasks

| Order | Task | Do not combine with |
|---:|---|---|
| 1 | Add baseline screen-state capture and local playtest metrics. | New mechanics or art replacement. |
| 2 | Extract or redesign terminal Results as a dedicated debrief panel. | New scenario content. |
| 3 | Add Preparation “current question / answer quality” summary. | UI monolith rewrite. |
| 4 | Improve board layer hierarchy and actor silhouettes using placeholders. | New enemy family. |
| 5 | Add approach/target-lock/wind-up/impact cues for one existing enemy. | New combat math. |
| 6 | Add a focused audio cue service for one complete battle loop. | Music system or platform audio integration. |
| 7 | Reconcile wave-two/wave-three start behavior and update tests/docs. | New wave doctrines. |
| 8 | Extract the event panel behind existing handlers. | Generic event scheduler. |
| 9 | Implement one Workshop Can Wait recovery event with visual treatment. | Regional campaign expansion. |
| 10 | Run five-person internal First Watch playtest and fix top three issues. | Large content expansion. |

### 9.3 Agent review questions

Before accepting an agent change, ask:

- Does the player know what to do next without reading a raw log?
- Is the current primary action visually dominant?
- Does the board remain visible while the decision is made?
- Is the cost of the action visible before confirmation?
- Does the change preserve the same authoritative command path?
- Does pause still freeze the simulation and presentation together?
- Does the feature work at 125% scaling and with controller focus?
- Does the screen look like a game state rather than a test state?
- Is the change understandable in one screenshot?
- What human question will the next playtest answer?

---

## 10. Testing and evidence plan

### 10.1 Automated tests

Maintain the existing deterministic suite and add the following classes of tests for game-quality work:

| Test | Purpose |
|---|---|
| Presentation snapshot | Screen renders the intended primary action, objective, board, and status at a known state. |
| Input path | Mouse, keyboard, controller, and remapped controls reach the same command. |
| Focus path | Focus order is logical and remains visible after scrolling or panel changes. |
| Pause invariance | Pausing does not advance simulation; resuming preserves the next result. |
| Speed invariance | Different speed settings do not alter authoritative state or outcome. |
| Animation independence | Presentation timing does not change command availability or state result. |
| Save checkpoint | Save/load at Preparation, Battle paused, Recovery, Event, and Results restores exact state. |
| Content visibility | New content has an icon/name/description, cost, weakness, and counter visible before commitment. |
| Replay | Same seed and command sequence produce the same canonical result and replay key. |
| Accessibility | Reduced motion, high contrast, scaling, audio mute, and controller paths remain valid. |

### 10.2 Human playtest script

Do not explain the intended answer. Give the tester the build and ask them to think aloud only after they have acted.

**Opening questions:**

- What do you think this game asks you to do?
- What would you click first?
- What do you think the fort is currently good or bad at?

**During Preparation:**

- What do you think this pack adds?
- Where would you put this defender, and why?
- What do you expect the next wave to attack?

**During Battle:**

- What do you think is about to happen?
- What made you pause?
- Why do you think that room or unit was targeted?

**During Recovery:**

- What is damaged?
- Which action seems most valuable?
- What are you giving up by choosing it?

**After Results:**

- Why did the keep hold or fail?
- What would you try differently?
- Do you want to play again? What would you change?

Record hesitations, wrong interpretations, ignored controls, and moments of surprise. Do not only record verbal opinions.

### 10.3 Visual evidence requirements

Every visual change should capture at least:

```text
Main Menu or Setup
Preparation with selected pack
Battle before impact
Battle after impact
Recovery with one action available
Terminal Results
```

Use the same logical viewport, compare before/after images, and document whether the screenshot is presentation inspection or human playtest evidence. Never call a screenshot proof of fun.

### 10.4 Balance evidence

For every scenario/commander/pack combination, report:

- Time to first meaningful decision.
- Wave hold/partial breach/collapse frequency.
- Average recovery actions used.
- Most common ignored or misunderstood counter.
- Dominant opening layout.
- Unused content or controls.
- Whether the replay suggestion changes behavior.

The target is not a perfectly equal win rate. The target is a set of understandable choices with no universal layout and no unavoidable defeat hidden behind an opaque forecast.

---

## 11. Definition of done for game quality

Pack the Keep is ready to move from technical pre-alpha toward a meaningful private alpha when:

1. The title, setup, preparation, battle, recovery, and Results screens each have a distinct purpose.
2. A new player can reach the first assault without developer explanation.
3. The fortress board communicates floor, room, defender, enemy, selection, and damage state at a glance.
4. The first assault has a readable approach, target, response, impact, and consequence.
5. Recovery presents a real trade-off and does not resemble a list of debug controls.
6. Terminal Results has a dedicated debrief composition.
7. Every implemented content item has a visible purpose, cost, weakness, and counter.
8. First Watch is enjoyable enough to replay, not merely completable.
9. Any completed human sessions have been recorded honestly and repeated high-severity comprehension issues have been addressed; absent human evidence does not block the automated game-quality gate.
10. Existing deterministic, save, accessibility, controller, packaged, and offline checks remain green.
11. The current visual fallback is either improved enough for internal alpha or replaced asset-by-asset with coherent provenance.
12. Release notes state exactly what remains prototype-level.

> **The real milestone is not “more systems.” It is when a player can look at the keep, understand the pressure, make a sacrifice, and care about whether the fortress holds.**

---

## 12. Immediate instruction to the next AI agent

```text
Do not add another large gameplay system.

Start from the current Pack the Keep remote main. Read AGENTS.md, README.md,
design/design_prompt.md, docs/agent_handoff_roadmap.md, and the latest visual
verification notes.

The automated K1–K8 transformation roadmap is complete. Preserve its gates and
known limitations. Run the P16 human private-alpha cohort only when the owner
schedules observers, record only direct observations, and do not claim public-
alpha or storefront readiness without explicit approval.
```

---

## References

[1] [`README.md`](../README.md) — current Pack the Keep scope and run flow.
[2] [`docs/agent_handoff_roadmap.md`](agent_handoff_roadmap.md) — long-horizon agent roadmap.
[3] [`docs/internal_test_release.md`](internal_test_release.md) — internal release scope and tester contract.
[4] [`docs/p16_human_playtest_protocol.md`](p16_human_playtest_protocol.md) — structured human playtest approach.
[5] [`docs/p31_first_watch_visual_verification.md`](p31_first_watch_visual_verification.md) — latest tutorial visual inspection.
[6] [`design/events_occurrences_bible.md`](../design/events_occurrences_bible.md) — future event and occurrence library.
[7] [`design/p4_greywatch_vertical_slice.md`](../design/p4_greywatch_vertical_slice.md) — earlier vertical-slice decision contract.

This is an internal product and implementation plan. It is not a claim that the listed future systems or final art are already implemented.
