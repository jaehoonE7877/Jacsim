# Projects/Jacsim

## Overview
- Jacsim app target (user-facing), SwiftUI + TCA + SwiftData centric
- `AppDelegate` attached via `@UIApplicationDelegateAdaptor` for Firebase/push/keyboard setup

## Structure
```
Projects/Jacsim/
├── Sources/
│   ├── Application/                # JacsimApp/AppDelegate/Notification
│   ├── Presentation/               # Feature/Screen unit (TCA)
│   ├── Database/                   # SwiftData models/repository
│   ├── Persistence/                # Storage adapter/migration (if any)
│   ├── Client/                     # API/external service clients
│   └── Utility/                    # Constants/helpers
├── Resources/                      # AppIcon/storyboard/plist resources
└── Tests/                          # Test target sources
```

## Where to Find
| Task | Location | Notes |
|------|----------|-------|
| App entry point | `Projects/Jacsim/Sources/Application/JacsimApp.swift` | SwiftUI `@main` |
| Push/FCM/Crashlytics | `Projects/Jacsim/Sources/Application/AppDelegate.swift` | No other UIKit extensions here |
| App root Feature | `Projects/Jacsim/Sources/Presentation/App/AppFeature.swift` | Child Feature composition point |
| Home/list/detail | `Projects/Jacsim/Sources/Presentation/**` | `*Feature.swift` + `*View.swift` pattern |
| SwiftData model | `Projects/Jacsim/Sources/Database/UserJacsim.swift` | Model definition |
| Data access | `Projects/Jacsim/Sources/Database/JacsimRepository.swift` | SwiftData container/query |

## Conventions
- Add new screens/flows under `Presentation` as Feature units (no UIKit VC addition)
- External dependencies: Use `ThirdPartyLibs` + `DependencyPlugin` for centralized management, not direct SPM
- Commit messages: follow root `AGENTS.md` "Commit Convention" (`type: subject`)

## Anti-Patterns
- Adding new UIKit-based screens/VCs
- Introducing new RxSwift/Realm (temporary bridges only during existing code replacement)
- Modifying generated artifacts like `Derived/`, `.xcodeproj/xcuserdata/`
