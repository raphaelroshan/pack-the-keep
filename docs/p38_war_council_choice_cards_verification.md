# P38 War Council Choice Cards Visual Verification

- Build: `0.23.0-war-council-cards`
- Local render: Godot 4.7.2, macOS, 1600×900 at 100% and 125% scale
- Scope: presentation inspection only; this is not human playtest evidence

The War Council now leads with two game-facing choice cards rather than a raw selected-loadout paragraph. The Commander card presents identity, passive strength, intervention, limitation, and first strategic question. The Defense card presents the keep, scenario identity and teaching question, objective, three-phase pressure arc, difficulty, peak pressure, terminal rule, and commitments fixed when entering the fortress.

Both cards provide Previous/Next actions. These actions select stable metadata in the existing dropdowns and call the existing `PackKeepState` selection path. The dropdowns remain in the command rail under **Advanced Selection** as a keyboard, controller, and accessibility fallback; the duplicate placeholder portrait and commander paragraph are removed from view.

First Watch renders the same composition with a visible lock notice and disables both card and fallback selection. At 125% UI scale the cards stack vertically rather than compressing their copy, and ordinary setup focus begins on the Commander card's Next action.

Automated inspection covers both commanders, scenario navigation and synchronization, tutorial locking, controller focus, 125% stacking, and non-mutating refresh. Whether new players understand the distinction between commander identity and scenario pressure remains pending structured human playtest evidence.
