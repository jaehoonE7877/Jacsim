# Projects/Modules/DSKit

**Purpose**: Design system — tokens, shared SwiftUI components, and UI extensions. No business logic.

## Key Paths

| Task | Path |
|---|---|
| Design assets | `Resources/**` |
| Shared UI components | `Sources/SwiftUI/Components/**` |
| UI extensions | `Sources/Extension/**` |

## Rules

### ✅ Do

- Focus on reusable, style-only components
- Keep state transitions in Jacsim Presentation, not here

### 🚫 Do Not

- Add networking, database, or domain logic
- Implement app-specific screens directly in DSKit
