# MacBook Screenshot Watcher Setup

## What This Does
Automatically sends screenshots from your MacBook to the Monster (Supermicro at DBA) and copies the remote path to your clipboard. You paste the path into your Termius Claude session and Claude can read the image instantly.

## Prompt for Claude on MacBook

Copy and paste this to Claude on your MacBook:

---

Set up the screenshot watcher for the Monster dev server. Here's what to do:

1. Install fswatch: `brew install fswatch`
2. Generate an SSH key for the monster if I don't have one: `ssh-keygen -t ed25519 -f ~/.ssh/monster_key -N ""`
3. Add this to my `~/.ssh/config` (create if it doesn't exist):

```
Host monster
    HostName 192.168.1.XXX
    User "Daniel Cobb"
    IdentityFile ~/.ssh/monster_key
    Port 22
    ForwardAgent yes
```

(I'll tell you the IP address — ask me for it.)

4. Copy `watch-screenshots.sh` from this repo to `~/bin/watch-screenshots.sh` and make it executable. The script is in this repo at `watch-screenshots.sh`. Update `MONSTER_HOST` to `monster` (the SSH alias).

5. Test SSH connectivity: `ssh monster "echo connected"`

6. Create a launchd plist or simple alias so I can start it easily:
   - Alias approach: add to `~/.zshrc`: `alias watch-ss='~/bin/watch-screenshots.sh'`
   - Then I just type `watch-ss` in a terminal tab

7. Show me my public key (`cat ~/.ssh/monster_key.pub`) so I can add it to the monster's authorized_keys.

---

## After Claude Sets It Up

You'll need to:
1. Get the monster's local IP (run `ipconfig` on the monster, or check Termius)
2. Tell MacBook Claude the IP so it can update the SSH config
3. Add the public key to the monster: paste it into `C:\Users\Daniel Cobb\.ssh\authorized_keys` (via Termius SFTP or monster Claude session)
4. Test: take a screenshot, check if it lands in `/d/blackwave/screenshots/` on the monster
