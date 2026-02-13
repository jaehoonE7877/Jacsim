# Business Logic Coverage Map

This map links business behaviors to concrete Swift Testing test files.

| Source (file / symbol) | Verified behavior | Test file |
|---|---|---|
| `Projects/Domain/Sources/Task.swift` `Task.dayArray` | Date range is start/end inclusive; invalid range returns empty | `Projects/Domain/Tests/Sources/TaskBusinessLogicTests.swift` |
| `Projects/Domain/Sources/Task.swift` `Task.progress` | Progress ratio uses checked records count over total day count | `Projects/Domain/Tests/Sources/TaskBusinessLogicTests.swift` |
| `Projects/Domain/Sources/Task.swift` `Task.completedDays` | Completed-day count includes only checked records | `Projects/Domain/Tests/Sources/TaskBusinessLogicTests.swift` |
| `Projects/Domain/Sources/Task.swift` `Task.hasRecord(for:)` | Record existence is matched by calendar day semantics | `Projects/Domain/Tests/Sources/TaskBusinessLogicTests.swift` |
| `Projects/Domain/Sources/Task.swift` `Task.isCompleted(on:)` | Completion false when missing/unchecked, true when checked for day | `Projects/Domain/Tests/Sources/TaskBusinessLogicTests.swift` |
| `Projects/Domain/Sources/Task.swift` `Task.isToday(dayIndex:)` | Out-of-range index returns false safely | `Projects/Domain/Tests/Sources/TaskBusinessLogicTests.swift` |
| `Projects/Domain/Sources/Task.swift` `Task.imageKey(for:)` | Out-of-range index returns nil safely | `Projects/Domain/Tests/Sources/DomainTests.swift` |
| `Projects/Domain/Sources/Task.swift` `StageSnapshot.stageType` / `result` | Invalid raw values fallback to safe defaults; setters sync raw values | `Projects/Domain/Tests/Sources/TaskBusinessLogicTests.swift` |
| `Projects/Domain/Sources/Task.swift` `StageSnapshot.dayArray` | Stage date range is start/end inclusive | `Projects/Domain/Tests/Sources/TaskBusinessLogicTests.swift` |
| `Projects/Jacsim/Sources/Application/UseCases/ReminderSchedulingUseCase.swift` `scheduleReminderIfNeeded` | Cancel branch runs before schedule when requested | `Projects/Jacsim/Tests/Sources/Application/ReminderSchedulingUseCaseTests.swift` |
| `Projects/Jacsim/Sources/Application/UseCases/ReminderSchedulingUseCase.swift` `scheduleReminderIfNeeded` | Scheduling blocked when alarm/global toggle is off | `Projects/Jacsim/Tests/Sources/Application/ReminderSchedulingUseCaseTests.swift` |
| `Projects/Jacsim/Sources/Application/UseCases/ReminderSchedulingUseCase.swift` `scheduleReminderIfNeeded` | Schedule failures are swallowed (non-throwing recovery path) | `Projects/Jacsim/Tests/Sources/Application/ReminderSchedulingUseCaseTests.swift` |
| `Projects/Jacsim/Sources/Application/UseCases/ReminderSchedulingUseCase.swift` `syncGlobalReminders` | ON => schedule all reminders | `Projects/Jacsim/Tests/Sources/Application/ReminderSchedulingUseCaseTests.swift` |
| `Projects/Jacsim/Sources/Application/UseCases/ReminderSchedulingUseCase.swift` `syncGlobalReminders` | OFF => cancel all reminders | `Projects/Jacsim/Tests/Sources/Application/ReminderSchedulingUseCaseTests.swift` |
| `Projects/Jacsim/Sources/Application/UseCases/ReminderSchedulingUseCase.swift` `syncGlobalReminders` | Continues after single reminder schedule failure | `Projects/Jacsim/Tests/Sources/Application/ReminderSchedulingUseCaseTests.swift` |
| `Projects/Domain/Sources/StagePolicy.swift` `minimumSuccessDays` / `evaluateStageResult` | Success threshold and in-progress/success/fail transitions | `Projects/Domain/Tests/Sources/StagePolicyTests.swift`, `Projects/Domain/Tests/Sources/StageEvaluationServiceTests.swift` |
| `Projects/Domain/Sources/UseCases/StageProgressionUseCase.swift` | Next stage creation, reset logic, record range rebuild | `Projects/Domain/Tests/Sources/StageProgressionUseCaseTests.swift` |
| `Projects/Domain/Sources/UseCases/CertificationUseCase.swift` | Invalid index throws; memo/certification updates persisted | `Projects/Domain/Tests/Sources/CertificationUseCaseTests.swift` |
| `Projects/Domain/Sources/NotificationPolicy.swift` `shouldScheduleNotification` | Eligibility gating by settings, stage state, date range, today record | `Projects/Domain/Tests/Sources/NotificationPolicyTests.swift` |
| `Projects/Domain/Sources/Services/ChallengeStateService.swift` `evaluateChallengeState` | Stage state evaluation, today status, day-view fallback ordering | `Projects/Domain/Tests/Sources/ChallengeStateServiceTests.swift` |

## Deferred Coverage Notes

- `Projects/Domain/Sources/UseCases/CreateTaskUseCase.swift`: deterministic assertions around `createdAt`/`updatedAt` are deferred (uses `.now` without clock injection).
- Navigation-only reducer flows are intentionally excluded from this business-logic map.
