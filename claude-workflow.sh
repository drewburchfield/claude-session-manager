#!/bin/bash

# Claude Code Session Workflow Manager
# Save and restore Claude Code sessions across restarts

SNAPSHOTS_DIR="$HOME/.claude-sessions"
mkdir -p "$SNAPSHOTS_DIR"

# Save current Claude sessions with timestamp
claude-save() {
  local timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
  local snapshot_file="$SNAPSHOTS_DIR/sessions-$timestamp.txt"

  echo "Saving current Claude sessions..."

  # Capture all running sessions
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

    # Only save if we have both directory and session
    if [ -n "$dir" ] && [ -n "$session" ]; then
      echo "$dir|$session" >> "$snapshot_file"
    fi
  done

  # Count saved sessions
  count=$(wc -l < "$snapshot_file" | tr -d ' ')
  echo "✓ Saved $count Claude sessions to:"
  echo "  $snapshot_file"
  echo ""
  echo "Sessions saved:"
  cat "$snapshot_file" | nl -w2 -s'. '
}

# Get the latest snapshot file
_get_latest_snapshot() {
  ls -t "$SNAPSHOTS_DIR"/sessions-*.txt 2>/dev/null | head -1
}

# List all available snapshots
claude-list() {
  if [ ! -d "$SNAPSHOTS_DIR" ] || [ -z "$(ls -A "$SNAPSHOTS_DIR"/sessions-*.txt 2>/dev/null)" ]; then
    echo "No snapshots found."
    echo "Run 'claude-save' to create your first snapshot."
    return 1
  fi

  echo "Available snapshots:"
  echo ""

  local count=1
  ls -t "$SNAPSHOTS_DIR"/sessions-*.txt | while read file; do
    local filename=$(basename "$file")
    local session_count=$(wc -l < "$file" | tr -d ' ')
    echo "$count. $filename ($session_count sessions)"
    count=$((count + 1))
  done
}

# Show restore commands in a copy-friendly format (latest by default)
claude-restore() {
  local snapshot_file="$1"

  # If no file specified, use the latest
  if [ -z "$snapshot_file" ]; then
    snapshot_file=$(_get_latest_snapshot)
    if [ -z "$snapshot_file" ]; then
      echo "No snapshots found. Run 'claude-save' first."
      return 1
    fi
    echo "Using latest snapshot: $(basename "$snapshot_file")"
    echo ""
  else
    # If user provided just a filename, prepend the directory
    if [[ "$snapshot_file" != /* ]]; then
      snapshot_file="$SNAPSHOTS_DIR/$snapshot_file"
    fi

    if [ ! -f "$snapshot_file" ]; then
      echo "Snapshot file not found: $snapshot_file"
      echo ""
      echo "Available snapshots:"
      claude-list
      return 1
    fi
  fi

  echo "Copy these commands (one per terminal tab):"
  echo ""

  local count=1
  while IFS='|' read -r dir session; do
    if [ -n "$dir" ] && [ -n "$session" ]; then
      echo "# Tab $count: $(basename "$dir")"
      echo "cd '$dir' && claude --resume '$session'"
      echo ""
      count=$((count + 1))
    fi
  done < "$snapshot_file"
}

# View saved sessions from a specific snapshot
claude-show() {
  local snapshot_file="$1"

  # If no file specified, use the latest
  if [ -z "$snapshot_file" ]; then
    snapshot_file=$(_get_latest_snapshot)
    if [ -z "$snapshot_file" ]; then
      echo "No snapshots found."
      return 1
    fi
    echo "Latest snapshot: $(basename "$snapshot_file")"
  else
    # If user provided just a filename, prepend the directory
    if [[ "$snapshot_file" != /* ]]; then
      snapshot_file="$SNAPSHOTS_DIR/$snapshot_file"
    fi

    if [ ! -f "$snapshot_file" ]; then
      echo "Snapshot file not found: $snapshot_file"
      echo ""
      echo "Available snapshots:"
      claude-list
      return 1
    fi
  fi

  echo ""
  echo "Saved Claude sessions:"
  echo ""

  local count=1
  while IFS='|' read -r dir session; do
    if [ -n "$dir" ] && [ -n "$session" ]; then
      echo "$count. Directory: $dir"
      echo "   Session:   $session"
      echo ""
      count=$((count + 1))
    fi
  done < "$snapshot_file"
}
