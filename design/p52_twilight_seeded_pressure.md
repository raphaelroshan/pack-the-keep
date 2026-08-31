# P52.3 — Twilight Seeded Pressure

## Intent

Make The Twilight Road's deterministic seed change a visible preparation decision, not merely starting resources.

## Variation contract

- `standard_bell` keeps the balanced final assault: two Outriders and two Gloam Knives.
- `fading_light` weights the final assault toward the unlit stair: one Outrider and three Gloam Knives.
- `long_twilight` weights the final assault toward the fast road: three Outriders and one Gloam Knife.

The chosen final composition is shown in War Council as part of the existing variation summary, including the balanced `standard_bell` composition. Each variation also translates that roster into a concise preparation focus naming the route question and two valid ways to answer it. The summary returns unchanged at Results, remains fixed for the run, and is recovered from the stable saved variation ID.

## Data boundary

Scenario variations may optionally define `final_wave_plan`, a non-empty bounded array of known enemy IDs, and `preparation_focus`, one to 160 characters of player-facing guidance. Runtime and offline validators enforce the same rules. The plan overrides only the last authored wave; doctrine order, objectives, recovery, and all combat rules remain unchanged.

## Acceptance

- Seeds deterministically select all three variations.
- War Council names the exact final composition and preparation emphasis before the player enters the keep.
- Results repeats the same seed pressure so the debrief can compare the plan with the chosen recovery branch.
- Phase three spawns exactly the disclosed composition.
- Save/load before and during the final phase produces byte-identical outcomes.
- Both recovery branches remain viable across all three commanders and representative seeds.
- No scenario without `final_wave_plan` changes behavior or preview output.
