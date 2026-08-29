# P39 Preparation Pack Offer Card

## Intent

Preparation should present the selected pack as a doctrine decision rather than a dropdown operation. Before spending materials, the player should see what the pack adds, what pressure it answers, what space it demands, and what weakness it accepts.

## Authority

The offer card is presentation-only. `PackKeepState.pack_preview()`, `open_pack()`, and `reserve_pack()` remain the sole owners of availability, costs, opening limits, contents, and reserve state. Card browsing changes only the existing selector; Open and Reserve use the existing handlers.

## Acceptance

- The selected pack exposes doctrine, contents, cost, strength, weakness, spatial demand, and strategic question.
- Previous/Next browse stable pack IDs without granting content.
- Opened, reserved, unaffordable, and exhausted-opening states are visibly distinct.
- First Watch locks browsing and reserve while enabling Open only at its authored Pike Line step.
- The advanced pack dropdown remains available outside First Watch.
- Rendering is non-mutating and controller focus begins on the card's Open action.
