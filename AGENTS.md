# AGENTS.md — Jacsim

> iOS 18+ · Swift 6 · Tuist 4 · SwiftUI + TCA · Port & Adapter

## Quick Start

```bash
tuist install
tuist generate
tuist build Jacsim
tuist test Jacsim
tuist test JacsimClient
tuist test Domain
tuist test Workflows
tuist test Ports
tuist test Adapters
tuist test Shared
```

> `DesignSystem`에는 전용 unit test target이 없습니다. DSKit 변경은 `tuist build Jacsim`과 영향받는 downstream scheme 테스트로 검증합니다.
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
| Presentation | `Projects/Jacsim/Sources/Presentation/**` |
| Use cases | `Projects/Workflows/Sources/UseCases/**` |
| Domain | `Projects/Domain/Sources/**` |
| Ports | `Projects/ExternalInterface/Sources/**` |
| Adapters | `Projects/Data/Sources/Adapters/**` |
| Design system | `Projects/Modules/DSKit/Sources/**` |
| Shared utilities | `Projects/Modules/Core/Sources/**` |

## Boundaries

### Never Do

| Rule | Detail |
|---|---|
| Generated files | Do not edit `Projects/**/Derived/**`, `.build/**`, `.derivedData/**`, or `build/**`. |
| Secrets | Do not commit API keys, credentials, or personal data. |
| Legacy frameworks | Do not add new RxSwift or Realm usage. |
| UIKit screens | Do not add new UIKit-based views. |
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
| App (`Jacsim`) | `Projects/Jacsim/AGENTS.md` | Screen changes, use case wiring, app lifecycle |
| `JacsimClient` | `Projects/JacsimClient/AGENTS.md` | DI bridge, ports/adapters wiring |
| `Workflows` | `Projects/Workflows/AGENTS.md` | Use case changes, orchestration |
| `Domain` | `Projects/Domain/AGENTS.md` | Entities, policies, domain services |
| `Ports` | `Projects/ExternalInterface/AGENTS.md` | Port contracts and boundaries |
| `Adapters` | `Projects/Data/AGENTS.md` | Infrastructure adapters and mapping |
| `DSKit` | `Projects/Modules/DSKit/AGENTS.md` | Design tokens and shared UI components |
| `Core` | `Projects/Modules/Core/AGENTS.md` | Shared utilities and extensions |
| `ThirdPartyLibs` | `Projects/Modules/ThirdPartyLibs/AGENTS.md` | External dependency management |
| `Tuist` | `Tuist/AGENTS.md` | Project generation and templates |
| `Plugins` | `Plugins/AGENTS.md` | Dependency alias and environment config |
| `xcconfigs` | `xcconfigs/AGENTS.md` | Build setting changes |

## Maintenance

- If an agent repeats the same mistake, add a one-line rule to the relevant file.
- Keep this file lean; prune rules that no longer change behavior.
- For a new module, add `Projects/<NewModule>/AGENTS.md` and register it in the table above.
