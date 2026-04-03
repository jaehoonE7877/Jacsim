# Projects/Data (Adapters)

**목적**: Adapter 구현 모듈. ExternalInterface의 Port를 구현하는 구체적인 인프라 Adapter를 담당하며, SwiftData, UserDefaults, UserNotifications, 파일 시스템 I/O를 처리한다.

## 핵심 경로

| 작업 | 경로 |
|---|---|
| Adapter 구현 | `Sources/Adapters/**` |
| SwiftData 스택 설정 | `Sources/SwiftDataStack.swift` |
| Entity-DTO 매핑 | `Sources/Mapping/**` |
| SwiftData 모델 | `Sources/Models/**` |
| 모듈 진입점 | `Sources/Data.swift` |

## Test

```bash
tuist test Adapters
```

## Verify

```bash
tuist build Jacsim
```

- `SwiftData` 모델, 매핑, 스택 변경이 있으면 `tuist build Jacsim`으로 downstream compile도 함께 확인합니다.

## 경계 규칙

### ⚠️ Ask First

- `Sources/Models/**`, `Sources/Mapping/**`, `Sources/SwiftDataStack.swift` 변경처럼 저장 포맷, schema, mapping contract에 영향을 주는 수정은 사전 확인합니다.

### ✅ 실행

- `Ports`(ExternalInterface)에 정의된 Port를 구현한다 (예: `TaskRepositoryPort`, `AppPreferencesPort`)
- Adapter는 `makePort()`를 통해 Port factory 책임도 함께 가진다
- 매핑 로직은 전용 `*Mapping.swift` 파일에 분리한다
- 스레드 안전성을 위해 모든 Port closure에 `@Sendable`을 사용한다
- 에러는 무조건 처리하고, 도메인에서 사용하기 좋은 형태로 변환한다
- 파생 상태(`isDone`, `isSuccess` 등)는 저장하지 않고 `Task`/`StageResult`에서 계산한다

### 🚫 금지

- Data에서 Presentation 또는 Application 레이어를 직접 참조하지 않는다
- SwiftData/Realm 모델을 Data 모듈 바깥으로 노출하지 않는다
- 비즈니스 로직을 추가하지 않고 인프라 관심사만 처리한다
- `@MainActor`는 꼭 필요하지 않다면 Adapter에서 사용하지 않는다
- task-owned record를 stage-owned copy로 중복 저장하지 않는다

## Adapter Pattern

```swift
// ✅ Good — Adapter가 Port 구현과 factory 책임을 함께 가진다
public actor SwiftDataTaskRepositoryAdapter {
    public nonisolated func makePort() -> TaskRepositoryPort {
        TaskRepositoryPort(
            fetchActiveTasks: { /* implementation */ },
            fetchTask: { /* implementation */ },
            // ...
        )
    }
}

// ❌ Bad — Adapter가 Presentation에 의존하거나 비즈니스 로직을 포함
public struct TaskRepositoryAdapter {
    func validateBusinessRule() { }  // 잘못된 예시
}

```

## Repository Pattern

- Data는 `TaskRepositoryPort`처럼 도메인 요구를 충족하는 Repository 형태의 Adapter를 제공한다
- Repository는 영속성 접근을 캡슐화해 Presentation/Workflows가 `SwiftData` 상세 구조를 알지 못하게 한다
- Repository 구현은 `Entity-DTO` 매핑과 트랜잭션 경계를 명확히 분리해 일관된 `Contract` 동작을 유지한다
- task 상태 분류는 저장된 flag가 아니라 mapped `Task`의 최종 `StageResult`에서 계산한다
- `DailyRecordSnapshot` 계열 record는 task 기준 단일 source of truth로 유지하고 stage-owned copy를 두지 않는다
