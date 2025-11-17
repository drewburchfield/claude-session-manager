# Claude Code Session Manager

> Track and restore Claude Code sessions across terminal restarts.

A bash utility for managing multiple Claude Code CLI sessions across terminal tabs and system restarts.

## The Problem

You run multiple Claude Code sessions in different terminal tabs. When your terminal crashes or you restart your computer, you lose track of which session was running in which directory. Restoring your workspace means hunting through session files and manually matching them to projects.

## The Solution

Claude Session Manager captures all running Claude sessions with their directories and session IDs, saves timestamped snapshots, and generates copy-paste commands to restore everything.

Features:
- Real-time visibility into all running Claude sessions
- Timestamped snapshots that preserve session state
- One-command restoration with copy-paste ready commands
- Historical snapshots for point-in-time restoration

## Installation

**Prerequisites:**
- macOS 10.15+
- Claude Code CLI
- Bash or Zsh
- Any terminal emulator (iTerm2, Terminal.app, Warp, Alacritty, etc.)

**Quick Install:**
```bash
git clone https://github.com/drewburchfield/claude-session-manager.git
cd claude-session-manager
./install.sh
source ~/.zshrc  # or source ~/.bashrc
```

**Manual Installation:**

1. Copy the scripts:
   ```bash
   cp claude-sessions.sh ~/.claude-sessions-helper.sh
   cp claude-workflow.sh ~/.claude-workflow-helper.sh
   chmod +x ~/.claude-sessions-helper.sh
   chmod +x ~/.claude-workflow-helper.sh
   ```

2. Update your shell config (`~/.zshrc` or `~/.bashrc`):
   ```bash
   # Claude Code session management helpers
   source ~/.claude-sessions-helper.sh
   source ~/.claude-workflow-helper.sh
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc  # or source ~/.bashrc
   ```

## Usage

### Quick Start

Before shutdown:
```bash
claude-save
```

After restart:
```bash
claude-restore
```

Copy-paste each command into a new terminal tab.

---

### Commands

**claude-sessions** - View all running sessions

```bash
$ claude-sessions
Current Running Claude Code Sessions:

PID: 12345 | Dir: /Users/you/project | Session: abc123-def456-...
PID: 12346 | Dir: /Users/you/other  | Session: xyz789-uvw012-...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Available Commands:

  claude-sessions  - View all running Claude sessions
  claude-save      - Save current sessions (timestamped)
  claude-restore   - Get copy-paste restore commands
  claude-list      - List all saved snapshots
  claude-show      - Show sessions in a snapshot

Quick workflow:
  1. claude-save     (before shutdown)
  2. claude-restore  (after restart)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**claude-save** - Save current sessions with timestamp

```bash
$ claude-save
✓ Saved 8 Claude sessions to:
  /Users/you/.claude-sessions/sessions-2025-11-17_14-30-00.txt
```

Each save creates a new timestamped file.

**claude-restore** - Get restore commands

```bash
$ claude-restore
Copy these commands (one per terminal tab):

# Tab 1: project-a
cd '/Users/you/project-a' && claude --resume 'abc123-def456-...'

# Tab 2: project-b
cd '/Users/you/project-b' && claude --resume 'xyz789-uvw012-...'
```

Uses latest snapshot by default. Specify a snapshot: `claude-restore sessions-2025-11-16_09-00-00.txt`

**claude-list** - List all snapshots

```bash
$ claude-list
Available snapshots:

1. sessions-2025-11-17_14-30-00.txt (8 sessions)
2. sessions-2025-11-17_09-00-00.txt (10 sessions)
3. sessions-2025-11-16_18-45-00.txt (12 sessions)
```

**claude-show** - View snapshot contents

```bash
$ claude-show
Latest snapshot: sessions-2025-11-17_14-30-00.txt

Saved Claude sessions:

1. Directory: /Users/you/project-a
   Session:   abc123-def456-...
