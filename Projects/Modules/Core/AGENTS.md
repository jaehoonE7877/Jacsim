# Projects/Modules/Core (Shared)

**Purpose**: Shared utilities, extensions, and logging — no business logic or UI.

## Key Paths

| Task | Path |
|---|---|
| Foundation extensions | `Sources/Extension/Foundation/**` |
| Logging helper | `Sources/Logger.swift` |

## Rules

### ✅ Do

- Keep functions pure and side-effect-free where possible
- Place only reusable, domain-agnostic utilities here

### 🚫 Do Not

- Add SwiftUI views or UI code
- Place app-specific business rules in Core
