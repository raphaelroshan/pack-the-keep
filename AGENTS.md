# AGENTS.md — Pack the Keep

## Mission

Build a polished single-player top-down fort-defense game for Windows, targeting Steam and Epic Games Store. Preserve the central promise: commanders and coherent packs create distinct defensive doctrines, and the keep layout makes those doctrines visible.

## Read before editing

Read `design/design_prompt.md`, `README.md`, `docs/decision_log.md`, and the smallest relevant source and test files before changing code.

## Rules

Use Godot 4.x and GDScript. Keep keep-grid rules, piece footprints, pack contents, commander effects, resource costs, invasion doctrines, wave scheduling, damage, repair, and save migration independent from rendering. UI scripts emit commands and display results; they do not own the defense rules.

Use stable identifiers rather than display names. Keep commanders, packs, pieces, enemies, doctrines, and wave definitions data-driven as the project expands. Make wave composition and damage outcomes deterministic from a seed. Every state-changing command should validate preconditions and return `ok`, `reason`, `state_changes`, and a player-facing message.

Make one coherent change at a time. Before adding a mechanic, write its player-facing purpose, data shape, acceptance criteria, and test cases. Before refactoring, append a decision-log entry. Do not add multiplayer, collectible rarity, microtransactions, fully destructible physics, or a large navigation system before one compact keep is fun and readable.

## Verification protocol

After changes to simulation, run:

```bash
godot --headless --path . --script res://tests/test_keep_state.gd
```

After UI or scene changes, launch the project and manually verify commander selection, pack opening, piece placement, overlap rejection, wave start, pause/speed behavior, commander ability, partial breach, save/load, resize, and controller focus. If Godot is unavailable, say so and report the exact command still required. Never claim a test passed without running it.

## Agent response format

Every implementation response must state **Intent**, **Plan**, **Changes**, **Verification**, **Risks**, and **Next task**. The next task must be small and bounded.

## Quality rules

Balance solo play first. The first hour must teach the defense language without requiring a wiki. Packs must change decisions, not only values. Commanders must change what the player notices and values. Randomness may create adaptation but must not remove every viable counter. A partial breach must be informative and recoverable.

Keep setup shorter than the interesting battle. Support pause, speed controls, group selection, controller navigation, display scaling, input remapping, readable labels, and color-safe threat cues from the first serious UI pass. Every building, pack, and enemy needs visible purpose and feedback.

## Art rules

Use a 2D illustrated top-down style with bold fort silhouettes, readable rooms and walls, expressive defenders, clear pack icons, and strong invasion colors. Placeholder art must preserve composition and scale and be replaceable through stable references. Do not add decorative density that hides the keep’s tactical state.
