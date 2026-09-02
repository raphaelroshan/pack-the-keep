# P70 — War Council progressive disclosure

## Player-facing purpose

Make the first decision screen read like a game briefing instead of two copies of the same selector. The commander and defense cards remain the primary choice surface; direct catalogue selectors, scenario detail, and campaign modifiers stay available behind one explicit advanced control.

## Data and ownership

- Existing commander, scenario, and modifier commands remain authoritative.
- The disclosure state is presentation-only and never enters save data or replay keys.
- A compact rail summary derives from the existing read-only War Council snapshot.

## Acceptance criteria

1. War Council opens with advanced controls collapsed and a visible current-pairing summary.
2. One button reveals or hides commander/scenario dropdowns, detailed scenario preview, and campaign ledger controls.
3. Card navigation and advanced dropdown selection remain synchronized through the existing handlers.
4. First Watch keeps all selection routes locked, including the disclosed fallback controls.
5. Primary Enter Keep focus, controller navigation, and responsive layouts remain intact.

## Verification

- Extend War Council card and navigation tests for default collapse, toggle behavior, summary synchronization, tutorial locks, and state immutability.
- Run focused P38, P46, P48, P53, and K3 tests plus full `scripts/verify.sh`.
- Capture and inspect the complete 1600×900 flow and a 1280×720 decision view.
