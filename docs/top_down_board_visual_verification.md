# Top-Down Board Visual Verification

The map-first layout was captured under a real virtual display with Godot 4.4.1 at 1280×720. The Battle screenshot now places the square-fort board immediately below the status line rather than below the forecast, enemy, metrics, and combat-explanation labels. This makes the fort the primary visible surface while keeping the command table visible at right.

The board reads as two coordinated top-down surfaces: a ground fort with a thick square wall ring and open courtyard, and an upper wall-walk surface with upper posts and interior room markers. The Battle screenshot showed the placed Pike Squad, Fire Team, wall-walk label, room state bars, scenario context, enemy phase readout, combat metrics, and the combat explanation together without parser or runtime errors.

The Preparation screenshot confirms that the existing title and preparation presentation still appears before the board-first battle layout. The next art pass should replace the procedural surfaces with coherent hand-crafted pixel tiles or a generated map asset while preserving the current geometry and overlay coordinates. The current implementation deliberately avoids claiming that the unavailable generated map asset exists.


The final compact-marker capture was re-run after spacing and glyph adjustments. It rendered as a valid 1280×720 PNG with the fort board directly below the battle status line. The ground board now has repeated crenellation blocks, four corner tower silhouettes with torch points, a dark central courtyard, room blocks, and compact `R` enemy markers at the gate approach. The upper board retains the wall-walk treatment. Full enemy names and HP remain in the battle readout, avoiding crowding the small map markers. The map remains visibly present while the command table stays available for placement and inspection.
