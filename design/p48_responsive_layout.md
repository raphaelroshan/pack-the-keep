# P48 — Responsive War Council and Preparation

## Player-facing purpose

Keep every run-defining choice and primary action readable and reachable on a 1280×720 display, at 1600×900, and with enlarged UI text. Narrow layouts should become a deliberate single-column flow instead of allowing the right command rail to extend beyond the visible window.

## Presentation contract

- Windowed launch size is fitted inside the active display while preserving the selected aspect ratio.
- Layout decisions use the effective width after UI scaling, not only the requested window width.
- War Council and Preparation stack the main surface above the command rail when the effective width is below the safe two-column threshold.
- At normal 1600×900 and 100% UI scale, the board and command rail may remain side by side.
- At 1280×720 or 125%+ UI scale, the command rail moves below the main surface and remains reachable through the page scroll.
- The top navigation hides nonessential screen shortcuts at narrow widths while retaining the current screen identity, Main Menu/Back behavior, and Settings access.
- Controller focus must begin on the same primary action and scrolling must reveal the focused control.

## Authority and data shape

This is presentation-only. `PackKeepState`, content definitions, command handlers, save schemas, combat timing, placement legality, resources, and replay keys do not change. The responsive decision is derived from viewport size and `content_scale_factor` and is never serialized into a run save.

## Acceptance criteria

1. A 1600×900, 100% layout uses the intentional two-column composition.
2. A 1280×720 layout stacks War Council and Preparation without horizontal overflow.
3. A 1600×900 layout at 125% UI scale stacks without clipping.
4. Commander, scenario, objective, risk, pack context, placement controls, and primary commit action remain present and reachable.
5. Controller focus begins on the War Council commit action and Preparation assault action, and focused controls can be scrolled into view.
6. Window fitting never enlarges a selected size and preserves its aspect ratio.
7. Responsive changes do not mutate serialized authoritative state.

## Test cases

- Pure window-fit cases for 1600×900 on 1280×720, 2560×1440 on 1920×1080, and an already fitting window.
- Explicit 1280×720 War Council and Preparation layout assertions.
- Explicit 1600×900 normal-scale and 125%-scale assertions.
- Global rectangle checks for the main column, command rail, War Council cards, and primary action.
- Focus checks after entering War Council and Preparation.
- Full repository verification and graphical captures at 1280×720 and 1600×900.

## Non-goals

- No simulation, balance, save, content, or combat changes.
- No new menus or navigation model.
- No broad visual-asset replacement; that remains P49.
- No claim that automated layout evidence is human comprehension evidence.
