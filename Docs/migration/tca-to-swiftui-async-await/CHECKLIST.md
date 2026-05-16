# TCA to SwiftUI async/await Checklist

## Checkpoint 1: Inventory and Plan

- [x] Read root `AGENTS.md`.
- [x] Read `Projects/Jacsim/AGENTS.md`.
- [x] Inspect `git status`.
- [x] Inspect current diff.
- [x] Run initial TCA inventory.
- [x] Create migration tracking documents.

## Checkpoint 2: Low-risk Leaf Screens

- [x] Convert `ChallengeCreate`.
- [x] Convert `WalkThrough`.
- [x] Convert `AllTask`.
- [x] Convert `Calendar`.
- [x] Convert `Setting`.
- [x] Run smallest relevant validation.

## Checkpoint 3: Task Mutation Flows

- [x] Convert `NewTask`.
- [x] Convert `TaskUpdate`.
- [x] Convert `TaskEdit`.
- [x] Convert `TaskDetail`.
- [x] Run smallest relevant validation.

## Checkpoint 4: Shell and Navigation

- [x] Convert `Home`.
- [x] Convert `Main`.
- [x] Convert `App`.
- [x] Run smallest relevant validation.

## Checkpoint 5: Client Dependency Cleanup

- [x] Remove `@Dependency` and `DependencyValues` usage from `Projects/Jacsim/Sources/Client`.
- [x] Provide explicit dependency construction for SwiftUI/Observation.
- [x] Run smallest relevant validation.

## Checkpoint 6: Tests

- [x] Replace `TestStore` tests with focused XCTest/Swift Testing tests.
- [x] Cover state transitions.
- [x] Cover async effects.
- [x] Cover navigation and presentation behavior.
- [x] Cover known regression cases.
- [x] Run `tuist test Jacsim`.

## Checkpoint 7: Manifests and Final Validation

- [x] Remove ComposableArchitecture dependency from app manifests.
- [x] Remove ComposableArchitecture dependency from third-party aggregation.
- [x] Remove ComposableArchitecture SPM helper.
- [x] Run final rg sweep.
- [x] Run `tuist generate`.
- [x] Run `tuist build Jacsim`.
- [x] Run `tuist test Jacsim`.
- [x] Run `tuist test Domain`.
- [x] Run `tuist test Data`.
- [x] Run `tuist test ExternalInterface`.

## Stop Condition

- [x] No TCA imports, runtime usage, test usage, or manifest dependencies remain outside migration docs.
- [x] Final validation passes.
