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

## UseCase 패턴

UseCase는 `execute()`를 통해 시작되며, 포트와 도메인 서비스를 조합해 여러 단계의 비즈니스 흐름을 조율하는 오케스트레이션 계층입니다.

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

## 아키텍처 역할

Workflows는 **Presentation**과 **Ports** 사이에 위치합니다:

```
Presentation (App) ──▶ Workflows (UseCases) ──▶ Ports
                                    │
                                    ▼
                              Domain Services
```

- **Presentation**: 의존성 주입(Dependency Injection)으로 UseCase를 트리거
- **Workflows**: 포트와 도메인 서비스를 조합해 비즈니스 과정을 오케스트레이션
- **Ports**: 인프라 세부사항을 추상화
- **Domain**: 핵심 비즈니스 규칙과 엔티티를 제공합니다

## Available Use Cases

| Use Case | Purpose |
|---|---|
| `CreateNewTaskUseCase` | `Task` 생성 및 초기 설정 조정 |
| `UpdateTaskSettingsUseCase` | 작업 설정 업데이트 처리 |
| `CertifyTaskTodayUseCase` | 당일 작업 인증 처리 |
| `StageProgressionUseCase` | 챌린지 단계 진행 상태 관리 |
| `ReminderSchedulingUseCase` | 알림 스케줄 조정 |
| `GlobalNotificationSettingUseCase` | 전역 알림 설정 관리 |
| `TaskUpdateUseCase` | 작업 데이터 변경 처리 |
| `CertificationUseCase` | 인증 비즈니스 로직 실행 |
| `DeleteTaskUseCase` | 작업 삭제 처리 |
| `LoadImageUseCase` | 이미지 로드 수행 |
| `RequestNotificationPermissionUseCase` | 알림 권한 요청 처리 |
| `AppPreferencesUseCase` | 앱 설정 조회 및 관리 |
| `NotificationSettingQueryUseCase` | 알림 설정 조회 전용 처리 |
| `ActiveTaskServiceUseCase` | 활성 작업 서비스 처리 |
| `TaskStatusServiceUseCase` | 작업 상태 처리 |
| `CalendarEventServiceUseCase` | 캘린더 이벤트 동기화 처리 |
| `ChallengeStateServiceUseCase` | 챌린지 상태 관리 |
| `StageEvaluationServiceUseCase` | 단계 평가 처리 |
| `TaskQueryUseCase` | 작업 조회 처리 |
