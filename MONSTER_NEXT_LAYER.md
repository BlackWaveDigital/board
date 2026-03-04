# Monster Next Layer — Build Plan

## Context

Full strategy doc lives in `myalchemy/blackwave-hq` at `strategy/monster-next-layer.md`. This doc is the actionable build guide for the Monster.

The ADBOX DevTracker already tracks developers via GitHub API — commits, PRs, reviews, daily metrics, leaderboards, performance scores. All async. The Monster gives us live runtime telemetry that GitHub can't: who's coding right now, what servers are running, test results as they happen, what Claude is building.

The goal: bridge live Monster telemetry into the existing DevTracker. Same leaderboard. Same scoring. Same UI. But live.

---

## Phase 1: Heartbeat Agent (START HERE)

A lightweight script on the Monster that reports machine state to the ADBOX backend.

### What it reports

Every 30-60 seconds, check and POST:

```json
{
  "machine_id": "monster",
  "timestamp": "2026-03-04T12:00:00Z",
  "worktrees": [
    {
      "name": "hurb-3",
      "branch": "hurb-3",
      "owner": "Daniel",
      "fe_port": 3103,
      "be_port": 4103,
      "fe_running": true,
      "be_running": false,
      "claude_active": true,
      "last_commit": "abc1234",
      "last_commit_message": "fix payment flow",
      "last_commit_time": "2026-03-04T11:45:00Z",
      "uncommitted_changes": 3,
      "ahead_of_remote": 2
    }
  ],
  "system": {
    "cpu_percent": 34,
    "memory_used_gb": 128,
    "memory_total_gb": 512,
    "disk_used_gb": 450,
    "disk_total_gb": 1900
  }
}
```

### How to detect each field

```bash
# Check if frontend server is running on a port
netstat -ano | findstr ":3103" | findstr "LISTENING"
# or: curl -s -o /dev/null -w "%{http_code}" http://localhost:3103 (200 = running)

# Check if backend server is running on a port
netstat -ano | findstr ":4103" | findstr "LISTENING"

# Check if Claude Code is running in a worktree
# Look for claude processes and match their working directory
wmic process where "name='node.exe' and commandline like '%claude%'" get processid,commandline
# or on Git Bash: ps aux | grep claude

# Git state per worktree
cd /d/blackwave/adbox/hurb-3
git log -1 --format="%H %s %aI"          # last commit hash, message, time
git status --porcelain | wc -l            # uncommitted changes count
git rev-list --count origin/hurb-3..HEAD  # commits ahead of remote

# System stats
wmic cpu get loadpercentage
wmic os get freephysicalmemory,totalvisiblememorysize
wmic logicaldisk get size,freespace,caption
```

### Script location

`D:\blackwave\scripts\heartbeat.sh`

Runs via: `while true; do bash /d/blackwave/scripts/heartbeat.sh; sleep 30; done`

Or better: a Node script at `D:\blackwave\scripts\heartbeat.js` that runs as a persistent process.

### Where it POSTs

**Option A (local Monster ADBOX instance):** `http://localhost:4150/api/v1/superadmin/dev-tracker/machine-heartbeat`
- Uses the testing worktree's backend (port 4150)
- Zero latency, zero auth complexity
- Requires backend running on Monster

**Option B (Railway):** `https://adbox-backend.railway.app/api/v1/superadmin/dev-tracker/machine-heartbeat`
- Uses production/staging backend
- Needs API key auth
- Works from anywhere

**Recommendation:** Start with Option A locally. Add Option B once Tailscale is live for remote monitoring.

---

## Phase 2: Live Session Tracking

After heartbeat is running and stable.

### New model: DevSession

```
DevSession {
  id                    INTEGER PRIMARY KEY
  developer_id          INTEGER FK -> Developer
  machine_id            VARCHAR (e.g., "monster", "macbook")
  worktree_name         VARCHAR (e.g., "hurb-3")
  branch                VARCHAR
  started_at            TIMESTAMP
  ended_at              TIMESTAMP NULL
  status                ENUM('active', 'idle', 'ended')
  commits_count         INTEGER DEFAULT 0
  lines_added           INTEGER DEFAULT 0
  lines_removed         INTEGER DEFAULT 0
  tests_run             INTEGER DEFAULT 0
  tests_passed          INTEGER DEFAULT 0
  tests_failed          INTEGER DEFAULT 0
  claude_turns          INTEGER DEFAULT 0 (number of AI interactions)
}
```

