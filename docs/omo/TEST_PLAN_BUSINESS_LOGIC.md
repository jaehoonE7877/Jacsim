# Business Logic Test Plan (Swift Testing)

## Goal
Ensure Jacsim always has deterministic business-logic unit tests for Domain rules and Application orchestration rules, using `import Testing`, `@Test`, `#expect`, and `#require`.

## Required Business Logic Inventory (with code evidence)

| Priority | Business logic to protect | Evidence (code location) | Existing status before this work | Action |
|---|---|---|---|---|
| REQUIRED | Date-range array generation includes start/end bounds | `Projects/Domain/Sources/Task.swift` (`Task.dayArray`), `Projects/Domain/Sources/Task.swift` (`StageSnapshot.dayArray`) | Missing direct edge coverage | Added tests |
| REQUIRED | Progress/completion calculations use checked records only | `Projects/Domain/Sources/Task.swift` (`progress`, `completedDays`) | Missing direct edge coverage | Added tests |
| REQUIRED | Record presence/completion by day are day-semantic | `Projects/Domain/Sources/Task.swift` (`hasRecord(for:)`, `isCompleted(on:)`) | Missing direct edge coverage | Added tests |
| REQUIRED | Safe out-of-range index handling | `Projects/Domain/Sources/Task.swift` (`isToday(dayIndex:)`, existing `imageKey(for:)`) | Partial (`imageKey` only) | Added `isToday` edge tests |
| REQUIRED | Stage/result rawValue fallback defaults for invalid persisted values | `Projects/Domain/Sources/Task.swift` (`StageSnapshot.stageType`, `StageSnapshot.result`) | Missing | Added tests |
| REQUIRED | Stage/result setter-to-raw synchronization | `Projects/Domain/Sources/Task.swift` (`StageSnapshot.stageType`, `StageSnapshot.result`) | Missing | Added tests |
| REQUIRED | UseCase orchestration: cancel/schedule branching and OFF behavior | `Projects/Jacsim/Sources/Application/UseCases/ReminderSchedulingUseCase.swift` | Missing direct use-case tests | Added tests with port spy |
| REQUIRED | UseCase orchestration: global reminder sync ON/OFF and per-item failure resilience | `Projects/Jacsim/Sources/Application/UseCases/ReminderSchedulingUseCase.swift` | Missing direct use-case tests | Added tests with throwing spy |
| RECOMMENDED | Stage result threshold and in-progress/success/fail policy | `Projects/Domain/Sources/StagePolicy.swift` | Covered | Kept existing coverage |
| RECOMMENDED | Stage progression/reset record rebuild invariants | `Projects/Domain/Sources/UseCases/StageProgressionUseCase.swift` | Covered | Kept existing coverage |
| RECOMMENDED | Certification index guards and task-not-found behavior | `Projects/Domain/Sources/UseCases/CertificationUseCase.swift` | Covered | Kept existing coverage |
| RECOMMENDED | Notification eligibility gating rules | `Projects/Domain/Sources/NotificationPolicy.swift` | Covered | Kept existing coverage |
| RECOMMENDED | Challenge state transitions and day view fallback mapping | `Projects/Domain/Sources/Services/ChallengeStateService.swift` | Covered | Kept existing coverage |
| DEFERRED | CreateTask timestamp fields (`createdAt`, `updatedAt`) are `Date.now`-based and not injectable | `Projects/Domain/Sources/UseCases/CreateTaskUseCase.swift` | No explicit deterministic timestamp assertion | Deferred: lower business risk than mandatory rules |
| DEFERRED | Non-business UI reducers and navigation-only transitions | `Projects/Jacsim/Sources/Presentation/**` | Broadly covered for reducer flows | Deferred from business-logic gate |

## Test Cases and Edge Cases Added

### 1) Domain entity/value-object rules
- `Task.dayArray` start/end inclusive and invalid range (`startDate > endDate`) behavior
- `Task.progress` and `Task.completedDays` with mixed checked/unchecked records
- `Task.hasRecord(for:)` and `Task.isCompleted(on:)` day-based logic (record exists but unchecked, missing record)
- `Task.isToday(dayIndex:)` out-of-range (`-1`, very large index)
- `StageSnapshot` invalid `stageTypeRaw` / invalid `resultRaw` fallback to defaults
- `StageSnapshot` setter-writeback to raw values and `dayArray` boundaries

### 2) Application use-case orchestration rules
- `scheduleReminderIfNeeded`: cancel-then-schedule branch when all toggles ON
- `scheduleReminderIfNeeded`: no schedule when alarm OFF or global notification OFF
- `scheduleReminderIfNeeded`: schedule error must not escape (non-throwing behavior maintained)
- `syncGlobalReminders`: ON schedules all reminders
- `syncGlobalReminders`: OFF cancels all reminders
- `syncGlobalReminders`: one reminder scheduling failure does not stop remaining reminders

## Port Double Strategy (Isolation)
- `NotificationSchedulerPort` is mocked with a dedicated actor spy in tests:
  - captures scheduled task IDs and times
  - captures cancelled task IDs
  - can force per-task schedule failures
- Existing Domain use cases continue using closure-injected handlers (`fetchTask`, `updateTask`) as in-memory doubles.
- No external I/O, network, system scheduler, or E2E dependency is used in unit tests.

## Determinism Strategy
- Tests use fixed input dates (explicit year/month/day/hour/minute) instead of `Date.now` assertions.
- Time extraction assertions for reminder scheduling use the same runtime calendar semantics as production code.
- Out-of-range, empty/invalid range, and invalid raw-value cases are explicitly asserted.
- No random input, no ordering race assumptions, and no async race-prone waits are used.

## Gate Execution Summary

| Command | Result | Notes |
|---|---|---|
| `tuist generate` | PASS | Workspace regenerated |
| `tuist build Jacsim` | PASS | Build succeeded (deprecation warning for `tuist build` only) |
| `tuist test Domain` | PASS | New Domain tests compile and pass |
| `tuist test ExternalInterface` | PASS | Scheme completed successfully |
| `tuist test Data` | PASS | Scheme completed successfully |
| `tuist test Jacsim` | PASS | New Application use-case tests compile and pass |

### Failure/Recovery log
- Initial `tuist test Jacsim` run failed once due to a timezone-sensitive assertion in `ReminderSchedulingUseCaseTests` (`hour == 8` mismatch).
- Fixed by constructing test alarm dates with `Calendar.current` semantics (matching production extraction logic).
- Re-ran full global gates; all commands passed.
