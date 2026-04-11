#!/usr/bin/env bash
set -uo pipefail

SOCKET_PATH="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
LOCK_FILE="${XDG_RUNTIME_DIR}/hypr/zen-bitwarden-float.lock"

if ! command -v hyprctl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1 || ! command -v socat >/dev/null 2>&1; then
    exit 0
fi

if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" || ! -S "${SOCKET_PATH}" ]]; then
    exit 0
fi

# Single-instance guard (safe across config reloads)
exec 9>"${LOCK_FILE}"
if ! flock -n 9; then
    exit 0
fi

float_bitwarden_zen_popup() {
    local addresses
    addresses="$(hyprctl -j clients | jq -r '.[] | select(.class=="zen" and (.title | test("(?i)^Extension:.*Bitwarden.*$")) and (.floating == false)) | .address')"
    [[ -z "${addresses}" ]] && return 0

    while IFS= read -r addr; do
        [[ -z "${addr}" ]] && continue
        hyprctl dispatch setfloating "address:${addr}" >/dev/null 2>&1 || true
        hyprctl dispatch centerwindow "address:${addr}" >/dev/null 2>&1 || true
    done <<< "${addresses}"
}

float_browser_auth_popup() {
    local addresses
    addresses="$(
        hyprctl -j clients | jq -r '
            .[]
            | select(
                (.class | test("^(chromium|google-chrome|brave-browser|microsoft-edge|Vivaldi-stable)$"))
                and (.floating == false)
                and (.title | test("(?i)(^Sign in to |^Sign in -|^Choose an account|Google Account|Google Accounts|OAuth|Authorize|Authentication)"))
            )
            | .address
        '
    )"
    [[ -z "${addresses}" ]] && return 0

    while IFS= read -r addr; do
        [[ -z "${addr}" ]] && continue
        hyprctl dispatch setfloating "address:${addr}" >/dev/null 2>&1 || true
        hyprctl dispatch centerwindow "address:${addr}" >/dev/null 2>&1 || true
        hyprctl dispatch resizewindowpixel exact 900 700,address:"${addr}" >/dev/null 2>&1 || true
    done <<< "${addresses}"
}

# Handle already-open popup on startup
float_bitwarden_zen_popup
float_browser_auth_popup

socat -u "UNIX-CONNECT:${SOCKET_PATH}" - | while IFS= read -r event_line; do
    case "${event_line}" in
        openwindow*|windowtitle*|windowtitlev2*|activewindow*|activewindowv2*)
            float_bitwarden_zen_popup
            float_browser_auth_popup
            ;;
    esac
done
