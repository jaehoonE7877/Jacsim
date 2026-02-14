# Projects/Jacsim

**Purpose**: App target — SwiftUI + TCA Presentation layer and Application orchestration layer.

## Key Paths

| Task | Path |
|---|---|
| App entry | `Sources/Application/JacsimApp.swift` |
| App lifecycle | `Sources/Application/AppDelegate.swift` |
| Root reducer | `Sources/Presentation/App/AppFeature.swift` |
| Home flow | `Sources/Presentation/Home/**` |
| Use cases | `Sources/Application/UseCases/**` |
| DI client wiring | `Sources/Client/**` |

## Test

```bash
tuist test Jacsim
```

## Rules

### ✅ Do

- Use port clients (`taskQueryClient`, `taskCommandClient`) for data access
- Keep concrete infrastructure access in `Client/` or `Application/` layer
- For multi-step workflows, call Application use cases via dependencies (e.g. `createNewTaskUseCase`, `updateTaskSettingsUseCase`)
- Every screen: `*Feature.swift` + `*View.swift` pair

### 🚫 Do Not

- Reference Data adapters from Presentation
- Hardcode UserDefaults/SwiftData inside Feature reducers
- Instantiate Application use cases directly in reducers (wire them through `Sources/Client/**` instead)
- Put `UseCase` types under `Projects/Domain` (Domain is entities/policies/services only)
- Add new UIKit-based screens
