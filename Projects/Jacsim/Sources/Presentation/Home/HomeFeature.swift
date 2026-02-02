import Foundation
import ComposableArchitecture
import Domain
import DSKit
import Core

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedDate: Date = Date()
        public var calendarScope: JSCalendarScope = .month
        public var calendar = CalendarFeature.State()
        public var tasks: [Domain.Task] = []
        public var activeTasks: [Domain.Task] = []
        public var heroTask: Domain.Task? = nil
        public var miniCardDisplayData: [MiniCardDisplayData] = []
        public var isLoading: Bool = false
        public var isRefreshing: Bool = false
        public var isFetching: Bool = false
        public var hasStartedNotificationListener = false
        public var toastMessage: String? = nil

        @Presents public var destination: Destination.State?
        @Presents public var migrationAlert: AlertState<Action.MigrationAlert>?
        public var path = StackState<Path.State>()

        public struct MiniCardDisplayData: Equatable, Identifiable {
            public let id: UUID
            public let title: String
            public let progress: Double
            public let totalDays: Int
            public let completedDays: Int
            public let imageData: Data?
            public let isTodayCertified: Bool

            public init(
                id: UUID,
                title: String,
                progress: Double,
                totalDays: Int,
                completedDays: Int,
                imageData: Data? = nil,
                isTodayCertified: Bool = false
            ) {
                self.id = id
                self.title = title
                self.progress = progress
                self.totalDays = totalDays
                self.completedDays = completedDays
                self.imageData = imageData
                self.isTodayCertified = isTodayCertified
            }
        }

        public var heroTaskImageData: Data? = nil
        public var loadingStartTime: Date? = nil
        
        public init() {}
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case dateSelected(Date)
        case refreshTriggered
        case tasksResponse([Domain.Task])
        case heroImageLoaded(Data?)
        case miniCardImageLoaded(index: Int, imageData: Data?)
        case calendar(CalendarFeature.Action)
        case settingButtonTapped
        case addButtonTapped
        case allTasksButtonTapped
        case taskTapped(Domain.Task)
        case notificationTapped(UUID)
        case notificationTaskLoaded(Domain.Task?)
        case deepLinkReceived(URL)
        case deepLinkTaskLoaded(Domain.Task?)
        case migrationCheckResponse(Bool)
        case migrationAlert(PresentationAction<MigrationAlert>)
        case toastDismissed

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
            case challengeCreate(ChallengeCreateFeature.State)
        }
        @CasePathable
        @dynamicMemberLookup
        public enum Action {
            case challengeCreate(ChallengeCreateFeature.Action)
        }
        public var body: some ReducerOf<Self> {
            Scope(state: \.challengeCreate, action: \.challengeCreate) { ChallengeCreateFeature() }
        }
    }

    @Dependency(\.taskRepository) var taskRepository
    @Dependency(\.activeTaskService) var activeTaskService
    @Dependency(\.imageStore) var imageStore

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.calendar, action: \.calendar) {
            CalendarFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.isFetching else { return .none }
                let shouldStartListener = !state.hasStartedNotificationListener
                state.hasStartedNotificationListener = true
                state.isFetching = true
                state.isLoading = state.tasks.isEmpty
                state.loadingStartTime = Date()
                Logger.homeFetchingTasks()
                let fetchStartTime = Date()
                let fetchEffect: Effect<Action> = .run { [taskRepository] send in
                    let tasks = try await taskRepository.fetchActiveTasks()
                    Logger.homeTasksFetched(count: tasks.count, duration: Date().timeIntervalSince(fetchStartTime))
                    if let firstTask = tasks.first {
                        let completedCount = firstTask.records.filter { $0.check }.count
                        Logger.homeFirstTaskDetails(title: firstTask.title, totalRecords: firstTask.records.count, completedRecords: completedCount)
                    }
                    // Ensure minimum skeleton display duration of 1.5 seconds
                    let elapsed = Date().timeIntervalSince(fetchStartTime)
                    let minDisplay: TimeInterval = 1.5
                    let remaining = minDisplay - elapsed
                    if remaining > 0 {
                        try await _Concurrency.Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
                    }
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
                let deepLinkEffect: Effect<Action> = shouldStartListener ? .run { send in
                    for await notification in NotificationCenter.default.notifications(named: .jacsimDeepLinkReceived) {
                        if let url = notification.userInfo?["url"] as? URL {
                            await send(.deepLinkReceived(url))
                        }
                    }
                } : .none
                return .merge(fetchEffect, notificationEffect, deepLinkEffect)

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
                let processStartTime = Date()
                state.tasks = tasks
                state.activeTasks = activeTaskService.filterActiveTasks(tasks, referenceDate: Date())
                state.heroTask = state.activeTasks.first
                let remainingTasks = Array(state.activeTasks.dropFirst())
                state.miniCardDisplayData = remainingTasks.map { task in
                    let completedDays = task.records.filter { $0.check }.count
                    let totalDays = task.dayArray.count
                    let progress = totalDays > 0 ? Double(completedDays) / Double(totalDays) : 0
                    let isTodayCertified = task.isCompleted(on: Date())
                    return State.MiniCardDisplayData(
                        id: task.id.rawValue,
                        title: task.title,
                        progress: progress,
                        totalDays: totalDays,
                        completedDays: completedDays,
                        imageData: nil,
                        isTodayCertified: isTodayCertified
                    )
                }
                state.isLoading = false
                state.isRefreshing = false
                state.isFetching = false
                Logger.homeTasksProcessed(
                    duration: Date().timeIntervalSince(processStartTime),
                    activeCount: state.activeTasks.count,
                    heroTaskTitle: state.heroTask?.title
                )
                return .run { [heroTask = state.heroTask, remainingTasks] send in
                    if let heroTask = heroTask {
                        let heroImageData = await self.imageStore.loadImage(heroTask.mainImageKey)
                        await send(.heroImageLoaded(heroImageData))
                    }
                    for (index, task) in remainingTasks.enumerated() {
                        let imageData = await self.imageStore.loadImage(task.mainImageKey)
                        await send(.miniCardImageLoaded(index: index, imageData: imageData))
                    }
                }
                
            case .settingButtonTapped:
                state.path.append(.setting(SettingFeature.State()))
                return .none
                
            case .addButtonTapped:
                state.destination = .challengeCreate(ChallengeCreateFeature.State())
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

            case let .deepLinkReceived(url):
                guard url.scheme == "jacsim",
                      url.host == "challenge" else {
                    return .none
                }
                let idString = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                guard let id = UUID(uuidString: idString) else { return .none }
                return .run { [taskRepository] send in
                    let task = try await taskRepository.fetchTask(TaskID(id))
                    await send(.deepLinkTaskLoaded(task))
                }

            case let .deepLinkTaskLoaded(task):
                guard let task else { return .none }
                state.path.append(.detail(TaskDetailFeature.State(task: task)))
                return .none

            case let .heroImageLoaded(imageData):
                state.heroTaskImageData = imageData
                return .none

            case let .miniCardImageLoaded(index, imageData):
                guard state.miniCardDisplayData.indices.contains(index) else { return .none }
                let currentData = state.miniCardDisplayData[index]
                state.miniCardDisplayData[index] = State.MiniCardDisplayData(
                    id: currentData.id,
                    title: currentData.title,
                    progress: currentData.progress,
                    totalDays: currentData.totalDays,
                    completedDays: currentData.completedDays,
                    imageData: imageData,
                    isTodayCertified: currentData.isTodayCertified
                )
                return .none

            case .migrationCheckResponse:
                return .none

            case .migrationAlert:
                return .none
                
            case let .path(.element(id: _, action: .detail(.delegate(.navigateToUpdate(task, index))))):
                state.path.append(.update(TaskUpdateFeature.State(task: task, index: index)))
                return .none

            case .path(.element(id: _, action: .detail(.delegate(.navigateBack)))):
                state.path.removeLast()
                return .none

            case .path(.element(id: _, action: .detail(.delegate(.taskDeleted)))):
                state.path.removeLast()
                return .send(.onAppear)

            case let .path(.element(id: _, action: .detail(.delegate(.navigateToMemoEdit(task))))):
                let today = Calendar.current.startOfDay(for: Date())
                if let index = task.dayArray.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                    state.path.append(.update(TaskUpdateFeature.State(task: task, index: index)))
                }
                return .none

            case .path(.element(id: _, action: .update(.delegate(.saveSuccess)))):
                state.path.removeLast()
                return .run { send in
                    await send(.onAppear)
                }

            case .destination(.dismiss):
                return .send(.onAppear)

            case .destination(.presented(.challengeCreate(.delegate(.challengeCreated)))):
                state.destination = nil
                state.toastMessage = "새 작심을 시작했어요"
                return .send(.onAppear)

            case .destination(.presented(.challengeCreate(.delegate(.cancelled)))):
                state.destination = nil
                return .none

            case .toastDismissed:
                state.toastMessage = nil
                return .none

            case .binding, .calendar, .delegate, .migrationAlert, .path:
                return .none

            case .destination:
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
