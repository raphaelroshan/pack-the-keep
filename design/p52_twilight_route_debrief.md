# P52.2 — Twilight Route Debrief

## Intent

Make the Twilight Crossroads choice legible after the defense ends. Results should explain what recovery prepared, what it deliberately left to the build, and what changing that branch would test on replay.

## Read model

`PackKeepState.replay_mastery_summary()` derives one optional `recovery_branch` object from the persisted `twilight_crossroads` event-history entry. It contains:

- the stable selected choice ID;
- one sentence naming the prepared route and effect;
- one sentence naming the forgone preparation;
- one sentence comparing the branch with opened pack families;
- one opposite-branch replay experiment.

This object is derived only. It is not serialized, does not alter replay identity, and does not change combat outcomes.

## Results composition

Terminal Results appends two lines to the existing mastery block:

- `RECOVERY BRANCH` — selected preparation plus build fit;
- `FORGONE PREPARATION` — the route deliberately left to placed defenders.

For a non-collapse Twilight Road result, the green replay card proposes the opposite recovery branch. Collapse continues to prioritize the existing failure-specific recommendation.

## Acceptance

- Both branch summaries survive save/load by rederiving from event history.
- Road Wardens plus Crossbow Watch with lamps is described as complementary, not universally optimal.
- Lantern Watch plus Runner Network with stakes is described as complementary, not universally optimal.
- An overprepared Road Wardens plus Lantern Watch defense is identified as redundant coverage rather than receiving a stacking bonus.
- Other scenarios retain byte-equivalent mastery and replay wording.
- Results remains readable at 1280×720 and 2560×1440 without a new panel or HUD layer.
