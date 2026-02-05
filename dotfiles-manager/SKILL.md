---
name: dotfiles-manager
description: Manage user dotfiles (Niri, Kitty, Zsh, etc.) using context7 for documentation and sequentialthinking for complex logic. Use when editing configuration files in the dotfiles repository.
---

# Dotfiles Manager

This skill guides the management of the user's configuration files (dotfiles), ensuring safe, syntactically correct, and well-reasoned changes.

## Standard Operating Procedure (SOP)
The following steps are **MANDATORY** for every configuration change:

1.  **Modify**: Apply changes to the configuration files.
2.  **Refresh Symlinks**: Always run `stow -R .` from the dotfiles root (`/home/shiraneko/dotfiles`) immediately after any file modification, addition, or deletion.
3.  **Validate**: 
    *   **Niri**: You **MUST** run `niri validate` after every change to any `.kdl` file in `.config/niri/`.
    *   **Others**: Use appropriate syntax checks (e.g., `zsh -n`, `kitty --check-config`) if available.
4.  **Verify State**: For Niri, use `niri msg` commands to ensure the live environment reflects the intended changes.

## Core Workflows

### 1. Configuration Editing
When asked to modify a configuration file:

1.  **Resolve Syntax**: Use `context7` tools (`resolve-library-id`, `query-docs`) to look up the latest syntax and options. *Never guess.*
2.  **Verify Structure**: Check `references/structure.md` for the correct file locations.
3.  **Apply SOP**: Follow the Mandatory SOP steps above.

### 2. Niri Implementation & Debugging
When implementing features or debugging issues in Niri:

1.  **Inspect Live State**: Use `niri msg` to retrieve information from the running instance.
    *   `niri msg windows`: To find the `app-id` or `title` needed for window rules.
    *   `niri msg focused-window`: To get properties of the currently active window.
    *   `niri msg outputs`: To list connected displays and their current configuration.
2.  **Test Actions**: Use `niri msg action <action-name>` to test behaviors (like moving windows or switching workspaces) without needing to modify the config.
3.  **Syntactic Verification**: Always run `niri validate` before considering a Niri config change complete.

### 3. Complex Refactoring & Debugging
For tasks involving multiple files, obscure errors (like "unexpected argument"), or cross-application theming:

1.  **Activate Sequential Thinking**: Use the `sequentialthinking` tool to break down the problem.
    *   *Step 1*: Analyze the error or requirement.
    *   *Step 2*: Formulate a hypothesis (e.g., "The parser expects named arguments").
    *   *Step 3*: Verify with `context7`.
    *   *Step 4*: Plan the edit.
2.  **Iterate**: Don't rush. One thought per step.

### 3. Theme Management (Noctalia)
The `noctalia` directory appears to be a custom theme/plugin system.
-   When modifying themes, check `noctalia/colorschemes/`.
-   Be aware of `noctalia/settings.json`.

## Tools & Validators
-   **Niri**: `niri validate` (for config syntax), `niri msg` (for state inspection).
-   **Stow**: `stow -R .` (run from `/home/shiraneko/dotfiles` to refresh symlinks).
-   **Git**: Ensure the repo is clean (`git status`) before applying large changes.