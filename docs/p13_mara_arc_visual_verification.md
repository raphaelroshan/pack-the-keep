# P13 Mara Venn Arc Visual Verification

## Capture

- Build: `0.13.3-mara-second-door`
- Viewport: 1280×720 windowed
- Screen: Gatehouse Lock terminal Results
- Commander: The Warden
- Prior arc choice: Workshop repaired

## Observed

- `AUTHORED EVENT — A Second Door | RESULTS` appears in the existing command table.
- The Warden-specific setup describes a deliberate response lane, and both buttons use Warden-specific movement language.
- The generic consequence text remains readable beneath each choice without horizontal clipping.
- The repaired Workshop is visible on the ground-floor board while Mara's later operational decision is presented.
- The command-table scrollbar remains visible; the event does not obscure the fort or require a new screen.
- The global subtitle now names Greywatch rather than incorrectly describing every commander as the Castellan.

The capture was used only for local inspection and removed afterward. Headless coverage verifies both commander variants, three bounded flags, future-event eligibility, save/load persistence, Ledger visibility, and render invariance.
