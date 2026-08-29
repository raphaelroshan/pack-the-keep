# P39 Pack Offer Card Verification

- Build: `0.23.1-pack-offer-card`
- Local render: Godot 4.7.2, macOS, 1600×900 at 100% scale
- Scope: automated presentation verification; human comprehension remains pending

Preparation now leads its command rail with a dedicated pack offer card. The selected doctrine shows its two granted pieces and placement costs, pack opening cost, strength, limitation, preferred floors and zones, open-lane or adjacency demand, strategic question, and explicit trade-off before the player spends materials.

Previous and Next browse the existing stable pack catalogue without changing `PackKeepState`. Open and Reserve call the existing authoritative handlers. The card distinguishes Available, Reserved, Opened, Needs Materials, and No Openings states, while the original dropdown remains beneath **Advanced Pack List** as a secondary fallback.

First Watch locks pack browsing and reserve. Its Open action remains disabled until the Gate inspection advances the lesson to the authored Pike Line step, then receives controller focus. At 125% scale the card remains in the stacked command rail.
