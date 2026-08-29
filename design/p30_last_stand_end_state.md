# P30 Last Stand End State

## Intent

Add one deliberately overwhelming scenario that proves the combat loop has a
clear, honest defeat state when every defender is disabled. Make that risk
legible in the briefing instead of surprising the player after the battle has
started.

## Simulation contract

- Scenarios may opt into `collapse_on_defender_wipe`. The default is `false`,
  preserving the recoverable partial-breach teaching rule used by the existing
  scenarios.
- When the option is enabled and at least one defensive piece was placed, the
  wave ends in `collapse` as soon as the resolved wave has no surviving
  defensive pieces.
- A defender-wipe collapse opens no repair interval, cannot start another
  authored wave, is recorded in wave history, and survives save/load exactly.
- Critical-room and morale collapse rules remain unchanged.
- The new `last_stand` scenario is an authored stress test, not part of the P12
  non-collapse viability matrix. Its dedicated test must demonstrate a real
  deterministic wave disabling the defense and reaching the terminal state.

## Selection contract

The scenario briefing must expose, before entering the keep:

- the selected scenario's position in the catalogue;
- a difficulty label and peak simultaneous attacker count;
- the distinct enemy roster and three doctrine phases;
- recommended packs;
- whether a defender wipe is recoverable or terminal;
- previous/next controls in addition to the existing direct dropdown.

Difficulty is explicit when authored. Older scenarios receive a deterministic
derived label from their peak wave size, so save data and existing content do
not require migration.

## Content shape

`last_stand` uses Greywatch, the Shieldwall and Crossbow Watch recommendations,
and escalating mixed unit-hunter/demolition pressure. Its first wave must be
strong enough to disable the minimal starter defense in the deterministic test;
later waves communicate the intended ceiling for players who build a stronger
line.

## Non-goals

- No permadeath or campaign deletion.
- No change to enemy targeting authority or damage values.
- No reward rebalance for the existing nine scenarios.
- No claim that the stress scenario is broadly winnable across the P12 matrix.
