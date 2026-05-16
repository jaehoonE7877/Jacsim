# TCA to SwiftUI async/await Migration Plan

## Goal

Remove ComposableArchitecture from Jacsim production code, tests, and project manifests while preserving current behavior and layer boundaries.

## Final Status

- Production Presentation/Application now uses SwiftUI + async/await + Observation models.
- `Projects/Jacsim/Sources/Client` now exposes explicit `JacsimDependencies` construction instead of TCA `DependencyValues`.
- Test coverage was migrated from `TestStore` to focused Swift Testing model tests and port recorder tests.
- ComposableArchitecture was removed from `Package.swift`, Jacsim project dependencies, ThirdPartyLibs aggregation, and the SPM dependency helper.
- Final validation passed on 2026-05-15; see `VALIDATION_LOG.md`.

## Constraints

- Keep `Domain`, `ExternalInterface`, `Data`, and `Application` boundaries intact.
- Do not let Presentation reference Data adapters directly.
- Use native SwiftUI, async/await, and iOS 18+ Observation.
- Prefer small `@MainActor @Observable` screen models or plain SwiftUI state over framework-style abstractions.
- Do not introduce another architecture framework, RxSwift, Realm, or heavy dependencies.
- Keep UI and behavior unchanged unless an implementation-only migration change is explicitly documented.

## Current TCA Surface

Initial inventory command:

```bash
rg "ComposableArchitecture|@Reducer|StoreOf<|TestStore|@Dependency|DependencyValues|Effect<|@Presents|StackState|StackAction" Package.swift Projects Plugins Tuist
```

Production and manifest files currently containing TCA usage:

- `Projects/Jacsim/Sources/Application/JacsimApp.swift`
- `Projects/Jacsim/Sources/Presentation/App/AppFeature.swift`
- `Projects/Jacsim/Sources/Presentation/App/AppView.swift`
- `Projects/Jacsim/Sources/Presentation/App/PresentationRedesignFlags.swift`
- `Projects/Jacsim/Sources/Presentation/Main/MainFeature.swift`
- `Projects/Jacsim/Sources/Presentation/Main/MainView.swift`
- `Projects/Jacsim/Sources/Presentation/Home/HomeFeature.swift`
- `Projects/Jacsim/Sources/Presentation/Home/HomeView.swift`
- `Projects/Jacsim/Sources/Presentation/ChallengeCreate/ChallengeCreateFeature.swift`
- `Projects/Jacsim/Sources/Presentation/ChallengeCreate/ChallengeCreateView.swift`
- `Projects/Jacsim/Sources/Presentation/WalkThorugh/WalkThroughFeature.swift`
- `Projects/Jacsim/Sources/Presentation/WalkThorugh/WalkThroughView.swift`
- `Projects/Jacsim/Sources/Presentation/AllTask/AllTaskFeature.swift`
- `Projects/Jacsim/Sources/Presentation/AllTask/AllTaskView.swift`
- `Projects/Jacsim/Sources/Presentation/Calendar/CalendarFeature.swift`
- `Projects/Jacsim/Sources/Presentation/Calendar/CalendarView.swift`
- `Projects/Jacsim/Sources/Presentation/Setting/SettingFeature.swift`
- `Projects/Jacsim/Sources/Presentation/Setting/SettingView.swift`
- `Projects/Jacsim/Sources/Presentation/NewTask/NewTaskFeature.swift`
- `Projects/Jacsim/Sources/Presentation/NewTask/NewTaskView.swift`
- `Projects/Jacsim/Sources/Presentation/TaskUpdate/TaskUpdateFeature.swift`
- `Projects/Jacsim/Sources/Presentation/TaskUpdate/TaskUpdateView.swift`
- `Projects/Jacsim/Sources/Presentation/TaskDetail/TaskDetailFeature.swift`
- `Projects/Jacsim/Sources/Presentation/TaskDetail/TaskDetailView.swift`
- `Projects/Jacsim/Sources/Presentation/TaskDetail/TaskEditFeature.swift`
- `Projects/Jacsim/Sources/Presentation/TaskDetail/TaskEditView.swift`
- `Projects/Jacsim/Sources/Client/AppPreferencesClient.swift`
- `Projects/Jacsim/Sources/Client/ImageStoreClient.swift`
- `Projects/Jacsim/Sources/Client/JacsimClient.swift`
- `Projects/Jacsim/Sources/Client/NotificationSchedulerClient.swift`
- `Projects/Jacsim/Sources/Client/TaskRepositoryClient.swift`
- `Projects/Jacsim/Project.swift`
- `Projects/Modules/ThirdPartyLibs/Project.swift`
- `Plugins/DependencyPlugin/ProjectDescriptionHelpers/Dependency+SPM.swift`

Test files currently containing TCA usage:

- `Projects/Jacsim/Tests/Sources/Presentation/AppFeatureTests.swift`
- `Projects/Jacsim/Tests/Sources/Presentation/CalendarFeatureTests.swift`
- `Projects/Jacsim/Tests/Sources/Presentation/HomeFeatureTests.swift`
- `Projects/Jacsim/Tests/Sources/Presentation/NewTaskFeatureTests.swift`
- `Projects/Jacsim/Tests/Sources/Presentation/PresentationRedesignFlagsTests.swift`
- `Projects/Jacsim/Tests/Sources/Presentation/SettingFeatureTests.swift`
- `Projects/Jacsim/Tests/Sources/Presentation/TaskDetailFeatureTests.swift`
- `Projects/Jacsim/Tests/Sources/Presentation/TaskEditFeatureTests.swift`

## Concept Mapping

| TCA concept | Native replacement |
|---|---|
| `@Reducer` feature | `@MainActor @Observable` screen model, or plain SwiftUI state for trivial screens |
| `StoreOf<Feature>` | Owned `@State` model plus explicit init dependencies |
| `ViewStore`/`send` actions | Direct method calls on the model or local view state mutations |
| `Effect.run` | `Task`, async methods, and `AsyncSequence` loops with explicit cancellation |
| `@Dependency` / `DependencyValues` | Constructor injection and SwiftUI `Environment` values where shared app dependencies are needed |
| `@Presents` | SwiftUI `sheet`, `fullScreenCover`, `alert`, and optional presentation state |
| `StackState` / `StackAction` | `NavigationStack` with typed route/path state |
| `TestStore` tests | Focused XCTest/Swift Testing tests for model methods, async side effects, navigation state, and regressions |

## Checkpoints

1. Inventory and migration tracking documents.
2. Low-risk leaf screens: ChallengeCreate, WalkThrough, AllTask, Calendar, Setting.
3. Task mutation flows: NewTask, TaskUpdate, TaskEdit, TaskDetail.
4. High-risk shell/navigation flows: Home, Main, App.
5. Client dependency cleanup under `Projects/Jacsim/Sources/Client`.
6. Test migration from TestStore to focused native tests.
7. Manifest cleanup and final validation.

## Validation Policy

- Run the smallest relevant build/test command after each checkpoint.
- Record every validation attempt in `VALIDATION_LOG.md`.
- Fix failed validation before moving to the next checkpoint unless a blocker is documented.
- Final validation must include the full TCA rg sweep, `tuist generate`, app build, and Jacsim/Domain/Data/ExternalInterface tests.
