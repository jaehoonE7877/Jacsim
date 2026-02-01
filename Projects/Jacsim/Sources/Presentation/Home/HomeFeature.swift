import Foundation
import ComposableArchitecture
import Domain
import DSKit

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedDate: Date = Date()
        public var calendarScope: JSCalendarScope = .month
        public var tasks: [Domain.Task] = []
        public var isLoading: Bool = false
        public var isRefreshing: Bool = false
        public var hasStartedNotificationListener = false

        @Presents public var destination: Destination.State?
        @Presents public var migrationAlert: AlertState<Action.MigrationAlert>?
        public var path = StackState<Path.State>()
        
        public init() {}
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case dateSelected(Date)
        case refreshTriggered
        case tasksResponse([Domain.Task])
        case settingButtonTapped
        case addButtonTapped
        case allTasksButtonTapped
        case taskTapped(Domain.Task)
        case notificationTapped(UUID)
        case notificationTaskLoaded(Domain.Task?)
        case migrationCheckResponse(Bool)
        case migrationAlert(PresentationAction<MigrationAlert>)

        case destination(PresentationAction<Destination.Action>)
        case path(StackAction<Path.State, Path.Action>)
        
        case delegate(Delegate)
        public enum Delegate {
            case complete
        }

        public enum MigrationAlert: Equatable {
            case confirm
            case cancel
        }
    }

    public struct Path: Reducer {
        @ObservableState
        @CasePathable
        @dynamicMemberLookup
        public enum State: Equatable {
            case detail(TaskDetailFeature.State)
            case update(TaskUpdateFeature.State)
            case allTasks(AllTaskFeature.State)
            case setting(SettingFeature.State)
        }
        @CasePathable
        @dynamicMemberLookup
        public enum Action {
            case detail(TaskDetailFeature.Action)
            case update(TaskUpdateFeature.Action)
            case allTasks(AllTaskFeature.Action)
            case setting(SettingFeature.Action)
        }
        public var body: some ReducerOf<Self> {
            Scope(state: \.detail, action: \.detail) { TaskDetailFeature() }
            Scope(state: \.update, action: \.update) { TaskUpdateFeature() }
            Scope(state: \.allTasks, action: \.allTasks) { AllTaskFeature() }
            Scope(state: \.setting, action: \.setting) { SettingFeature() }
        }
    }

    public struct Destination: Reducer {
        @ObservableState
        @CasePathable
        @dynamicMemberLookup
        public enum State: Equatable {
            case newTask(NewTaskFeature.State)
        }
        @CasePathable
        @dynamicMemberLookup
        public enum Action {
            case newTask(NewTaskFeature.Action)
        }
        public var body: some ReducerOf<Self> {
            Scope(state: \.newTask, action: \.newTask) { NewTaskFeature() }
        }
    }

    @Dependency(\.taskRepository) var taskRepository

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                let shouldStartListener = !state.hasStartedNotificationListener
                state.hasStartedNotificationListener = true
                state.isLoading = state.tasks.isEmpty
                let fetchEffect: Effect<Action> = .run { [taskRepository] send in
                    let tasks = try await taskRepository.fetchActiveTasks()
                    await send(.tasksResponse(tasks))
                }
                let notificationEffect: Effect<Action> = shouldStartListener ? .run { send in
                    for await notification in NotificationCenter.default.notifications(named: .jacsimLocalNotificationTapped) {
                        if let idString = notification.userInfo?["id"] as? String,
                           let id = UUID(uuidString: idString) {
                            await send(.notificationTapped(id))
                        }
                    }
                } : .none
                return .merge(fetchEffect, notificationEffect)

            case let .dateSelected(date):
                state.selectedDate = date
                return .none

            case .refreshTriggered:
                state.isRefreshing = true
                return .run { [taskRepository] send in
                    let tasks = try await taskRepository.fetchActiveTasks()
                    await send(.tasksResponse(tasks))
                }
                
            case let .tasksResponse(tasks):
                state.tasks = tasks
                state.isLoading = false
                state.isRefreshing = false
                return .none
                
            case .settingButtonTapped:
                state.path.append(.setting(SettingFeature.State()))
                return .none
                
            case .addButtonTapped:
                state.destination = .newTask(NewTaskFeature.State())
                return .none
                
            case .allTasksButtonTapped:
                state.path.append(.allTasks(AllTaskFeature.State()))
                return .none
                
            case let .taskTapped(task):
                state.path.append(.detail(TaskDetailFeature.State(task: task)))
                return .none

            case let .notificationTapped(id):
                return .run { [taskRepository] send in
                    let task = try await taskRepository.fetchTask(TaskID(id))
                    await send(.notificationTaskLoaded(task))
                }

            case let .notificationTaskLoaded(task):
                guard let task else { return .none }
                if let index = task.dayArray.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: Date()) }) {
                    let isCertifiable = task.records.indices.contains(index) ? !task.records[index].check : true
                    if isCertifiable {
                        state.path.append(.update(TaskUpdateFeature.State(task: task, index: index)))
                        return .none
                    }
                }
                state.path.append(.detail(TaskDetailFeature.State(task: task)))
                return .none

            case .migrationCheckResponse:
                return .none

            case .migrationAlert:
                return .none
                
            case let .path(.element(id: _, action: .detail(.delegate(.navigateToUpdate(task, index))))):
                state.path.append(.update(TaskUpdateFeature.State(task: task, index: index)))
                return .none
                
            case .destination(.dismiss):
                return .send(.onAppear)
                
            case .path, .destination, .binding, .delegate, .migrationAlert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
        .ifLet(\.$migrationAlert, action: \.migrationAlert)
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
}
