# Projects/Modules/ThirdPartyLibs

**Purpose**: Aggregation module for all external dependencies. Upstream modules depend on aliases, not raw packages.

## Key Paths

| Task | Path |
|---|---|
| SPM package declarations | `../../Package.swift` (repo root) |
| SPM aliases | `../../Plugins/DependencyPlugin/ProjectDescriptionHelpers/Dependency+SPM.swift` |
| Module wiring | `Project.swift` |

## Rules

### ✅ Do

- Add libraries in order: `Package.swift` → alias in `DependencyPlugin` → link in `Project.swift`
- Keep dependency list minimal and deduplicated

### ⚠️ Ask First

- **Any new dependency addition** — requires human approval before proceeding

### 🚫 Do Not

- Add direct SPM references from individual app/module targets
- Introduce libraries without verifying license and maintenance status
