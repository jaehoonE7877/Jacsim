import DSKit
import Observation

@MainActor
@Observable
public final class MainModel {
    public enum Route: Hashable {
        case newTask
    }

    public var selectedTab: JSTabItem = .today
    public var isPlusSheetPresented: Bool = false
    public var path: [Route] = []
    public var newTask: NewTaskModel?
    public let home: HomeModel
    public let calendar: CalendarModel
    public let feed: FeedPlaceholderModel
    public let me: MePlaceholderModel

    @ObservationIgnored private let dependencies: JacsimDependencies

    public init(dependencies: JacsimDependencies) {
        self.dependencies = dependencies
        self.home = HomeModel(dependencies: dependencies)
        self.calendar = CalendarModel(dependencies: dependencies)
        self.feed = FeedPlaceholderModel()
        self.me = MePlaceholderModel()
    }

    public func tabSelected(_ tab: JSTabItem) {
        guard tab != .plus else {
            plusButtonTapped()
            return
        }
        selectedTab = tab
    }

    public func plusButtonTapped() {
        isPlusSheetPresented = true
    }

    public func createTaskActionTapped() {
        isPlusSheetPresented = false
        newTask = NewTaskModel(
            dependencies: dependencies,
            onTaskCreated: { [weak self] in
                self?.newTaskCreated()
            },
            onCancelled: { [weak self] in
                self?.newTaskCancelled()
            }
        )
        path.append(.newTask)
    }

    private func newTaskCreated() {
        popNewTaskRoute()
        newTask = nil
        selectedTab = .today
        home.onAppear()
        calendar.loadTasks()
    }

    private func newTaskCancelled() {
        popNewTaskRoute()
        newTask = nil
    }

    private func popNewTaskRoute() {
        if path.last == .newTask {
            path.removeLast()
        } else {
            path.removeAll { $0 == .newTask }
        }
    }
}

@MainActor
@Observable
public final class FeedPlaceholderModel {
    public init() {}
}

@MainActor
@Observable
public final class MePlaceholderModel {
    public init() {}
}
