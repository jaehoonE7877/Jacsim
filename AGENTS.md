# Jacsim Knowledge Base (AGENTS.md)

## Overview
- iOS 26+, Swift 6, Tuist + SPM 멀티모듈
- SwiftUI + async/await + @Observable + Port & Adapter 아키텍처 기반
- Liquid Glass + focus.mode + Social V2 디자인/소셜 시스템 적용
- 앱 로직은 레이어 경계를 유지하며 모듈 단위로 관리

## Current Structure
```text
./
├── Projects/
│   ├── Jacsim/                     # App(Presentation/Application)
│   ├── JacsimWidget/               # WidgetKit extensions
│   ├── Domain/                     # Domain rules/entities/services
│   ├── ExternalInterface/          # Port contracts
│   ├── Data/                       # Adapter implementations
│   └── Modules/
│       ├── Core/                   # Utilities/extensions
│       ├── DSKit/                  # Design system
│       └── ThirdPartyLibs/         # Third-party aggregation
├── Tuist/
├── Plugins/
├── xcconfigs/
├── Workspace.swift
└── Package.swift
```

## Layer Responsibilities
- `Jacsim`: Presentation(SwiftUI + @Observable) + Application use case orchestration
- `Domain`: 비즈니스 규칙, 엔티티 불변식, 도메인 계산
- `ExternalInterface`: 상위 레이어가 의존할 Port 계약
- `Data`: 외부 I/O 구현체(Adapter)

## Why ExternalInterface Exists
- Keeps Domain/Application from depending directly on concrete Data implementations
- Makes adapters replaceable and in-memory/mock ports easy to inject in tests
- Fixes dependency direction so layer boundaries stay stable

## Quick Start
```bash
tuist install
tuist generate
tuist build Jacsim
tuist test Jacsim
tuist test Domain
tuist test Data
tuist test ExternalInterface
```

> `DSKit` does not have a dedicated unit test target. Validate DSKit changes with `tuist build Jacsim` and affected downstream scheme tests.
> No lint/format tool is configured yet. Do not introduce one without approval.

## Success Criteria
1. `tuist generate` completes without errors.
2. `tuist build Jacsim` succeeds.
3. `tuist test <affected-scheme>` passes for every touched module.
4. No new compiler warnings are introduced.

## Key Paths
| Task | Path |
|---|---|
| App entry | `Projects/Jacsim/Sources/Application/JacsimApp.swift` |
| App lifecycle | `Projects/Jacsim/Sources/Application/AppDelegate.swift` |
| App use cases | `Projects/Jacsim/Sources/Application/UseCases/**` |
| Client/DI wiring | `Projects/Jacsim/Sources/Client/**` |
| SwiftUI screens/models | `Projects/Jacsim/Sources/Presentation/**` |
| Widgets | `Projects/JacsimWidget/**` |
| Domain logic | `Projects/Domain/Sources/**` |
| Port contracts | `Projects/ExternalInterface/Sources/**` |
| Data adapters | `Projects/Data/Sources/Adapters/**` |
| Design system | `Projects/Modules/DSKit/**` |
| Common utilities | `Projects/Modules/Core/**` |

## Boundaries

### Never Do
| Rule | Detail |
|---|---|
| Generated files | Do not edit `Projects/**/Derived/**`, `.build/**`, `.derivedData/**`, or `build/**`. |
| Secrets | Do not commit API keys, credentials, personal data, or private operational details. |
| Legacy frameworks | Do not add new RxSwift or Realm usage. |
| UIKit screens | Do not add new UIKit-based views. |
| TCA screens | Do not add new ComposableArchitecture/TCA-based flows. |
| Production deploy | Do not trigger Xcode Cloud or App Store workflows directly. |
| CI workflows | Do not edit `.github/workflows/**` without explicit approval. |

### Ask First
| Rule | Detail |
|---|---|
| New dependency | Adding a package to `Package.swift` needs approval. |
| Tuist config | Changes to `Tuist.swift`, `Workspace.swift`, or `Plugins/**` need review. |
| xcconfig | Changes to `xcconfigs/**` can affect all targets; confirm scope first. |
| New module | Follow Tuist templates for any new `Projects/` module. |
| Design system | DSKit token or component changes affect app-wide UI. |

## Context Hygiene
- Read this file first, then the relevant scoped `AGENTS.md`, then source files.
- Do not read `.build/`, `.derivedData/`, `build/`, or `*.xcodeproj/` contents.
- Summarize command output over 200 lines instead of pasting it whole.
- Use the `Key Paths` table before scanning directories.

## Sub-Module Guides
| Module | Guide | Read When |
|---|---|---|
| App (`Jacsim`) | `Projects/Jacsim/AGENTS.md` | Screen changes, client wiring, app lifecycle |
| Widget (`JacsimWidget`) | `Projects/JacsimWidget/**` | WidgetKit extension surfaces |
| `Domain` | `Projects/Domain/AGENTS.md` | Entities, policies, domain services |
| `ExternalInterface` | `Projects/ExternalInterface/AGENTS.md` | Port contracts and boundaries |
| `Data` | `Projects/Data/AGENTS.md` | Infrastructure adapters and mapping |
| `DSKit` | `Projects/Modules/DSKit/AGENTS.md` | Design tokens and shared UI components |
| `Core` | `Projects/Modules/Core/AGENTS.md` | Shared utilities and extensions |
| `ThirdPartyLibs` | `Projects/Modules/ThirdPartyLibs/AGENTS.md` | External dependency management |
| `Tuist` | `Tuist/AGENTS.md` | Project generation and templates |
| `Plugins` | `Plugins/AGENTS.md` | Dependency alias and environment config |
| `xcconfigs` | `xcconfigs/AGENTS.md` | Build setting changes |

## Public Repository Policy
- Do not record secrets, credentials, personal identifiers, or internal operating procedures in docs.
- Keep sensitive configuration in local or CI secret storage.

## Maintenance
- If an agent repeats the same mistake, add a one-line rule to the relevant file.
- Keep this file lean; prune rules that no longer change behavior.
- For a new module, add `Projects/<NewModule>/AGENTS.md` and register it in the table above.
