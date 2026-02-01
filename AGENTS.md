# Jacsim Knowledge Base (AGENTS.md)

**Generated:** 2026-02-01
**Commit:** ceb3acd
**Branch:** refactor-home-UI

## Overview
- iOS 18+, Swift 6, Tuist + SPM multi-module
- App (UI) centered on SwiftUI + TCA, data on SwiftData
- `AppDelegate` serves as runtime service bridge for Firebase/push/keyboard

## Structure
```
./
├── Projects/
│   ├── Jacsim/                     # App target
│   ├── Modules/
│   │   ├── DSKit/                  # Design tokens/assets + some SwiftUI components
│   │   ├── Core/                   # Utilities/extensions
│   │   └── ThirdPartyLibs/         # External dependencies aggregation
│   └── Features/                   # (Caution) Individual Feature xcodeproj storage/experimental traces
├── Tuist/                          # Template/project generation rules
├── Plugins/                        # Tuist plugins (dependency/environment/xcconfig)
├── xcconfigs/                      # Build settings (Framework/Tests/Demo/Project)
├── Workspace.swift                 # Tuist workspace
├── Package.swift                   # SPM dependency declaration
└── memory/constitution.md          # Top-level rules (prohibitions/exceptions/deadlines)
```

## Where to Find
| Task | Location | Notes |
|------|----------|-------|
| App entry | `Projects/Jacsim/Sources/Application/JacsimApp.swift` | SwiftUI `@main` + TCA Store creation |
| App lifecycle/push | `Projects/Jacsim/Sources/Application/AppDelegate.swift` | Firebase/Crashlytics/Messaging |
| Screens/flows (TCA) | `Projects/Jacsim/Sources/Presentation/**` | `*Feature.swift` (Reducer) + `*View.swift` |
| SwiftData models/repository | `Projects/Jacsim/Sources/Database/**` | SwiftData import check |
| Design tokens/assets | `Projects/Modules/DSKit/Resources/**` | Fonts/colors/images |
| Common utils/extensions | `Projects/Modules/Core/Sources/**` | Foundation extensions, etc. |
| External dependencies | `Package.swift`, `Projects/Modules/ThirdPartyLibs/Project.swift`, `Plugins/DependencyPlugin/**` | SPM declaration + TargetDependency alias |
| Tuist generation rules | `Tuist/ProjectDescriptionHelpers/Project+Templates.swift` | `Project.makeModule(...)` |
| Build settings (.xcconfig) | `xcconfigs/**`, `Plugins/ConfigurationPlugin/**` | Tuist config connection |

## Rules/Prohibitions (Core)
- New screens: Implement only with SwiftUI + TCA, UIKit new screen prohibited (per `memory/constitution.md`)
- RxSwift/Realm: New code prohibited (legacy bridge exceptions only at Feature boundaries)
- Generated/external code modification prohibited: `Projects/**/Derived/**`, `.build/**`, `.derivedData/**`, `build/**`
- Commits/PRs: Korean, present tense `type: subject` (e.g., `Feat: ...`)

## Commands
```bash
tuist generate
tuist build --scheme Jacsim
tuist test --scheme Core

# If needed (adjust simulator name to your environment)
xcodebuild -workspace Jacsim.xcworkspace -scheme Jacsim -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
```

## Sub-AGENTS.md (Depth 3)
- `Projects/Jacsim/AGENTS.md`
- `Projects/Modules/DSKit/AGENTS.md`
- `Projects/Modules/Core/AGENTS.md`
- `Projects/Modules/ThirdPartyLibs/AGENTS.md`
- `Projects/Features/AGENTS.md`
- `Tuist/AGENTS.md`
- `Plugins/AGENTS.md`
- `xcconfigs/AGENTS.md`

## Notes
- `GoogleService-Info.plist` required: `Projects/Jacsim/Resources/GoogleService-Info.plist`
