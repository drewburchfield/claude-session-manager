#!/bin/bash

# Claude Code Session Manager
# Shows all running Claude Code sessions with their directories and session IDs

claude-sessions() {
  echo "Current Running Claude Code Sessions:"
  echo ""

  ps aux | grep "claude --" | grep -v grep | awk '{print $2}' | while read pid; do
    # Get working directory
    dir=$(lsof -p $pid 2>/dev/null | grep cwd | awk '{print $NF}')

    # Get session from command line if available
    session=$(ps -p $pid -o command= | grep -oE '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}')

    # If no session in command, find it from the encoded directory
    if [ -z "$session" ]; then
      # Encode the directory path
      encoded=$(echo "$dir" | sed 's/\//-/g')
      # Find the most recently modified session file in that directory
      session=$(ls -t ~/.claude/projects/$encoded/*.jsonl 2>/dev/null | head -1 | xargs basename 2>/dev/null | sed 's/.jsonl//')
    fi

    echo "PID: $pid | Dir: $dir | Session: $session"
  done

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Available Commands:"
  echo ""
  echo "  claude-sessions  - View all running Claude sessions"
  echo "  claude-save      - Save current sessions (timestamped)"
  echo "  claude-restore   - Get copy-paste restore commands"
  echo "  claude-list      - List all saved snapshots"
  echo "  claude-show      - Show sessions in a snapshot"
  echo ""
  echo "Quick workflow:"
  echo "  1. claude-save     (before shutdown)"
  echo "  2. claude-restore  (after restart)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}
