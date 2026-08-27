# P10 Controller and Scaling Visual Verification

## Captures

- Runtime: Godot 4.7.2 on macOS, 1280×720 window.
- Default scale: preparation retains the established side-by-side keep and command rail, now inside a page-level vertical safety scroll.
- 125% scale: the keep board and command rail stack vertically rather than clipping horizontally.
- Settings detail: high contrast, reduced motion, the 125% scale label, action selector, current keyboard/controller binding, rebind action, and reset action remain legible at the larger scale.

## Observations

- The two keep floors remain readable together at 125% without horizontal truncation.
- Large-scale layout exposes a visible vertical scrollbar and lets controller focus reveal off-screen controls.
- Binding text names both keyboard and controller inputs; current values are not communicated by color alone.
- The wider stacked command panel prevents the controller binding description from collapsing into a narrow column.
- Default 100% layout retains the prior board footprint and scrollable command rail.

## Result

PASS — 100% preserves the established layout, while 125% uses a readable stacked flow with reachable settings and explicit input labels.
