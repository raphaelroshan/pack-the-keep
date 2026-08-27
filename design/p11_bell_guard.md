# P11 — Bell Guard vs. Smoke and Signal

## Intent

Add a second teaching pair about preserving reliable warning through disrupted sightlines. The player should see that one information source is fragile, while a short, spatially connected signal chain can prevent an enemy from arriving early.

## Friendly doctrine: Coordinated Response

### Bellkeepers

- Non-attacking morale/support unit for either floor.
- Carries the `signal_redundancy` tag and links to a living Signal Beacon on the same floor within four cells.
- An intact link preserves authored forecast detail and arrival timing against signal disruption.

### Signal Beacon

- Reused from Scouts so packs can share compatible infrastructure.
- Supplies the `warden_signal_coverage` relay endpoint required by Bellkeepers.
- Remains useful outside this pair through its existing Warden signal bonus.

## Enemy question: Smoke and Signal

### Ash Slinger

- Light service-lane attacker with an authored signal-disruption profile.
- If the keep lacks an intact Bellkeeper-to-Beacon link, its target forecast is obscured and it contacts one step early.
- The disruption changes information and timing, not hit points or hidden random rolls.

## Scenario: Ash at the Bell

1. Isolate one Ash Slinger under Smoke and Signal.
2. Combine an Ash Slinger with a Climber under Feint and Flank.
3. Combine smoke, sabotage, and gate pressure under Smoke and Signal.

## Acceptance criteria

- Catalog validation covers the optional disruption profile and all cross-references.
- Without an intact signal network, the forecast names smoke obscuration and Ash Slinger arrives one step early.
- Bellkeepers plus a nearby same-floor Signal Beacon preserve the authored target forecast and arrival step.
- A lone Bellkeepers or lone Signal Beacon does not counter disruption.
- The same seed and command sequence reproduce the same three-wave result.
- Save/load preserves active Bell Guard pieces and Ash Slinger state.
- Preparation, Battle, and Results expose the pack, scenario, smoke state, effective arrival, and causal report.
- Existing P1, Relief Road, and Red Banner Road balance baselines remain unchanged.

## Non-goals

- No fog-of-war renderer, line-of-sight ray casting, dynamic wind, accuracy rolls, or new commander.
- Signal disruption does not modify user accessibility auto-pause settings.
- No external image is copied into the repository; the first pass uses procedural smoke and bell glyphs.
