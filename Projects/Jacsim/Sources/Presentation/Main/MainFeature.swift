import Domain
import DSKit
import Foundation
import Observation

@MainActor
@Observable
public final class MainModel {
    public var selectedTab: JSTabItem = .today
    public var isPlusSheetPresented: Bool = false
    public var isCoachPresented: Bool = false
    public var presentedGraduation: GraduationContext?
    public var plusToastText: String?
    public let home: HomeModel
    public let calendar: CalendarModel
    public let feed: FeedModel
    public let me: MeModel
    public let coach: CoachModel

    @ObservationIgnored private let dependencies: JacsimDependencies
#if DEBUG
    @ObservationIgnored private var didPresentDebugGraduation = false
#endif

    public init(dependencies: JacsimDependencies) {
        self.dependencies = dependencies
        self.home = HomeModel(dependencies: dependencies)
        self.calendar = CalendarModel(dependencies: dependencies)
        self.feed = FeedModel(dependencies: dependencies)
        self.me = MeModel(dependencies: dependencies)
        self.coach = CoachModel(dependencies: dependencies)
        self.feed.onFollowChallengePrefill = { [weak self] draft in
            self?.createTaskFromFollowChallenge(draft: draft)
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

    public func coachActionTapped() {
        isPlusSheetPresented = false
        plusToastText = nil
        isCoachPresented = true
    }

    public func graduationPresented(_ context: GraduationContext) {
        presentedGraduation = context
    }

#if DEBUG
    public func presentDebugGraduationIfRequested() {
        guard !didPresentDebugGraduation else { return }
        guard ProcessInfo.processInfo.arguments.contains("-JACSIM_SHOW_GRADUATION_DEMO") else { return }
        didPresentDebugGraduation = true
        graduationPresented(
            GraduationContext(
                taskId: TaskID(UUID()),
                taskTitle: "테스트 작심",
                stageTypeRaw: 7,
                durationDays: 7,
                successDays: 7
            )
        )
    }
#endif

    public func graduationNextStageTapped() {
        guard let context = presentedGraduation else { return }
        let taskId = context.taskId
        presentedGraduation = nil
        let dependencies = dependencies
        _Concurrency.Task { [weak self] in
            await dependencies.stageFlowClient.createNextStage(taskId)
            await MainActor.run {
                self?.home.onAppear()
                self?.calendar.loadTasks()
            }
        }
    }

    public func graduationFinishTapped() {
        presentedGraduation = nil
        home.onAppear()
        calendar.loadTasks()
    }

    public func graduationBragTapped() {
        guard let context = presentedGraduation else { return }
        presentedGraduation = nil
        selectedTab = .feed
        feed.presentGraduationComposer(
            taskId: context.taskId,
            taskTitle: context.taskTitle
        )
    }

    private func newTaskCreated() {
        popHomeNewTaskRoute()
        home.newTask = nil
        selectedTab = .today
        home.onAppear()
        calendar.loadTasks()
    }

    private func createTaskFromFollowChallenge(draft: FollowChallengeDraft) {
        isPlusSheetPresented = false
        selectedTab = .today
        home.newTask = NewTaskModel(
            dependencies: dependencies,
            prefillTitle: draft.title,
            onTaskCreatedWithTask: { [weak self] task in
                self?.feed.followChallengeCreated(draft, copiedTask: task)
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
