import Foundation
import ComposableArchitecture

struct JacsimClient {
    var fetchActiveTasks: @Sendable () async -> [UserJacsim]
    var fetchIsSuccess: @Sendable () async -> [UserJacsim]
    var fetchIsFail: @Sendable () async -> [UserJacsim]
    var fetchDate: @Sendable (Date) async -> [UserJacsim]
    var fetchIsNotDone: @Sendable () async -> Int
    var fetchTask: @Sendable (UUID) async -> UserJacsim?
    var addJacsim: @Sendable (UserJacsim) async -> Void
    var updateMemo: @Sendable (UserJacsim, Int, String) async -> Void
    var deleteJacsim: @Sendable (UserJacsim) async -> Void
    var deleteAlarm: @Sendable (UserJacsim) async -> Void
    var checkIsDone: @Sendable ([UserJacsim]) async -> Void
    var updateTaskInfo: @Sendable (UserJacsim, String, Int, Bool, Date) async -> Void
    var createNextStage: @Sendable (UserJacsim) async -> Stage?
    var evaluateStageResult: @Sendable (Stage) async -> StageResult
    var needsMigrationV0_1: @Sendable () async -> Bool
    var performMigrationV0_1: @Sendable () async -> Void
}

extension JacsimClient: DependencyKey {
    static let liveValue = JacsimClient(
        fetchActiveTasks: { await MainActor.run { JacsimRepository.shared.fetchActiveTasks() } },
        fetchIsSuccess: { await MainActor.run { JacsimRepository.shared.fetchIsSuccess() } },
        fetchIsFail: { await MainActor.run { JacsimRepository.shared.fetchIsFail() } },
        fetchDate: { date in await MainActor.run { JacsimRepository.shared.fetchDate(date: date) } },
        fetchIsNotDone: { await MainActor.run { JacsimRepository.shared.fetchIsNotDone() } },
        fetchTask: { id in await MainActor.run { JacsimRepository.shared.fetchTask(id: id) } },
        addJacsim: { item in await MainActor.run { JacsimRepository.shared.addJacsim(item: item) } },
        updateMemo: { item, index, memo in await MainActor.run { JacsimRepository.shared.updateMemo(item: item, index: index, memo: memo) } },
        deleteJacsim: { item in await MainActor.run { JacsimRepository.shared.deleteJacsim(item: item) } },
        deleteAlarm: { item in await MainActor.run { JacsimRepository.shared.deleteAlarm(item: item) } },
        checkIsDone: { items in await MainActor.run { JacsimRepository.shared.checkIsDone(items: items) } },
        updateTaskInfo: { task, title, success, isAlarmEnabled, alarmDate in
            await MainActor.run {
                JacsimRepository.shared.updateTaskInfo(
                    task: task,
                    title: title,
                    success: success,
                    isAlarmEnabled: isAlarmEnabled,
                    alarmDate: alarmDate
                )
            }
        },
        createNextStage: { task in await MainActor.run { JacsimRepository.shared.createNextStage(for: task) } },
        evaluateStageResult: { stage in await MainActor.run { JacsimRepository.shared.evaluateStageResult(stage) } },
        needsMigrationV0_1: { await MainActor.run { JacsimRepository.shared.needsMigrationV0_1() } },
        performMigrationV0_1: { await MainActor.run { JacsimRepository.shared.performMigrationV0_1() } }
    )

    static let testValue = JacsimClient(
        fetchActiveTasks: { [] },
        fetchIsSuccess: { [] },
        fetchIsFail: { [] },
        fetchDate: { _ in [] },
        fetchIsNotDone: { 0 },
        fetchTask: { _ in nil },
        addJacsim: { _ in },
        updateMemo: { _, _, _ in },
        deleteJacsim: { _ in },
        deleteAlarm: { _ in },
        checkIsDone: { _ in },
        updateTaskInfo: { _, _, _, _, _ in },
        createNextStage: { _ in nil },
        evaluateStageResult: { _ in .inProgress },
        needsMigrationV0_1: { false },
        performMigrationV0_1: { }
    )
}

extension DependencyValues {
    var jacsimClient: JacsimClient {
        get { self[JacsimClient.self] }
        set { self[JacsimClient.self] = newValue }
    }
}
