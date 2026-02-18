#!/usr/bin/python3
"""
Like open-float, but dynamically. Floats a window when it matches the rules.
Some windows don't have the right title and app-id when they open, and only set
them afterward. This script is like open-float for those windows.
Usage: fill in the RULES array below, then run the script.
"""
from dataclasses import dataclass, field
import json
import os
import re
import subprocess
from socket import AF_UNIX, SHUT_WR, socket


@dataclass(kw_only=True)
class Match:
    title: str | None = None
    app_id: str | None = None

    def matches(self, window):
        if self.title is None and self.app_id is None:
            return False
        matched = True
        if self.title is not None:
            matched &= re.search(self.title, window["title"]) is not None
        if self.app_id is not None:
            matched &= re.search(self.app_id, window["app_id"]) is not None
        return matched


@dataclass
class Rule:
    match: list[Match] = field(default_factory=list)
    exclude: list[Match] = field(default_factory=list)

    def matches(self, window):
        if len(self.match) > 0 and not any(m.matches(window) for m in self.match):
            return False
        if any(m.matches(window) for m in self.exclude):
            return False
        return True


# Write your rules here. One Rule() = one window-rule {}.
RULES = [
    # Match Bitwarden on Zen or Firefox
    Rule([Match(title="Bitwarden", app_id="zen")]),
    Rule([Match(title="Bitwarden", app_id="firefox")]),
    # Match Picture-in-Picture
    Rule([Match(title="^Picture-in-Picture$")]),
]

if len(RULES) == 0:
    print("fill in the RULES list, then run the script")
    exit()

niri_socket_path = os.environ.get("NIRI_SOCKET")
if not niri_socket_path:
    print("NIRI_SOCKET not found")
    exit(1)

niri_socket = socket(AF_UNIX)
niri_socket.connect(niri_socket_path)
file = niri_socket.makefile("rw")
_ = file.write('"EventStream"')
file.flush()
niri_socket.shutdown(SHUT_WR)

windows = {}


def niri_action(*args):
    try:
        subprocess.run(["niri", "msg", "action"] + list(args), check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running niri action {args}: {e}")


def float_window(win):
    win_id = str(win["id"])
    title = win["title"]
    
    print(f"Floating window: {title} (id={win_id})")
    
    # Focus the window first
    niri_action("focus-window", "--id", win_id)
    # Move to floating
    niri_action("move-window-to-floating")
    
    # If it's Bitwarden, set a reasonable size (application requested size is often lost after tiling)
    if "Bitwarden" in title:
        # We set it to a smaller size, the app should be able to handle it
        niri_action("set-window-width", "450")
        niri_action("set-window-height", "700")
    
    # Center it
    niri_action("center-window")


def update_matched(win):
    win["matched"] = False
    if existing := windows.get(win["id"]):
        win["matched"] = existing["matched"]

    matched_before = win["matched"]
    win["matched"] = any(r.matches(win) for r in RULES)

    if win["matched"] and not matched_before:
        float_window(win)


for line in file:
    try:
        event = json.loads(line)
        if changed := event.get("WindowsChanged"):
            for win in changed["windows"]:
                update_matched(win)
            windows = {win["id"]: win for win in changed["windows"]}
        elif changed := event.get("WindowOpenedOrChanged"):
            win = changed["window"]
            update_matched(win)
            windows[win["id"]] = win
        elif changed := event.get("WindowClosed"):
            if changed["id"] in windows:
                del windows[changed["id"]]
    except Exception as e:
        print(f"Error processing event: {e}")
