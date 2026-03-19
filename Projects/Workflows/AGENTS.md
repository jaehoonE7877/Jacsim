# Projects/Workflows

**Purpose**: Application UseCases layer — orchestration layer that coordinates between Presentation and Domain/Ports. Contains all multi-step workflows and business process coordination.

## Key Paths

| Task | Path |
|---|---|
| Use case implementations | `Sources/UseCases/**` |
| Use case tests | `Tests/Sources/Application/**` |
| App-side `DependencyValues` registration | `../JacsimClient/Sources/UseCaseClients.swift` (external module) |
| Composition root | `../JacsimClient/Sources/DependencyAssembly.swift` (external module) |

## Test

```bash
tuist test Workflows
```

## Rules

### ✅ Do

- Implement use cases as pure orchestration logic (coordinate ports and domain services)
- Compose use cases with `TaskRepositoryPort`, `ImageStorePort`, `NotificationSchedulerPort` 같은 Port 타입을 `live(...)` 또는 initializer 인자로 주입
- Keep use cases focused on single responsibility (one workflow per use case)
- Make use case factory methods `public` for cross-module DI access
- Use `@Sendable` for all closure-based APIs to ensure thread safety
- Keep `DependencyValues` registration in `Jacsim` or `JacsimClient`, not inside `Workflows`
- Prefer read-only summary/query use cases over exposing Domain services directly to Presentation
- The source of truth for the full use case list is `Sources/UseCases/**`; do not maintain a fixed catalog in this document.

### 🚫 Do Not

- Reference Presentation layer (SwiftUI/TCA views or reducers)
- Import concrete adapter implementations from `Data` module
- Declare `DependencyKey` / `DependencyValues` wiring inside `Workflows`
- Add UI code or view logic
- Put business rules that belong in Domain

## UseCase 패턴

UseCase는 `execute()`를 통해 시작되며, 포트와 도메인 서비스를 조합해 여러 단계의 비즈니스 흐름을 조율하는 오케스트레이션 계층입니다.

```swift
// ✅ Good — Use case composes Ports through live(...) and exposes a callable API
public struct CreateNewTaskUseCase: Sendable {
    public var execute: @Sendable (Input) async throws -> Task
}

extension CreateNewTaskUseCase {
    public static func live(
        taskRepository: TaskRepositoryPort,
        imageStore: ImageStorePort,
        reminderSchedulingUseCase: ReminderSchedulingUseCase
    ) -> Self {
        Self(
            execute: { input in
                var task = Task(/* build domain entity from input */)
                if let data = input.mainImageData {
                    _ = try await imageStore.saveImage(task.mainImageKey, data)
                }
                try await taskRepository.addTask(task)
                await reminderSchedulingUseCase.resyncRepresentativeReminder()
                return task
            }
        )
    }
}

// ❌ Bad — dependency registration and infrastructure belong outside Workflows
public extension DependencyValues {
    var createNewTaskUseCase: CreateNewTaskUseCase { ... }
}
```

## 아키텍처 역할

Workflows는 **Presentation**과 **Ports** 사이에 위치합니다:

```
Presentation (App) ──▶ Workflows (UseCases) ──▶ Ports
                                    │
                                    ▼
                              Domain Services
```

- **Presentation**: 의존성 주입(Dependency Injection)으로 UseCase를 트리거
- **App / Composition**: `DependencyValues` 등록과 Port 조립은 `Jacsim` / `JacsimClient`에서 담당
- **Workflows**: 포트와 도메인 서비스를 조합해 비즈니스 과정을 오케스트레이션
- **Ports**: 인프라 세부사항을 추상화
- **Domain**: 핵심 비즈니스 규칙과 엔티티를 제공합니다
