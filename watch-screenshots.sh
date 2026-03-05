#!/bin/bash
# watch-screenshots.sh — MacBook-side script
# Watches for new screenshots AND files dropped into a drop folder,
# SCPs them to the target machine, puts remote path on clipboard.
#
# SETUP (one-time):
#   1. Disable thumbnail for instant save:
#      defaults write com.apple.screencapture show-thumbnail -bool false
#   2. Set screenshot save location to ~/Pictures/Screenshots (accessible without permissions):
#      mkdir -p ~/Pictures/Screenshots
#      defaults write com.apple.screencapture location ~/Pictures/Screenshots
#
# USAGE:
#   watch-ss            → defaults to monster
#   watch-ss monster    → screenshots + "Send → Monster" drop folder
#   watch-ss homepc     → screenshots + "Send → HomePC" drop folder
#
# HOW TO ADD A NEW TARGET:
#   Add a new block to the case statement below.
#   SEP: use "/" for monster (MSYS2), "\\" for Windows OpenSSH native (homepc)

TARGET="${1:-monster}"
SCREENSHOT_DIR="${HOME}/Pictures/Screenshots"

# ─── TARGET CONFIGS ────────────────────────────────────────────────────────────
case "$TARGET" in
  monster)
    SSH_HOST="monster"
    REMOTE_DIR="D:/blackwave/screenshots"
    CLIP_PREFIX="/d/blackwave/screenshots"
    SEP="/"
    DROP_FOLDER="${HOME}/Pictures/Send → Monster"
    ;;
  homepc)
    SSH_HOST="homepc"
    REMOTE_DIR='E:\projects\blackwave\screenshots'
    CLIP_PREFIX="/e/projects/blackwave/screenshots"
    SEP="\\"
    DROP_FOLDER="${HOME}/Pictures/Send → HomePC"
    ;;
  *)
    echo "[!] Unknown target: '$TARGET'"
    echo "    Available: monster, homepc"
    exit 1
    ;;
esac

# ─── ENSURE DROP FOLDER EXISTS ────────────────────────────────────────────────
mkdir -p "${DROP_FOLDER}"

# ─── START ─────────────────────────────────────────────────────────────────────
echo "Target:    ${TARGET} (${SSH_HOST})"
echo "Remote:    ${REMOTE_DIR}"
echo "Watching:  ${SCREENSHOT_DIR} (screenshots)"
echo "           ${DROP_FOLDER} (dropped files)"
echo "Press Ctrl+C to stop."
echo ""

# ─── SEND FUNCTION ─────────────────────────────────────────────────────────────
send_file() {
    local file="$1"

    # Sanitize filename — replace Unicode spaces/special chars with regular spaces
    local original_name
    original_name=$(basename "${file}")
    local clean_name
    clean_name=$(echo "${original_name}" | LC_ALL=C sed 's/[^[:print:]]/ /g' | sed 's/  */ /g')

    echo "[$(date '+%H:%M:%S')] Sending: ${clean_name}"

    # Put BOTH paths on clipboard — MacBook Claude uses local, remote Claude uses remote
    local local_path="${file}"
    local remote_path="${CLIP_PREFIX}/${clean_name}"
    printf "%s\n%s" "${local_path}" "${remote_path}" | pbcopy
    echo "  Local:  ${local_path}"
    echo "  Remote: ${remote_path}"
    echo "  (both on clipboard)"

    # SCP in background so clipboard is instant
    local scp_dest="${SSH_HOST}:${REMOTE_DIR}${SEP}${clean_name}"
    (scp "${file}" "${scp_dest}" 2>/dev/null \
        && echo "  [$(date '+%H:%M:%S')] Transferred to ${TARGET}: ${clean_name}" \
        || echo "  [!] Failed to SCP to ${TARGET} — is it reachable?") &
}

# ─── WATCHER ───────────────────────────────────────────────────────────────────
fswatch -0 "${SCREENSHOT_DIR}" "${DROP_FOLDER}" | while IFS= read -r -d '' file; do
    # Skip directories
    [[ -d "${file}" ]] && continue

    # Skip dot-prefixed temp files
    basename_check=$(basename "${file}")
    [[ "${basename_check}" == .* ]] && continue

    # Dedup — skip if we just processed this file
    [[ "${file}" == "${last_file}" ]] && continue
    last_file="${file}"

    # Determine source: screenshot from Desktop, or any file from drop folder
    if [[ "${file}" == "${DROP_FOLDER}/"* ]]; then
        # Drop folder — send anything that lands here
        send_file "${file}"
    elif [[ "${file}" == *"Screenshot"* ]] || [[ "${file}" == *"Screen Shot"* ]]; then
        # Desktop screenshot
        send_file "${file}"
    fi
done
