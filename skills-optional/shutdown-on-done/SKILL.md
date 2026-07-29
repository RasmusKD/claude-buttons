---
description: Shut down the PC when this chat is completely done with its work
argument-hint: on | off | status | group-on | group-done | group-off
disable-model-invocation: true
allowed-tools: Bash(node "{{SCRIPT}}" toggle request-off), Bash(node "{{SCRIPT}}" toggle on --this-turn), Bash(node "{{SCRIPT}}" toggle off), Bash(node "{{SCRIPT}}" toggle status), Bash(node "{{SCRIPT}}" toggle group-done), Bash(node "{{SCRIPT}}" toggle group-off)
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

**group-on** — group ("last one out") mode, for when several chats are running at once (a grid) and the PC must wait for ALL of them: the LAST chat to finish triggers the shutdown, not the first. The user clicks this in each chat they want to wait for.
- Run `node "{{SCRIPT}}" toggle group-on` once to join the group. **Like request-on, joining is the consent step and is not pre-authorized by default, so it may prompt; that approval IS the consent to a group power-off. `-OneClickArm` waives it. Run it the same way either case and do not remark on which happened.**
- Then treat it EXACTLY like **on**: keep working, and only when THIS chat is COMPLETELY done (background shells, subagents, and workflows all finished) run this as the final action of your wrap-up response:
  `node "{{SCRIPT}}" toggle group-done`
  If you were the last chat still working, the PC powers off 60 seconds after this response; if other chats are still going, you simply drop out of the group and say so. Never run group-done early: it is judged completion, exactly like arming.
- The fulfilled-once rule above applies here too: if the PC already shut down via the group earlier in this conversation and it has since resumed, do not rejoin.

**group-off** — run `node "{{SCRIPT}}" toggle group-off` to leave the group WITHOUT shutting down; the other chats still trigger when they finish.

**off** — run `node "{{SCRIPT}}" toggle off` (this also aborts a countdown already in flight, and cancels the WHOLE group) and drop any standing arm-at-completion request from this conversation.

**status** — run `node "{{SCRIPT}}" toggle status` and also say whether an arm-at-completion request or group membership is standing in this conversation.

Relay the script's output to the user. Grace period is 60 seconds; `shutdown -a` aborts it.
