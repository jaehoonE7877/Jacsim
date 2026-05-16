import SwiftUI
import Domain
import DSKit
import _Concurrency

public struct HomeView: View {
    @Bindable var model: HomeModel
    @State private var tapFeedbackTrigger = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var shouldShowSummarySection: Bool {
        PresentationRedesignFlags.isEnabled(.home) &&
        PresentationRedesignFlags.isSectionEnabled(.homeSummary)
    }
    private var shouldShowMiniCardsSection: Bool {
        PresentationRedesignFlags.isSectionEnabled(.homeMiniCards)
    }
    private var contentBottomPadding: CGFloat { 96.jsScaled() }
    private var toastBottomPadding: CGFloat { 104.jsScaled() }
    private var overallProgress: Double {
        guard !model.activeTasks.isEmpty else { return 0 }
        let total = model.activeTasks.reduce(0.0) { partial, task in
            partial + task.progress
        }
        return total / Double(model.activeTasks.count)
    }
    private var todayCompletedCount: Int {
        model.activeTasks.filter { $0.isCompleted(on: Date()) }.count
    }
    private var todayLabel: String {
        DateFormatType.toString(Date(), to: .fullWithoutYear)
    }

    public init(model: HomeModel) {
        self.model = model
    }

    public var body: some View {
        NavigationStack(path: $model.path) {
            mainContent
                .navigationBarHidden(true)
                .navigationDestination(for: HomeModel.Route.self) { route in
                    destinationView(route: route)
                }
        }
    }

    @ViewBuilder
    private func destinationView(route: HomeModel.Route) -> some View {
        switch route {
        case let .detail(task, shouldScrollToRecords):
            TaskDetailView(
                model: TaskDetailModel(
                    task: task,
                    dependencies: model.dependencies,
                    shouldScrollToRecords: shouldScrollToRecords,
                    onTaskDeleted: model.taskDeleted,
                    onNavigateToUpdate: { task, index in
                        model.navigateToUpdate(task, index: index)
                    },
                    onNavigateBack: model.navigateBack
                )
            )
        case let .update(task, index):
            TaskUpdateView(
                model: TaskUpdateModel(
                    task: task,
                    index: index,
                    dependencies: model.dependencies,
                    onSaveSuccess: model.updateSaved
                )
            )
        case .allTasks:
            AllTaskView(model: AllTaskModel(dependencies: model.dependencies))
        case .setting:
            SettingView(model: SettingScreenModel(dependencies: model.dependencies))
        }
    }

    private var mainContent: some View {
        ZStack {
            Color.backgroundNormal.ignoresSafeArea()

            scrollContent
        }
        .onAppear { model.onAppear() }
        .overlay(alignment: .bottom) {
            if let message = model.toastMessage {
                RedesignToastView(
                    payload: .success(message),
                    bottomPadding: toastBottomPadding
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .task(id: message) {
                    await dismissToast()
                }
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: model.toastMessage)
        .sensoryFeedback(.impact(weight: .light), trigger: tapFeedbackTrigger)
    }

    private var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: .jsXXL) {
                HomeHeaderSection(
                    todayLabel: todayLabel,
                    onSettingsTap: handleSettingsButtonTap
                )

                contentSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, contentBottomPadding)
            .animation(
                reduceMotion ? .none : .easeInOut(duration: 0.22),
                value: model.isLoading
            )
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        if model.isLoading && model.tasks.isEmpty {
            HomeSkeletonSection(
                showsSummary: shouldShowSummarySection,
                showsMiniCards: shouldShowMiniCardsSection
            )
            .transition(.opacity)
        } else if let heroTask = model.heroTask {
            loadedContent(for: heroTask)
        } else {
            HomeEmptyStateSection()
                .padding(.top, 40.jsScaled())
                .padding(.horizontal, .jsXL)
        }
    }

    @ViewBuilder
    private func loadedContent(for heroTask: Domain.Task) -> some View {
        if shouldShowSummarySection {
            HomeSummaryCardSection(
                activeTaskCount: model.activeTasks.count,
                overallProgress: overallProgress,
                todayCompletedCount: todayCompletedCount
            )
            .transition(.opacity)
        }

        HomeHeroTaskSection(
            task: heroTask,
            imageData: model.heroTaskImageData,
            onTap: { handleTaskTap(heroTask) }
        )
        .padding(.horizontal, .jsXL)

        HomeFocusActionRow(
            state: focusActionState(for: heroTask),
            onPrimaryTap: { handleFocusPrimaryAction(heroTask) },
            onSecondaryTap: { handleFocusSecondaryAction(heroTask) }
        )
        .padding(.horizontal, .jsXL)

        if shouldShowMiniCardsSection && model.activeTasks.count > 1 {
            HomeMiniCardsSection(
                cards: makeMiniHeroCardData(from: model.miniCardDisplayData),
                onAllTasksTap: handleAllTasksButtonTap,
                onCardTap: handleMiniCardTap
            )
        }
    }

    private func dismissToast() async {
        try? await _Concurrency.Task.sleep(
            nanoseconds: RedesignToastView.defaultDismissNanoseconds
        )
        model.toastDismissed()
    }

    private func handleSettingsButtonTap() {
        model.settingButtonTapped()
        triggerTapFeedback()
    }

    private func handleAllTasksButtonTap() {
        model.allTasksButtonTapped()
        triggerTapFeedback()
    }

    private func handleFocusPrimaryAction(_ task: Domain.Task) {
        model.focusPrimaryButtonTapped(task)
        triggerTapFeedback()
    }

    private func handleFocusSecondaryAction(_ task: Domain.Task) {
        model.focusSecondaryButtonTapped(task)
        triggerTapFeedback()
    }

    private func handleTaskTap(_ task: Domain.Task) {
        model.taskTapped(task)
        triggerTapFeedback()
    }

    private func handleMiniCardTap(_ cardID: UUID) {
        let tasks = Array(model.activeTasks.dropFirst())
        guard let task = tasks.first(where: { $0.id.rawValue == cardID }) else { return }
        handleTaskTap(task)
    }

    private func triggerTapFeedback() {
        tapFeedbackTrigger += 1
    }

    private func makeMiniHeroCardData(
        from displayData: [HomeModel.MiniCardDisplayData]
    ) -> [JSMiniHeroCardData] {
        displayData.map { data in
            let image = data.imageData.flatMap { UIImage(data: $0) }.map { Image(uiImage: $0) }
            return JSMiniHeroCardData(
                id: data.id,
                title: data.title,
                progress: data.progress,
                totalDays: data.totalDays,
                completedDays: data.completedDays,
                image: image,
                isTodayCertified: data.isTodayCertified
            )
        }
    }

    private func focusActionState(for task: Domain.Task) -> HomeFocusActionState {
        switch task.stages.last?.result ?? .inProgress {
        case .success where task.stages.last?.stageType.next != nil:
            return .completedStageReady
        case .success:
            return .allDoneToday
        case .fail:
            return .failed
        case .inProgress:
            return task.isCompleted(on: Date()) ? .allDoneToday : .pending
        }
    }

}

#Preview {
    HomeView(
        model: HomeModel(dependencies: .test)
    )
}
