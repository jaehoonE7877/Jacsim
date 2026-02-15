# Projects/Data (Adapters)

**Purpose**: Adapter implementations — concrete infrastructure adapters that implement ExternalInterface ports. Handles SwiftData, UserDefaults, UserNotifications, and file system I/O.

## Key Paths

| Task | Path |
|---|---|
| Adapter implementations | `Sources/Adapters/**` |
| SwiftData stack setup | `Sources/SwiftDataStack.swift` |
| Entity-DTO mapping | `Sources/Mapping/**` |
| SwiftData models | `Sources/Models/**` |
| Module entry | `Sources/Data.swift` |

## Test

```bash
tuist test Adapters
```

## Rules

### ✅ Do

- Implement ports defined in `Ports` (ExternalInterface) (e.g., `TaskRepositoryPort`, `AppPreferencesPort`)
- Keep mapping logic in dedicated `*Mapping.swift` files
- Use `@Sendable` for all port closures to ensure thread safety
- Handle errors gracefully and map to domain-appropriate errors

### 🚫 Do Not

- Reference Presentation or Application layer from Data
- Expose SwiftData/Realm models outside the Data module
- Add business logic — only infrastructure concerns
- Use `@MainActor` in adapters unless absolutely necessary

## Adapter Pattern

```swift
// ✅ Good — Adapter implements ExternalInterface port
public struct SwiftDataTaskRepositoryAdapter: Sendable {
    private let context: ModelContext
    
    public func asPort() -> TaskRepositoryPort {
        TaskRepositoryPort(
            fetchActiveTasks: { /* implementation */ },
            fetchTask: { /* implementation */ },
            // ...
        )
    }
}

// ❌ Bad — Adapter depends on Presentation or contains business logic
public struct TaskRepositoryAdapter {
    func validateBusinessRule() { }  // Never do this
}
```