```

Uses latest snapshot by default. Specify a snapshot: `claude-show sessions-2025-11-16_09-00-00.txt`

---

## Common Workflows

### Daily Restart
```bash
claude-list          # Check yesterday's snapshots
claude-restore       # Get restore commands
```

Copy each command into new terminal tabs.

### System Restart
```bash
claude-save          # Before shutdown
claude-restore       # After restart
```

### Context Switching
```bash
claude-save                                      # Save current project
claude-restore sessions-2025-11-17_14-30-00.txt # Restore previous project
```

### View Past Sessions
```bash
claude-list                                      # See all snapshots
claude-show sessions-2025-11-10_15-30-00.txt    # View specific day
claude-restore sessions-2025-11-10_15-30-00.txt # Restore that day
```

## How It Works

### Session Detection
1. Scans for `claude --` processes via `ps aux`
2. Gets working directories via `lsof`
3. Extracts session IDs from command arguments or session files

Claude Code stores sessions at `~/.claude/projects/[encoded-directory]/[session-uuid].jsonl`. Directory paths encode by replacing `/` with `-` (e.g., `/Users/you/project` becomes `-Users-you-project`).

### Snapshot Format
Pipe-delimited text:
```
/Users/you/project-a|abc123-def456-ghi789-jkl012-mno345pqr678
/Users/you/project-b|xyz789-uvw012-stu345-pqr678-mno901def234
```

Stored in `~/.claude-sessions/sessions-YYYY-MM-DD_HH-MM-SS.txt`

## File Locations

| Purpose | Location |
|---------|----------|
| Helper scripts | `~/.claude-sessions-helper.sh`<br>`~/.claude-workflow-helper.sh` |
| Shell config | `~/.zshrc` or `~/.bashrc` |
| Snapshots | `~/.claude-sessions/` |
| Claude sessions | `~/.claude/projects/` |

## Maintenance

**Clean old snapshots:**
```bash
# List all
ls -lh ~/.claude-sessions/

# Remove older than 30 days
find ~/.claude-sessions -name "sessions-*.txt" -mtime +30 -delete

# Remove specific snapshot
rm ~/.claude-sessions/sessions-2025-10-15_*.txt
```

**Check size:**
```bash
du -sh ~/.claude-sessions/
```

Typical snapshot: 1-2 KB.

## Troubleshooting

**"No snapshots found"**
Run `claude-save` at least once.

**"No session ID found"**
Session files might not exist until first interaction. Send a message in the Claude session, then run `claude-sessions` again.

**Commands not found after installation**
1. Restart your terminal or run `source ~/.zshrc`
2. Verify scripts exist: `ls -la ~/.claude-*helper.sh`
3. Check shell config: `grep claude ~/.zshrc`

**Sessions restore in wrong directories**
Check snapshot contents with `claude-show`. Edit the snapshot file manually if needed.

## FAQ

**Which terminals does this work with?**
All macOS terminal emulators: iTerm2, Terminal.app, Warp, Alacritty, Kitty, and others.

**Does this work with Claude Code Desktop?**
No. This is for the Claude Code CLI only.

**Will this work on Linux or Windows?**
Currently macOS only. The `lsof` and `ps` commands need adjustment for other platforms.

**Can I edit snapshots manually?**
Yes. They're plain text with format `directory|session-id` (one per line).

**Does this backup my conversation history?**
No. This saves only session IDs and directories. Conversations remain in `~/.claude/projects/`.

**Where are snapshots saved?**
`~/.claude-sessions/sessions-YYYY-MM-DD_HH-MM-SS.txt`

**Do I need to save before every shutdown?**
Yes, if you want to restore those sessions later.

## Uninstall

```bash
./uninstall.sh
```

Removes helper scripts and shell config. Optionally keeps or deletes snapshots.

## License

MIT License - see LICENSE file.

Copyright (c) 2025 Drew Burchfield
