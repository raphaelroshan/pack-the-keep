# P71 Recovery action order — verification

Build `0.58.0-recovery-action-order` keeps every Recovery option and exact explanation visible while stably placing legal cards before blocked diagnostics. The authored room → piece → assignment → clear order is preserved within each readiness group, and Finish Recovery remains last.

Focused coverage verifies mixed ready/blocked states, a sole legal clear-assignment action, exhausted budgets, controller-first legal focus, responsive layout, and authoritative-state immutability. P5 Recovery actions, P37 Recovery hierarchy, K3 snapshots, P48 responsive layout, and P53 integrated flow pass locally.

The complete verification suite passes with 228 viable cases / 456 deterministic simulations. K8 completes 40 runs in 2293 ms and 120 large-text UI refreshes in 249 ms.

Normal 1600×900 and 1280×720 large-text renderer captures verify that the current legal action leads the command rail. These are automated presentation checks, not human comprehension evidence. Human P16 observation and owner distribution approval remain pending.
