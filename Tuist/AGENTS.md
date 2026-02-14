# Tuist

**Purpose**: Declarative project/target/template generation layer. Source of truth for module structure and build config.

## Key Paths

| Task | Path |
|---|---|
| Module templates | `ProjectDescriptionHelpers/Project+Templates.swift` |
| Target type definitions | `ProjectDescriptionHelpers/FeatureTarget.swift` |
| Scaffold templates | `Templates/**` |
| Workspace config | `../Workspace.swift` |

## Verify

```bash
tuist generate   # must complete without errors after changes
```

## Rules

### ✅ Do

- Reflect target/structure changes in templates and helpers first
- Keep xcconfig mappings in sync when modifying build configuration

### ⚠️ Ask First

- Changes to `Tuist.swift`, `Workspace.swift`, or plugin references — they affect all modules

### 🚫 Do Not

- Modify settings only through Xcode UI without updating Tuist definitions
