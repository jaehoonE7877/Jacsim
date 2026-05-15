import SwiftUI
import ComposableArchitecture
import Domain
import DSKit
import _Concurrency

public struct HomeView: View {
    private enum FabState {
        case expanded
        case collapsed
        case hidden
    }

    @Bindable var store: StoreOf<HomeFeature>
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
        guard !store.activeTasks.isEmpty else { return 0 }
        let total = store.activeTasks.reduce(0.0) { partial, task in
            partial + task.progress
        }
        return total / Double(store.activeTasks.count)
    }
    private var todayCompletedCount: Int {
        store.activeTasks.filter { $0.isCompleted(on: Date()) }.count
    }
    private var todayLabel: String {
        DateFormatType.toString(Date(), to: .fullWithoutYear)
    }

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            mainContent
                .navigationBarHidden(true)
        } destination: { store in
            destinationView(store: store)
        }
    }

    @ViewBuilder
    private func destinationView(store: Store<HomeFeature.Path.State, HomeFeature.Path.Action>) -> some View {
        switch store.state {
        case .detail:
            if let store = store.scope(state: \.detail, action: \.detail) {
                TaskDetailView(store: store)
            }
        case .update:
            if let store = store.scope(state: \.update, action: \.update) {
                TaskUpdateView(store: store)
            }
        case .allTasks:
            if let store = store.scope(state: \.allTasks, action: \.allTasks) {
                AllTaskView(store: store)
            }
        case .setting:
            if let store = store.scope(state: \.setting, action: \.setting) {
                SettingView(store: store)
            }
        }
    }

    private var mainContent: some View {
        ZStack {
            Color.backgroundNormal.ignoresSafeArea()

            scrollContent
        }
        .onAppear { store.send(.onAppear) }
        .overlay(alignment: .bottom) {
            if let message = store.toastMessage {
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
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: store.toastMessage)
        .sheet(item: $store.scope(state: \.destination?.challengeCreate, action: \.destination.challengeCreate)) { store in
            ChallengeCreateView(store: store)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
        }
        .alert($store.scope(state: \.migrationAlert, action: \.migrationAlert))
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
                value: store.isLoading
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
        if store.isLoading && store.tasks.isEmpty {
            HomeSkeletonSection(
                showsSummary: shouldShowSummarySection,
                showsMiniCards: shouldShowMiniCardsSection
            )
            .transition(.opacity)
        } else if let heroTask = store.heroTask {
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
                activeTaskCount: store.activeTasks.count,
                overallProgress: overallProgress,
                todayCompletedCount: todayCompletedCount
            )
            .transition(.opacity)
        }

        HomeHeroTaskSection(
            task: heroTask,
            imageData: store.heroTaskImageData,
            onTap: { handleTaskTap(heroTask) }
        )
        .padding(.horizontal, .jsXL)

        HomeFocusActionRow(
            state: focusActionState(for: heroTask),
            onPrimaryTap: { handleFocusPrimaryAction(heroTask) },
            onSecondaryTap: { handleFocusSecondaryAction(heroTask) }
        )
        .padding(.horizontal, .jsXL)

        if shouldShowMiniCardsSection && store.activeTasks.count > 1 {
            HomeMiniCardsSection(
                cards: makeMiniHeroCardData(from: store.miniCardDisplayData),
                onAllTasksTap: handleAllTasksButtonTap,
                onCardTap: handleMiniCardTap
            )
        }
    }

    private func dismissToast() async {
        try? await _Concurrency.Task.sleep(
            nanoseconds: RedesignToastView.defaultDismissNanoseconds
        )
        store.send(.toastDismissed)
    }

    private func handleAddButtonTap() {
        store.send(.addButtonTapped)
        triggerTapFeedback()
    }

    private func handleSettingsButtonTap() {
        store.send(.settingButtonTapped)
        triggerTapFeedback()
    }

    private func handleAllTasksButtonTap() {
        store.send(.allTasksButtonTapped)
        triggerTapFeedback()
    }

    private func handleFocusPrimaryAction(_ task: Domain.Task) {
        store.send(.focusPrimaryButtonTapped(task))
        triggerTapFeedback()
    }

    private func handleFocusSecondaryAction(_ task: Domain.Task) {
        store.send(.focusSecondaryButtonTapped(task))
        triggerTapFeedback()
    }

    private func handleTaskTap(_ task: Domain.Task) {
        store.send(.taskTapped(task))
        triggerTapFeedback()
    }

    private func handleMiniCardTap(_ cardID: UUID) {
        let tasks = Array(store.activeTasks.dropFirst())
        guard let task = tasks.first(where: { $0.id.rawValue == cardID }) else { return }
        handleTaskTap(task)
    }

    private func triggerTapFeedback() {
        tapFeedbackTrigger += 1
    }

    private func makeMiniHeroCardData(
        from displayData: [HomeFeature.State.MiniCardDisplayData]
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
        store: Store(
            initialState: HomeFeature.State()
        ) {
            HomeFeature()
        }
    )
}
