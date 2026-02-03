---
name: dotfiles-manager
description: Manage user dotfiles (Niri, Kitty, Zsh, etc.) using context7 for documentation and sequentialthinking for complex logic. Use when editing configuration files in the dotfiles repository.
---

# Dotfiles Manager

This skill guides the management of the user's configuration files (dotfiles), ensuring safe, syntactically correct, and well-reasoned changes.

## Core Workflows

### 1. Configuration Editing
When asked to modify a configuration file (e.g., `niri`, `kitty`, `zsh`):

1.  **Resolve Syntax**: Use `context7` tools (`resolve-library-id`, `query-docs`) to look up the latest syntax and options for the specific tool. *Never guess configuration syntax.*
    *   *Example*: `query-docs` for "niri window-rule syntax" before editing `pip.kdl`.
2.  **Verify Structure**: Check `references/structure.md` to understand where specific configurations reside (e.g., `noctalia` themes vs. standard `.config`).
3.  **Apply Changes**: Use standard file editing tools.
4.  **Validate**: Where possible, run validation commands (e.g., `niri validate`, `source ~/.zshrc` in a subshell if appropriate) to ensure correctness.

### 2. Complex Refactoring & Debugging
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
-   **Niri**: `niri validate`
-   **Git**: Ensure the repo is clean (`git status`) before applying large changes.