# Agent QA scenarios

Scenario manifests describe semantic player journeys, readiness checkpoints, save checkpoints, screenshot states, and time budgets. A manifest marked `planned` must not be reported as an executed journey. An `implemented` manifest must bind every semantic command, pass its logic fixture, and produce its exact state sequence and named screenshots before the runner may classify it `PASS`.
