# Blackwave Infrastructure Changelog

> Monster (Supermicro — 512GB RAM, 48 threads, dual GV100) changes log.
> Tracks infrastructure, tooling, and environment changes — not ADBOX feature work.

---

## 2026-03-06 — WSL Recovery, Storage Overhaul, EVE Rebuild

**Operator:** Daniel (remote via Claude Code)

### Root Cause: C: Drive Full → WSL Destroyed

A Llama 70B model download (~42GB) filled the C: NVMe (952GB) to 0.03GB free. WSL2's ext4.vhdx virtual disk couldn't journal writes, corrupting the Ubuntu filesystem. All `dev` commands broke (they route through WSL for tmux).

### What Was Done

#### 1. C: Drive Cleanup (0.03GB → 192GB free)
- Uninstalled Epic Games: Fortnite (63GB) + Unreal Engine 5.2 (64GB) = **127GB**
- Cleaned user temp files: **9.4GB**
- Cleaned yarn cache: **2.9GB**
- Cleaned npm cache: **1.3GB**
- Cleaned C:\adobeTemp: **4.2GB**
- Total reclaimed: **~145GB**

#### 2. WSL2 Ubuntu Rebuilt on D: Drive
- Old WSL disk (`C:\Users\...\AppData\Local\wsl\ext4.vhdx`, 42.5GB) was destroyed
- Unregistered broken Ubuntu distro
- Fresh Ubuntu install → exported → re-imported to **`D:\wsl\Ubuntu`**
- Created user `daniel_cobb` (UID 1000, NOPASSWD sudo)
- Set as default user via registry
- Installed: nvm, Node v20.20.1, yarn 1.22.22, Claude CLI 2.1.70, tmux, dos2unix
- Installed WSL-side `dev` command (`/usr/local/bin/dev` from `wsl-dev.sh`)
- Installed `eve` command (`/usr/local/bin/eve` from `eve.sh`)
- Installed `.tmux.conf` from `wsl-tmux.conf`
- Ran `wsl-setup-bins.sh` logic to symlink node/npm/yarn/claude into `/usr/local/bin`
- Set locale `en_US.UTF-8` (prevents `fopen(/etc/default/locale)` errors)

**Key change:** WSL now lives on D:, not C:. It can never fill C: again.

#### 3. Cache Redirection to D:
- npm cache → `D:\caches\npm` (via `npm config set cache`)
- yarn cache → `D:\caches\yarn` (via `yarn config set cache-folder`)

#### 4. Ollama + Llama 3.3 70B Installed
- Ollama v0.17.7 installed (silent install, `C:\Users\...\AppData\Local\Programs\Ollama`)
- Pulled `llama3.3:70b` (42GB) to **`D:\models\active`**
- Environment variable `OLLAMA_MODELS=D:\models\active` set (User scope, persistent)
- Environment variable `HF_HOME=F:\models\huggingface` set (User scope, persistent)
- Same vars added to WSL `~/.bashrc`
- Inference tested and working on dual GV100s

#### 5. EVE Rebuilt (3 Isolated Instances)
- Upgraded all Modelfiles from `llama3.1:8b` → `llama3.3:70b`
- Created Ollama models: `eve-internal`, `eve-team`, `eve-client`
- Rebuilt Python venv (`D:\blackwave\eve\.venv`) with chromadb + ollama
- Installed `eve` command in WSL PATH
- **Vector DBs not yet re-ingested** — RAG indexes need rebuilding

All three EVE instances share the same base model (llama3.3:70b) but have:
- Separate system prompts defining access boundaries
- Separate RAG source lists (ingest.py SOURCES dict)
- Separate ChromaDB vector databases (`eve/vectordb/<instance>/`)

#### 6. Automated WSL Backup
- Created `D:\blackwave\scripts\wsl-backup.sh`
  - Exports WSL Ubuntu to `D:\wsl\backups\ubuntu-YYYYMMDD-HHMM.tar`
  - Keeps last 3 backups, prunes older
  - Shuts down WSL cleanly before export
- Registered Windows Task Scheduler task: **"WSL Ubuntu Backup"**
  - Runs every Sunday at 4:00 AM
  - First backup completed: `ubuntu-20260306-0934.tar` (2.2GB)
- Recovery command: `wsl --import Ubuntu D:\wsl\Ubuntu D:\wsl\backups\<backup>.tar`

### Current Drive Layout

| Drive | Type | Total | Free | Purpose |
|-------|------|-------|------|---------|
| C: | NVMe Samsung 970 | 953GB | 192GB | Windows + programs ONLY |
| D: | NVMe Samsung 970 | 954GB | 854GB | Dev work, WSL, active models, caches |
| F: | HDD RAID5 (6x 18TB Toshiba, OWC SoftRAID) | 84TB | 39TB | Archive, HuggingFace cache |

### Directory Structure (Post-Recovery)

```
D:\blackwave\
  adbox.git/              <- bare repo
  adbox/                  <- worktrees (hurb-1 through hurb-10, juhnk, danbox, testing)
  board/                  <- this repo
  consulting/             <- consulting docs
  eve/                    <- EVE AI assistant (3 instances)
    internal/Modelfile
    team/Modelfile
    client/Modelfile
    chat.py               <- RAG chat client
    ingest.py             <- RAG indexer
    eve.sh                <- launcher script
    vectordb/             <- per-instance ChromaDB stores
    .venv/                <- Python env (chromadb, ollama)
  scripts/                <- dev tooling
    dev.sh                <- native MSYS2 dev launcher (backup)
    wsl-dev.sh            <- WSL-side dev launcher (primary)
    wsl-setup-bins.sh     <- symlink node/etc into /usr/local/bin
    wsl-tmux.conf         <- tmux config
    onboard.sh            <- new developer onboarding
    wsl-backup.sh         <- weekly WSL backup
    wsl-backup-task.xml   <- Task Scheduler definition
  screenshots/            <- MacBook screenshot landing

D:\wsl\
  Ubuntu/                 <- WSL2 virtual disk (ext4.vhdx)

D:\models\
  active/                 <- Ollama models (llama3.3:70b, eve-*)

D:\caches\
  npm/                    <- npm cache
  yarn/                   <- yarn cache

F:\models\
  archive/                <- cold storage for models
  huggingface/            <- HuggingFace download cache
```

### Known Issues
- **Harddisk8 (F: drive, OWC SoftRAID) controller errors** — dozens since March 3. Windows reports disk as "Healthy" but errors are persistent. Monitor closely.
- **EVE RAG not ingested** — vector DBs need rebuilding. Run `eve ingest internal`, `eve ingest team` from WSL.
- **Windows scripts have `\r\n` line endings** — must `dos2unix` before running in WSL. The installed `/usr/local/bin/dev` and `/usr/local/bin/eve` are already fixed.

### TODO
- [ ] Ingest EVE RAG indexes (internal, team, client)
- [ ] Investigate F: drive controller errors
- [ ] Consider moving Ollama install itself to D: (currently on C: in AppData)
- [ ] Set up Ollama to auto-start as a service with correct OLLAMA_MODELS path
