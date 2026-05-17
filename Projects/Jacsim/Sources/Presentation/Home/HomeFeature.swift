import Core
import Domain
import DSKit
import Foundation
import Observation

@MainActor
@Observable
public final class HomeModel {
    public enum Route: Hashable {
        case detail(Domain.Task, scrollToRecords: Bool)
        case update(Domain.Task, index: Int)
        case allTasks
        case setting
        case newTask
    }

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

    public var selectedDate: Date = Date()
    public var calendarScope: JSCalendarScope = .month
    public var tasks: [Domain.Task] = []
    public var activeTasks: [Domain.Task] = []
    public var heroTask: Domain.Task?
    public var miniCardDisplayData: [MiniCardDisplayData] = []
    public var isLoading: Bool = false
    public var isRefreshing: Bool = false
    public var isFetching: Bool = false
    public var loadFailed: Bool = false
    public var hasStartedNotificationListener = false
    public var toastMessage: String?
    public var heroTaskImageData: Data?
    public var wallpaperRaw: String = "morning"
    public var loadingStartTime: Date?
    public var path: [Route] = []
    public var newTask: NewTaskModel?

    @ObservationIgnored public let dependencies: JacsimDependencies
    @ObservationIgnored private var fetchTask: _Concurrency.Task<Void, Never>?
    @ObservationIgnored private var imageLoadingTask: _Concurrency.Task<Void, Never>?
    @ObservationIgnored private var settingsTask: _Concurrency.Task<Void, Never>?
    @ObservationIgnored private var notificationListenerTask: _Concurrency.Task<Void, Never>?
    @ObservationIgnored private var deepLinkListenerTask: _Concurrency.Task<Void, Never>?

    private enum LoadingPolicy {
        static let minimumSkeletonDuration: TimeInterval = 1.25
    }

    public init(dependencies: JacsimDependencies) {
        self.dependencies = dependencies
    }

    deinit {
        fetchTask?.cancel()
        imageLoadingTask?.cancel()
        settingsTask?.cancel()
        notificationListenerTask?.cancel()
        deepLinkListenerTask?.cancel()
    }

    public func onAppear() {
        guard !isFetching else { return }
        startListenersIfNeeded()
        isFetching = true
        isLoading = tasks.isEmpty
        loadFailed = false
        loadingStartTime = Date()
        Logger.homeFetchingTasks()
        let fetchStartTime = Date()
        fetchTask?.cancel()
        settingsTask?.cancel()
        settingsTask = _Concurrency.Task { [dependencies] in
            wallpaperLoaded(await dependencies.userSettingsRepository.wallpaperRaw())
        }
        fetchTask = _Concurrency.Task { [dependencies] in
            do {
                let tasks = try await dependencies.taskQueryClient.fetchActiveTasks()
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
                let elapsed = Date().timeIntervalSince(fetchStartTime)
                let remaining = LoadingPolicy.minimumSkeletonDuration - elapsed
                if remaining > 0 {
                    try await _Concurrency.Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
                }
                tasksResponse(tasks)
            } catch is CancellationError {
                return
            } catch {
                tasksLoadFailed()
            }
        }
    }

    public func dateSelected(_ date: Date) {
        selectedDate = date
    }

    public func refreshTriggered() {
        isRefreshing = true
        loadFailed = false
        imageLoadingTask?.cancel()
        fetchTask?.cancel()
        fetchTask = _Concurrency.Task { [dependencies] in
            do {
                let tasks = try await dependencies.taskQueryClient.fetchActiveTasks()
                tasksResponse(tasks)
            } catch is CancellationError {
                return
            } catch {
                tasksLoadFailed()
            }
        }
    }

    public func settingButtonTapped() {
        path.append(.setting)
    }

    public func allTasksButtonTapped() {
        path.append(.allTasks)
    }

    public func focusPrimaryButtonTapped(_ task: Domain.Task) {
        if shouldOpenCheckIn(for: task),
           let index = todayIndex(in: task) {
            path.append(.update(task, index: index))
            return
        }

        let shouldScrollToRecords = task.isCompleted(on: Date())
        path.append(.detail(task, scrollToRecords: shouldScrollToRecords))
    }

    public func focusSecondaryButtonTapped(_ task: Domain.Task) {
        path.append(.detail(task, scrollToRecords: false))
    }

    public func taskTapped(_ task: Domain.Task) {
        path.append(.detail(task, scrollToRecords: false))
    }

    public func notificationTapped(_ id: UUID) {
        _Concurrency.Task { [dependencies] in
            do {
                let task = try await dependencies.taskQueryClient.fetchTask(TaskID(id))
                notificationTaskLoaded(task)
            } catch {
                notificationTaskLoaded(nil)
            }
        }
    }

