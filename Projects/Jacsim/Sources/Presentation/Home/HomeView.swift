import SwiftUI
import ComposableArchitecture
import Domain
import DesignSystem
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
    private var sectionHorizontalPadding: CGFloat { .jsXL }
    private var sectionSpacing: CGFloat { .jsXL }

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
        case .walkThrough:
            if let store = store.scope(state: \.walkThrough, action: \.walkThrough) {
                WalkThroughView(store: store)
            }
        case .openSourceLicense:
            if let store = store.scope(state: \.openSourceLicense, action: \.openSourceLicense) {
                OpenSourceLicenseView(store: store)
            }
        }
    }

    private var mainContent: some View {
        ZStack {
            Color.backgroundNormal.ignoresSafeArea()

            contentVStack
        }
        .onAppear(perform: handleAppear)
        .overlay(alignment: .bottom) {
            if let message = store.toastMessage {
                RedesignToastView(
                    payload: .success(message),
                    bottomPadding: toastBottomPadding,
                    dismissAction: handleToastDismissed
                )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task {
                        try? await _Concurrency.Task.sleep(
                            nanoseconds: RedesignToastView.defaultDismissNanoseconds
                        )
                        handleToastDismissed()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                addButton
            }
            .padding(.top, .jsXS)
            .padding(.trailing, .jsMD)
            .padding(.bottom, .jsSM)
        }
        .animation(reduceMotion ? .none : JSAnimation.toast, value: store.toastMessage)
        .sheet(item: $store.scope(state: \.destination?.challengeCreate, action: \.destination.challengeCreate)) { store in
            ChallengeCreateView(store: store)
                .presentationDragIndicator(.visible)
        }
        .alert($store.scope(state: \.migrationAlert, action: \.migrationAlert))
        .sensoryFeedback(.impact(weight: .light), trigger: tapFeedbackTrigger)
    }

    private var addButton: some View {
        HomeAddButton(
            stateIndex: fabStateStateIndex,
            isExpanded: fabState == .expanded,
            isHidden: fabState == .hidden,
            reduceMotion: reduceMotion,
            fabHeight: fabHeight,
            onTap: handleAddButtonTapped
        )
    }

    private func triggerTapFeedback() {
        tapFeedbackTrigger += 1
    }

    private var contentVStack: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: sectionSpacing) {
                headerView

                if store.isLoading && store.tasks.isEmpty {
                    skeletonContent
                        .transition(.opacity)
                } else if store.loadFailed && store.tasks.isEmpty {
                    loadFailedView
                        .padding(.top, 40.jsScaled())
                        .padding(.horizontal, sectionHorizontalPadding)
                } else {
                    primaryContentSection
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, sectionHorizontalPadding)

                    if !store.secondaryTasks.isEmpty {
                        secondaryTasksSection
                    }
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, contentBottomPadding)
            .animation(
                reduceMotion ? .none : JSAnimation.navigation,
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

    private var headerView: some View {
        HomeHeaderSection(todayLabel: todayLabel, onSettingsTapped: handleSettingButtonTapped)
            .padding(.horizontal, sectionHorizontalPadding)
            .padding(.top, .jsXS)
    }



    private var emptyStateView: some View {
        VStack(spacing: .jsXL) {
            Image(systemName: "square.text.square.fill")
                .font(.jsDisplayScaledBold(size: 64))
                .foregroundColor(Color.labelAlternative)

            VStack(spacing: .jsXS) {
                Text("오늘 이어가는 작심이 없어요")
                    .font(.jsHeadlineMedium)
                    .foregroundColor(.labelStrong)

                Text("새 작심을 만들면 오늘 할 일이 바로 보이기 시작해요")
                    .font(.jsBodySmall)
                    .foregroundColor(.labelNeutral)
                    .multilineTextAlignment(.center)
            }

            JSButton(title: "작심 시작하기", style: .primary, size: .large) {
                handleAddButtonTapped()
            }
            .padding(.horizontal, .jsXL)
            .accessibilityLabel("작심 시작하기")
            .accessibilityHint("새 작심 생성 화면을 엽니다")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: 24.jsScaled())
                .fill(Color.backgroundStrong)
                .shadow(color: Color.labelStrong.opacity(0.05), radius: 10.jsScaled(), x: 0, y: 4.jsScaled())
        )
    }

    private var loadFailedView: some View {
        VStack(spacing: .jsXL) {
            Image(systemName: "wifi.exclamationmark")
                .font(.jsDisplayScaledBold(size: 64))
                .foregroundColor(.destructive)

            VStack(spacing: .jsXS) {
                Text("홈을 불러오지 못했어요")
                    .font(.jsHeadlineMedium)
                    .foregroundColor(.labelStrong)

                Text("연결 상태를 확인한 뒤 다시 시도해 주세요")
                    .font(.jsBodySmall)
                    .foregroundColor(.labelNeutral)
                    .multilineTextAlignment(.center)
            }

            JSButton(title: "다시 시도", style: .secondary, size: .medium) {
                handleAppear()
            }
            .accessibilityHint("홈 화면 정보를 다시 불러옵니다")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: 24.jsScaled())
                .fill(Color.backgroundStrong)
                .shadow(color: Color.labelStrong.opacity(0.05), radius: 10.jsScaled(), x: 0, y: 4.jsScaled())
        )
        .jsAccessibility("홈을 불러오지 못했어요. 연결 상태를 확인한 뒤 다시 시도해 주세요")
    }

    private var staleContentErrorBanner: some View {
        HStack(alignment: .center, spacing: .jsSM) {
            Image(systemName: "wifi.exclamationmark")
                .font(.jsLabelMedium)
                .foregroundColor(.cautionary)

            Text("최신 상태를 확인하지 못했어요. 연결이 안정되면 새로고침으로 다시 가져올 수 있어요.")
                .font(.jsBodySmall)
                .foregroundColor(.labelStrong)
                .multilineTextAlignment(.leading)

            Spacer(minLength: .jsSM)

            Button(action: handleRefreshTriggered) {
                Text("새로고침")
                    .font(.jsButtonSmall)
                    .foregroundColor(.cautionary)
                    .padding(.horizontal, .jsSM)
                    .padding(.vertical, .jsXS)
                    .background(
                        Capsule()
                            .fill(Color.backgroundNormal.opacity(0.82))
                    )
            }
            .buttonStyle(.plain)
            .accessibilityHint("진행 중인 작심 목록을 다시 불러옵니다")
        }
        .padding(.horizontal, .jsSM)
        .padding(.vertical, .jsSM)
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(Color.cautionary.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .stroke(Color.cautionary.opacity(0.18), lineWidth: 1)
        )
    }

    private var homeSummaryCard: some View {
        HomeSummaryDashboardCard(presentation: summaryPresentation)
    }

    private func makeMiniHeroCardData(
        from displayData: [HomeFeature.State.MiniCardDisplayData]
    ) -> [HomeMiniHeroCardData] {
        displayData.map { data in
            let image = data.imageData.flatMap { UIImage(data: $0) }.map { Image(uiImage: $0) }
            return HomeMiniHeroCardData(
                id: data.id,
                title: data.title,
                progress: data.progress,
                totalDays: data.totalDays,
                completedDays: data.completedDays,
                image: image,
                isTodayCertified: data.isTodayCertified,
                accessibilityLabel: "\(data.title), 진행률 \(Int(data.progress * 100))퍼센트, \(data.completedDays)일 완료",
                accessibilityHint: "작심 상세 화면으로 이동합니다"
            )
        }
    }

    private var skeletonContent: some View {
        VStack(alignment: .leading, spacing: 24.jsScaled()) {
            homeSummarySkeleton

            RoundedRectangle(cornerRadius: 20.jsScaled())
                .frame(height: 320.jsScaled())
                .skeleton(shape: RoundedRectangle(cornerRadius: 20.jsScaled()))
                .padding(.horizontal, 24.jsScaled())

            VStack(alignment: .leading, spacing: 16.jsScaled()) {
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 140.jsScaled(), height: 20.jsScaled())
                        .skeleton(shape: RoundedRectangle(cornerRadius: 8))

                    Spacer()

                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 60.jsScaled(), height: 16.jsScaled())
                        .skeleton(shape: RoundedRectangle(cornerRadius: 6))
                }
                .padding(.horizontal, 24.jsScaled())

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12.jsScaled()) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 20.jsScaled())
                                .frame(width: 160.jsScaled(), height: 200.jsScaled())
                                .skeleton(shape: RoundedRectangle(cornerRadius: 20.jsScaled()))
                        }
                    }
                    .padding(.horizontal, 20.jsScaled())
                    .padding(.vertical, 4.jsScaled())
                }
                .frame(height: 200.jsScaled())
                .padding(.horizontal, 0)
            }
        }
    }

    private var homeSummarySkeleton: some View {
        HomeSummaryDashboardSkeleton()
            .padding(.horizontal, sectionHorizontalPadding)
    }

    private var primaryContentSection: some View {
        VStack(alignment: .leading, spacing: .jsLG) {
            homeSummaryCard
                .transition(.opacity)

            if store.loadFailed {
                staleContentErrorBanner
                    .transition(.opacity)
            }

            if let heroTask = store.heroTask {
                let heroImage = store.heroTaskImageData.flatMap { UIImage(data: $0) }.map { Image(uiImage: $0) }
                HomeHeroCard(
                    title: heroTask.title,
                    subtitle: heroSubtitle(for: heroTask),
                    progress: heroTask.progress,
                    totalDays: heroTask.dayArray.count,
                    completedDays: heroTask.completedDays,
                    image: heroImage,
                    isTodayCertified: heroTask.isCompleted(on: Date()),
                    accessibilityLabel: heroAccessibilityLabel(for: heroTask),
                    accessibilityHint: heroAccessibilityHint,
                    onTap: {
                        handleTaskTapped(heroTask)
                    }
                )
                .frame(maxWidth: .infinity)
            } else {
                emptyStateView
            }
        }
    }

    private var secondaryTasksSection: some View {
        let cards = makeMiniHeroCardData(from: store.miniCardDisplayData)

        return HomeSecondaryTasksSection(
            title: secondarySectionTitle,
            subtitle: secondarySectionSubtitle,
            count: store.secondaryTasks.count,
            cards: cards,
            onCardTap: handleMiniHeroCardTapped,
            onAllTasksTapped: handleAllTasksButtonTapped
        )
        .padding(.horizontal, 0)
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

    private var contentBottomPadding: CGFloat {
        switch fabState {
        case .expanded:
            return .jsSM
        case .collapsed, .hidden:
            return .jsXS
        }
    }

    private var fabStateStateIndex: Int {
        switch fabState {
        case .expanded:
            return 0
        case .collapsed:
            return 1
        case .hidden:
            return 2
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

    private var todayLabel: String {
        DateFormatType.toString(Date(), to: .fullWithoutYear)
    }

    private var summaryPresentation: HomeSummaryCardPresentation {
        HomeSummaryCardPresentation(
            todayFocusState: store.todayFocusState,
            pendingCount: store.todayPendingCount,
            completedCount: store.todayCompletedCount,
            overallProgressText: overallProgressText,
            isStale: store.loadFailed && !store.tasks.isEmpty
        )
    }

    private var secondarySectionTitle: String {
        "이어가는 작심들"
    }

    private var secondarySectionSubtitle: String {
        "오늘 포커스 외에 \(store.secondaryTasks.count)개를 더 이어갈 수 있어요"
    }

    private var heroAccessibilityHint: String {
        "작심 상세 화면으로 이동합니다"
    }

    private func heroSubtitle(for task: Domain.Task) -> String {
        "\(task.startDate.formatted(.dateTime.month().day())) ~ \(task.endDate.formatted(.dateTime.month().day()))"
    }

    private func heroAccessibilityLabel(for task: Domain.Task) -> String {
        switch store.todayFocusState {
        case .completedStageReady:
            return "\(task.title), 오늘 단계를 완료한 작심, 다음 단계 준비됨, 진행률 \(Int(task.progress * 100))퍼센트"
        case .allDoneToday:
            return "\(task.title), 오늘 완료한 작심, 진행률 \(Int(task.progress * 100))퍼센트"
        case .empty, .pending:
            return "\(task.title), 오늘 포커스 작심, 진행률 \(Int(task.progress * 100))퍼센트, \(task.completedDays)일 완료"
        }
    }

    private var overallProgressText: String {
        let totalDays = store.activeTasks.reduce(0) { partialResult, task in
            partialResult + task.dayArray.count
        }
        let completedDays = store.activeTasks.reduce(0) { partialResult, task in
            partialResult + task.completedDays
        }
        guard totalDays > 0 else { return "0%" }
        let progress = (Double(completedDays) / Double(totalDays)) * 100
        return "\(Int(progress.rounded()))%"
    }

    private func handleAppear() {
        store.send(.onAppear)
    }

    private func handleToastDismissed() {
        store.send(.toastDismissed)
    }

    private func handleAddButtonTapped() {
        store.send(.addButtonTapped)
        triggerTapFeedback()
    }

    private func handleSettingButtonTapped() {
        store.send(.settingButtonTapped)
        triggerTapFeedback()
    }

    private func handleAllTasksButtonTapped() {
        store.send(.allTasksButtonTapped)
        triggerTapFeedback()
    }

    private func handleMiniHeroCardTapped(_ cardID: UUID) {
        guard let task = store.secondaryTasks.first(where: { $0.id.rawValue == cardID }) else { return }
        handleTaskTapped(task)
    }

    private func handleTaskTapped(_ task: Domain.Task) {
        store.send(.taskTapped(task))
        triggerTapFeedback()
    }

    private func handleRefreshTriggered() {
        store.send(.refreshTriggered)
    }
}

private struct HomeScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct HomeHeaderSection: View {
    let todayLabel: String
    let onSettingsTapped: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: .jsMD) {
            VStack(alignment: .leading, spacing: .jsXS) {
                Text("작심")
                    .font(.jsDisplayMedium)
                    .foregroundColor(.labelStrong)

                Text(todayLabel)
                    .font(.jsLabelMedium)
                    .foregroundColor(.primaryStrong)
                    .padding(.horizontal, .jsSM)
                    .padding(.vertical, .jsMicro)
                    .background(
                        Capsule()
                            .fill(Color.primaryNormal.opacity(0.08))
                    )
            }

            Spacer(minLength: .jsSM)

            Button(action: onSettingsTapped) {
                Image(systemName: "gearshape.fill")
                    .font(.jsHeadlineSmall)
                    .foregroundColor(.labelNeutral)
                    .frame(width: 44.jsScaled(.touchTarget), height: 44.jsScaled(.touchTarget))
                    .background(
                        Circle()
                            .fill(Color.backgroundAlternative)
                    )
            }
            .buttonStyle(.plain)
            .zIndex(10)
            .accessibilityLabel("설정")
            .accessibilityHint("설정 화면으로 이동합니다")
        }
    }
}

