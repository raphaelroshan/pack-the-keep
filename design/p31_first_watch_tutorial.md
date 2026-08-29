# P31 First Watch Tutorial and Game Shell

## Intent

Turn the existing deterministic vertical slice into a first-run game journey.
The player should learn Greywatch by performing real commands, not by reading a
debug manual or playing a separate scripted simulation.

## Player flow

`New Game` starts **First Watch** until it has been completed or skipped.
`Learn to Play` always restarts it. The tutorial uses the Castellan,
Gatehouse Lock, and seed `3307`.

The guided sequence teaches:

1. Greywatch, resources, rooms, and outcomes through three short in-world cards.
2. The War Council briefing and the selected commander/scenario.
3. Opening Pike Line, placing Pike Squad and Narrow Gate, and inspecting a unit.
4. Reading the forecast, starting the assault, inspecting a Raider, pausing, and
   resuming real-time combat.
5. Reading the first outcome, repairing a damaged defender, and assigning Pike
   Squad to Gate during recovery.
6. Identifying a Sapper as a structure attacker and repairing a damaged room.
7. Comparing the mixed final-wave threats, using Lockdown, and completing the
   scenario without collapse.

## Authority boundary

- `PackKeepState` remains the only owner of placement, combat, assignment,
  repair, resources, wave outcomes, and saves.
- `TutorialDirector` is a presentation controller. It identifies the current
  lesson, exposes the permitted action family, observes successful commands and
  authoritative state, and selects the next lesson.
- Progress is never awarded for a click whose underlying command failed.
- Tutorial checkpoints contain a normal serialized keep snapshot plus the
  current lesson ID. They do not add tutorial fields to the simulation schema.

## Persistence

- Presentation settings schema 5 stores `tutorial_completed` and
  `tutorial_dismissed`.
- Active progress uses a separate atomic `user://pack_the_keep_tutorial.save`
  with a primary and backup candidate.
- Checkpoints are written at the start of Preparation and each recovery/battle
  phase. Collapse exposes `Retry Phase`, which restores the latest checkpoint.
- Skipping records dismissal, deletes active tutorial progress, and opens the
  normal War Council. It does not claim completion.

## Game-shell presentation

- Player-facing screens are Main Menu, War Council, Fortress, Assault,
  Aftermath, and Settings.
- Phase navigation becomes a non-interactive journey indicator rather than a
  debug tab bar.
- The normal HUD prioritizes objective, resources, current threat, selected
  unit/room, primary action, and outcome.
- Raw IDs, the aggregate metric dump, replay keys, seed language, and the full
  causal event feed are hidden outside developer UI.
- The pre-alpha build identity remains in a quiet footer to preserve the release
  boundary.
- Tutorial coach cards use concise dialogue from the Castellan and Mara Venn,
  plus a mechanically explicit objective and one highlighted action.

## Failure and accessibility

- Tutorial actions are strictly gated, except Settings, Help, and Skip Tutorial.
- Mouse, keyboard, and controller focus must reach the permitted action.
- A failed command keeps the same lesson and explains the rejection.
- Collapse offers a phase retry from the last exact checkpoint.
- High contrast, reduced motion, UI scaling, pause, and remapping remain
  available and presentation-only.

## Acceptance

- A clean profile can complete the three authored Gatehouse Lock phases through
  real commands and reach Tutorial Complete without outside explanation.
- Restarting the app preserves completion/dismissal and can resume an active
  checkpoint.
- A normal custom run has no tutorial gating and produces the same deterministic
  state as before this slice.
- At 1280x720 and 2560x1440, the primary action, tutorial objective, keep, and
  selected-unit/enemy information remain readable without debug text.
