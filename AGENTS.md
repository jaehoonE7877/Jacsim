# Jacsim Knowledge Base (AGENTS.md)

**Generated:** 2026-02-02
**Commit:** c5a3f6a
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
- Commit/PR messages: follow the commit convention below

## Commit Convention
- 모든 브랜치/PR에서 동일하게 적용합니다.
- 제목은 50자 이내, 본문은 100자 이내를 권장합니다.
- 기본 포맷:
  - `type: subject` (제목 한 줄)
  - 빈 줄 1개
  - `body` (선택)
  - 빈 줄 1개
  - `footer` (선택, 이슈 링크 등)
- Type 규칙 (첫 글자 대문자, 영어):
  - `Feat`: 새로운 기능 추가
  - `Fix`: 버그 수정
  - `Docs`: 문서 수정
  - `Style`: 포맷/세미콜론 등(코드 변경 없음)
  - `Refactor`: 리팩터링(동작 변화 없음)
  - `Test`: 테스트 코드 추가/수정
  - `Chore`: 빌드/도구/환경 등 그 외
- Subject 규칙:
  - 한국어, 마침표/특수문자 지양, 50자 이내 개조식 문장
  - 예: `Feat: 오늘의 카드 화면 추가`
- Body 규칙 (선택):
  - 무엇을/왜 변경했는지 1~3문장 내로 간결히 작성
  - 줄당 72자 이내 권장(최대 100자)
- Footer 규칙 (선택):
  - 이슈 레퍼런스: `Resolves: #123`, `Related to: #45`
- 예시:
  - `Fix: 토큰 재발급 무한 루프 방지`
  - `Test: 카드 상세 OK권 구매 플로우 단위 테스트 추가`
  - `Refactor: Store 유즈케이스 최소 인터페이스로 전환`

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
