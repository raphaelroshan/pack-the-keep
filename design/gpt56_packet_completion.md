# GPT56 Investment Packet Completion Contract

## Player-facing purpose

Turn the existing Early Access breadth into a legible investment proof. A player should be able to choose a commander and immediately understand how that commander's doctrine changes the selected keep's geometry, then carry a visible plan through forecast, three live assaults, intervention, recovery, and a causal terminal report.

## Authoritative data

- Each keep owns a `doctrine_geometry` row for every active commander. A row names one compatible pack, the intended opening pattern, why the pairing works in that keep, and the risk it accepts.
- Existing `PackKeepState` commands remain the only authority for commander/scenario selection, pack opening, placement, combat, recovery, events, progression, and persistence.
- War Council derives its geometry-fit sentence from the selected keep and commander. It does not score, auto-build, or mutate the run.
- `content/gpt56_progress.json` composes the exact evidence for PTK-GPT56-1 through PTK-GPT56-5 and retains the owner-controlled distribution boundary.

## Acceptance criteria

1. Greywatch exposes at least two viable deterministic opening patterns, and its complete 1600x900 evidence sequence includes War Council, Preparation, all three assaults, both recoveries, and terminal Results.
2. Ash Ford exposes a spatial rule, recovery priority, teaching and combined scenarios, two viable opening patterns, and a player-facing explanation of why a Greywatch opening cannot be copied unchanged.
3. The selected commander/keep pair exposes its doctrine-to-geometry fit in War Council, with complete 4x3 catalog coverage and valid pack references.
4. Every active pack states its purpose, cost, space, limitation, and strategic choice; every active enemy states a telegraph, target mode, at least two counter families, and a visible failure consequence.
5. The three-keep campaign floor, bounded scenario/event variation, save boundaries, accessibility, offline package, provenance, rollback, and known-limitations evidence remain green.
6. Automated completion never claims human observation, storefront approval, signing, or owner distribution approval.

## Deterministic tests

- Runtime content validation rejects incomplete or duplicate doctrine-to-geometry rows.
- War Council snapshot/UI coverage verifies that changing either commander or keep changes the displayed geometry fit without mutating state.
- The GPT56 progress validator checks ordered packet completion, exact evidence, inventory bounds, scenario ownership, semantic pack/enemy contracts, 4x3 pair coverage, and the distribution boundary.
- Mutation tests reject stale versions, missing evidence, false completion, incomplete pair matrices, weak enemy counters, and invalid capture manifests.
- Existing 36-run Greywatch balance, 456-run all-scenario parity, all-phase save/resume, responsive/controller, performance, and packaged lifecycle suites remain authoritative.

## Out of scope

No fifth commander, nineteenth pack, procedural campaign layer, hidden build score, automatic placement bonus, human-evidence claim, or public distribution action. The current catalog already sits inside the packet's approved Early Access floor; new content is added only when it creates a new player question.
