# K3 — Screen presentation snapshots

## Purpose

Complete a read-only presentation boundary for every major game chapter so UI composition can evolve without moving simulation ownership into controls. War Council, Preparation, Battle, Recovery, and terminal Results each consume one deterministic plain-data snapshot derived from authoritative state.

## Ownership

- `PackKeepState` owns simulation, legality, costs, targeting, outcomes, persistence, and replay identity.
- Snapshot builders may call read models and format player-facing text, but may not execute commands or mutate state.
- `main.gd` owns navigation, visibility, focus, scrolling, signals, and command handlers.
- Panels own rendering only.
- Snapshot fields are never serialized.

## Screen contracts

- War Council: run mode, modifier, risk, commander identity and constraints, scenario pressure and fixed commitments.
- Preparation: pack offer, doctrine question/visible answer/open weakness, and advanced layout lens.
- Battle: readiness/live state, time controls, commander intervention, focused threat, and response preview.
- Recovery: what changed, why it matters, next pressure, ranked priorities, exact action cards, and explicit finish state.
- Results: outcome, resources, timeline, causal chain, persistent fortress damage, consequences, and replay experiment.

## Acceptance

1. Identical inputs produce byte-equivalent JSON projections.
2. Projection leaves serialized authoritative state unchanged.
3. Existing commands, tutorial locks, controller focus, responsive layouts, accessibility, save/load, and deterministic outcomes remain unchanged.
4. Screen panels render the exact snapshot retained by the UI controller.
5. No content or save schema changes are introduced.