private struct HomeSecondaryTasksSection: View {
    let title: String
    let subtitle: String
    let count: Int
    let cards: [HomeMiniHeroCardData]
    let onCardTap: (UUID) -> Void
    let onAllTasksTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            HStack {
                VStack(alignment: .leading, spacing: .jsMicro) {
                    Text(title)
                        .font(.jsHeadlineMedium)
                        .foregroundColor(.labelStrong)

                    Text(subtitle)
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelNeutral)
                }

                Spacer(minLength: .jsSM)

                Text("\(count)")
                    .font(.jsButtonSmall)
                    .foregroundColor(.labelStrong)
                    .padding(.horizontal, .jsSM)
                    .padding(.vertical, .jsMicro)
                    .background(
                        Capsule()
                            .fill(Color.backgroundAlternative)
                    )

                Button(action: onAllTasksTapped) {
                    Text("전체 보기")
                        .font(.jsButtonSmall)
                        .foregroundColor(.labelStrong)
                        .padding(.horizontal, .jsSM)
                        .padding(.vertical, .jsXS)
                        .background(
                            Capsule()
                                .fill(Color.backgroundAlternative)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("전체 보기")
                .accessibilityHint("모든 작심 목록 화면으로 이동합니다")
            }

            HomeMiniHeroCardCarousel(
                cards: cards,
                onCardTap: onCardTap
            )
        }
    }
}

