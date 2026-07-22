---
description: Shut down the PC when this chat is completely done with its work
argument-hint: on | off | status
disable-model-invocation: true
allowed-tools: Bash(node "{{SCRIPT}}" toggle request-off), Bash(node "{{SCRIPT}}" toggle on --this-turn), Bash(node "{{SCRIPT}}" toggle off), Bash(node "{{SCRIPT}}" toggle status)
---
The user wants the PC to shut down when this chat's work is COMPLETELY finished. This is typically sent while you are mid-task because the user is leaving (e.g. going to sleep): keep working normally, and treat the shutdown as the very last thing that happens.

Requested action: $ARGUMENTS (if empty, report status)

**on** — the one rule: arm the shutdown only at the moment everything is truly done, and only for ONE power-off.

A shutdown request is fulfilled by a single power-off; it does not stand forever. If earlier in THIS conversation the PC already shut down (you announced "PC shutting down in 60 seconds" or similar and the chat has since resumed on a later turn), the request is DONE. Do not arm again, do not re-run `request-on`, and drop the standing request from your working memory. The user resuming the chat means they came back to keep working, not to be shut down a second time. Arm again only if they explicitly ask again in the resumed session. This rule wins over every bullet below.

- First, for a genuine un-fulfilled request, run `node "{{SCRIPT}}" toggle request-on` once to record the standing request (external button panels read this marker for their toggle state). **By default this one command is not pre-authorized and will ask the user to approve it — that approval IS the consent to arm a power-off, so do not try to route around it, and do not treat the prompt as an error.** Everything after it runs unattended, which is the point: the user approves once, then leaves. An install run with `-OneClickArm` waives that approval deliberately, so the command may simply succeed with no prompt; run it identically either way and do not remark on which happened.
- Still working, or background tasks/subagents/workflows pending? Acknowledge briefly, continue the work, and remember this standing request. When EVERYTHING is verified complete (background shells included) and you are writing your final wrap-up response, run this as that response's final action:
  `node "{{SCRIPT}}" toggle on --this-turn`
  The PC then powers off 60 seconds after that response ends. Never arm early: the Stop hook fires when a response ends and is blind to still-running work, so arming before you are done shuts the PC down mid-task.
- Nothing running and nothing left to do? Then you ARE at the wrap-up: run the command above now, tell the user the PC will shut down 60 seconds after this response, and end your response.
- If the session continues past the arming and the shutdown did NOT fire (you aborted a countdown, or the user replied before your arming response ended so it never triggered), the flag is one-shot, so re-arm at the new true completion point. If it DID fire, the fulfilled-request rule above applies: do not re-arm. When unsure whether a prior arm fired, run `toggle status` first; a standing request that is no longer active already fired or was cancelled, so treat it as fulfilled.

**off** — run `node "{{SCRIPT}}" toggle off` (this also aborts a countdown already in flight) and drop any standing arm-at-completion request from this conversation.

**status** — run `node "{{SCRIPT}}" toggle status` and also say whether an arm-at-completion request is standing in this conversation.

Relay the script's output to the user. Grace period is 60 seconds; `shutdown -a` aborts it.
