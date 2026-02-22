# Projects/Jacsim

**Purpose**: App target. `SwiftUI + TCA` 기반 화면 계층(Presentation)을 담당하고, 애플리케이션 오케스트레이션은 `Workflows`로 분리해 관리합니다.

`*Feature.swift`는 `@Reducer` 기반의 화면 상태·`Action`·`State` 정책을 정의하고, 대응 `*View.swift`에서 `Store` 바인딩으로 화면 렌더링을 담당하는 구조입니다.

## Key Paths

| Task | Path |
|---|---|
| 앱 진입점 | `Sources/Application/JacsimApp.swift` |
| 앱 생명주기 관리 | `Sources/Application/AppDelegate.swift` |
| 루트 Reducer | `Sources/Presentation/App/AppFeature.swift` |
| 홈 흐름 화면 | `Sources/Presentation/Home/**` |
| Use case 진입 지점 | `Projects/Workflows/Sources/UseCases/**` (external module) |
| 의존성 `Dependency` 연결(`Client`) | `Sources/Client/**` |

## Test

```bash
tuist test Jacsim
```

## Rules

### ✅ Do

- `taskQueryClient`, `taskCommandClient` 같은 port `Client`를 통해서만 데이터 접근
- 실제 인프라(`Data` 접근) 의존은 `Client/` 계층에서만 구체화
- 다단계 화면 흐름은 `Workflows`의 use case를 `Dependency`(예: `createNewTaskUseCase`, `updateTaskSettingsUseCase`)로 호출
- 각 화면은 반드시 `*Feature.swift` + `*View.swift` 쌍으로 구성

### 🚫 Do Not

- Presentation에서 Data adapter를 직접 참조
- `Feature` reducer 내부에 `UserDefaults`/`SwiftData`를 하드코딩
- `Reducer`에서 Application use case를 직접 인스턴스화 (`Sources/Client/**` 경유로 주입)
- `Projects/Domain`에 `UseCase` 타입 배치 (`Domain`은 엔티티/정책/서비스만 유지)
- 새 `UIKit` 기반 화면 추가
