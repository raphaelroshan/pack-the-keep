# P34 Board Visual Hierarchy and Actor Silhouettes

## Intent

The fortress should read as structure, rooms, defenders, threats, damage, and focus in that order at normal play distance. Ground and upper floors need distinct identities, while defender and enemy roles must remain recognizable without relying on their labels or colors alone.

## Authority

This slice is presentation-only. `PackKeepState` continues to own geometry, placement, health, targeting, timing, and combat. The board consumes existing state and a visual registry; drawing and snapshot inspection must not mutate the simulation or saved data.

## Presentation contract

- A single visual registry owns the board palette, layer order, floor treatments, and procedural actor profiles.
- Ground and upper floors use distinct surfaces, frames, landmarks, and header plates while preserving the current hit boxes.
- Critical rooms receive a shape cue and accent strip in addition to color.
- Defender footprints remain visible, but a darker card, role-colored edge, and centered role silhouette replace the flat colored block treatment.
- Raiders, Sappers, Climbers, armored infantry, ranged attackers, breakers, and Siege Beasts use distinct marker silhouettes. Initials remain a secondary cue.
- Health, damage trails, placement previews, target lines, timeline positions, focus, and tutorial highlights remain above structural art.

## Acceptance

- The registry exposes the exact render-layer order and stable visual profiles.
- Ground and upper treatments are visibly distinct without changing geometry.
- At least the four original threats have different silhouettes, with larger mass reserved for Siege Beast.
- Defender combat/support/fortification families have distinct shape tokens.
- High contrast, 125% scaling, hit testing, pause, and deterministic outcomes remain unchanged.
- Refreshing or drawing the board leaves serialized keep state unchanged.

