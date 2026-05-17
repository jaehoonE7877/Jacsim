# Projects/Jacsim

## Overview
- 사용자 앱 타깃 (SwiftUI + @Observable)
- Presentation 레이어와 Application 오케스트레이션 레이어 포함
- 앱 라이프사이클 초기화는 `AppDelegate`에서 처리

`*Feature.swift` files define `@Observable` screen models, state, and user-action methods. Matching `*View.swift` files render SwiftUI and bind to those models.

## Key Paths
| Task | Path |
|---|---|
| App entry | `Sources/Application/JacsimApp.swift` |
| App lifecycle | `Sources/Application/AppDelegate.swift` |
| App use cases | `Sources/Application/UseCases/**` |
| Dependency/client wiring | `Sources/Client/**` |
| Root app model | `Sources/Presentation/App/AppFeature.swift` |
| Home flow | `Sources/Presentation/Home/**` |
| Shared presentation helpers | `Sources/Presentation/Common/**` |

## Test
```bash
tuist test Jacsim
```

## Conventions
- Presentation accesses data/settings through injected client ports and `JacsimDependencies`.
- Concrete infrastructure access stays in `Client`/`Application` wiring, not in SwiftUI views.
- Screen state and user-action methods live in `@Observable` `*Model` types.
- UI composition stays in `*View.swift`; keep business rules in `Domain` and orchestration in Application use cases.
- New screens should follow the existing `*Feature.swift` + `*View.swift` pairing.

## Anti-Patterns
- Importing `Data` or referencing adapters directly from Presentation.
- Hardcoding `UserDefaults`, SwiftData, or notification implementation details inside screen models.
- Adding new UIKit-based screens.
- Adding new ComposableArchitecture/TCA reducers, stores, or `TestStore` tests.
