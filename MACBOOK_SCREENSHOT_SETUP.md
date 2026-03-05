# MacBook Screenshot Watcher Setup

> **See the full setup guide in the blackwave-hq repo:**
> `blackwave/docs/screenshot-watcher-setup.md`
>
> That doc has everything: macOS one-time setup, SSH config for monster + homepc,
> script installation, drop folder usage, and how to add new targets.

## Quick Reference

```bash
# Install
cp watch-screenshots.sh ~/bin/watch-screenshots.sh
chmod +x ~/bin/watch-screenshots.sh
echo "alias watch-ss='~/bin/watch-screenshots.sh'" >> ~/.zshrc
source ~/.zshrc

# Run
watch-ss              # → monster (default)
watch-ss monster      # → monster
watch-ss homepc       # → homepc
```

On startup it creates the drop folder, then watches:
- `~/Pictures/Screenshots/` — new screenshots auto-detected
- `~/Pictures/Send → [Target]/` — drag any file here to send it

Both the **local path** and **remote path** are copied to clipboard simultaneously.
Paste into MacBook Claude → reads local. Paste into remote Claude → reads remote.
