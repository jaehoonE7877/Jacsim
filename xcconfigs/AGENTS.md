# xcconfigs

**Purpose**: Centralized `.xcconfig` build settings for all projects and targets.

## Key Paths

| Task | Path |
|---|---|
| xcconfig → Tuist mapping | `../Plugins/ConfigurationPlugin/ProjectDescriptionHelpers/Configurations.swift` |
| Project-level settings | `Base/Projects/**` |
| Target-type settings | `targets/**` |

## Rules

### ✅ Do

- Make build setting changes via xcconfig files, not Xcode GUI
- Keep ConfigurationPlugin mapping in sync after any change

### ⚠️ Ask First

- xcconfig changes may affect all targets — confirm scope before editing

### 🚫 Do Not

- Edit Xcode build settings through the GUI without reflecting changes here
