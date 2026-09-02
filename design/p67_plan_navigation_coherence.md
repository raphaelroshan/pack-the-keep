# P67 — Plan and Navigation Coherence

## Player-facing purpose

When the player enters a keep, the doctrine card beside the board must agree with the authored opening plan, and the top bar must identify the current phase without making Settings look selected everywhere.

## Data and ownership

- The keep-owned `starter_plan.pack_id` remains the source of the recommended doctrine.
- `pack_option` selection and navigation styling are presentation state only.
- Pack ownership, materials, placement, battle, recovery, and saves remain authoritative in `PackKeepState`.

## Acceptance

1. Entering ordinary Preparation selects the current keep's recommended pack card before any plan is applied.
2. Applying a first plan leaves its doctrine card selected and showing its actual open state.
3. Browsing a different pack remains presentation-only and is never forcibly reset during ordinary refresh.
4. The current top-level phase has a distinct active treatment; Settings is visually secondary unless it is the current screen.
5. Compact navigation still hides decorative phase tabs and retains the Settings action.

## Tests

- Verify Ash Ford enters Preparation with Runner Network selected and applying the plan shows it opened.
- Verify manual next/previous pack browsing remains stable across refreshes.
- Verify active/inactive navigation styles at War Council, Preparation, and Settings.
- Preserve responsive layout, controller focus, tutorial pack locking, full flow, and deterministic state tests.
