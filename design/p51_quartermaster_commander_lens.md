# P51.1 — Quartermaster Commander Lens

## Player-facing purpose

The Quartermaster asks the player which reserve should be made to last. The lens trades the weakest opening stockpile for cheaper access to one doctrine pack each Preparation, a stronger surviving Supply Cache, and one active Resupply order during every assault.

This is a resource-timing commander, not a stronger Castellan or Warden. The opening is constrained, the first pack discount must be visible before purchase, and the active ability has no value until defenders have spent ammunition or taken damage.

## Data shape

`data/commanders/quartermaster.json` owns the identity, starting resources, favored pack families, and two bounded rule profiles:

- `passive_profile.kind = reserve_economy`
- `first_pack_discount = 2`
- `supply_cache_recovery_bonus = 2`
- `ability_profile.kind = resupply`
- `ammo_restore = 2`
- `health_restore = 2`

The existing commander definitions remain behaviorally unchanged. `PackKeepState` owns effective pack cost, Supply Cache recovery, Resupply mutation, once-per-wave use, save/load, and deterministic reports. Presentation reads only previews and commander definitions.

## Acceptance criteria

1. War Council can browse Castellan, Warden, and Quartermaster through the existing commander selection path.
2. Before purchase, the first pack card shows the Quartermaster's effective cost and named two-material discount; later packs use authored base cost.
3. A surviving Supply Cache grants seven materials for the Quartermaster and five for other commanders.
4. Resupply restores at most two health and two ammunition to each eligible living defender, never exceeds authored maxima, costs one command point, and can be used once per assault.
5. Resupply is unavailable when it would change nothing and returns a player-facing reason without spending command points.
6. Save/load preserves the selected commander and whether Resupply was spent without changing save schema 4.
7. The same seed and command sequence remains byte-for-byte deterministic through a mid-assault save/resume.
8. First Watch remains locked to the Castellan and the original P16 human matrix remains explicitly scoped to its existing two-commander cohort.

## Tests

- Runtime content validation and catalog order/count.
- Effective first-pack cost, one-discount boundary, and insufficient-material behavior.
- Supply Cache recovery bonus comparison.
- Resupply caps, no-op rejection, command-point cost, once-per-wave reset, and save/load.
- War Council navigation, card copy, Battle ability availability, and tutorial lock.
- Full deterministic scenario matrix expanded to all active commanders.

## Non-goals

- No new keep, pack, enemy family, event chain, campaign unlock, portrait asset, or save-schema migration.
- No change to Castellan Lockdown, Warden Rally, placement legality, attack timing, targeting, or damage authority.
- No expansion of the pending human playtest matrix until a new artifact cohort is deliberately scheduled.
