# Pack the Keep Quality Contract

Reviewers must treat this game as a deterministic top-down fort-defense strategy prototype in which commanders deploy packs of equipment or soldiers against invading waves. The system must remain legible and fair for solo players.

## Gameplay review criteria

A change is suspect when packs become grindy or unreadable; units overlap or target inconsistently; balance is expressed as unexplained percentages; waves become predictable; setup takes longer than play; or co-op assumptions make solo defense unreasonable. Review whether a player can identify what a pack contains, where it acts, why a target was selected, and how to recover after a breach.

## Architecture and QA criteria

Keep commander, pack, piece-grid, wave, breach, repair, and save state deterministic under a fixed seed and independent of presentation. Add headless tests for placement and overlap rules, targeting tie-breaks, wave resolution, breach and repair, pause/control behavior, invalid commands, and save/load round trips whenever those systems change.

## Release-quality criteria

Keyboard, mouse, and controller inputs should reach the same explicit commands. Tooltips, previews, pause behavior, and accessibility options must not change simulation outcomes. Avoid network or storefront dependencies in the simulation layer and never add platform credentials to the repository.
