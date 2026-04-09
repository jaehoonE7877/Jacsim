import Foundation
import ComposableArchitecture
import Domain
import Workflows

public typealias CreateNewTaskUseCase = Workflows.CreateNewTaskUseCase
public typealias UpdateTaskSettingsUseCase = Workflows.UpdateTaskSettingsUseCase
public typealias GlobalNotificationSettingUseCase = Workflows.GlobalNotificationSettingUseCase
public typealias CertifyTaskTodayUseCase = Workflows.CertifyTaskTodayUseCase
public typealias StageProgressionUseCase = Workflows.StageProgressionUseCase
public typealias DeleteTaskUseCase = Workflows.DeleteTaskUseCase
public typealias ReminderSchedulingUseCase = Workflows.ReminderSchedulingUseCase

private enum CreateNewTaskUseCaseKey: DependencyKey {
    static let liveValue = UseCaseAssembly.createNewTaskUseCase

    static let testValue = CreateNewTaskUseCase(
        execute: { input in
            let now = Date()
            return Task(
                id: TaskID(UUID()),
                title: input.title,
                startDate: now,
                endDate: now,
                stages: [],
                records: []
            )
        }
    )
}

private enum UpdateTaskSettingsUseCaseKey: DependencyKey {
    static let liveValue = UseCaseAssembly.updateTaskSettingsUseCase

    static let testValue = UpdateTaskSettingsUseCase(
        execute: { _ in }
    )
}

private enum GlobalNotificationSettingUseCaseKey: DependencyKey {
    static let liveValue = UseCaseAssembly.globalNotificationSettingUseCase

    static let testValue = GlobalNotificationSettingUseCase(
        setEnabled: { _ in .disabled }
    )
}

private enum CertifyTaskTodayUseCaseKey: DependencyKey {
    static let liveValue = UseCaseAssembly.certifyTaskTodayUseCase

    static let testValue = CertifyTaskTodayUseCase(
        execute: { _ in }
    )
}

private enum StageProgressionUseCaseKey: DependencyKey {
    static let liveValue = UseCaseAssembly.stageProgressionUseCase

    static let testValue: StageProgressionUseCase = {
        StageProgressionUseCase(taskRepository: .init(
            fetchActiveTasks: { [] },
            fetchTask: { _ in nil },
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        ))
    }()
}

private enum DeleteTaskUseCaseKey: DependencyKey {
    static let liveValue = UseCaseAssembly.deleteTaskUseCase

    static let testValue = DeleteTaskUseCase(
        execute: { _ in }
    )
}

private enum ReminderSchedulingUseCaseKey: DependencyKey {
    static let liveValue = UseCaseAssembly.reminderSchedulingUseCase

    static let testValue = ReminderSchedulingUseCase(
        notificationScheduler: .init(
            scheduleReminder: { _ in },
            cancelReminder: { _ in },
            cancelAllReminders: { },
            requestAuthorization: { false }
        ),
        userSettingsRepository: .init(
            isNotificationEnabled: { false },
            getAllReminders: { [] },
            updateNotificationEnabled: { _ in }
        ),
        taskRepository: .init(
            fetchActiveTasks: { [] },
            fetchTask: { _ in nil },
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        )
    )
}

public extension DependencyValues {
    var createNewTaskUseCase: CreateNewTaskUseCase {
        get { self[CreateNewTaskUseCaseKey.self] }
        set { self[CreateNewTaskUseCaseKey.self] = newValue }
    }

    var updateTaskSettingsUseCase: UpdateTaskSettingsUseCase {
        get { self[UpdateTaskSettingsUseCaseKey.self] }
        set { self[UpdateTaskSettingsUseCaseKey.self] = newValue }
    }

    var globalNotificationSettingUseCase: GlobalNotificationSettingUseCase {
        get { self[GlobalNotificationSettingUseCaseKey.self] }
        set { self[GlobalNotificationSettingUseCaseKey.self] = newValue }
    }

    var certifyTaskTodayUseCase: CertifyTaskTodayUseCase {
        get { self[CertifyTaskTodayUseCaseKey.self] }
        set { self[CertifyTaskTodayUseCaseKey.self] = newValue }
    }

    var stageProgressionUseCase: StageProgressionUseCase {
        get { self[StageProgressionUseCaseKey.self] }
        set { self[StageProgressionUseCaseKey.self] = newValue }
    }

    var deleteTaskUseCase: DeleteTaskUseCase {
        get { self[DeleteTaskUseCaseKey.self] }
        set { self[DeleteTaskUseCaseKey.self] = newValue }
    }

    var reminderSchedulingUseCase: ReminderSchedulingUseCase {
        get { self[ReminderSchedulingUseCaseKey.self] }
        set { self[ReminderSchedulingUseCaseKey.self] = newValue }
    }
}
