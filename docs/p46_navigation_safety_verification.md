# P46 Navigation Safety Verification

- Build: `0.25.3-navigation-safety`
- Scope: Escape/controller-back routing and unsaved-run confirmation
- Authoritative simulation changes: none

## Automated evidence

- `tests/test_p46_navigation_safety.gd` covers War Council back, dirty Preparation confirmation, Stay, confirmed discard, active-placement cancellation priority, Settings return, successful-save signatures, and save-file preservation.
- Existing save recovery, input remapping, controller navigation, tutorial, and deterministic suites remain in `scripts/verify.sh`.

## Visual evidence

A 1600×900 render confirmed the centered confirmation panel, dimmed underlying fortress, explicit Continue Saved Run wording, primary **Stay with defense** action, and destructive **Discard and return to War Council** action.

## Human evidence

No human navigation or comprehension claim is made. The required P16 matrix remains the next gate.
