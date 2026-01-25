#!/bin/bash
# Auto-float AB Download Manager windows
# This script monitors for ABDM windows and automatically floats them

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    case $line in
        openwindow*com-abdownloadmanager*)
            # Extract window address from the event
            address=$(echo "$line" | cut -d',' -f1 | cut -d'>' -f2)
            # Give the window a moment to fully initialize
            sleep 0.1
            # Float, resize, and center the window
            hyprctl dispatch focuswindow address:0x$address
            hyprctl dispatch togglefloating
            hyprctl dispatch resizeactive exact 900 600
            hyprctl dispatch centerwindow
            ;;
    esac
done
