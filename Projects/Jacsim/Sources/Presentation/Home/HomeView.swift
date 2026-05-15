import SwiftUI
import Domain
import DSKit
import _Concurrency

public struct HomeView: View {
    private enum FabState {
        case expanded
        case collapsed
        case hidden
    }

    @Bindable var model: HomeModel
    @State private var tapFeedbackTrigger = 0
    @State private var fabState: FabState = .expanded
    @State private var previousScrollOffset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var fabHeight: CGFloat { 56.jsScaled() }
    private var fabCollapseThreshold: CGFloat { -56.jsScaled() }
    private var fabHiddenThreshold: CGFloat { -148.jsScaled() }
    private var fabExpandThreshold: CGFloat { -20.jsScaled() }
    private var scrollDeltaDeadZone: CGFloat { 3.jsScaled() }
    private var shouldShowSummarySection: Bool {
        PresentationRedesignFlags.isEnabled(.home) &&
        PresentationRedesignFlags.isSectionEnabled(.homeSummary)
    }
    private var shouldShowMiniCardsSection: Bool {
        PresentationRedesignFlags.isSectionEnabled(.homeMiniCards)
    }
    private var contentBottomPadding: CGFloat {
        switch fabState {
        case .expanded:
            return .jsSM
        case .collapsed, .hidden:
            return .jsXS
        }
    }
    private var toastBottomPadding: CGFloat {
        switch fabState {
        case .expanded:
            return 116.jsScaled()
        case .collapsed:
            return 96.jsScaled()
        case .hidden:
            return 40.jsScaled()
        }
    }
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
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                floatingAddButton
            }
            .padding(.top, .jsXS)
            .padding(.trailing, .jsMD)
            .padding(.bottom, .jsSM)
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: model.toastMessage)
        .sheet(item: $model.challengeCreate) { challengeModel in
            ChallengeCreateView(model: challengeModel)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
        }
        .sensoryFeedback(.impact(weight: .light), trigger: tapFeedbackTrigger)
    }

    private var floatingAddButton: some View {
        HomeFloatingAddButton(
            isExpanded: fabState == .expanded,
            isHidden: fabState == .hidden,
            reduceMotion: reduceMotion,
            height: fabHeight,
            action: handleAddButtonTap
        )
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
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: HomeScrollOffsetPreferenceKey.self,
                        value: proxy.frame(in: .named("homeScrollView")).minY
                    )
                }
            )
        }
        .coordinateSpace(name: "homeScrollView")
        .onPreferenceChange(HomeScrollOffsetPreferenceKey.self) { offset in
            updateFabState(for: offset)
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
            HomeEmptyStateSection(onStart: handleAddButtonTap)
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

    private func handleAddButtonTap() {
        model.addButtonTapped()
        triggerTapFeedback()
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

    private func updateFabState(for offset: CGFloat) {
        let delta = offset - previousScrollOffset
        previousScrollOffset = offset

        guard abs(delta) > scrollDeltaDeadZone else { return }

        switch fabState {
        case .expanded:
            if offset < fabCollapseThreshold {
                setFabState(.collapsed)
            }
        case .collapsed:
            if offset < fabHiddenThreshold && delta < 0 {
                setFabState(.hidden)
            } else if offset > fabExpandThreshold {
                setFabState(.expanded)
            }
        case .hidden:
            if delta > 0 {
                if offset > fabExpandThreshold {
                    setFabState(.expanded)
                } else {
                    setFabState(.collapsed)
                }
            }
        }
    }

    private func setFabState(_ state: FabState) {
        guard fabState != state else { return }
        fabState = state
    }
}

private struct HomeScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    HomeView(
        model: HomeModel(dependencies: .test)
    )
}
