# Agent Feeding Guide — Pack the Keep

## How the environment works

The repository separates product intent, keep simulation, invasion simulation, presentation, and verification. `design/design_prompt.md` is the persistent product brief. `AGENTS.md` is the coding contract. `src/core/keep_state.gd` owns deterministic commanders, packs, grid placement, pieces, waves, abilities, recovery, and serialization. `src/ui/main.gd` displays the keep and emits prototype actions. `tests/test_keep_state.gd` protects the simulation without rendering.

Give the coding agent the persistent prompt once, then feed it one risk slice at a time. Do not ask it to “build the whole tower-defense game.” Give it one player-facing behavior, a small set of files, acceptance criteria, and the exact verification command. For the current post-v0.12.3 sequence, use [`agent_handoff_roadmap.md`](agent_handoff_roadmap.md) as the long-horizon roadmap, [`design/events_occurrences_bible.md`](../design/events_occurrences_bible.md) as the creative event library, and the current `data/` definitions plus `src/core/content_catalog.gd` as the runtime content baseline.

## Persistent context prompt

> Current baseline override for the compact prompt below: `0.57.0-war-council-disclosure`, including completed PTK-I1 through PTK-I6 and PTK-EA-1 through PTK-EA-6, synchronized first plans, explicit active navigation, phase-specific decision framing, bounded tactical labels, progressive War Council disclosure, four commanders, three six-scenario keeps, fifteen packs, twenty-nine pieces, twelve enemies, fourteen events, and the complete automated/package gate.

```text
You are the lead implementation agent for Pack the Keep. Read `design/design_prompt.md`, `README.md`, `AGENTS.md`, `docs/decision_log.md`, `docs/agent_handoff_roadmap.md`, and the relevant design card before editing. The current baseline is `0.57.0-war-council-disclosure`: four commanders, fifteen packs, twenty scenarios across three keeps, twelve enemy types, fourteen events, synchronized keep-authored first plans and doctrine cards, explicit active navigation, truthful phase-specific headers, bounded tactical board labels, progressive War Council disclosure, deterministic continuous combat, save schema 4, settings schema 5, 2560x1440 support, controller/accessibility coverage, original active presentation assets, and completed investment and Early Access gates. Human P16 evidence must be recorded only from real scheduled sessions, and public distribution still requires explicit owner approval. Keep simulation separate from UI and preserve every completed gate.
```

## Current post-P31 feed order

The original feeds below describe the historical build-up from the prototype and should not be issued as unimplemented tasks. The current baseline is `0.57.0-war-council-disclosure`; PTK-I1 through PTK-I6, PTK-EA-1 through PTK-EA-6, P67–P70, and the automated K1–K8, P51–P66, P54, responsive-decision, room-label, authored-actor, authored-room, authored-effect, authored-audio, and repair-feedback gates are complete. Human sessions must be recorded only through the P16 protocol when the owner schedules them.

### Completed feed — K3 presentation-panel extraction

```text
Extract Preparation presentation first, followed by War Council, Recovery, and Results, from the monolithic main UI controller into read-only snapshots and dedicated panels. Preserve every existing command handler, focus target, responsive breakpoint, accessibility path, save schema, and deterministic outcome. Add focused snapshot tests plus normal-flow regressions after each extraction. Do not redesign mechanics or add content while moving ownership.
```

### Completed feed — K4 battle beat readability

```text
Use the Battle presentation snapshot to stage forecast, approach, target commitment, wind-up, defender response, hostile impact, dependency consequence, and settle as one readable beat grammar. Preserve authoritative tick timing, outcomes, targeting, pause, speed, manual step, replay keys, reduced motion, and audio settings. Add deterministic beat-state tests and visual checkpoints before changing content.
```

### Completed feed — K5 Recovery and Results distinction

```text
Sharpen the transition from assault consequence into the two-action Recovery decision, and from the final assault into terminal Results. Recovery must foreground one damaged priority and the sacrificed alternative; Results must foreground the run-specific causal story and replay experiment. Preserve the completed screen snapshots, exact costs, save/load, tutorial retry, controller focus, and deterministic reports.
```

### Completed feed — K6 controlled content slice

```text
Add exactly one complete teaching slice: one commander lens, keep identity, pack, or enemy family with a clear question, counter, weakness, authored scenario fixture, visual states, deterministic balance coverage, and player-facing explanation. Prefer depth over count and preserve at least two viable answers. Do not bundle unrelated content.
```

### Completed feed — K7 replay mastery

```text
Add one bounded, forecastable source of scenario variation and make the terminal report compare the player's chosen answer with the pressure encountered. Preserve at least two viable solutions, pause-based solo fairness, deterministic seeds, and save/load parity. Do not add grind, rarity tiers, forced builds, or permanent power escalation.
```

### Completed feed — K8 private-alpha hardening

