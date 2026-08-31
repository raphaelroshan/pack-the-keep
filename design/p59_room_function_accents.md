# P59 — Temporary Room-Function Accents

## Player-facing purpose

Make Greywatch's functional rooms easier to distinguish at normal play distance without replacing its authored stone-and-timber board or competing with tactical state. A player should be able to associate the gate, armory, workshop, barracks, supply room, north tower, and old chapel with a compact prop silhouette before reading every label.

## Data shape

`BoardVisualRegistry.room_function_accent_profile(keep_id, room_id)` returns a presentation-only profile containing:

- whether the accent is active;
- one stable room and keep identifier;
- a loadable texture path;
- draw size and opacity;
- temporary-asset status and CC0 provenance.

Only `greywatch_keep` receives these accents. The inner yard and outer wall remain quiet so movement space and structural boundaries stay clear. Room geometry, condition, targeting, saves, and simulation state remain authoritative elsewhere.

## Acceptance criteria

1. The seven supported Greywatch rooms resolve distinct or purposefully reused Tiny Dungeon prop silhouettes.
2. Other keeps and unaccented rooms return inactive profiles.
3. Accents render beneath room labels, condition bars, damage effects, placed pieces, selection, and combat feedback.
4. High-contrast mode keeps the accents subordinate to semantic outlines and text.
5. Rendering and snapshot inspection do not mutate `KeepState`.
6. Every texture is present locally and reported as temporary CC0 material.

## Test cases

- Validate each supported room profile and texture path.
- Validate the inner yard, outer wall, and non-Greywatch keeps remain inactive.
- Validate the board snapshot reports temporary room-accent provenance.
- Validate normal and high-contrast snapshots preserve geometry and authoritative state.
- Capture Greywatch Preparation at 1600×900 and review label, health, placement, and prop hierarchy.
