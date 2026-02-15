# Projects/Workflows

**Purpose**: Application UseCases layer — orchestration layer that coordinates between Presentation and Domain/Ports. Contains all multi-step workflows and business process coordination.

## Key Paths

| Task | Path |
|---|---|
| Use case implementations | `Sources/UseCases/**` |
| Use case tests | `Tests/Sources/Application/**` |
| Module entry | `Sources/Workflows.swift` |

## Test

```bash
tuist test Workflows
```

## Rules

### ✅ Do

- Implement use cases as pure orchestration logic (coordinate ports and domain services)
- Use `@Dependency` to access ports from the `Ports` module
- Keep use cases focused on single responsibility (one workflow per use case)
- Make use case factory methods `public` for cross-module DI access
- Use `@Sendable` for all closure-based APIs to ensure thread safety

### 🚫 Do Not

- Reference Presentation layer (SwiftUI/TCA views or reducers)
- Import concrete adapter implementations from `Data` module
- Add UI code or view logic
- Put business rules that belong in Domain

## UseCase Pattern

```swift
// ✅ Good — Use case coordinates ports and domain services
public struct CreateNewTaskUseCase: Sendable {
    @Dependency(\.taskRepositoryClient) var taskRepository
    @Dependency(\.notificationSchedulerClient) var notificationScheduler
    
    public func execute(task: Task) async throws {
        // 1. Validate through domain service
        try await domainValidationService.validate(task)
        
        // 2. Persist through port
        try await taskRepository.addTask(task)
        
        // 3. Schedule notifications through port
        try await notificationScheduler.schedule(task)
    }
}

// ❌ Bad — Use case references concrete implementations or UI
public struct CreateNewTaskUseCase {
    let realm = try! Realm()  // Never do this
    let viewModel: TaskViewModel  // Never reference UI
}
```

## Architecture Role

Workflows sits between **Presentation** and **Ports**:

```
Presentation (App) ──▶ Workflows (UseCases) ──▶ Ports
                                    │
                                    ▼
                              Domain Services
```

- **Presentation** triggers use cases via dependencies
- **Workflows** orchestrates the business process
- **Ports** abstracts infrastructure concerns
- **Domain** provides business rules and entities

## Available Use Cases

| Use Case | Purpose |
|---|---|
| `CreateNewTaskUseCase` | 새 작업 생성 및 초기 설정 |
| `UpdateTaskSettingsUseCase` | 작업 설정 업데이트 |
| `CertifyTaskTodayUseCase` | 오늘 작업 인증 처리 |
| `StageProgressionUseCase` | 챌린지 단계 진행 관리 |
| `ReminderSchedulingUseCase` | 알림 스케줄링 |
| `GlobalNotificationSettingUseCase` | 전역 알림 설정 관리 |
| `TaskUpdateUseCase` | 작업 데이터 업데이트 |
| `CertificationUseCase` | 인증 로직 |
| `DeleteTaskUseCase` | 작업 삭제 |
| `LoadImageUseCase` | 이미지 로드 |
| `RequestNotificationPermissionUseCase` | 알림 권한 요청 |
| `AppPreferencesUseCase` | 앱 설정 관리 |
| `NotificationSettingQueryUseCase` | 알림 설정 조회 |
| `ActiveTaskServiceUseCase` | 활성 작업 서비스 |
| `TaskStatusServiceUseCase` | 작업 상태 서비스 |
| `CalendarEventServiceUseCase` | 캘린더 이벤트 서비스 |
| `ChallengeStateServiceUseCase` | 챌린지 상태 서비스 |
| `StageEvaluationServiceUseCase` | 단계 평가 서비스 |
| `TaskQueryUseCase` | 작업 조회 |