private struct HomeAddButton: View {
    let stateIndex: Int
    let isExpanded: Bool
    let isHidden: Bool
    let reduceMotion: Bool
    let fabHeight: CGFloat
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: .jsXS) {
                Image(systemName: "plus")
                    .font(.jsHeadlineSmall)
                    .foregroundColor(.onPrimary)

                if isExpanded {
                    Text("새 작심")
                        .font(.jsButtonMedium)
                        .foregroundColor(.onPrimary)
                        .lineLimit(1)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .frame(height: fabHeight)
            .padding(.horizontal, isExpanded ? .jsLG : .jsMD)
            .background(
                Capsule()
                    .fill(Color.primaryNormal)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: .primaryNormal.opacity(0.26), radius: 14.jsScaled(), x: 0, y: 8.jsScaled())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .opacity(isHidden ? 0 : 1)
        .scaleEffect(isHidden ? 0.92 : 1)
        .offset(y: isHidden ? 24.jsScaled() : 0)
        .allowsHitTesting(!isHidden)
        .accessibilityHidden(isHidden)
        .animation(
            reduceMotion ? .none : JSAnimation.emphasisSpring,
            value: stateIndex
        )
        .accessibilityLabel("새 작심 만들기")
        .accessibilityHint("새 작심 생성 화면을 엽니다")
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
