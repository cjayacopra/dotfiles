# GEMINI.md - Dotfiles Configuration

This directory contains the personal dotfiles for a customized Linux desktop environment. It's a non-code project, meaning it's a collection of configuration files rather than a software application.

## Directory Overview

This repository manages the configuration for a Linux desktop environment built around the Hyprland tiling window manager and the Zsh shell. The configuration is highly modular and customized for a developer-centric workflow.

### Key Technologies

*   **Window Manager:** [Hyprland](https://hyprland.org/) (a dynamic tiling Wayland compositor)
*   **Shell:** [Zsh](https://www.zsh.org/) with [Oh My Zsh](https://ohmyz.sh/)
*   **Terminal:** Alacritty and Kitty
*   **Application Launcher:** Noctalia Shell
*   **System Information:** fastfetch

## Key Files

*   `.config/hypr/hyprland.conf`: The main entry point for the Hyprland window manager configuration. It sources other files in the same directory for a modular setup.
*   `.config/hypr/autostart.conf`: Defines applications and services to be launched automatically when Hyprland starts.
*   `.config/hypr/bindings.conf`: Contains all the keybindings for managing windows, launching applications, and controlling the desktop environment.
*   `.zshrc`: The main entry point for the Zsh shell configuration. It loads a modular configuration from `.config/zshrc/`.
*   `.config/zshrc/00-init`: Initializes shell variables and exports environment variables.
*   `.config/zshrc/20-customization`: Configures Oh My Zsh plugins and shell history.
*   `.config/zshrc/25-aliases`: Defines custom aliases for frequently used commands.
*   `.config/alacritty/alacritty.toml` & `.config/kitty/kitty.conf`: Configuration for the Alacritty and Kitty terminal emulators.

## Usage

These dotfiles are intended to be symlinked to the user's home directory to configure the desktop environment. For example, `ln -s ~/dotfiles/.zshrc ~/.zshrc`.

The configuration is highly personalized, but it can be used as a reference or a starting point for creating a similar setup.

### Development Conventions

*   **Modularity:** The configuration is broken down into smaller, modular files for easier management. For example, both Hyprland and Zsh have their configurations split into multiple files.
*   **Customization:** The user is expected to customize their setup by modifying the files in the `.config` directory. The `.zshrc` file explicitly mentions a `~/.config/zshrc/custom` directory for user-specific customizations.

### Rules
* Always use Context7 MCP and Sequential Thinking when I need library/API documentation, code generation, setup or configuration steps or any form of assistance without me having to explicitly ask.
