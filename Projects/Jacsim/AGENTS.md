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
- Every screen: `*Feature.swift` + `*View.swift` pair

### 🚫 Do Not

- Reference Data adapters from Presentation
- Hardcode UserDefaults/SwiftData inside Feature reducers
- Add new UIKit-based screens
