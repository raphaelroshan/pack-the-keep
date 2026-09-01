# P64 — Authored Room-Function Accents

## Player-facing purpose

Give Greywatch's functional rooms a coherent fortress-specific visual vocabulary at normal play distance. The gate, armory, workshop, barracks, supply room, north tower, and old chapel should be recognizable before their labels are read, while the open yard, structural wall, units, health, damage, and targeting remain visually dominant.

## Data shape

`BoardVisualRegistry.room_function_accent_profile(keep_id, room_id)` remains a presentation-only profile containing:

- whether the accent is active;
- stable room and keep identifiers;
- one loadable original SVG path;
- draw size and opacity;
- authored-asset status and Pack the Keep provenance.

Only `greywatch_keep` receives this first authored set. The inner yard and outer wall stay quiet, and other keeps retain their existing surfaces until a keep-specific asset pass. Room geometry, condition, targeting, saves, and simulation state remain authoritative elsewhere.

## Acceptance criteria

1. Seven supported Greywatch rooms resolve seven distinct original, text-free 32×32 silhouettes.
2. Other keeps and unaccented rooms return inactive profiles.
3. Accents render beneath room labels, condition bars, damage effects, placed pieces, selection, and combat feedback.
4. Normal and high-contrast modes keep accents subordinate to tactical information.
5. Rendering and snapshot inspection do not mutate `KeepState`.
6. No active Greywatch room-function profile depends on a temporary third-party texture.

## Test cases

- Validate every supported profile, unique path, provenance field, and resource load.
- Validate the inner yard, outer wall, and non-Greywatch keeps remain inactive.
- Validate the board snapshot reports complete authored-room provenance and no temporary room accents.
- Validate normal and high-contrast snapshots preserve geometry and authoritative state.
- Capture the complete Greywatch flow at 1600×900 and review room/actor/health hierarchy in Preparation and Assault.
