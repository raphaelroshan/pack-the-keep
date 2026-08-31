# P55 Temporary Actor Readability

## Player-facing purpose

Defenders and attackers should read as people or siege actors at normal board distance, while the existing shapes, colors, health bars, target lines, focus rings, and status labels continue to explain their tactical role.

## Presentation data

- Piece visual profiles may reference one temporary CC0 sprite for active defender roles.
- Enemy visual profiles may reference one temporary CC0 sprite selected by attack role and enemy identity.
- The board renderer loads and caches those textures as presentation-only resources.
- Stable piece IDs, enemy IDs, combat style, targeting, damage, timing, and save data remain unchanged.

## Acceptance criteria

- Melee and ranged defenders use visibly different Tiny Battle actor sprites inside their existing board cards.
- Melee, ranged, demolition, fast, concealed, and siege enemies retain their existing profile silhouette/color while gaining an actor sprite.
- Enemy health, cadence, target, focus, armor, smoke, breach, and command-hunter overlays remain above or around the actor art.
- Timeline markers remain compact procedural symbols rather than unreadable miniature sprites.
- Missing temporary assets fall back to the existing procedural glyphs without affecting play.
- High contrast, reduced motion, pause, speed, manual-step, selection, and deterministic replay remain unchanged.
- The asset paths and CC0 temporary status are exposed through the read-only board visual snapshot.

## Test cases

- Assert formation and ranged defenders resolve different temporary sprite paths and both textures load.
- Assert Raider, Ash Slinger, Sapper, Outrider, Gloam Knife, and Siege Beast profiles retain distinct tactical shapes/colors while resolving appropriate temporary actor sprites.
- Render Preparation and a live Battle through the normal flow and confirm serialization is unchanged.
- Capture a 1600×900 battle exchange and visually verify actor readability alongside health bars, target lines, focus, and impact feedback.
