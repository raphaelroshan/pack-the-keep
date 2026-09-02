# PTK-EA-3 — Twinwatch and Marshal Verification

Twinwatch now owns six scenarios: `the_divided_bell`, `the_cut_standard`, `before_the_horn`, `the_unlit_stair`, `two_fires`, and `rimebound_relief`. Its paired-bastion rule, divided room graph, western/eastern approaches, medium-depth recovery, and two-plan coverage remain authoritative in `PackKeepState`.

The Marshal is the fourth commander. Posted Orders adds one response damage only to assigned combat defenders. Relief Order restores four health only to living damaged assigned defenders and is limited to once per assault. The no-op, command cost, persistence, and deterministic damage contracts are covered by `tests/test_early_access_campaign.gd`; all four commander/keep combinations are included in the expanded replay matrix.

Ridge Company plus Mason Train forms a posted split defense. Ridge Company plus Fallback Convoy keeps one command anchor and one independent relief line.
