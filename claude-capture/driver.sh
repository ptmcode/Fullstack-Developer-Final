#!/bin/bash
# Claude remote driver: executes command files Claude drops into claude-capture/.
# Press Ctrl+C to stop it at any time.
CAP="$(cd "$(dirname "$0")" && pwd)"
export PATH="$PATH:${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools"
echo "Driver running. Waiting for commands from Claude... (Ctrl+C to stop)"
rm -f "$CAP/cmd.sh" "$CAP"/done_* 2>/dev/null
SEQ=0
while true; do
  if [ -f "$CAP/cmd.sh" ]; then
    SEQ=$((SEQ+1))
    echo "--- running command #$SEQ"
    bash "$CAP/cmd.sh" > "$CAP/out.txt" 2>&1
    rm -f "$CAP/cmd.sh"
    rm -f "$CAP"/done_* 2>/dev/null
    touch "$CAP/done_$SEQ"
  fi
  sleep 1
done
