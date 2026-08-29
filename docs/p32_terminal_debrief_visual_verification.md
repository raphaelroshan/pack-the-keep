# P32 Terminal Debrief Visual Verification

- Build: `0.21.0-terminal-debrief`
- Local render: Godot 4.7.2, macOS, 1600×900
- Scope: presentation inspection only; this is not human playtest evidence

## 100% scale

- The damaged two-floor keep remains fully visible as evidence beside the debrief.
- The terminal panel replaces the recovery command rail and immediately distinguishes outcome, scenario, commander, resources, and three resolved phases.
- Each phase uses outcome-colored framing and names doctrine, principal pressure, defeated enemies, room damage, defender damage, and recovery use.
- The high-emphasis replay action and secondary Save Result / Return to Main Menu actions remain fixed and visible while detailed causal and fortress evidence scrolls independently.

## 125% scale

- The gameplay columns stack vertically at the supported scale.
- The debrief retains its bounded panel, complete timeline, independent detail scroll, and fixed action footer.
- No horizontal page scrolling is required; the page scroll provides access between the preserved keep and the debrief.

## State boundary

- Refreshing the panel leaves serialized keep state unchanged.
- A terminal save restored through Continue Saved Run derives the same outcome, fortress state, causal report, and replay experiment without adding save fields.
- Inter-wave Results continues to use the recovery action panel and never displays the terminal composition.

Human comprehension, emotional response, and replay intent remain pending structured playtest evidence.
