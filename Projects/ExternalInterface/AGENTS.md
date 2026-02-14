# Projects/ExternalInterface

**Purpose**: Port contracts — protocol definitions that form the Dependency Inversion boundary between Domain and Data layers. No implementation, only interfaces.

## Key Paths

| Task | Path |
|---|---|
| Task repository port | `Sources/TaskRepositoryPort.swift` |
| App preferences port | `Sources/AppPreferencesPort.swift` |
| Image store port | `Sources/ImageStorePort.swift` |
| Notification scheduler port | `Sources/NotificationSchedulerPort.swift` |
| User settings repository port | `Sources/UserSettingsRepositoryPort.swift` |
| Module entry | `Sources/ExternalInterface.swift` |

## Test

```bash
tuist test ExternalInterface
```

## Rules

### ✅ Do

- Define ports as struct-based dependency injection (closure-based)
- Use `@Sendable` for all closures to ensure concurrency safety
- Import only `Domain` types — no external dependencies
- Keep ports focused on single responsibility

### 🚫 Do Not

- Add implementation code — this is the contract layer only
- Import Data, Presentation, or any concrete framework
- Add business logic or validation
- Reference SwiftData, UserDefaults, or any infrastructure types

## Port Pattern

```swift
// ✅ Good — Port is a struct with Sendable closures
public struct TaskRepositoryPort: Sendable {
    public var fetchActiveTasks: @Sendable () async throws -> [Task]
    public var fetchTask: @Sendable (TaskID) async throws -> Task?
    public var addTask: @Sendable (Task) async throws -> Void
    // ...
}

// ❌ Bad — Port depends on concrete types or contains logic
public protocol TaskRepository { }  // Avoid protocols for DI in TCA
public struct TaskRepositoryPort {
    func validate() { }  // Never add implementation
}
```

## Architecture Role

ExternalInterface sits at the **Dependency Inversion boundary**:

```
Presentation (App) ──▶ Application UseCases ──▶ ExternalInterface (Ports)
                                                          │
Domain ◀────────────────────────────────────────────── Data (Adapters)
```

- **Domain** defines entities and business rules
- **ExternalInterface** defines how Domain requests external services
- **Data** implements those requests using concrete infrastructure
