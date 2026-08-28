# Human playtest session evidence

Create one JSON file per observed session with `tools/new_playtest_session.py`, supplying the tested executable and the bundled `playtest-build.json`, then complete it according to `docs/p16_human_playtest_protocol.md`. Give the same repeated problem a stable `issue_key` so `tools/summarize_p16_playtests.py` can surface it as a task candidate.

These records are human-authored evidence. Automation may validate their structure and matrix coverage, but it must not create successful observations, mark sessions complete, change the human gate, or imply release approval.
