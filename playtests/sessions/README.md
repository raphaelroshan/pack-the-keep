# Human playtest session evidence

Create one JSON file per observed session with `tools/new_playtest_session.py`, supplying the tested executable and the bundled `playtest-build.json`, or copy the matching unfilled file from the artifact's `playtest-templates/` directory. Complete it according to `docs/p16_human_playtest_protocol.md`; templates remain invalid evidence until their blank human-owned fields are filled. The artifact's `PLAYTEST_README.md` provides the same exact build identity and observation prompts when the repository is not open. Give the same repeated problem a stable `issue_key` so `tools/summarize_p16_playtests.py` can surface it as a task candidate.

These records are human-authored evidence. Automation may validate their structure and matrix coverage, but it must not create successful observations, mark sessions complete, change the human gate, or imply release approval.
