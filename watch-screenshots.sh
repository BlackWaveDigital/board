#!/bin/bash
# watch-screenshots.sh — MacBook-side script
# Watches for new screenshots and SCPs them to the monster
#
# SETUP (on MacBook):
#   1. brew install fswatch
#   2. Copy this script to your MacBook
#   3. Edit MONSTER_HOST below (use Tailscale IP or local IP)
#   4. Run: ./watch-screenshots.sh
#
# HOW IT WORKS:
#   - Watches ~/Desktop for new screenshots
#   - Copies them to monster:/d/blackwave/screenshots/
#   - Puts the monster path on your clipboard
#   - Paste the path into Claude Code (Termius session on monster)

MONSTER_HOST="monster"  # SSH config alias — set this up in ~/.ssh/config
MONSTER_USER="Daniel Cobb"
MONSTER_SCREENSHOTS="/d/blackwave/screenshots"
WATCH_DIR="${HOME}/Desktop"

echo "Watching for screenshots in ${WATCH_DIR}..."
echo "Monster: ${MONSTER_HOST}:${MONSTER_SCREENSHOTS}"
echo "Press Ctrl+C to stop."
echo ""

fswatch -0 --event Created "${WATCH_DIR}" | while IFS= read -r -d '' file; do
    # Only process screenshot files (macOS naming convention)
    if [[ "${file}" == *"Screenshot"* ]] || [[ "${file}" == *"Screen Shot"* ]]; then
        filename=$(basename "${file}")
        echo "[$(date '+%H:%M:%S')] New screenshot: ${filename}"

        # Copy to monster
        scp "${file}" "${MONSTER_HOST}:${MONSTER_SCREENSHOTS}/${filename}" 2>/dev/null
        if [ $? -eq 0 ]; then
            # Put the monster path on clipboard
            monster_path="/d/blackwave/screenshots/${filename}"
            echo "${monster_path}" | pbcopy
            echo "  Copied to monster. Path on clipboard: ${monster_path}"
        else
            echo "  [!] Failed to SCP — is monster reachable?"
        fi
    fi
done
