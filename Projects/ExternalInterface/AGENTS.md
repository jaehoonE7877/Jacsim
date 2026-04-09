# Projects/ExternalInterface (Ports)

**목적**: `Port` 계약 — Domain과 Data 계층 사이의 `Dependency inversion` 경계를 형성하는 `Protocol`/`Interface` 정의입니다. 구현은 없고 `Interface`만 제공합니다.

## 핵심 경로

| Task | Path |
|---|---|
| Task repository port | `Sources/TaskRepositoryPort.swift` |
| App preferences port | `Sources/AppPreferencesPort.swift` |
| Image store port | `Sources/ImageStorePort.swift` |
| Notification scheduler port | `Sources/NotificationSchedulerPort.swift` |
| User settings repository port | `Sources/UserSettingsRepositoryPort.swift` |
| Module entry | `Sources/ExternalInterface.swift` |

## 테스트

```bash
tuist test Ports
```

## 규칙

### ✅ Do

- Port를 `struct` 기반 `Dependency injection`(closure 기반)으로 정의
- 동시성 안전성을 위해 모든 closure에 `@Sendable` 적용
- `Domain` 타입만 import(`Data`, `Presentation` 등 외부 의존성 금지)
- Port를 단일 책임에 집중하도록 유지

### 🚫 Do Not

- 구현 코드를 추가하지 않음 — 이 레이어는 contract layer 전용
- `Data`, `Presentation`, 구체 프레임워크를 import하지 않음
- 비즈니스 로직 또는 validation 로직 추가 금지
- `SwiftData`, `UserDefaults` 및 기타 인프라 타입을 참조하지 않음

## Port Pattern

```swift
// ✅ Good — Port는 Sendable closure를 가진 struct입니다
public struct TaskRepositoryPort: Sendable {
    public var fetchActiveTasks: @Sendable () async throws -> [Task]
    public var fetchTask: @Sendable (TaskID) async throws -> Task?
    public var addTask: @Sendable (Task) async throws -> Void
    // ...
}

// ❌ Bad — Port가 구체 타입에 의존하거나 로직을 포함
public protocol TaskRepository { }  // Avoid protocols for DI in TCA
public struct TaskRepositoryPort {
    func validate() { }  // Never add implementation
}
```

## 아키텍처 역할

Ports(ExternalInterface)는 **Dependency Inversion boundary**에 위치합니다:

```
Presentation (App) ──▶ Workflows (UseCases) ──▶ Ports
                                                    │
Domain ◀────────────────────────────────────── Adapters
```

- **Domain**은 엔티티와 비즈니스 규칙을 정의
- **Ports**(ExternalInterface)는 Domain이 외부 서비스를 요청하는 방법을 정의
- **Adapters**(Data)는 해당 요청을 구체 인프라로 구현
