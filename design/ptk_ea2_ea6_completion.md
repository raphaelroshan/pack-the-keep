# PTK-EA-2 through PTK-EA-6 — Early Access Completion Contract

## Intent

Turn the current Greywatch-led vertical slice into the smallest honest Early Access campaign: three mechanically distinct keeps, four viable commander lenses, a bounded roster at the approved breadth floor, meaningful seeded replay choices, and a release candidate that preserves the existing deterministic, accessible, offline-first boundary.

## PTK-EA-2 — Ash Ford completion

### Player-facing purpose

Ash Ford makes empty space and distributed recovery into active resources. Its six-scenario route asks the player to keep the causeway useful while pressure alternates between the bridgehead, sluice, stores, and raised warning line.

### Data shape

- Six active scenarios reference `ash_ford_redoubt`.
- The keep retains `clear_causeway`, shallow 20-condition repairs, and two approach families.
- River Wardens and Ferry Scouts add a prepared crossing line and a mobile information answer without introducing map-specific command code.

### Acceptance criteria

- Six Ash Ford scenarios cover gate, support, upper-route, demolition, and mixed pressure.
- At least two seeded opening plans complete a representative Ash Ford scenario without collapse.
- War Council, Preparation, Battle, Recovery, Results, controller, scaling, reduced-motion, save, and replay paths work on Ash Ford.

### Tests

- Catalog and scenario distribution assertions.
- Clear-causeway and shallow-repair assertions.
- Two-plan deterministic completion and save/resume parity.
- Screen snapshot and responsive-layout checks.

## PTK-EA-3 — Twinwatch and the Marshal

### Player-facing purpose

Twinwatch makes divided attention the spatial problem. The Marshal turns assignments into a stronger but more exposed command network, providing a fourth lens that is neither compact adjacency, open mobility, nor reserve economy.

### Data shape

- Six active scenarios reference `twinwatch_bastion`.
- `marshal` uses `assigned_command` for a bounded +1 assigned-defender response.
- `relief_order` restores bounded health to living assigned defenders once per assault.
- Ridge Company and Mason Train provide split-post response and structural counterplay.

### Acceptance criteria

- Twinwatch exposes two approaches and its paired-bastion rule in previews and results.
- The Marshal's passive and intervention are deterministic, saveable, previewed, and reject no-op use.
- Every commander can start every keep; two seeded Twinwatch plans remain viable.

### Tests

- Commander schema, passive damage, intervention preconditions, save/load, and UI-card coverage.
- Twinwatch scenario distribution, paired-post state, two-plan completion, and responsive flow coverage.

## PTK-EA-4 — Enemy families and counters

### Player-facing purpose

The Battering Ram asks for structural preparation against an armored room destroyer. The Harrier asks the player to protect depleted ranged and signal specialists rather than merely the weakest defender.

### Data shape

- `battering_ram`: armored demolition room destroyer with a slow cadence.
- `harrier`: ranged unit hunter using deterministic `lowest_ammo_ratio` target preference.
- Hammer Road and Harrying Fire doctrines disclose those rules and counter families.
- New pack pieces use existing attack, armor-piercing, fortification, route-delay, and assignment contracts.

### Acceptance criteria

- Telegraphs, forecast, target selection, attack style, counter identity, impacts, recovery consequences, and reports are visible.
- Target selection is stable under ties and survives save/resume.
- Both threats have at least two viable answer families.

### Tests

- Catalog rejection for unsupported target preferences.
- Harrier target ordering, Battering Ram armor/room pressure, counter damage, visual-registry, and replay parity.

## PTK-EA-5 — Events and mastery

### Player-facing purpose

Four keep-specific events make preparation and recovery choices carry into the next pressure without permanent power. Results compare the chosen branch, disclosed seed pressure, opened packs, and uncovered doctrine.

### Data shape

- Four schema-valid authored events use the existing typed requirement/effect vocabulary.
- Event chains are scenario-local, bounded, deterministic, and persisted.
- Five new scenarios bring the active catalog to twenty while each keep owns six or more.

### Acceptance criteria

- The catalog contains 14–18 active events and 20–24 active scenarios.
- New choices mutate only through existing commands, survive save/load, and close before terminal Results.
- Seed variants disclose different preparation pressure without hiding stat changes.

### Tests

- Event schema/graph validation, branch effects, history, replay summary, and all-scenario matrix coverage.

## PTK-EA-6 — Candidate hardening

### Player-facing purpose

Make the breadth expansion behave like the same game at every supported size and input method, and make its downloadable candidate recover safely from interruption.

### Data shape

- One machine-readable progress ledger binds all six milestones to repository evidence.
- `early_access_ready` means the automated candidate gates pass; owner distribution approval remains required.
- The release continues to publish exact source, executable, smoke, provenance, observer brief, templates, limitations, and release manifest.

### Acceptance criteria

- Breadth inventory is within every approved range: 3 keeps, 4 commanders, 15 packs, 29 pieces, 12 enemies, 20 scenarios, 14 events, and 12 commander/keep starts.
- Full deterministic, save/resume, UI, accessibility, controller, performance, and packaged lifecycle gates pass.
- No human session is fabricated; P16 observations and owner distribution approval remain explicit external gates.

### Tests

- Generalized Early Access validator with negative fixtures for incomplete milestones and out-of-range inventory.
- Full `scripts/verify.sh`, visual capture review, exact-main CI, tagged Windows package smoke, and artifact audit.
