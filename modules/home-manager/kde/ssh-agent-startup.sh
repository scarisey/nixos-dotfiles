#!/bin/bash
export SSH_ASKPASS="$(which ksshaskpass)"
export SSH_ASKPASS_REQUIRE=prefer

if ! pgrep -u $USER ssh-agent >/dev/null; then
	ssh-agent >~/.ssh-agent-info
fi
if [[ "$SSH_AGENT_PID" == "" ]]; then
	eval $(<~/.ssh-agent-info)
fi
