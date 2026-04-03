import SwiftUI
import UIKit
import ComposableArchitecture
import Domain
import DesignSystem
import JacsimClient

enum OnboardingCaptureScreen: String, CaseIterable {
    case home
    case newTask
    case calendar
    case allTask

    static var current: Self? {
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-onboarding-capture"),
              arguments.indices.contains(index + 1) else {
            return nil
        }
        return Self(rawValue: arguments[index + 1])
#else
        return nil
#endif
    }
}

struct OnboardingCaptureRootView: View {
    let screen: OnboardingCaptureScreen

    var body: some View {
        Group {
            switch screen {
            case .home:
                HomeView(store: staticStore(initialState: OnboardingCaptureFixture.homeState()))
            case .newTask:
                NavigationStack {
                    NewTaskView(store: staticStore(initialState: OnboardingCaptureFixture.newTaskState()))
                }
            case .calendar:
                NavigationStack {
                    CalendarView(store: staticStore(initialState: OnboardingCaptureFixture.calendarState()))
                }
            case .allTask:
                NavigationStack {
                    AllTaskView(store: staticStore(initialState: OnboardingCaptureFixture.allTaskState()))
                }
            }
        }
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .preferredColorScheme(.light)
    }

    private func staticStore<State, Action>(initialState: State) -> Store<State, Action> {
        Store(initialState: initialState) {
            StaticCaptureReducer<State, Action>()
        }
    }
}

private struct StaticCaptureReducer<State, Action>: Reducer {
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        .none
    }
}

private enum OnboardingCaptureFixture {
    private static let calendar = Calendar(identifier: .gregorian)
    private static let today = calendar.startOfDay(for: Date())
    private static let readModelQueries = TaskReadModelQueries.live()

    static func homeState() -> HomeFeature.State {
        let heroTask = makeTask(
            title: "매일 10분 독서",
            startOffset: -2,
            duration: 7,
            completedOffsets: [-2, -1],
            stageType: .seven,
            notificationEnabled: true
        )
        let waterTask = makeTask(
            title: "물 2L 마시기",
            startOffset: -1,
            duration: 7,
            completedOffsets: [-1, 0],
            stageType: .seven
        )
        let englishTask = makeTask(
            title: "하루 영어 15분",
            startOffset: 0,
            duration: 15,
            completedOffsets: [],
            stageType: .fifteen
        )

        let tasks = [heroTask, waterTask, englishTask]
        let summary = readModelQueries.home(
            tasks: tasks,
            referenceDate: today
        )

        var state = HomeFeature.State()
        state.tasks = tasks
        state.activeTasks = summary.visibleTasks
        state.heroTask = summary.focusTask
        state.secondaryTasks = summary.secondaryTasks
        state.todayFocusState = switch summary.state {
        case .empty: .empty
        case .pending: .pending
        case .completedStageReady: .completedStageReady
        case .allDoneToday: .allDoneToday
        }
        state.todayPendingCount = summary.pendingCount
        state.todayCompletedCount = summary.completedTodayCount
        state.heroTaskImageData = OnboardingCaptureFixtureImage.readingWide.jpegData
        state.miniCardDisplayData = summary.secondaryTasks.map { task in
            let imageData: Data? = switch task.id {
            case waterTask.id: OnboardingCaptureFixtureImage.waterPortrait.jpegData
            case englishTask.id: OnboardingCaptureFixtureImage.studyPortrait.jpegData
            default: nil
            }

            return .init(
                id: task.id.rawValue,
                title: task.title,
                progress: task.progress,
                totalDays: task.dayArray.count,
                completedDays: task.completedDays,
                imageData: imageData,
                isTodayCertified: task.isCompleted(on: today)
            )
        }
        return state
    }

    static func newTaskState() -> NewTaskFeature.State {
        var state = NewTaskFeature.State()
        state.title = "매일 10분 독서"
        state.lastAcceptedTitle = state.title
        state.stageType = .seven
        state.image = OnboardingCaptureFixtureImage.readingWide.image
        state.currentStep = .photo
        return state
    }

    static func calendarState() -> CalendarFeature.State {
        let readingTask = makeTask(
            title: "매일 10분 독서",
            startOffset: -6,
            duration: 15,
            completedOffsets: [-6, -5, -4, -2, -1, 0, 2],
            stageType: .fifteen,
            notificationEnabled: true
        )
        let waterTask = makeTask(
            title: "물 2L 마시기",
            startOffset: -3,
            duration: 7,
            completedOffsets: [-3, -2, 0],
            stageType: .seven
        )

        let tasks = [readingTask, waterTask]
        let summary = readModelQueries.calendar(tasks: tasks)

        var state = CalendarFeature.State()
        state.selectedDate = today
        state.tasks = tasks
        state.eventDates = summary.eventDates
        state.dateColors = summary.dateColors
        return state
    }

    static func allTaskState() -> AllTaskFeature.State {
        let ongoing = makeTask(
            title: "물 2L 마시기",
            startOffset: -1,
            duration: 7,
            completedOffsets: [-1, 0],
            stageType: .seven
        )
        let success = makeTask(
            title: "하루 영어 15분",
            startOffset: -30,
            duration: 30,
            completedOffsets: Array(-30 ... -1),
            stageType: .thirty,
            result: .success
        )
        let fail = makeTask(
            title: "아침 스트레칭",
            startOffset: -10,
            duration: 7,
            completedOffsets: [-10, -9],
            stageType: .seven,
            result: .fail
        )

        let summary = readModelQueries.allTasks(
            ongoingTasks: [ongoing],
            doneTasks: [success, fail]
        )

        var state = AllTaskFeature.State()
        state.ongoingTasks = summary.ongoingTasks
        state.successTasks = summary.successTasks
        state.failTasks = summary.failTasks
        return state
    }

    private static func makeTask(
        title: String,
        startOffset: Int,
        duration: Int,
        completedOffsets: [Int],
        stageType: StageType,
        notificationEnabled: Bool = false,
        result: StageResult = .inProgress
    ) -> Task {
        let startDate = calendar.date(byAdding: .day, value: startOffset, to: today) ?? today
        let endDate = calendar.date(byAdding: .day, value: duration - 1, to: startDate) ?? startDate
        let stage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: stageType.rawValue,
            startDate: startDate,
            endDate: endDate,
            durationDays: duration,
            successDays: max(1, Int(Double(duration) * 0.7)),
            resultRaw: result.rawValue
        )
        let records = completedOffsets.map { offset in
            DailyRecordSnapshot(
                id: UUID(),
                memo: "",
                check: true,
                date: calendar.date(byAdding: .day, value: offset, to: today) ?? today,
                imagePath: nil
            )
        }
        return Task(
            id: TaskID(UUID()),
            title: title,
            startDate: startDate,
            endDate: endDate,
            alarm: notificationEnabled ? alarmDate(hour: 21, minute: 0) : nil,
            isNotificationEnabled: notificationEnabled,
            stages: [stage],
            records: records,
            updatedAt: Date()
        )
    }

    private static func alarmDate(hour: Int, minute: Int) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? today
    }
}

private enum OnboardingCaptureFixtureImage: String {
    case readingWide = "captureReadingWide"
    case waterPortrait = "captureWaterPortrait"
    case studyPortrait = "captureStudyPortrait"
    case stretchingPortrait = "captureStretchingPortrait"

    var image: UIImage {
        guard let image = UIImage(named: rawValue) else {
            fatalError("Missing onboarding capture fixture asset: \(rawValue)")
        }
        return image
    }

    var jpegData: Data? {
        image.jpegData(compressionQuality: 0.94)
    }
}
