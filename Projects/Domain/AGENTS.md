# Projects/Domain

**Purpose**: Core business layer. 엔티티, value type, 정책, 순수 domain service를 관리하며 application orchestration이나 infrastructure wiring은 포함하지 않습니다.

## Key Paths

| Task | Path |
|---|---|
| Entity / snapshot models | `Sources/Task.swift` |
| Stage policy | `Sources/StagePolicy.swift` |
| Notification policy | `Sources/NotificationPolicy.swift` |
| Domain services | `Sources/Services/**` |
| Domain tests | `Tests/Sources/**` |
| Module project | `Project.swift` |

## Test

```bash
tuist test Domain
```

## Rules

### ✅ Do

- Keep entities, policies, and services framework-light and focused on business rules
- Use pure, deterministic service logic where possible and keep shared types concurrency-safe (`Sendable`)
- Depend on `Foundation` and other `Domain` types only unless a module-local reason clearly requires more
- Move reusable business rules here when they do not require Ports, adapters, or application orchestration

### 🚫 Do Not

- Add SwiftUI, TCA, `DependencyValues`, or screen/application flow logic
- Import `Ports`, `Adapters`, or concrete infrastructure frameworks
- Perform repository access, notification scheduling, file I/O, or database I/O
- Put multi-step orchestration that belongs in `Workflows`
