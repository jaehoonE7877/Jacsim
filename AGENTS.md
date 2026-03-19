# AGENTS.md — Jacsim

> iOS 18+ · Swift 6 · Tuist 4 · SwiftUI + TCA · Port & Adapter

---

## 1. Quick Start

```bash
# Bootstrap (run once after clone / dependency change)
tuist install

# Generate Xcode project
tuist generate

# Build
tuist build Jacsim

# Test (per-module)
tuist test Jacsim
tuist test JacsimClient
tuist test Domain
tuist test Workflows
tuist test Ports
tuist test Adapters
tuist test Shared
```

> `DesignSystem`은 현재 전용 unit test target이 없습니다. DSKit 변경은 `tuist build Jacsim`과 영향받는 downstream scheme 테스트로 검증합니다.
> No lint/format tool이 아직 구성되어 있지 않습니다. 승인 없이 새로 도입하지 마세요.

---

## 2. Success Criteria

변경이 적절하려면 아래 조건을 **모두** 충족해야 합니다:

1. `tuist generate`가 오류 없이 완료되어야 함
2. `tuist build Jacsim`이 성공해야 함
3. 수정한 각 모듈에 대해 `tuist test <affected-scheme>`가 통과해야 함
4. 새로 추가된 컴파일러 경고가 없어야 함

---

## 3. Repo Structure

```text
./
├── Projects/
│   ├── Jacsim/             # App target (Presentation)
│   ├── JacsimClient/       # App composition / DI bridge
│   ├── Workflows/          # Application UseCases (Orchestration)
│   ├── Domain/             # Business rules / entities
│   ├── ExternalInterface/  # Port contracts (Ports)
│   ├── Data/               # Adapter implementations (Adapters)
│   └── Modules/
│       ├── Core/           # Shared utilities / extensions (Shared)
│       ├── DSKit/          # Design system (DesignSystem)
│       └── ThirdPartyLibs/ # Third-party dependency aggregation
├── Tuist/                  # Project generation helpers & templates
├── Plugins/                # Tuist plugins (Dependency/Environment/Configuration)
├── xcconfigs/              # Build settings (.xcconfig)
├── scripts/                # CI & helper scripts
├── design-system/          # Design reference docs (read-only for agents)
├── Workspace.swift
├── Package.swift
└── Tuist.swift
```

### Where to Find

| 작업 | 경로 |
|---|---|
| 앱 진입점 | `Projects/Jacsim/Sources/Application/JacsimApp.swift` |
| 앱 라이프사이클 | `Projects/Jacsim/Sources/Application/AppDelegate.swift` |
| TCA 화면 | `Projects/Jacsim/Sources/Presentation/**` |
| Use case | `Projects/Workflows/Sources/UseCases/**` |
| Domain 로직 | `Projects/Domain/Sources/**` |
| Port 계약 | `Projects/ExternalInterface/Sources/**` |
| Data 어댑터 | `Projects/Data/Sources/Adapters/**` |
| Design system | `Projects/Modules/DSKit/Sources/**` |
| 공통 유틸리티 | `Projects/Modules/Core/Sources/**` |

---

## 4. Code Style

- **UI**: SwiftUI + TCA만 사용. 새 UIKit 화면을 추가하지 않는다.
- **Architecture**: Port & Adapter — Presentation → Workflows → Ports ← Adapters.
- **Screen pattern**: `*Feature.swift` (TCA Reducer) + `*View.swift` (SwiftUI View) pair.
- **Scaffolding**: 새 화면 템플릿은 `Projects/Jacsim/Sources/Presentation/<Name>`와 `Projects/Jacsim/Tests/Sources/Presentation`에 직접 생성한다. `Projects/Features`를 다시 만들지 않는다.
- **Dependency access**: `taskRepository`, `userSettingsRepository`, `appPreferences` 같은 client dependency를 사용하고, Presentation에서 concrete adapter를 직접 쓰지 않는다.
- **Third-party deps**: raw SPM URL 대신 plugin alias(`Plugins/DependencyPlugin`)를 사용한다.

```swift
// ✅ Good — Feature + View pair, port client dependency
@Reducer
struct HomeFeature {
    @Dependency(\.taskRepository) var taskRepository
}

// ❌ Bad — direct adapter / infrastructure in Presentation
struct HomeView: View {
    let realm = try! Realm()    // Never do this
}
```

---

## 5. Boundaries

### 🚫 Never Do

