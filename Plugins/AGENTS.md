# Plugins

**Purpose**: Tuist plugins (Dependency / Environment / Configuration) — single source of truth for dependency aliases, environment values, and xcconfig mappings.

## Key Paths

| Task | Path |
|---|---|
| Dependency aliases | `DependencyPlugin/ProjectDescriptionHelpers/**` |
| App environment values | `EnvironmentPlugin/ProjectDescriptionHelpers/Enviroment.swift` |
| xcconfig mapping | `ConfigurationPlugin/ProjectDescriptionHelpers/Configurations.swift` |

## Rules

### ✅ Do

- Use plugin aliases in projects instead of hardcoded paths/values
- Keep bundle ID and deployment target centralized in EnvironmentPlugin

### ⚠️ Ask First

- Plugin changes propagate to all modules — confirm scope before editing

### 🚫 Do Not

- Duplicate target-specific settings across individual project files
