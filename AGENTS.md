# Jacsim Knowledge Base (AGENTS.md)

## Overview
- iOS 18+, Swift 6, Tuist + SPM 멀티모듈
- SwiftUI + TCA + Port & Adapter 아키텍처 기반
- 앱 로직은 레이어 경계를 유지하며 모듈 단위로 관리

## Current Structure
```text
./
├── Projects/
│   ├── Jacsim/                     # App(Presentation/Application)
│   ├── Domain/                     # Domain rules/entities/services
│   ├── ExternalInterface/          # Port contracts
│   ├── Data/                       # Adapter implementations
│   ├── Modules/
│   │   ├── Core/                   # Utilities/extensions
│   │   ├── DSKit/                  # Design system
│   │   └── ThirdPartyLibs/         # Third-party aggregation
│   └── Features/                   # Legacy/experimental traces
├── Tuist/
├── Plugins/
├── xcconfigs/
├── Workspace.swift
└── Package.swift
```

## Layer Responsibilities
- `Jacsim`: Presentation(TCA) + Application use case orchestration
- `Domain`: 비즈니스 규칙, 엔티티 불변식, 도메인 계산
- `ExternalInterface`: 상위 레이어가 의존할 Port 계약
- `Data`: 외부 I/O 구현체(Adapter)

## Why ExternalInterface Exists
- Domain/Application이 구체 구현(Data)에 직접 의존하지 않도록 DIP를 보장
- 구현체 교체 비용을 낮추고 테스트에서 mock/in-memory 포트 주입을 쉽게 만듦
- 레이어 간 의존 방향을 고정해 아키텍처 안정성 확보

## Where to Find
| Task | Location |
|---|---|
| App entry | `Projects/Jacsim/Sources/Application/JacsimApp.swift` |
| App lifecycle | `Projects/Jacsim/Sources/Application/AppDelegate.swift` |
| App use cases | `Projects/Jacsim/Sources/Application/UseCases/**` |
| TCA screens | `Projects/Jacsim/Sources/Presentation/**` |
| Domain logic | `Projects/Domain/Sources/**` |
| Port contracts | `Projects/ExternalInterface/Sources/**` |
| Data adapters | `Projects/Data/Sources/Adapters/**` |
| Design system | `Projects/Modules/DSKit/**` |
| Common utilities | `Projects/Modules/Core/**` |

## Core Rules
- 신규 화면은 SwiftUI + TCA만 허용
- RxSwift/Realm 신규 도입 금지
- 생성 산출물 직접 수정 금지: `Projects/**/Derived/**`, `.build/**`, `.derivedData/**`, `build/**`

## Commands
```bash
tuist generate
tuist build Jacsim
tuist test Jacsim
tuist test Domain
tuist test Data
tuist test ExternalInterface
```

## Public Repository Policy
- 문서에 비밀값/인증키/개인 식별자/내부 운영 절차를 기록하지 않습니다.
- 민감 설정은 로컬/CI 비밀 저장소에서 관리합니다.

## Sub AGENTS
- `Projects/Jacsim/AGENTS.md`
- `Projects/Modules/DSKit/AGENTS.md`
- `Projects/Modules/Core/AGENTS.md`
- `Projects/Modules/ThirdPartyLibs/AGENTS.md`
- `Projects/Features/AGENTS.md`
- `Tuist/AGENTS.md`
- `Plugins/AGENTS.md`
- `xcconfigs/AGENTS.md`
