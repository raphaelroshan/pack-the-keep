# P40 Preparation Command Hierarchy

## Intent

Preparation should read as three verbs: choose a pack, shape the fortress, and commit the defense. Low-frequency selectors and diagnostic layout detail must remain available without competing with those actions.

## Authority

This is a presentation-only regrouping. Pack, placement, removal, scenario doctrine, inspection, save, and assault commands retain their existing handlers and `PackKeepState` ownership. Expanding or collapsing advanced controls never changes run state.

## Acceptance

- The command rail presents numbered Pack and Placement stages in that order.
- Piece and floor selectors sit beside placement actions rather than in a separate generic inspector section.
- The advanced pack catalogue, invasion doctrine selector, and full layout lens are collapsed by default and remain reachable.
- Map inspection and the primary Ready Defense action remain visible and authoritative.
- First Watch can focus and complete every existing target.
- Toggling advanced controls is non-mutating and remains usable at 125% scale.
