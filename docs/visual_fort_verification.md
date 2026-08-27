# Visual Fort Initial-Run Verification

The visual-fort capture was run under a real virtual display with Godot 4.4.1 at 1280×720. The Preparation capture rendered a valid PNG and confirmed the existing Greywatch art banner, command table, scenario context, and the updated combat explanation remain available before the battle begins.

The Battle capture rendered a valid PNG and showed the new square-shaped fort treatment: a thick outer wall ring, a large open central courtyard, named interior rooms, an upper wall-walk surface, a ground-floor Gate/yard/supply layout, and the Fire Team placed on an upper-floor wall position. The map remains partially below the fold because the existing left-side battle report and command surfaces are intentionally retained; the command panel remains independently scrollable. The screenshot proved the map’s stronger silhouette and wall-versus-interior distinction without relying on a generated map file.

The capture also confirmed that the live readout names the scenario, enemy approach/contact state, route, target, combat metrics including ammunition spent, and the real-time auto-battle rule. The visible placeholder enemies in the captured short wave were already stopped by the two placed defenders before reaching a room, so the open-gate movement path was verified by the renderer contract and coordinates but not captured at mid-approach in this particular frame. A later capture should hold at step zero or use a weaker layout if a mid-route visual is needed.

The generated pixel-art map request was attempted before implementation but image generation was unavailable at the current quota. The procedural fort renderer is therefore a functional, deterministic fallback and is documented as such; no generated map asset is claimed.
