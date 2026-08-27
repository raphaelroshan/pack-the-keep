# Content Pipeline

## Purpose

Content is authored as both a human-readable design bible and a machine-readable manifest. The design bible explains the dramatic purpose, player-facing language, and progression logic. `content/content_manifest.json` contains stable identifiers and structured fields that future Godot systems can load without parsing prose.

The content layer is deliberately separate from simulation code. Events describe requirements and intended effects, but runtime code must translate those effects into explicit validated commands. Narrative text must never be used as a hidden scripting language. Pack the Keep also keeps its unit, pack, enemy, resource, and solo-balance framework in `content/gameplay_framework.json`; this file is design data, not executable balancing logic. The two-floor relationship between walls and towers and the ground keep lives in `content/vertical_layers.json`; it defines upper and ground dependencies without creating separate maps or economies. P6 runtime definitions for active commanders, pieces, packs, enemy actors, invasion doctrines, and scenarios live under `data/`; `src/core/content_catalog.gd` validates, normalizes, and loads those files for `PackKeepState`.

## Repository structure

| Path | Responsibility |
| --- | --- |
| `design/content_bible.md` | Narrative premise, tone, locations or rooms, characters or commanders, event rules, progression, endings, and implementation guidance. |
| `design/events_occurrences_bible.md` | Expanded event cards, random occurrences, meetings, recovery incidents, character arcs, regional developments, scenario chains, and event implementation templates. |
| `content/content_manifest.json` | Stable IDs and structured authored content for campaign chapters, locations, events, progression tracks, and endings. |
| `content/gameplay_framework.json` | Stable-ID gameplay framework for units, pack families, enemy doctrines, resources, spatial rules, progression, and solo-balance constraints. |
| `content/vertical_layers.json` | Two-floor design for walls and towers, ground rooms and yard, vertical connections, floor dependencies, pack identity, and enemy tests. |
| `data/commanders/*.json` | Runtime commander identity, doctrine, ability, limitations, and starting resources. |
| `data/pieces/*.json` | Runtime piece identity, footprint, combat/support profile, availability, assignment, and presentation metadata. |
| `data/packs/*.json` | Runtime definitions for active pack identity, contents, cost, doctrine, trade-offs, affinities, and spatial demand. |
| `data/enemies/*.json` | Runtime enemy health, damage, timing, route, targeting, counter, telegraph, and presentation metadata. |
| `data/doctrines/*.json` | Runtime default compositions, route and target policies, forecast language, pressure summaries, and counter families. |
| `data/scenarios/*.json` | Runtime scenario objectives, lessons, wave plans, and bounded deterministic variations. |
| `src/core/content_catalog.gd` | Runtime loader that validates content files, normalizes piece data, and returns immutable definition copies. |
| `tools/validate_content.py` | Deterministic JSON/reference validator used by CI. |
| `tools/validate_gameplay_framework.py` | Pack-specific validator for gameplay-framework references and design minimums. |
| `tools/validate_vertical_layers.py` | Validator for floor roles, unit registration, vertical connections, pack relationships, and slice scope. |
| `tools/validate_runtime_content.py` | Validator for runtime commander, piece, pack, enemy, doctrine, and scenario schemas, stable filenames/IDs, references, and manifest parity. |
| `tests/test_runtime_content_validator.py` | Negative-path tests proving malformed runtime definitions fail with actionable diagnostics. |
| `ci/quality_contract.md` | Game-specific review criteria used by the multi-agent reviewer. |

## Authoring contract

Every authored object receives a stable `id` in `snake_case`. IDs are implementation references and should not be renamed casually after a feature is merged. Display names, descriptions, and dialogue can change without changing the ID.

Every event belongs to a campaign chapter, references only known locations or rooms, and contains at least two choices. Every choice has a label, requirements, effects, and visible result. Requirements and effects are intentionally represented as data for later command mapping; they are not executed by the validator or interpreted directly by the UI.

Progression nodes should unlock a new decision or response rather than only increase a number. Endings should be reachable through multiple reasonable play styles when the simulation supports them. A failure or partial-success outcome must explain what was lost and preserve a meaningful next action.

## Agent workflow

An implementation agent should first read the relevant section of the content bible or [`design/events_occurrences_bible.md`](../design/events_occurrences_bible.md), then inspect the manifest and current simulation state. It should add or update the smallest content slice: one event card, one location or room report, one choice effect, or one progression milestone. The agent must update the manifest, add or update deterministic validation coverage, and show the player-facing result before expanding the catalog.

When content introduces a new mechanic, the agent should make the command and state change explicit in the simulation layer. When content only changes text or presentation, it should preserve deterministic outcomes. Before merging, run the policy checker, content validator, gameplay-framework validator, vertical-layer validator, runtime-content validator, and Godot headless tests. For local checks, use `python tools/validate_gameplay_framework.py --framework content/gameplay_framework.json`, `python tools/validate_vertical_layers.py --layers content/vertical_layers.json`, and `python tools/validate_runtime_content.py --pieces data/pieces --packs data/packs --commanders data/commanders --enemies data/enemies --doctrines data/doctrines --scenarios data/scenarios --manifest content/content_manifest.json`. During review, use the game-specific quality contract to check that the new content strengthens the central decision rather than adding lore without consequence.

## Content quality checklist

A content change is ready for review when a player can identify where it occurs, why it matters, what choices are available, what resources or relationships are at stake, and what visible result follows. The event should not rely on an unexplained random draw, a mandatory counter, or an invisible reputation threshold. The location or room should have a distinct role, visual identity, and strategic consequence. The progression node should create a new option or make a previously weak option viable.
