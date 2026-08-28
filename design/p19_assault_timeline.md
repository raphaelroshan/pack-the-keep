# P19 Assault Timeline

## Player-facing purpose

Real-time combat needs a readable sense of cadence. The player should know which deterministic tick is resolving, how far the current second has progressed, and when each active threat is expected to make contact without opening an inspector or reading raw event history.

## Presentation contract

- Replace the undifferentiated battle progress bar beneath the fort with six labelled tick segments.
- Fill completed ticks, partially fill the active tick from the fractional battle clock, and leave future ticks visually distinct.
- Place compact enemy initial markers above their authored arrival tick using the existing stable enemy order and colors.
- Identify the next unresolved arrival in plain text.
- Preserve the existing route, target, focus, health, armor, smoke, break, and impact layers.
- Keep the timeline inside the existing board footer; do not add another command panel or scrolling section.

## Authority boundary

The timeline reads `battle_step`, `battle_clock`, enemy `arrival_step`, and defeat state. It does not schedule enemies, alter time, pause combat, or write save data.

## Acceptance criteria

1. Six tick segments remain readable from 1280×720 through 2560×1440.
2. Fractional progress advances between authoritative ticks and freezes when the battle is paused.
3. Every active enemy has one stable marker on its authored arrival tick.
4. Defeated enemies are visually de-emphasized or omitted from the next-arrival summary.
5. High contrast changes timeline colors without removing labels.
6. Inspecting or drawing the timeline does not change serialized state.

## Tests

- UI smoke validates six segments, fractional progress, stable arrival grouping, next-arrival summary, pause invariance, and serialized-state invariance.
- Real-renderer capture validates the footer at normal play distance with multiple arrival markers.
- Full repository verification remains required.

## Non-goals

- Scrubbing, seeking, or issuing commands from the timeline.
- Changing authored arrival timing.
- Per-frame simulation or sub-tick damage.
- A separate minimap, combat log, or timeline panel.
