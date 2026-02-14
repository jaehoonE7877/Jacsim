# Projects/Features

**Purpose**: Legacy/experimental feature modules. Active screen development happens in `Projects/Jacsim/Sources/Presentation`.

## Key Paths

| Task | Path |
|---|---|
| Feature template | `../Tuist/Templates/Feature/**` |
| Module generation rules | `../Tuist/ProjectDescriptionHelpers/Project+Templates.swift` |

## Rules

### ✅ Do

- Reference this directory only for legacy context
- New features follow the main app structure and Tuist templates

### 🚫 Do Not

- Add new active features here — use `Projects/Jacsim/Sources/Presentation/`
- Manually create `.xcodeproj` files (use `tuist generate`)