| 규칙 | 상세 |
|---|---|
| Generated files | `Projects/**/Derived/**`, `.build/**`, `.derivedData/**`, `build/**`는 수정하지 않는다 |
| Secrets | API keys, credentials, 개인 식별 정보는 어떤 파일에도 커밋하지 않는다 |
| Legacy frameworks | 신규 RxSwift 또는 Realm 사용을 추가하지 않는다 |
| UIKit screens | UIKit 기반 새 뷰를 만들지 않는다 |
| Production deploy | Xcode Cloud 또는 App Store workflows를 직접 트리거하지 않는다 |
| CI workflows | 명시적 승인 없이 `.github/workflows/**`를 수정하지 않는다 |

### ⚠️ Ask First

| 규칙 | 상세 |
|---|---|
| 신규 의존성 | `Package.swift`에 패키지를 추가하려면 사람 승인 필요 |
| Tuist config | `Tuist.swift`, `Workspace.swift`, `Plugins/**` 변경은 리뷰가 필요하다 |
| xcconfig 변경 | `xcconfigs/**` 수정은 모든 타겟에 영향이 있을 수 있으므로 범위를 먼저 확인한다 |
| 모듈 생성 | `Projects/` 하위 신규 모듈은 Tuist 템플릿 규칙을 따라야 함 |
| Design system | `DSKit`의 토큰/컴포넌트 변경은 앱 전체 UI에 영향을 준다 |

---

## 6. Git & PR Workflow

- **Branch**: 현재 default branch에서 `feature/*`, `fix/*`, `refactor/*` 브랜치 사용
- **Commit prefix**: `Feat:`, `Fix:`, `Refactor:`, `Chore:`, `Docs:` (본문은 한국어 가능)
- **PR**: `.github/PULL_REQUEST_TEMPLATE.md`를 작성하고 테스트 명령 출력 결과를 포함한다
- **CI gate**: 병합 전 `ios-ci.yml`을 통해 `tuist test <scheme>` 통과 필요

---

## 7. Context Hygiene

- **필요한 범위만 읽는다.** 먼저 이 파일을 확인한 뒤 관련 sub-AGENTS.md, 다음으로 소스 파일을 본다.
- **Never read** `.build/`, `.derivedData/`, `build/`, `*.xcodeproj/`의 내용을 읽지 않는다 — 생성물이라 크기가 큼.
- **Large outputs**: 200줄을 넘는 명령 결과는 전체 출력 대신 요약해서 확인한다.
- **Token budget**: 디렉터리를 스캔하기 전에 먼저 위의 `Where to Find` 테이블을 참고한다.

---

## 8. Sub-Module Guides

해당 모듈 작업 시에만 아래 AGENTS를 읽는다:

| 모듈 | 가이드 | 읽을 대상 |
|---|---|---|
| App (Jacsim) | `Projects/Jacsim/AGENTS.md` | 화면 추가/수정, Use case 작업, 앱 라이프사이클 변경 |
| JacsimClient | `Projects/JacsimClient/AGENTS.md` | 앱 의존성 조립, Ports/Adapters bridge, composition root 변경 |
| Workflows | `Projects/Workflows/AGENTS.md` | Use case 추가/수정, 애플리케이션 오케스트레이션 |
| Domain | `Projects/Domain/AGENTS.md` | 엔티티, 정책, 순수 도메인 서비스 변경 |
| Ports (ExternalInterface) | `Projects/ExternalInterface/AGENTS.md` | Port 계약, closure contract, dependency boundary 변경 |
| Adapters (Data) | `Projects/Data/AGENTS.md` | 인프라 adapter, 매핑, SwiftData 구현 변경 |
| DSKit | `Projects/Modules/DSKit/AGENTS.md` | Design token 또는 공통 UI 컴포넌트 변경 |
| Core | `Projects/Modules/Core/AGENTS.md` | 공통 유틸리티 또는 extension 추가 |
| ThirdPartyLibs | `Projects/Modules/ThirdPartyLibs/AGENTS.md` | 외부 dependency 관리 |
| Tuist | `Tuist/AGENTS.md` | 프로젝트 생성 또는 템플릿 수정 |
| Plugins | `Plugins/AGENTS.md` | dependency alias 또는 환경 설정 변경 |
| xcconfigs | `xcconfigs/AGENTS.md` | Build settings 수정 |

---

## 9. Maintenance

- **On failure**: If an agent repeatedly makes the same mistake, add a one-line rule to the relevant section of this file or the sub-AGENTS.md.
- **Prune**: If this file exceeds ~120 lines or a rule no longer applies, remove it. Keep only actionable instructions.
- **New module**: Create `Projects/<NewModule>/AGENTS.md` following the sub-module template (Purpose / Key Paths / Rules / Test), then add a row to section 8.
