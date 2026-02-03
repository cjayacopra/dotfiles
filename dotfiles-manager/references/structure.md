# Dotfiles Directory Structure

## Root: `/home/shiraneko/dotfiles/`

### Shell & System
- `.zshrc`: Main Zsh configuration.
- `.p10k.zsh`: Powerlevel10k theme config.
- `.local/share/fonts/`: User fonts (Nerd Fonts).

### Configuration (`.config/`)
- **Niri** (`.config/niri/`):
    - `config.kdl`: Main entry point.
    - `cfg/*.kdl`: Modular config segments (input, layout, keybinds, etc.).
    - `app-rules/*.kdl`: Application specific window rules.
- **Terminal**:
    - `kitty/`: Kitty terminal config and themes.
    - `warp-terminal/`: Warp terminal preferences.
- **System Utilities**:
    - `btop/`: Resource monitor.
    - `fastfetch/`: System fetch info.
    - `lazygit/`: Git TUI.
- **Browser Flags**:
    - `chrome-flags.conf`, `thorium-flags.conf`: Persistent flags for Chromium-based browsers.

### Custom Tooling (`noctalia/`)
- Appears to be a custom configuration/theme manager.
- `colorschemes/`: JSON definitions for themes (Catppuccin, Tokyo Night, etc.).
- `plugins/`: QML-based plugins (e.g., `keybind-cheatsheet`).
