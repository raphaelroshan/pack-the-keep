# P45 Presentation Audit Mode Verification

- Build: `0.25.2-presentation-audit`
- Scope: debug-only layout and focus diagnostics
- Authoritative simulation changes: none

## Automated evidence

- `tests/test_p45_presentation_audit_mode.gd` verifies normal-launch absence, named region snapshots, clipping counts, focus reporting, mouse/focus pass-through, and serialized-state invariance.
- Existing controller/scaling, local observation, capture, Battle snapshot, and deterministic suites remain in `scripts/verify.sh`.

## Visual evidence

The nine-screen capture harness was run with `--debug-ui`. Title showed a labeled title-card boundary and focused New Game control. Battle showed labeled main-content, command-rail, primary-action, fortress-board, and inspection regions plus the audit footer. The overlay remained translucent and did not obscure the underlying hierarchy.

## Player boundary

The overlay is instantiated only when `--debug-ui` is present. Normal and packaged launches retain no audit node or diagnostic drawing.
