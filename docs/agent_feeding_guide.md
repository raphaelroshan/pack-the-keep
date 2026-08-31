# Agent Feeding Guide — Pack the Keep

## How the environment works

The repository separates product intent, keep simulation, invasion simulation, presentation, and verification. `design/design_prompt.md` is the persistent product brief. `AGENTS.md` is the coding contract. `src/core/keep_state.gd` owns deterministic commanders, packs, grid placement, pieces, waves, abilities, recovery, and serialization. `src/ui/main.gd` displays the keep and emits prototype actions. `tests/test_keep_state.gd` protects the simulation without rendering.

Give the coding agent the persistent prompt once, then feed it one risk slice at a time. Do not ask it to “build the whole tower-defense game.” Give it one player-facing behavior, a small set of files, acceptance criteria, and the exact verification command. For the current post-v0.12.3 sequence, use [`agent_handoff_roadmap.md`](agent_handoff_roadmap.md) as the long-horizon roadmap, [`design/events_occurrences_bible.md`](../design/events_occurrences_bible.md) as the creative event library, and the current `data/` definitions plus `src/core/content_catalog.gd` as the runtime content baseline.

## Persistent context prompt

> Current baseline override for the compact prompt below: `0.32.0-twinwatch`, including the first two P51 controlled-content slices, the completed automated K8 hardening gate, and real packaged process-termination recovery evidence.

```text
You are the lead implementation agent for Pack the Keep. Read `design/design_prompt.md`, `README.md`, `AGENTS.md`, `docs/decision_log.md`, `docs/agent_handoff_roadmap.md`, and the relevant design card before editing. The current baseline is `0.32.0-twinwatch`: three commanders, nine packs, twelve scenarios across Greywatch, Ash Ford, and Twinwatch, one Low Mill/Miller's Road consequence, eight enemy types, authored multi-phase combat presented continuously with one deterministic target commitment per defender per tick, unit-first attacker targeting with explicit Sapper/Siege Beast demolition roles and Standard Cutter assigned-specialist priority, friendly target projections, data-driven enemy attack cadence with next-strike projections, distinct enemy melee/ranged/demolition impacts and wind-up telegraphs, target recoil and recent-damage health trails, an opt-in terminal defender-wipe rule demonstrated by The Last Bell, an expanded scenario briefing with difficulty/roster/doctrine/end-state information, data-driven defender combat exchange effects, authoritative room/defender/enemy health bars, a larger gridless keep with preparation-only placement guides, room hover detail, a six-tick timeline with selectable enemy arrivals and next contact, automatic threat focus and defeated-target handoff, matching map/timeline hover details, a dedicated ground-route approach apron, width-fitted board labels with occupied-room decluttering, runtime JSON content under `data/`, bounded authored events, Campaign Ledger modifiers, controller/scaling/accessibility settings including 2560x1440 support, a separate main-menu/briefing/preparation/battle/report journey with contextual controls, packaged Windows lifecycle smoke coverage, a strict but skippable three-phase First Watch tutorial, a dedicated terminal debrief that preserves the damaged keep beside its outcome, timeline, causal chain, persistent damage, and replay action, a compact Preparation question/answer/weakness brief, a centralized board visual grammar with distinct floor treatments, critical-room cues, defender role cards, and enemy silhouettes, one presentation-only semantic audio service covering the complete battle loop, a tick-zero Sound the Bell readiness beat for first or materially changed assault phases, a dedicated inter-wave Recovery brief for what changed, why it matters, next pressure, and the two-action trade-off, game-facing War Council cards for commander identity and authored scenario pressure, a complete pack doctrine offer card with advanced fallback selectors, a terminal replay-mastery summary that compares seeded pressure, doctrine fit, recovery commitment, and pack plan, a CI-enforced private-alpha gate covering accessibility, persistence, controller, audio, package lifecycle, migration, performance, provenance, failure recovery, and known limitations, and packaged forced-process termination followed by backup recovery and current-schema rewrite. The Quartermaster adds visible first-pack reserve pricing, stronger surviving Supply Cache recovery, and bounded Resupply. Twinwatch Bastion adds a paired-post spatial rule, ridge visual identity, and The Divided Bell teaching scenario. The human-authored P16 evidence protocol remains pending. The core promise remains commander-and-pack-driven top-down fort defense: choose a doctrine, arrange a readable keep, and adapt when an invasion tests it. Keep simulation separate from UI. Work in small reversible slices, preserve deterministic seeded outcomes and save compatibility, add tests before polish, and report intent, plan, changed files, exact verification, risks, and one next task. Never fabricate human observations or infer approval for public distribution or storefront release.
```

## Current post-P31 feed order

The original feeds below describe the historical build-up from the prototype and should not be issued as unimplemented tasks. The current baseline is `0.32.0-twinwatch`; the automated K1–K8 sequence and P54 forced-close package gate are complete. P51.1–P51.2 are implemented; the next bounded task is one teaching pack paired with one isolated enemy question. Human sessions are optional validation and must be recorded only through the P16 protocol when the owner schedules them.

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
