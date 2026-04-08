# Dotfiles

A comprehensive Linux dotfiles repository using GNU Stow for configuration management, featuring Niri window manager, Kitty terminal, and Noctalia desktop shell.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/cjayacopra/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install dependencies
./.agents/skills/dotfiles/dotfiles install

# Sync all configurations
./.agents/skills/dotfiles/dotfiles sync
```

## What's Included

### Window Manager & Desktop
- **[Hyprland](https://hyprland.org)** - Dynamic tiling Wayland compositor
- **[Niri](https://github.com/YaLTeR/niri)** - Scrollable tiling Wayland compositor
- **[Noctalia](https://noctalia.dev)** - Customizable desktop shell (app launcher, bar, notifications)

### Terminal & Tools
- **Kitty** - GPU-accelerated terminal with Tokyo Night theme
- **Warp** - Modern Rust-based terminal
- **Zsh** + Powerlevel10k - Shell with custom prompt
- **Lazygit** - Terminal UI for git

### Development Tools
- **Neovim** - Modal editor with custom config
- **Fastfetch** - System information display
- **Bat** - Syntax-highlighted cat replacement
- **Ripgrep (rg)** - Fast grep replacement
- **Eza** - Modern ls replacement
- **Zoxide** - Smart cd command

### System Management
- **Surge** - Proxy management
- **Btop** - System resource monitor
- **NMTUI** - Network manager TUI

## Stow Directory Structure

Configurations are organized using GNU Stow:

```
stow/
├── configs/          # Miscellaneous configs (btop, fastfetch, git, browser flags)
├── fonts/            # Nerd Fonts (Caskaydia Cove, JetBrains Mono)
├── hypr/             # Hyprland (Wayland)
├── kitty/            # Kitty terminal
├── lazygit/          # Lazygit TUI
├── local/            # ~/.local/share (icons, warp themes)
├── niri/             # Niri window manager
├── noctalia/         # Noctalia desktop shell
├── nvim/             # Neovim config
├── surge/            # Surge proxy configuration
├── warp/             # Warp terminal
└── zsh/              # Zsh configuration and Powerlevel10k
```

### Correct Structure Guidelines

**IMPORTANT**: Files must be in the correct subdirectory for stow to work:

```bash
# CORRECT:
stow/kitty/.config/kitty/kitty.conf
stow/fonts/.local/share/fonts/CaskaydiaCoveNerdFont-Regular.ttf
stow/zsh/.config/zshrc/00-init
stow/zsh/.zshrc

# INCORRECT (won't work):
stow/kitty/.config/kitty.conf  # Missing app directory
stow/fonts/.local/share/font.ttf  # Missing fonts directory
stow/zsh/.config/00-init  # Missing zshrc directory
```

## Dotfiles Management Skill

This repository includes an AI-compatible skill for managing dotfiles.

### Location
- **Skill**: `.agents/skills/dotfiles/`
- **Script**: `.agents/skills/dotfiles/dotfiles`
- **Docs**: `.agents/skills/dotfiles/SKILL.md`

### Available Commands

```bash
# Sync all dotfiles
./.agents/skills/dotfiles/dotfiles sync

# Sync specific packages
./.agents/skills/dotfiles/dotfiles sync kitty niri

# Check for issues
./.agents/skills/dotfiles/dotfiles check

# Fix structure issues
./.agents/skills/dotfiles/dotfiles repair

# Show status
./.agents/skills/dotfiles/dotfiles status

# Check dependencies
./.agents/skills/dotfiles/dotfiles install --check-only
```

### Features
- **Automatic backups** - Backs up existing configs before stowing
- **Structure validation** - Detects common stow structure mistakes
- **Auto-repair** - Fixes structure issues automatically
- **Dependency checking** - Verifies required tools are installed

## Installation

### Prerequisites

```bash
# Arch Linux
sudo pacman -S stow git zsh

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Install dependencies**
   ```bash
   # Check what's missing
   ./.agents/skills/dotfiles/dotfiles install --check-only
   
   # Install all missing packages
   ./.agents/skills/dotfiles/dotfiles install
   ```

3. **Sync configurations**
   ```bash
   ./.agents/skills/dotfiles/dotfiles sync
   ```

4. **Restart your shell**
   ```bash
   exec zsh
   ```

## Adding New Configurations

### Using the dotfiles skill

```bash
# Add a new config
./.agents/skills/dotfiles/dotfiles add ~/.config/newapp

# Or add and sync immediately
./.agents/skills/dotfiles/dotfiles add ~/.config/newapp --stow
```

### Manual method

```bash
# Create the stow package structure
mkdir -p stow/newapp/.config/newapp

# Copy your config
cp ~/.config/newapp/* stow/newapp/.config/newapp/

# Stow it
stow --target=$HOME newapp
```

## Key Bindings (Niri)

| Key | Action |
|-----|--------|
| `Mod+Return` | Open Kitty |
| `Mod+Space` | App Launcher |
| `Mod+B` | Open Browser |
| `Mod+Q` | Close Window |
| `Mod+Shift+ESCAPE` | Keybind Cheatsheet |
| `Mod+Alt+L` | Lock Screen |

See `stow/niri/.config/niri/cfg/keybinds.kdl` for complete bindings.

## Themes

### Available Themes
- Tokyo Night (default)
- Catppuccin (Mocha, Macchiato, Latte, Frappe)

### Switching Themes

```bash
./.agents/skills/dotfiles/dotfiles theme catppuccin-mocha
```

Or manually edit:
- Kitty: `stow/kitty/.config/kitty/current-theme.conf`
- Noctalia: `stow/noctalia/.config/noctalia/colors.json`

## Secrets Management

Sensitive files are excluded from git:
- `.profile` - API keys and tokens
- `.zshrc_custom` - Machine-specific zsh config
- `.config/noctalia/plugins/**/settings.json` - Plugin settings

Create `.profile` for your secrets:
```bash
export CONTEXT7_API_KEY="your-api-key"
export GITHUB_MCP_PAT="your-pat"
```

## Troubleshooting

### Keybindings not working
```bash
# Reload Niri config
niri msg action load-config-file

# Check config validity
niri validate
```

### Fonts not loading
```bash
# Rebuild font cache
fc-cache -fv ~/.local/share/fonts/

# Verify fonts
fc-list | grep -i "caskaydia\|jetbrains"
```

### Stow conflicts
```bash
# Check for issues
./.agents/skills/dotfiles/dotfiles check

# Fix structure
./.agents/skills/dotfiles/dotfiles repair

# Re-sync
./.agents/skills/dotfiles/dotfiles sync
```

## License

MIT License - Feel free to use and modify as needed.

## Credits

- [Niri](https://github.com/YaLTeR/niri) - Window manager
- [Noctalia](https://noctalia.dev) - Desktop shell
- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink farm manager
- [Nerd Fonts](https://www.nerdfonts.com/) - Icon fonts
- [Catppuccin](https://catppuccin.com/) - Color scheme
- [Tokyo Night](https://github.com/folke/tokyonight.nvim) - Color scheme