```text
Consolidate accessibility, persistence, controller navigation, audio settings, clean install, migration, performance budgets, package provenance, rollback, and known limitations into one machine-readable private-alpha readiness gate. Reuse the existing focused tests and packaged smoke evidence. Keep human-session evidence pending and do not infer public-alpha or storefront readiness.
```

### Current feed 2 — P33.1 Preparation inspector

```text
Make Preparation a board-first decision surface. For one selected defender, show pack doctrine, footprint, valid/invalid placement reason, affected room/dependency, next threat, and one strength/weakness summary without opening multiple panels. Preserve mouse, keyboard, controller, large-text, high-contrast, save/load, and presentation-only state invariants. Add targeted placement and focus regression tests plus a normal-distance visual checkpoint.
```

### Current feed 3 — P34.1 battle beat readability

```text
Stage one existing deterministic assault as forecast, approach, target commitment, wind-up, response, impact, damage reaction, and settling beat. Use presentation-only interpolation/effects; do not change KeepState outcomes, tick timing, target rules, or replay keys. Verify pause, speed, manual step, same-seed replay, focus handoff, and screenshots showing the threat, target, counter, and result.
```

### Current feed 4 — P35.1 recovery/results separation

```text
Split the terminal Results composition from inter-wave Recovery. Results must show the final defense, causal timeline, fortress condition, resources, saved/lost elements, and one run-specific replay experiment. Preserve collapse-safe behavior, save/resume, controller focus, large text, and deterministic reports. Add hold, partial breach, collapse, victory, defender-wipe, recovery-save, and results-save coverage.
```

### Current feed 5 — P36 human comprehension pass

```text
Run the existing P16 protocol against one artifact cohort using First Watch and the quick path. Record only observed player behavior. Triage repeated confusion about what to do, why it matters, or what happened. Implement only repeated high-severity fixes, then update the observation matrix and evidence package. Never fabricate human observations from automated tests.
```

### Current feed 6 — P37 controlled content breadth

```text
Only after P32–P36 gates pass, add one commander lens, one keep identity, two teaching packs, and two enemy families. For each item create a design card, stable runtime definition, visual-state list, counter/weakness relationship, scenario fixture, deterministic test, and player-facing explanation. Introduce each question in isolation before composing it with existing doctrines.
```

### Current feed 7 — P38 replayable mastery

```text
Add bounded scenario variation, pack choices, recovery trade-offs, challenge modifiers, and causal replay reports without rarity tiers, duplicate grinding, forced build orders, or permanent power creep. Prove at least two viable solutions per expanded scenario and preserve pause-based solo fairness.
```

### Current feed 8 — P39/P40 alpha gate

```text
Complete accessibility, performance, save migration, clean-install, controller, high-DPI, audio, failure-recovery, provenance, and rollback checks. Package one honest private-alpha artifact with build manifest, observer brief, known limitations, and human evidence. Do not make a public-alpha, Steam-ready, or Epic-ready claim without explicit owner approval.
```

## Historical feeds: prototype build sequence

```text
Inspect the repository without adding gameplay. Confirm the project entry scene, keep state, UI actions, test runner, and exact launch/test commands. If Godot is unavailable, state that clearly. Produce a small plan for stabilizing the current grid and test runner. Do not add new commanders, packs, enemies, or systems.
```

## Second feed: data-drive the defense vocabulary

```text
Move commander, pack, piece, enemy, and doctrine definitions into one data-driven source under data/. Preserve behavior exactly. Validate identifiers, footprints, costs, roles, and pack references. Do not add content. Add or update headless tests and report the exact result.
```

## Third feed: formalize pack choices

```text
Introduce an explicit pack-offer command with a small choice set, a reserve slot, and a clear preview. The player must understand what a pack adds, what space or resources it consumes, and what doctrine it favors. Preserve the current prototype and add tests for duplicate packs, invalid packs, reserve behavior, and save/load. Do not introduce rarity, duplicate cards, or monetization.
```

## Fourth feed: prove commander differentiation

```text
Implement the Castellan and Warden as two viable rule lenses. Each must change the preferred layout and intervention pattern, not just apply a larger percentage bonus. Add one passive, one active ability, one limitation, clear UI explanation, and deterministic tests. Balance both for solo play. Do not add more commanders.
```

## Fifth feed: improve grid placement and readability

```text
Audit piece placement as a new player. Add clear footprint previews, valid/invalid placement states, resource cost, role explanation, rotation only if necessary, and deterministic overlap handling. Support mouse, keyboard, and controller selection paths. Preserve the small grid and add tests for edges, overlaps, occupied spaces, save/load, and reset.
```

## Sixth feed: implement one invasion doctrine

```text
Implement only Gate Assault. It should forecast the attack, pressure a readable gate or corridor, and offer at least three responses: concentrate defenders, reinforce the entry, or use the commander ability. Add a low-stakes teaching wave, deterministic scheduling, pause/speed control, clear progress, and headless tests. Do not combine doctrines yet.
```

