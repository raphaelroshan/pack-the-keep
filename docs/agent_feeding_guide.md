# Agent Feeding Guide — Pack the Keep

## How the environment works

The repository separates product intent, keep simulation, invasion simulation, presentation, and verification. `design/design_prompt.md` is the persistent product brief. `AGENTS.md` is the coding contract. `src/core/keep_state.gd` owns deterministic commanders, packs, grid placement, pieces, waves, abilities, recovery, and serialization. `src/ui/main.gd` displays the keep and emits prototype actions. `tests/test_keep_state.gd` protects the simulation without rendering.

Give the coding agent the persistent prompt once, then feed it one risk slice at a time. Do not ask it to “build the whole tower-defense game.” Give it one player-facing behavior, a small set of files, acceptance criteria, and the exact verification command.

## Persistent context prompt

```text
You are the lead implementation agent for Pack the Keep. Read design/design_prompt.md, README.md, AGENTS.md, and docs/decision_log.md before editing. This is a Godot 4.x premium single-player Windows game for Steam and Epic Games Store. The core promise is commander-and-pack-driven top-down fort defense: choose a doctrine, open meaningful equipment or soldier packs, arrange a compact keep, and adapt to invasions. The first milestone is one keep, two commanders, four packs, four defender/equipment types, four enemy types, three invasion doctrines, three wave stages, a breach state, repair, and an outcome report. Keep simulation separate from UI. Work in small reversible slices, run headless tests, launch the game when possible, and report intent, plan, changed files, exact verification, risks, and one next task.
```

## First feed: inspect and stabilize

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
