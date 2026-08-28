# P13 — Mara Venn: A Second Door

## Arc contract

Mara's first bounded arc is carried by three visible boolean flags:

- `mara_workshop_repaired`
- `mara_station_trusted`
- `mara_second_door_open`

Resolving `workshop_can_wait` sets exactly one of the first two flags after its authoritative repair or assignment effect succeeds. At Gatehouse Lock's terminal Results, `mara_second_door` becomes eligible only when either earlier flag exists. Opening or refusing the route sets the third flag explicitly true or false.

## Commander variants

The Castellan frames the second door as a controlled breach in compact structure. The Warden frames it as a deliberate response lane. The underlying choices and effects remain identical; only authored setup and labels vary.

## Acceptance criteria

- Choice flags validate as stable booleans and apply only after all typed effects succeed.
- The future event is absent without a prior Mara flag and present after either Workshop path.
- Both commander variants render their authored setup and labels.
- All three flags persist, appear in the existing Ledger, and replay deterministically.
- The arc uses the generic event panel and adds no combat modifier, relationship score, or dialogue subsystem.
