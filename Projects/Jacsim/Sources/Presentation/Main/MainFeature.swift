import DSKit
import Observation

@MainActor
@Observable
public final class MainModel {
    public var selectedTab: JSTabItem = .today
    public var isPlusSheetPresented: Bool = false
    public var plusToastText: String?
    public let home: HomeModel
    public let calendar: CalendarModel
    public let feed: FeedModel
    public let me: MeModel

    @ObservationIgnored private let dependencies: JacsimDependencies

    public init(dependencies: JacsimDependencies) {
        self.dependencies = dependencies
        self.home = HomeModel(dependencies: dependencies)
        self.calendar = CalendarModel(dependencies: dependencies)
        self.feed = FeedModel(dependencies: dependencies)
        self.me = MeModel(dependencies: dependencies)
        self.feed.onFollowChallengePrefill = { [weak self] title in
            self?.createTaskFromFollowChallenge(title: title)
        }
    }

    public var isRootTabBarVisible: Bool {
        home.path.isEmpty
    }

    public func tabSelected(_ tab: JSTabItem) {
        guard tab != .plus else {
            plusButtonTapped()
            return
        }
        selectedTab = tab
    }

    public func plusButtonTapped() {
        plusToastText = nil
        isPlusSheetPresented = true
    }

    public func comingSoonActionTapped() {
        plusToastText = "곧 출시"
    }

    public func plusToastDismissed() {
        plusToastText = nil
    }

    public func createTaskActionTapped() {
        isPlusSheetPresented = false
        plusToastText = nil
        selectedTab = .today
        home.newTask = NewTaskModel(
            dependencies: dependencies,
            onTaskCreated: { [weak self] in
                self?.newTaskCreated()
            },
            onCancelled: { [weak self] in
                self?.newTaskCancelled()
            }
        )
        home.path.append(.newTask)
    }

    public func createBragActionTapped() {
        isPlusSheetPresented = false
        plusToastText = nil
        selectedTab = .feed
        feed.composerButtonTapped()
    }

    private func newTaskCreated() {
        popHomeNewTaskRoute()
        home.newTask = nil
        selectedTab = .today
        home.onAppear()
        calendar.loadTasks()
    }

    private func createTaskFromFollowChallenge(title: String) {
        isPlusSheetPresented = false
        selectedTab = .today
        home.newTask = NewTaskModel(
            dependencies: dependencies,
            prefillTitle: title,
            onTaskCreated: { [weak self] in
                self?.newTaskCreated()
            },
            onCancelled: { [weak self] in
                self?.newTaskCancelled()
            }
        )
        home.path.append(.newTask)
    }

    private func newTaskCancelled() {
        popHomeNewTaskRoute()
        home.newTask = nil
    }

    private func popHomeNewTaskRoute() {
        if home.path.last == .newTask {
            home.path.removeLast()
        } else {
            home.path.removeAll { $0 == .newTask }
        }
    }
}
