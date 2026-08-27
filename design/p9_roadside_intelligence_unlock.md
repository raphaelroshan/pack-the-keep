# P9 — Roadside Intelligence Unlock

## Player-facing intent

Completing The Relief Road should unlock a new way to plan the next run, not a permanent stat increase. **Roadside Intelligence** reveals the full authored composition of the next wave in the forecast, but equipping it reduces starting morale by one. The player chooses certainty at the cost of recovery margin.

## Unlock and use flow

1. Resolve The Refuge Bell conclusion event in The Relief Road.
2. The typed `unlock_modifier` effect adds `roadside_intelligence` to the persistent profile.
3. Results shows the new unlock in a compact Campaign Ledger.
4. Start a new run, equip the modifier, then select a scenario.
5. Forecast shows the exact next-wave actor composition and the run begins with one less morale.

The normal scenario selector remains available. This prototype proves between-run progression without adding a regional map or grind.

## Data shape and authority

`data/modifiers/roadside_intelligence.json` owns the stable ID, player question, unlock source, information effect, morale cost, and limitation. `ContentCatalog` validates the definition and event references.

`PackKeepState` owns:

- `unlocked_modifier_ids`
- `equipped_modifier_id`
- `unlock_modifier()` and `equip_modifier()` commands
- application of starting-morale cost
- composition disclosure in `forecast()`

Save schema 4 persists both fields. `reset_run()` preserves profile progression while clearing the current defense. Schema-3 saves default to no unlocks and no equipped modifier.

## Acceptance criteria

- The modifier definition loads with a stable ID and valid event unlock source.
- The Relief Road conclusion unlocks the modifier once; repeated resolution cannot duplicate it.
- Locked, unknown, mid-wave, and already-equipped requests reject without mutation.
- Equipping changes only future/new-run starting morale and forecast information.
- Unequipping restores the normal starting morale and hidden composition on the next run.
- Reset preserves unlock/equip state while clearing run state.
- Save/load preserves progression; schema-3 saves migrate safely.
- Forecast composition matches the authored wave plan and never changes simulation outcomes.
- Campaign Ledger UI shows LOCKED, UNLOCKED, or EQUIPPED and exposes the legal action.
- Existing and modifier-equipped balance runs remain bounded and deterministic.

## Non-goals

- No XP, currency grind, rarity, permanent damage bonus, regional map, achievement adapter, or multiple unlock trees.
- No restriction of the existing free scenario selector.
- No UI-owned unlock mutation or forecast simulation.
