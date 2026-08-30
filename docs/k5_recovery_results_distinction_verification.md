# K5 — Recovery and Results distinction verification

- Build: `0.27.1-recovery-results-distinction`
- Scope: clearer post-assault choice and terminal causal hierarchy

## Automated evidence

`tests/test_k5_recovery_results_distinction.gd` verifies that Recovery exposes a first priority, remaining-action sacrifice, and trade-off rationale without mutating state. It also verifies that terminal Results leads with a deterministic decisive-pattern summary, retains a replay experiment, and never exposes Recovery controls.

Existing P32, P37, and K3 snapshot tests preserve terminal save/load, inter-wave focus, exact action costs and blocks, responsive layouts, and deterministic presentation derivation. The full `scripts/verify.sh` suite remains the release gate.

## Visual evidence

The 1600×900 full-flow capture at `/tmp/pack-the-keep-k5-final` confirms that Recovery presents priority, sacrifice, and rationale above the keep, while terminal Results shows the causal summary before the detailed timeline with replay actions pinned below.

This is automated visual evidence, not a human playtest finding.
