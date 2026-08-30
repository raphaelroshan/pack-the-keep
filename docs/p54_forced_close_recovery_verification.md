# P54 — Packaged forced-close recovery verification

- Build: `0.30.1-forced-close-recovery`
- Platform gate: exported Windows x86_64 candidate

The packaged lifecycle now contains six reported phases plus external forced-termination evidence. After clean install, relocated reinstall, stale backup, missing profile, and schema upgrade, the runner launches the relocated executable in `forced_close_prepare`, waits for a flushed readiness sentinel, kills the process, and relaunches it as `forced_close_recovery`.

The recovery report must prove malformed primary detection, run recovery at battle step one, settings recovery at 125% UI scale with the 2560×1440 preset and controller remap, and successful rewrite of schema-4 run and schema-5 settings primaries. P12 and K8 validators independently reject missing termination or recovery evidence.

Python coverage verifies the lifecycle matrix, termination coordinator, forced-close report acceptance, and negative recovery cases. The tagged Windows workflow is the authoritative end-to-end platform evidence.
