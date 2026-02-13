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
        public var loadFailed: Bool = false
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
        case tasksLoadFailed
        case heroImageLoaded(Data?)
        case miniCardImageLoaded(id: UUID, imageData: Data?)
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
            case walkThrough(WalkThroughFeature.State)
            case openSourceLicense(OpenSourceLicenseFeature.State)
        }
        @CasePathable
        @dynamicMemberLookup
        public enum Action {
            case detail(TaskDetailFeature.Action)
            case update(TaskUpdateFeature.Action)
            case allTasks(AllTaskFeature.Action)
            case setting(SettingFeature.Action)
            case walkThrough(WalkThroughFeature.Action)
            case openSourceLicense(OpenSourceLicenseFeature.Action)
        }
        public var body: some ReducerOf<Self> {
            Scope(state: \.detail, action: \.detail) { TaskDetailFeature() }
            Scope(state: \.update, action: \.update) { TaskUpdateFeature() }
            Scope(state: \.allTasks, action: \.allTasks) { AllTaskFeature() }
            Scope(state: \.setting, action: \.setting) { SettingFeature() }
            Scope(state: \.walkThrough, action: \.walkThrough) { WalkThroughFeature() }
            Scope(state: \.openSourceLicense, action: \.openSourceLicense) { OpenSourceLicenseFeature() }
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

    @Dependency(\.taskQueryClient) var taskQueryClient
    @Dependency(\.activeTaskService) var activeTaskService
    @Dependency(\.imageStore) var imageStore
    @Dependency(\.externalNavigationClient) var externalNavigationClient

    private enum LoadingPolicy {
        // Splash minimum duration overlaps with Home loading.
        // Keep startup skeleton long enough so users still perceive the animation.
        static let minimumInitialSkeletonDuration: TimeInterval =
            StartupDisplayPolicy.initialHomeSkeletonMinimumDuration
    }

    private enum CancelID {
        case imageLoading
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.calendar, action: \.calendar) {
            CalendarFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.isFetching else { return .none }
                let shouldShowInitialSkeleton = state.tasks.isEmpty
                let minimumLoadingDuration = shouldShowInitialSkeleton
                    ? LoadingPolicy.minimumInitialSkeletonDuration
                    : 0
                let shouldStartListener = !state.hasStartedNotificationListener
                state.hasStartedNotificationListener = true
                state.isFetching = true
                state.isLoading = shouldShowInitialSkeleton
                state.loadFailed = false
                state.loadingStartTime = Date()
                Logger.homeFetchingTasks()
                let fetchStartTime = Date()
                let fetchEffect: Effect<Action> = .run { [taskQueryClient] send in
                    do {
                        let tasks = try await taskQueryClient.fetchActiveTasks()
                        Logger.homeTasksFetched(
                            count: tasks.count,
                            duration: Date().timeIntervalSince(fetchStartTime)
                        )
                        if let firstTask = tasks.first {
                            let completedCount = firstTask.records.filter { $0.check }.count
                            Logger.homeFirstTaskDetails(
                                title: firstTask.title,
                                totalRecords: firstTask.records.count,
                                completedRecords: completedCount
                            )
                        }
                        if minimumLoadingDuration > 0 {
                            // Ensure minimum startup skeleton duration for stable loading perception.
                            let elapsed = Date().timeIntervalSince(fetchStartTime)
                            let remaining = minimumLoadingDuration - elapsed
                            if remaining > 0 {
                                try await _Concurrency.Task.sleep(
                                    nanoseconds: UInt64(remaining * 1_000_000_000)
                                )
                            }
                        }
                        await send(.tasksResponse(tasks))
                    } catch is CancellationError {
                        return
                    } catch {
                        await send(.tasksLoadFailed)
                    }
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
                return .merge(
                    .cancel(id: CancelID.imageLoading),
                    fetchEffect,
                    notificationEffect,
                    deepLinkEffect
                )

            case let .dateSelected(date):
                state.selectedDate = date
                return .none

            case .refreshTriggered:
                state.isRefreshing = true
                state.loadFailed = false
                return .merge(
                    .cancel(id: CancelID.imageLoading),
                    .run { [taskQueryClient] send in
                        do {
                            let tasks = try await taskQueryClient.fetchActiveTasks()
                            await send(.tasksResponse(tasks))
                        } catch is CancellationError {
                            return
                        } catch {
                            await send(.tasksLoadFailed)
                        }
                    }
                )
                
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
                state.loadFailed = false
                Logger.homeTasksProcessed(
                    duration: Date().timeIntervalSince(processStartTime),
                    activeCount: state.activeTasks.count,
                    heroTaskTitle: state.heroTask?.title
                )
                let imageStore = imageStore
                return .run { [heroTask = state.heroTask, remainingTasks, imageStore] send in
                    if let heroTask = heroTask {
                        let heroImageData = await imageStore.loadImage(heroTask.mainImageKey)
                        await send(.heroImageLoaded(heroImageData))
                    }
                    for task in remainingTasks {
                        let imageData = await imageStore.loadImage(task.mainImageKey)
                        await send(.miniCardImageLoaded(id: task.id.rawValue, imageData: imageData))
                    }
                }
                .cancellable(id: CancelID.imageLoading, cancelInFlight: true)

            case .tasksLoadFailed:
                state.isLoading = false
                state.isRefreshing = false
                state.isFetching = false
                state.loadFailed = true
                return .none
                
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
                return .run { [taskQueryClient] send in
                    do {
                        let task = try await taskQueryClient.fetchTask(TaskID(id))
                        await send(.notificationTaskLoaded(task))
                    } catch {
                        await send(.notificationTaskLoaded(nil))
                    }
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
                return .run { [taskQueryClient] send in
                    do {
                        let task = try await taskQueryClient.fetchTask(TaskID(id))
                        await send(.deepLinkTaskLoaded(task))
                    } catch {
                        await send(.deepLinkTaskLoaded(nil))
                    }
                }

            case let .deepLinkTaskLoaded(task):
                guard let task else { return .none }
                state.path.append(.detail(TaskDetailFeature.State(task: task)))
                return .none

            case let .heroImageLoaded(imageData):
                state.heroTaskImageData = imageData
                return .none

            case let .miniCardImageLoaded(id, imageData):
                guard let targetIndex = state.miniCardDisplayData.firstIndex(where: { $0.id == id }) else {
                    return .none
                }
                let currentData = state.miniCardDisplayData[targetIndex]
                state.miniCardDisplayData[targetIndex] = State.MiniCardDisplayData(
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

            case let .path(.element(id: _, action: .allTasks(.delegate(.navigateToDetail(task))))):
                state.path.append(.detail(TaskDetailFeature.State(task: task)))
                return .none

            case .path(.element(id: _, action: .setting(.delegate(.navigateToWalkThrough)))):
                state.path.append(.walkThrough(WalkThroughFeature.State(fromSetting: true)))
                return .none

            case .path(.element(id: _, action: .setting(.delegate(.navigateToLicence)))):
                state.path.append(.openSourceLicense(OpenSourceLicenseFeature.State()))
                return .none

            case .path(.element(id: _, action: .setting(.delegate(.presentMailCompose)))):
                state.toastMessage = "문의하기를 시도했어요. 메일 앱이 열리지 않으면 메일 설정을 확인해 주세요"
                return .run { [externalNavigationClient] _ in
                    _ = await externalNavigationClient.openInquiryMail()
                }

            case .path(.element(id: _, action: .setting(.delegate(.openReviewURL)))):
                state.toastMessage = "리뷰 요청을 시도했어요. 의견을 남겨주시면 큰 힘이 돼요"
                return .run { [externalNavigationClient] _ in
                    _ = await externalNavigationClient.requestReview()
                }

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

            case .path:
                return .none

            case .binding, .calendar, .delegate:
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