### Session lifecycle

1. Heartbeat detects Claude process in worktree -> create DevSession (status: active)
2. Each heartbeat tick while active -> update commit count, lines changed
3. No Claude process detected for 5 min -> status: idle
4. No activity for 30 min -> status: ended, set ended_at
5. Claude process reappears -> new session

### DevTracker frontend changes

- ActiveBranchesCard: green dot = active session, yellow = idle, grey = no session
- DeveloperStatCard: "Currently active in hurb-3" or "Last session: 2h ago"
- ActivityFeedCard: real-time entries "Daniel started session in hurb-6", "Nick pushed 3 commits from juhnk"

---

## Phase 3: Test and Build Telemetry

### What to capture

- Jest test runs: parse stdout for pass/fail/skip counts, duration, coverage
- Build times: frontend bundle time, backend compilation
- Lint results: error/warning counts

### How

Heartbeat agent watches for test runner processes. When a test process exits:
1. Check exit code (0 = pass, non-zero = fail)
2. Parse the last N lines of terminal output for summary stats
3. POST to `POST /api/v1/superadmin/dev-tracker/test-results`

Alternative: wrap `npm test` in a script that captures output and reports automatically.

---

## Phase 4: PM Claude

Dedicated Claude session that acts as project manager.

### Setup

```
D:\blackwave\pm\
  ├── CLAUDE.md          <- PM Claude's context and rules
  ├── state/             <- local state files PM Claude maintains
  └── alerts/            <- alerts PM Claude has generated
```

### PM Claude's CLAUDE.md

Tells Claude:
- You are the PM. You don't write code.
- Read BOARD.md, heartbeat data, DevTracker API, git state across all worktrees
- Detect: scope drift, file conflicts, idle sessions, blocked devs
- Write: daily summaries, alerts, task suggestions
- Update BOARD.md task queue based on GitHub issues + priorities

### Trigger options

- **Cron**: run every 15 min via `claude --print` or `claude --message`
- **Event-driven**: heartbeat agent triggers PM Claude on interesting events (new session, commit to testing, test failure)
- **Always-on**: persistent Claude session that reads events from a file/pipe

Start with cron. Graduate to event-driven once the data flow is proven.

---

## Phase 5: Real-Time Dashboard (WebSocket)

Push events to DevTracker frontend instead of polling.

- Add Socket.IO or SSE to ADBOX backend
- Heartbeat agent emits events to backend
- Backend broadcasts to connected frontends
- LeaderboardCard updates live as commits land
- PM Claude alerts appear as toasts/notifications

This is last because it's polish. The data and intelligence layers need to work first.

---

## File Inventory (Monster)

After all phases, the Monster has:

```
D:\blackwave\
  ├── adbox.git/                    <- bare repo (exists)
  ├── adbox/                        <- worktrees (exists)
  │   ├── hurb-1/ through hurb-10/
  │   ├── juhnk/
  │   ├── danbox/
  │   └── testing/
  ├── board/                        <- adbox-board repo (exists)
  ├── scripts/                      <- utility scripts (exists)
  │   ├── onboard.sh                <- (exists)
  │   ├── add-worktree.sh           <- (exists)
  │   ├── status.sh                 <- (exists)
  │   ├── heartbeat.sh              <- NEW: Phase 1
  │   └── heartbeat.js              <- NEW: Phase 1 (upgrade)
  ├── pm/                           <- NEW: Phase 4
  │   ├── CLAUDE.md
  │   ├── state/
  │   └── alerts/
  └── screenshots/                  <- (exists)
```

---

## Getting Started (Right Now)

1. Open a Claude session on the Monster (any worktree or `D:\blackwave\scripts/`)
2. Build `heartbeat.sh` — start simple: just check which ports are listening and which worktrees have recent commits
3. Print output to stdout first. Don't worry about POSTing to an API yet.
4. Once the data looks right, add the POST to the testing worktree backend (port 4150)
5. The backend endpoint doesn't exist yet — you'll need to add it to ADBOX. Do that in a `hurb-*` branch.

Full strategy rationale: `myalchemy/blackwave-hq` -> `strategy/monster-next-layer.md`
