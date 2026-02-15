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
tuist test Domain
tuist test Workflows
tuist test Ports
tuist test Adapters
tuist test Shared
tuist test DesignSystem
```

> No lint/format tool is configured yet. Do **not** introduce one without approval.

---

## 2. Success Criteria

Your change is correct when **all** of the following pass:

1. `tuist generate` completes without errors
2. `tuist build Jacsim` succeeds
3. `tuist test <affected-scheme>` passes for every module you touched
4. No new compiler warnings introduced

---

## 3. Repo Structure

```text
./
├── Projects/
│   ├── Jacsim/             # App target (Presentation)
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

| Task | Path |
|---|---|
| App entry | `Projects/Jacsim/Sources/Application/JacsimApp.swift` |
| App lifecycle | `Projects/Jacsim/Sources/Application/AppDelegate.swift` |
| TCA screens | `Projects/Jacsim/Sources/Presentation/**` |
| Use cases | `Projects/Workflows/Sources/UseCases/**` |
| Domain logic | `Projects/Domain/Sources/**` |
| Port contracts | `Projects/ExternalInterface/Sources/**` |
| Data adapters | `Projects/Data/Sources/Adapters/**` |
| Design system | `Projects/Modules/DSKit/Sources/**` |
| Common utils | `Projects/Modules/Core/Sources/**` |

---

## 4. Code Style

- **UI**: SwiftUI + TCA only. No new UIKit screens.
- **Architecture**: Port & Adapter — Presentation → Workflows → Ports ← Adapters.
- **Screen pattern**: `*Feature.swift` (TCA Reducer) + `*View.swift` (SwiftUI View) pair.
- **Dependency access**: Use port clients (`taskQueryClient`, `taskCommandClient`, etc.), never concrete adapters in Presentation.
- **Third-party deps**: Reference via plugin alias (`Plugins/DependencyPlugin`), not raw SPM URLs.

```swift
// ✅ Good — Feature + View pair, port client dependency
@Reducer
struct HomeFeature {
    @Dependency(\.taskQueryClient) var taskQueryClient
}

// ❌ Bad — direct adapter / infrastructure in Presentation
struct HomeView: View {
    let realm = try! Realm()    // Never do this
}
```

---

## 5. Boundaries

### 🚫 Never Do

| Rule | Detail |
|---|---|
| Generated files | Never edit `Projects/**/Derived/**`, `.build/**`, `.derivedData/**`, `build/**` |
| Secrets | Never commit API keys, credentials, or personal identifiers to any file |
| Legacy frameworks | Never add new RxSwift or Realm usage |
| UIKit screens | Never create new UIKit-based views |
| Production deploy | Never trigger Xcode Cloud or App Store workflows |
| CI workflows | Never modify `.github/workflows/**` without explicit approval |

### ⚠️ Ask First

| Rule | Detail |
|---|---|
| New dependency | Adding a package to `Package.swift` requires human approval |
| Tuist config | Changes to `Tuist.swift`, `Workspace.swift`, or `Plugins/**` need review |
| xcconfig changes | Modifying `xcconfigs/**` may affect all targets — confirm scope |
| Module creation | New modules under `Projects/` must follow Tuist template conventions |
| Design system | `DSKit` token/component changes affect the entire app UI |

---

## 6. Git & PR Workflow

- **Branch**: feature/*, fix/*, refactor/* from `develop`
- **Commit prefix**: `Feat:`, `Fix:`, `Refactor:`, `Chore:`, `Docs:` (Korean body OK)
- **PR**: Fill `.github/PULL_REQUEST_TEMPLATE.md` — include test command output
- **CI gate**: `tuist test <scheme>` must pass via `ios-ci.yml` before merge

---

## 7. Context Hygiene

- **Read only what you need.** Start from this file, then the relevant sub-AGENTS.md, then source files.
- **Never read** `.build/`, `.derivedData/`, `build/`, `*.xcodeproj/` contents — they are generated and huge.
- **Large outputs**: If a command produces > 200 lines, summarize instead of pasting in full.
- **Token budget**: Prefer reading the `Where to Find` table above before scanning directories.

---

## 8. Sub-Module Guides

Read these **only when working on the corresponding module**:

| Module | Guide | When to Read |
|---|---|---|
| App (Jacsim) | `Projects/Jacsim/AGENTS.md` | Adding/modifying screens, use cases, app lifecycle |
| Workflows | `Projects/Workflows/AGENTS.md` | Adding/modifying use cases, application orchestration |
| DSKit | `Projects/Modules/DSKit/AGENTS.md` | Changing design tokens or shared UI components |
| Core | `Projects/Modules/Core/AGENTS.md` | Adding shared utilities or extensions |
| ThirdPartyLibs | `Projects/Modules/ThirdPartyLibs/AGENTS.md` | Managing external dependencies |
| Features (legacy) | `Projects/Features/AGENTS.md` | Referencing old experimental code |
| Tuist | `Tuist/AGENTS.md` | Modifying project generation or templates |
| Plugins | `Plugins/AGENTS.md` | Changing dependency aliases or environment config |
| xcconfigs | `xcconfigs/AGENTS.md` | Editing build settings |

---

## 9. Maintenance

- **On failure**: If an agent repeatedly makes the same mistake, add a one-line rule to the relevant section of this file or the sub-AGENTS.md.
- **Prune**: If this file exceeds ~120 lines or a rule no longer applies, remove it. Keep only actionable instructions.
- **New module**: Create `Projects/<NewModule>/AGENTS.md` following the sub-module template (Purpose / Key Paths / Rules / Test), then add a row to section 8.
