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
public typealias LoadImageUseCase = Workflows.LoadImageUseCase
public typealias ReminderSchedulingUseCase = Workflows.ReminderSchedulingUseCase
public typealias RequestNotificationPermissionUseCase = Workflows.RequestNotificationPermissionUseCase
public typealias HomeSummaryUseCase = Workflows.HomeSummaryUseCase
public typealias AllTaskSummaryUseCase = Workflows.AllTaskSummaryUseCase
public typealias CalendarSummaryUseCase = Workflows.CalendarSummaryUseCase
public typealias TaskDetailSummaryUseCase = Workflows.TaskDetailSummaryUseCase

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

private enum LoadImageUseCaseKey: DependencyKey {
    static let liveValue = UseCaseAssembly.loadImageUseCase

    static let testValue = LoadImageUseCase(
        loadImage: { _ in nil }
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

private enum RequestNotificationPermissionUseCaseKey: DependencyKey {
    static let liveValue = UseCaseAssembly.requestNotificationPermissionUseCase

    static let testValue = RequestNotificationPermissionUseCase(
        requestAuthorization: { false }
    )
}

private enum HomeSummaryUseCaseKey: DependencyKey {
    static let liveValue = UseCaseAssembly.homeSummaryUseCase
    static let testValue = HomeSummaryUseCase.live()
}

private enum AllTaskSummaryUseCaseKey: DependencyKey {
    static let liveValue = UseCaseAssembly.allTaskSummaryUseCase
    static let testValue = AllTaskSummaryUseCase.live()
}

private enum CalendarSummaryUseCaseKey: DependencyKey {
    static let liveValue = UseCaseAssembly.calendarSummaryUseCase
    static let testValue = CalendarSummaryUseCase.live()
}

private enum TaskDetailSummaryUseCaseKey: DependencyKey {
    static let liveValue = UseCaseAssembly.taskDetailSummaryUseCase
    static let testValue = TaskDetailSummaryUseCase.live()
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

    var loadImageUseCase: LoadImageUseCase {
        get { self[LoadImageUseCaseKey.self] }
        set { self[LoadImageUseCaseKey.self] = newValue }
    }

    var reminderSchedulingUseCase: ReminderSchedulingUseCase {
        get { self[ReminderSchedulingUseCaseKey.self] }
        set { self[ReminderSchedulingUseCaseKey.self] = newValue }
    }

    var requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase {
        get { self[RequestNotificationPermissionUseCaseKey.self] }
        set { self[RequestNotificationPermissionUseCaseKey.self] = newValue }
    }

    var homeSummaryUseCase: HomeSummaryUseCase {
        get { self[HomeSummaryUseCaseKey.self] }
        set { self[HomeSummaryUseCaseKey.self] = newValue }
    }

    var allTaskSummaryUseCase: AllTaskSummaryUseCase {
        get { self[AllTaskSummaryUseCaseKey.self] }
        set { self[AllTaskSummaryUseCaseKey.self] = newValue }
    }

    var calendarSummaryUseCase: CalendarSummaryUseCase {
        get { self[CalendarSummaryUseCaseKey.self] }
        set { self[CalendarSummaryUseCaseKey.self] = newValue }
    }

    var taskDetailSummaryUseCase: TaskDetailSummaryUseCase {
        get { self[TaskDetailSummaryUseCaseKey.self] }
        set { self[TaskDetailSummaryUseCaseKey.self] = newValue }
    }
}