## Seventh feed: add partial breach and recovery

```text
Add damage and partial breach state to rooms, walls, or placed pieces. A failed wave must create a recoverable problem rather than an automatic restart. Add repair, rebuild, or doctrine-change options, show why the breach occurred, and add deterministic tests for damage, repair, resource limits, and saved breach state. Avoid permadeath or irreversible campaign loss.
```

## Eighth feed: add remaining doctrines and pack expression

```text
Add Distributed Sabotage and Feint and Flank only after Gate Assault is stable. Each doctrine must change what the player values and must have multiple counters. Ensure each pack has at least one meaningful interaction with each doctrine. Add authored teaching scenarios and a combination test matrix. Do not expand the pack count until the current four packs produce distinct decisions.
```

## Ninth feed: visual and game-feel polish

```text
Audit the keep at normal play distance. Replace only high-impact placeholders with a 2D illustrated top-down style: strong silhouettes, readable rooms, pack icons, defender states, enemy markers, breach effects, and clear construction feedback. Test sound and animation timing, selection under overlap, pause, speed changes, display scaling, color-safe cues, and controller focus. Do not add decorative density that reduces tactical readability.
```

## Tenth feed: balance and storefront readiness

```text
Build a seeded harness covering commanders, packs, pieces, doctrines, wave compositions, and outcomes. Report dominant openings, unwinnable pack offers, setup time, breach frequency, and recovery success. Then prepare Windows Steam/Epic smoke tests for launch, offline play, saves, migration, controller, scaling, remapping, pause, achievements behind adapters, and cloud-safe paths. Do not put platform credentials in the repository.
```

## How to review an agent response

Ask: What commander, pack, piece, or invasion behavior changed? Which class owns the rule? What test fails if it breaks? Did the agent actually run the test command? Can a new player predict the purpose of the pack? Is solo play still fair? Is the preparation phase shorter than the interesting defense? What is intentionally incomplete?

Use a separate critique agent once the slice is playable. Give it the build, screenshots, test output, design prompt, and a rubric covering readability, doctrine differentiation, fairness, recovery, pacing, controls, and feedback. The critic should report issues rather than rewrite the code.

## Compact task template

```text
Task: [one observable commander, pack, keep, or invasion behavior]
Context: Read design/design_prompt.md and AGENTS.md.
Constraints: [systems that must not change; explicit non-goals]
Acceptance criteria:
1. [player-visible result]
2. [blocked or failure case]
3. [deterministic test]
4. [save/load or input requirement]
Verification: [exact command plus manual check]
Report: intent, plan, files changed, verification result, risks, one next task.
```


## Early Access breadth contract

Before adding broader content, read [`early_access_requirements.md`](early_access_requirements.md). Greywatch is the quality anchor, not the complete Early Access game. After the current K1–K8 presentation and hardening gates, issue one complete keep slice at a time: distinct room geometry, three named zones, two approach patterns, one recovery rule, two viable seeded opening plans, a contextual briefing, presentation snapshots, save coverage, and deterministic evidence. Continue until the Early Access floor of three keeps, four commanders, fifteen to eighteen packs, twenty-four to thirty defensive pieces, twelve to fourteen enemy families, twenty to twenty-four scenarios, fourteen to eighteen events, and twelve or more viable commander/keep starts is met.

Do not make human testing a prerequisite. Use headless state tests, deterministic replay, complete-flow launches, 1280×720 and 1600×900 layout checks, large-text/controller/reduced-motion checks, save boundaries, screenshots, and known-limitations notes as the active gates. No new unit or enemy should be a cosmetic reskin with no distinct defensive question.

The recommended feeds are **PTK-EA-1** Greywatch completion, **PTK-EA-2** second keep, **PTK-EA-3** third keep and commander lens, **PTK-EA-4** enemy/counter breadth, **PTK-EA-5** events and mastery, and **PTK-EA-6** release hardening.


## Investment-evaluation feed

Read [`investment_evaluation_roadmap.md`](investment_evaluation_roadmap.md) before adding further breadth. The investment standard requires a complete Greywatch creative vertical: commander/keep choice, doctrine pack, visible placement plan, forecast, live auto-battle, one intervention, recoverable damage, and causal Results. The game must then prove that a second keep changes spatial priorities rather than merely changing labels.

Issue the feeds in order: **PTK-I1** lock Greywatch as the creative vertical; **PTK-I2** add a mechanically distinct second keep; **PTK-I3** expand commander and pack expression; **PTK-I4** add enemy questions with visible counters; **PTK-I5** complete the campaign loop; **PTK-I6** harden the Early Access package. Do not add more enemies, packs, or decorative density while the first defense plan is hard to read. Human testing is optional and must not block implementation.