    public func deepLinkReceived(_ url: URL) {
        guard url.scheme == "jacsim" else {
            return
        }
        guard url.host == "challenge" || url.host == "task" else { return }
        let idString = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let id = UUID(uuidString: idString) else { return }
        _Concurrency.Task { [dependencies] in
            do {
                let task = try await dependencies.taskQueryClient.fetchTask(TaskID(id))
                deepLinkTaskLoaded(task)
            } catch {
                deepLinkTaskLoaded(nil)
            }
        }
    }

    public func heroImageLoaded(_ imageData: Data?) {
        heroTaskImageData = imageData
    }

    public func miniCardImageLoaded(id: UUID, imageData: Data?) {
        guard let targetIndex = miniCardDisplayData.firstIndex(where: { $0.id == id }) else {
            return
        }
        let currentData = miniCardDisplayData[targetIndex]
        miniCardDisplayData[targetIndex] = MiniCardDisplayData(
            id: currentData.id,
            title: currentData.title,
            progress: currentData.progress,
            totalDays: currentData.totalDays,
            completedDays: currentData.completedDays,
            imageData: imageData,
            isTodayCertified: currentData.isTodayCertified
        )
    }

    public func navigateToUpdate(_ task: Domain.Task, index: Int) {
        path.append(.update(task, index: index))
    }

    public func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    public func taskDeleted() {
        if !path.isEmpty {
            path.removeLast()
        }
        onAppear()
    }

    public func updateSaved() {
        if !path.isEmpty {
            path.removeLast()
        }
        onAppear()
    }

    public func toastDismissed() {
        toastMessage = nil
    }

    public func wallpaperLoaded(_ rawValue: String) {
        wallpaperRaw = rawValue
    }

    private func startListenersIfNeeded() {
        guard !hasStartedNotificationListener else { return }
        hasStartedNotificationListener = true
        notificationListenerTask = _Concurrency.Task {
            for await notification in NotificationCenter.default.notifications(named: .jacsimLocalNotificationTapped) {
                if let idString = notification.userInfo?["id"] as? String,
                   let id = UUID(uuidString: idString) {
                    notificationTapped(id)
                }
            }
        }
        deepLinkListenerTask = _Concurrency.Task {
            for await notification in NotificationCenter.default.notifications(named: .jacsimDeepLinkReceived) {
                if let url = notification.userInfo?["url"] as? URL {
                    deepLinkReceived(url)
                }
            }
        }
    }

    private func tasksResponse(_ tasks: [Domain.Task]) {
        let processStartTime = Date()
        self.tasks = tasks
        activeTasks = dependencies.activeTaskService.filterActiveTasks(tasks, referenceDate: Date())
        heroTask = activeTasks.first
        let remainingTasks = Array(activeTasks.dropFirst())
        miniCardDisplayData = remainingTasks.map { task in
            let completedDays = task.records.filter { $0.check }.count
            let totalDays = task.dayArray.count
            let progress = totalDays > 0 ? Double(completedDays) / Double(totalDays) : 0
            let isTodayCertified = task.isCompleted(on: Date())
            return MiniCardDisplayData(
                id: task.id.rawValue,
                title: task.title,
                progress: progress,
                totalDays: totalDays,
                completedDays: completedDays,
                imageData: nil,
                isTodayCertified: isTodayCertified
            )
        }
        isLoading = false
        isRefreshing = false
        isFetching = false
        loadFailed = false
        Logger.homeTasksProcessed(
            duration: Date().timeIntervalSince(processStartTime),
            activeCount: activeTasks.count,
            heroTaskTitle: heroTask?.title
        )
        imageLoadingTask?.cancel()
        imageLoadingTask = _Concurrency.Task { [heroTask, remainingTasks, dependencies] in
            if let heroTask {
                let heroImageData = await dependencies.imageStore.loadImage(heroTask.mainImageKey)
                heroImageLoaded(heroImageData)
            }
            for task in remainingTasks {
                let imageData = await dependencies.imageStore.loadImage(task.mainImageKey)
                miniCardImageLoaded(id: task.id.rawValue, imageData: imageData)
            }
        }
    }

    private func tasksLoadFailed() {
        isLoading = false
        isRefreshing = false
        isFetching = false
        loadFailed = true
    }

    private func notificationTaskLoaded(_ task: Domain.Task?) {
        guard let task else { return }
        if let index = task.dayArray.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: Date()) }) {
            let isCertifiable = task.records.indices.contains(index) ? !task.records[index].check : true
            if isCertifiable {
                path.append(.update(task, index: index))
                return
            }
        }
        path.append(.detail(task, scrollToRecords: false))
    }

    private func deepLinkTaskLoaded(_ task: Domain.Task?) {
        guard let task else { return }
        path.append(.detail(task, scrollToRecords: false))
    }

    private func shouldOpenCheckIn(for task: Domain.Task) -> Bool {
        guard (task.stages.last?.result ?? .inProgress) == .inProgress else { return false }
        return todayIndex(in: task) != nil && !task.isCompleted(on: Date())
    }

    private func todayIndex(in task: Domain.Task) -> Int? {
        task.dayArray.firstIndex { Calendar.current.isDate($0, inSameDayAs: Date()) }
    }
}
