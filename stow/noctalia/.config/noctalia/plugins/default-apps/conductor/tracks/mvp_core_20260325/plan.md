# Implementation Plan: Build MVP: MIME management and default association core

## Phase 1: Core Plugin Infrastructure [checkpoint: 38ae66a]
- [x] **Task: Scaffold Noctalia Standalone Plugin** (977016b)
  - Create the basic directory structure and `manifest.json` for a Noctalia standalone plugin.
- [x] **Task: Implement Entry Point** (b0a6a6b)
  - Create `main.qml` that defines a basic window using Noctalia's `AppWindow` or equivalent component.

## Phase 2: Backend Logic Core
- [x] **Task: MIME Type Discovery Logic** (71d9bb2)
  - Implement a JavaScript module to list MIME types from the system (e.g., parsing `/usr/share/mime`).
- [ ] **Task: Default Handler Query Logic**
  - Implement logic using `xdg-mime query default <mimetype>` to get the current handler.
- [ ] **Task: Association Management Logic**
  - Implement logic using `xdg-mime default <application>.desktop <mimetype>` to update associations.

## Phase 3: Basic UI Implementation
- [ ] **Task: MIME Type Browser UI**
  - Create a QML view to display a searchable list of MIME types.
- [ ] **Task: Handler Selection UI**
  - Implement a view to show current defaults and list other available applications for a selected MIME type.

## Phase 4: Verification & MVP Polish
- [ ] **Task: Basic Integration Testing**
  - Verify that changes in the UI correctly update the system's `xdg-mime` associations.
- [ ] **Task: Basic UI/UX Polish**
  - Ensure the UI follows Noctalia design guidelines (consistent margins, spacing, and styling).
