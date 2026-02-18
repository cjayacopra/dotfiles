---
name: dotfiles
description: A comprehensive dotfiles manager using GNU Stow for symlink management. Helps manage configuration files across the system using stow packages with validation, repair, and theme switching capabilities.
license: MIT
compatibility: linux
metadata:
  category: system-management
  tags: [dotfiles, stow, configuration, symlink]
  version: 1.1.0
  author: shiraneko
---

# Dotfiles Management Skill

## Description

A comprehensive dotfiles manager using GNU Stow for symlink management. This skill helps manage configuration files across the system using stow packages.

## Location

- Skill script: `skills/dotfiles/dotfiles` or `.opencode/skills/dotfiles/dotfiles`
- Stow packages: `stow/`
- Backups: `backups/`

## Available Commands

All commands are executed via the dotfiles script:

```bash
./skills/dotfiles/dotfiles <command> [options]
```

### Commands

#### sync [package...] [--dry-run]
Synchronize dotfiles using GNU Stow.

```bash
# Sync all packages
./skills/dotfiles/dotfiles sync

# Sync specific packages only
./skills/dotfiles/dotfiles sync kitty niri

# Preview changes without applying
./skills/dotfiles/dotfiles sync --dry-run
```

#### add <path> [--stow]
Add a new configuration file to the repository.

```bash
# Add a config file (moves it to stow and backs up original)
./skills/dotfiles/dotfiles add ~/.config/btop

# Add and immediately stow the package
./skills/dotfiles/dotfiles add ~/.zshrc_custom --stow
```

#### check
Verify all symlinks are correct and check for issues.

```bash
./skills/dotfiles/dotfiles check
```

Checks:
- GNU Stow is installed
- All symlinks point to correct locations
- No orphaned symlinks exist
- No regular files exist where symlinks should be

#### repair
Fix common stow structure issues automatically.

```bash
./skills/dotfiles/dotfiles repair
```

This will detect and fix issues like:
- Files in `stow/kitty/.config/` instead of `stow/kitty/.config/kitty/`
- Files in `stow/fonts/.local/share/` instead of `stow/fonts/.local/share/fonts/`
- Files in `stow/zsh/.config/` instead of `stow/zsh/.config/zshrc/`

After running repair, use `sync` to apply the fixes.

#### status
Show current status of dotfiles.

```bash
./skills/dotfiles/dotfiles status
```

Displays:
- Available packages and file counts
- Git status
- Active symlinks

#### install [--check-only]
Check and install dependencies.

```bash
# Check which dependencies are installed
./skills/dotfiles/dotfiles install --check-only

# Check and install missing dependencies
./skills/dotfiles/dotfiles install
```

Monitored packages:
- **Pacman**: stow, niri, kitty, zsh, fastfetch, bat, ripgrep, lazygit, eza
- **Cargo**: zoxide

#### theme [name]
Switch between available themes.

```bash
# List available themes
./skills/dotfiles/dotfiles theme

# Switch to a theme
./skills/dotfiles/dotfiles theme catppuccin-mocha
```

Available themes:
- catppuccin-mocha
- catppuccin-macchiato
- catppuccin-latte
- catppuccin-frappe

## Stow Directory Structure

Configs are organized in the `stow/` directory:

```
stow/
├── configs/          # Miscellaneous configs (btop, fastfetch, git, browser flags)
├── fonts/            # Nerd Fonts (Caskaydia Cove, JetBrains Mono)
├── kitty/            # Kitty terminal
├── lazygit/          # Lazygit TUI
├── local/            # ~/.local/share (icons, warp themes)
├── niri/             # Niri window manager
├── noctalia/         # Noctalia desktop shell
├── surge/            # Surge proxy
├── warp/             # Warp terminal
└── zsh/              # Zsh configuration
```

## Correct Structure Guidelines

**IMPORTANT**: Files must be in the correct subdirectory for stow to work properly:

### kitty, lazygit, niri, noctalia, warp, surge
**CORRECT:**
```
stow/kitty/.config/kitty/kitty.conf
stow/kitty/.config/kitty/themes/noctalia.conf
```

**INCORRECT:**
```
stow/kitty/.config/kitty.conf  # ❌ Won't work!
```

### fonts
**CORRECT:**
```
stow/fonts/.local/share/fonts/CaskaydiaCoveNerdFont-Regular.ttf
```

**INCORRECT:**
```
stow/fonts/.local/share/CaskaydiaCoveNerdFont-Regular.ttf  # ❌ Won't work!
```

### zsh
**CORRECT:**
```
stow/zsh/.config/zshrc/00-init
stow/zsh/.config/zshrc/20-customization
stow/zsh/.zshrc
stow/zsh/.p10k.zsh
```

**INCORRECT:**
```
stow/zsh/.config/00-init  # ❌ Won't work!
```

## Common Workflows

### Adding a new config
```bash
# 1. Add the config to the repo
./skills/dotfiles/dotfiles add ~/.config/newapp

# 2. Sync to create symlinks
./skills/dotfiles/dotfiles sync
```

### Fixing structure issues
```bash
# 1. Check for issues
./skills/dotfiles/dotfiles check

# 2. Repair structure
./skills/dotfiles/dotfiles repair

# 3. Re-sync
./skills/dotfiles/dotfiles sync
```

### After pulling changes
```bash
./skills/dotfiles/dotfiles sync
```

### Complete verification
```bash
./skills/dotfiles/dotfiles check
./skills/dotfiles/dotfiles status
```

## Features

- **Automatic backups**: Existing configs are backed up before stowing (single backup per session)
- **Conflict detection**: Warns about files that would be overwritten
- **Structure validation**: Detects common stow structure mistakes
- **Auto-repair**: Can fix structure issues automatically
- **Directory symlinks**: Properly handles both file and directory symlinks
- **Git integration**: Shows git status in `status` command
- **Dependency checking**: Verifies required tools are installed

## Requirements

- GNU Stow
- Bash 4.0+
- Git (for status checking)

## Notes

- Each package mirrors the home directory structure for stow compatibility
- The script auto-detects the dotfiles repo root by searching for the `stow/` directory
- Backup directory is created per sync session at `backups/YYYYMMDD_HHMMSS/`
