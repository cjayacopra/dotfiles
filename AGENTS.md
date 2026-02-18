# AGENTS.md - Dotfiles Repository Guidelines

## Project Overview

This is a **Linux dotfiles repository** using GNU Stow for configuration management. It contains configurations for Niri (Wayland compositor), Kitty terminal, Noctalia desktop shell, Zsh, and various development tools.

## Repository Structure

```
.
├── stow/                    # Configuration packages (GNU Stow format)
│   ├── configs/             # Misc configs (btop, git, fastfetch)
│   ├── fonts/               # Nerd Fonts
│   ├── kitty/               # Kitty terminal
│   ├── lazygit/             # Lazygit TUI
│   ├── local/               # ~/.local/share (icons, themes)
│   ├── niri/                # Niri window manager
│   ├── noctalia/            # Noctalia desktop shell
│   ├── surge/               # Surge proxy
│   ├── warp/                # Warp terminal
│   └── zsh/                 # Zsh configuration
├── .agents/skills/dotfiles/ # Dotfiles management skill
├── backups/                 # Automatic backups
└── README.md                # User documentation
```

## Testing & Validation

### Validate All Configs
```bash
# Check stow structure and symlinks
./.agents/skills/dotfiles/dotfiles check

# Check Niri config syntax
niri validate

# Verify Kitty config
kitty +kitten show_config

# Test zsh syntax
zsh -n ~/.zshrc
```

### Test Single Component
```bash
# Test specific package sync (dry run)
./.agents/skills/dotfiles/dotfiles sync <package> --dry-run

# Validate KDL files (niri)
cat stow/niri/.config/niri/cfg/keybinds.kdl | head -20

# Validate JSON files
python3 -m json.tool stow/noctalia/.config/noctalia/colors.json > /dev/null && echo "Valid JSON"
```

## Code Style Guidelines

### Bash Scripts

**Formatting:**
- Use `#!/bin/bash` shebang with `set -e`
- 4-space indentation
- Functions use `snake_case`
- Variables use `UPPER_CASE` for globals, `local` for function vars
- Always quote variables: `"$variable"` not `$variable`

**Error Handling:**
```bash
set -e  # Exit on error
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
```

### Stow Package Structure

**MANDATORY: Files must be in correct subdirectories**

```bash
# CORRECT:
stow/kitty/.config/kitty/kitty.conf
stow/fonts/.local/share/fonts/font.ttf
stow/zsh/.config/zshrc/00-init
stow/zsh/.zshrc

# INCORRECT (will break):
stow/kitty/.config/kitty.conf  # Missing app directory!
stow/zsh/.config/00-init       # Missing zshrc directory!
```

### Configuration Files

**KDL (Niri):**
- Use consistent indentation (4 spaces)
- Group related settings with comments
- Include hotkey-overlay-title for keybinds

**JSON (Noctalia):**
- Use 4-space indentation
- No trailing commas
- Validate with `python3 -m json.tool`

**YAML (Warp):**
- 2-space indentation
- No tabs

## Working with Configs

### Adding New Configs
```bash
# Method 1: Use the skill
./.agents/skills/dotfiles/dotfiles add ~/.config/newapp

# Method 2: Manual
mkdir -p stow/newapp/.config/newapp
cp -r ~/.config/newapp/* stow/newapp/.config/newapp/
./.agents/skills/dotfiles/dotfiles sync newapp
```

### Repairing Issues
```bash
./.agents/skills/dotfiles/dotfiles repair
./.agents/skills/dotfiles/dotfiles sync
```

## Security Guidelines

**NEVER commit:**
- API keys or tokens
- Personal access tokens
- Passwords
- Machine-specific paths containing home directory

**Files that should be gitignored:**
- `.profile` (contains secrets)
- `.zshrc_custom` (machine-specific)
- `backups/` directories
- Plugin settings with API keys

## Common Tasks

```bash
# Update all packages
./.agents/skills/dotfiles/dotfiles sync

# Check for issues
./.agents/skills/dotfiles/dotfiles check

# Switch themes
./.agents/skills/dotfiles/dotfiles theme catppuccin-mocha
```

## Git Workflow

```bash
# Before committing
./.agents/skills/dotfiles/dotfiles check
niri validate  # If modifying niri configs

# Commit changes
git add stow/<package>/
git commit -m "feat: Add/update <package> configuration"
```

## Notes for Agents

- This is NOT a traditional software project - no Makefile, package.json, etc.
- All configs are symlinked via GNU Stow
- The `stow/` directory contains the source of truth
- Always validate structure before and after changes
- Test changes in a way that won't break the user's desktop
