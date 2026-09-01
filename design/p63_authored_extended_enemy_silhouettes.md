# P63 — Authored Extended Enemy Silhouettes

## Player-facing purpose

Complete the board-scale enemy language so every hostile family has an original silhouette rather than a borrowed character tile. Each shape should communicate the enemy's tactical verb before the player reads its name: guard, obscure, break, cut command, rush, or conceal.

## Presentation data

`BoardVisualRegistry` owns a stable original SVG path for all ten enemy IDs. The six P63 silhouettes join the four P62 core enemies at the same text-free 32×32 source scale. Existing procedural enemy profiles remain underneath as color/shape redundancy and as the fallback when a texture is unavailable.

No enemy ID, doctrine, arrival, route, target priority, armor, concealment, momentum, damage, save field, or simulation command changes.

## Acceptance criteria

1. Shield Guard, Ash Slinger, Shieldbreaker, Standard Cutter, Outrider, and Gloam Knife resolve distinct original silhouettes.
2. The visual motif matches each existing rule: shield, sling/smoke, breaking axe, cut standard, forward charge, and concealed blades.
3. Every source is transparent, text-free, and designed on a 32×32 view box for the 13–20px board range.
4. All ten shipped enemy IDs now use authored actor assets; unknown IDs retain procedural fallback.
5. Health, armor, smoke, command-hunter, momentum, concealment, focus, target, and cadence overlays remain dominant.
6. Asset lookup and drawing remain presentation-only and do not mutate `KeepState`.

## Test cases

- Enumerate all ten enemy IDs and assert unique, loadable authored paths.
- Assert an unknown enemy reports procedural fallback with no texture path.
- Assert the board snapshot reports a complete authored enemy set and no temporary actor dependency.
- Capture representative real-scale assaults for every extended family.
- Preserve deterministic serialization before and after rendering and high-contrast toggles.
