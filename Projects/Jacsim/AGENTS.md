# Projects/Jacsim

## Overview
- 사용자 앱 타깃 (SwiftUI + Observation + async/await)
- Presentation 레이어와 Application 오케스트레이션 레이어 포함
- 앱 라이프사이클 초기화는 `AppDelegate`에서 처리

## Where to Find
| Task | Location |
|---|---|
| App entry | `Projects/Jacsim/Sources/Application/JacsimApp.swift` |
| App lifecycle | `Projects/Jacsim/Sources/Application/AppDelegate.swift` |
| Root app model | `Projects/Jacsim/Sources/Presentation/App/AppFeature.swift` |
| Home flow | `Projects/Jacsim/Sources/Presentation/Home/**` |
| App use cases | `Projects/Jacsim/Sources/Application/UseCases/**` |
| DI client wiring | `Projects/Jacsim/Sources/Client/**` |

## Conventions
- Presentation은 포트 클라이언트(`taskQueryClient`, `taskCommandClient` 등) 중심으로 사용
- 구체 인프라 접근은 `Client`/`Application` 계층으로 제한
- 화면 상태/액션은 `*Feature.swift`의 `@Observable` `*Model`에 두고, UI는 `*View.swift`에 둔다

## Anti-Patterns
- Presentation에서 Data adapter 직접 참조
- 화면 모델 내부에 UserDefaults/SwiftData 구현 세부 하드코딩
- 신규 UIKit 기반 화면 추가
