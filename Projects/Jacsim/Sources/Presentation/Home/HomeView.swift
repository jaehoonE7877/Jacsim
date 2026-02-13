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
        .onAppear { store.send(.onAppear) }
        .overlay(alignment: .bottom) {
            if let message = store.toastMessage {
                RedesignToastView(
                    payload: .success(message),
                    bottomPadding: toastBottomPadding
                )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task {
                        try? await _Concurrency.Task.sleep(
                            nanoseconds: RedesignToastView.defaultDismissNanoseconds
                        )
                        store.send(.toastDismissed)
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
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: store.toastMessage)
        .sheet(item: $store.scope(state: \.destination?.challengeCreate, action: \.destination.challengeCreate)) { store in
            ChallengeCreateView(store: store)
                .presentationDragIndicator(.visible)
        }
        .alert($store.scope(state: \.migrationAlert, action: \.migrationAlert))
        .sensoryFeedback(.impact(weight: .light), trigger: tapFeedbackTrigger)
    }

    private var addButton: some View {
        Button(action: {
            store.send(.addButtonTapped)
            triggerTapFeedback()
        }) {
            HStack(spacing: .jsXS) {
                Image(systemName: "plus")
                    .font(.system(size: 19.jsScaled(.displayTypography), weight: .semibold))
                    .foregroundColor(.white)

                if fabState == .expanded {
                    Text("새 TODO")
                        .font(.jsButtonMedium)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .frame(height: fabHeight)
            .padding(.horizontal, fabState == .expanded ? .jsLG : .jsMD)
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
        .pressEffect()
        .opacity(fabState == .hidden ? 0 : 1)
        .scaleEffect(fabState == .hidden ? 0.92 : 1)
        .offset(y: fabState == .hidden ? 24.jsScaled() : 0)
        .allowsHitTesting(fabState != .hidden)
        .accessibilityHidden(fabState == .hidden)
        .animation(
            reduceMotion ? .none : .spring(response: 0.28, dampingFraction: 0.88),
            value: fabState
        )
        .accessibilityLabel("새 TODO 만들기")
        .accessibilityHint("새 할 일 추가 화면을 엽니다")
    }

    private func triggerTapFeedback() {
        tapFeedbackTrigger += 1
    }

    private var contentVStack: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: .jsXXL) {
                HStack {
                    Text("작심")
                        .font(.jsDisplayMedium)
                        .foregroundColor(.labelStrong)

                    Spacer(minLength: .jsXS)

                    Text(todayLabel)
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelAlternative)
                        .padding(.horizontal, .jsSM)
                        .padding(.vertical, .jsMicro)
                        .background(
                            Capsule()
                                .fill(Color.backgroundAlternative)
                        )

                    Spacer()
                    
                    Button(action: {
                        store.send(.settingButtonTapped)
                        triggerTapFeedback()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.jsHeadlineLarge)
                            .foregroundColor(.labelAlternative)
                            .frame(width: 44.jsScaled(.touchTarget), height: 44.jsScaled(.touchTarget))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .zIndex(10)
                }
                .padding(.horizontal, .jsXL)
                .padding(.top, .jsXS)

                if store.isLoading && store.tasks.isEmpty {
                    skeletonContent
                        .transition(.opacity)
                } else if let heroTask = store.heroTask {
                    let remainingTasks = Array(store.activeTasks.dropFirst())
                    if PresentationRedesignFlags.isEnabled(.home) &&
                        PresentationRedesignFlags.isSectionEnabled(.homeSummary) {
                        homeSummaryCard
                            .transition(.opacity)
                    }
                    VStack(alignment: .leading, spacing: .jsMD) {
                        let heroImage = store.heroTaskImageData.flatMap { UIImage(data: $0) }.map { Image(uiImage: $0) }
                        JSUnifiedHeroCard(
                            title: heroTask.title,
                            subtitle: "\(heroTask.startDate.formatted(.dateTime.month().day())) ~ \(heroTask.endDate.formatted(.dateTime.month().day()))",
                            progress: heroTask.progress,
                            totalDays: heroTask.dayArray.count,
                            completedDays: heroTask.completedDays,
                            image: heroImage,
                            isTodayCertified: heroTask.isCompleted(on: Date()),
                            onTap: {
                                store.send(.taskTapped(heroTask))
                                triggerTapFeedback()
                            }
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, .jsXL)
                    
                    if !remainingTasks.isEmpty &&
                        PresentationRedesignFlags.isSectionEnabled(.homeMiniCards) {
                        VStack(alignment: .leading, spacing: .jsMD) {
                            HStack {
                                Text("진행 중인 작심들")
                                    .font(.jsHeadlineMedium)
                                    .foregroundColor(.labelStrong)
                                
                                Spacer()
                                
                                Button(action: {
                                    store.send(.allTasksButtonTapped)
                                    triggerTapFeedback()
                                }) {
                                    Text("전체보기")
                                        .font(.jsButtonSmall)
                                        .foregroundColor(.labelAlternative)
                                }
                            }
                            .padding(.horizontal, .jsXL)
                            
                            JSMiniHeroCardCarousel(
                                cards: makeMiniHeroCardData(from: store.miniCardDisplayData),
                                onCardTap: { cardID in
                                    guard let task = remainingTasks.first(where: { $0.id.rawValue == cardID }) else { return }
                                    store.send(.taskTapped(task))
                                    triggerTapFeedback()
                                }
                            )
                            .padding(.horizontal, 0)
                        }
                    }
                } else {
                    emptyStateView
                        .padding(.top, 40.jsScaled())
                        .padding(.horizontal, .jsXL)
                }
                
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



    private var emptyStateView: some View {
        VStack(spacing: .jsXL) {
            Image(systemName: "square.text.square.fill")
                .font(.jsDisplayScaledBold(size: 64))
                .foregroundColor(Color.labelAssistive)

            VStack(spacing: .jsXS) {
                Text("진행 중인 작심이 없어요")
                    .font(.jsHeadlineMedium)
                    .foregroundColor(.labelStrong)

                Text("새로운 작심을 시작해보세요!")
                    .font(.jsBodySmall)
                    .foregroundColor(.labelAlternative)
            }

            Button(action: {
                store.send(.addButtonTapped)
                triggerTapFeedback()
            }) {
                Text("작심 시작하기")
                    .font(.jsButtonMedium)
                    .foregroundColor(.white)
                    .frame(height: 50.jsScaled())
                    .frame(maxWidth: .infinity)
                    .background(Color.primaryNormal)
                    .cornerRadius(.jsRadiusMD)
            }
            .padding(.horizontal, .jsXL)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: 24.jsScaled())
                .fill(Color.backgroundStrong)
                .shadow(color: Color.labelStrong.opacity(0.05), radius: 10.jsScaled(), x: 0, y: 4.jsScaled())
        )
    }

    private var homeSummaryCard: some View {
        RedesignSectionCard(
            title: "오늘 할 일",
            subtitle: "인증 가능한 작심 \(store.activeTasks.count)개"
        ) {
            HStack(spacing: .jsSM) {
                summaryMetric(
                    title: "전체 진행",
                    value: "\(Int(overallProgress * 100))%",
                    color: .primaryNormal
                )
                summaryMetric(
                    title: "오늘 완료",
                    value: "\(todayCompletedCount)개",
                    color: .positive
                )
                summaryMetric(
                    title: "남은 항목",
                    value: "\(max(0, store.activeTasks.count - todayCompletedCount))개",
                    color: .cautionary
                )
            }
        }
        .padding(.horizontal, .jsXL)
    }

    private func summaryMetric(title: String, value: String, color: Color) -> some View {
        VStack(spacing: .jsMicro) {
            Text(title)
                .font(.jsLabelSmall)
                .foregroundColor(.labelAlternative)
            Text(value)
                .font(.jsHeadlineSmall)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, minHeight: 72.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(color.opacity(0.08))
        )
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

    private var skeletonContent: some View {
        VStack(alignment: .leading, spacing: 24.jsScaled()) {
            if PresentationRedesignFlags.isEnabled(.home) &&
                PresentationRedesignFlags.isSectionEnabled(.homeSummary) {
                homeSummarySkeleton
            }

            JSHeroCardSkeleton()
                .padding(.horizontal, 24.jsScaled())

            if PresentationRedesignFlags.isSectionEnabled(.homeMiniCards) {
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
                            JSMiniCardSkeleton()
                            JSMiniCardSkeleton()
                            JSMiniCardSkeleton()
                        }
                        .padding(.horizontal, 20.jsScaled())
                        .padding(.vertical, 4.jsScaled())
                    }
                    .frame(height: 200.jsScaled())
                    .padding(.horizontal, 0)
                }
            }
        }
    }

    private var homeSummarySkeleton: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 72.jsScaled(), height: 20.jsScaled())
                .skeleton(shape: RoundedRectangle(cornerRadius: 8))

            RoundedRectangle(cornerRadius: 6)
                .frame(width: 160.jsScaled(), height: 14.jsScaled())
                .skeleton(shape: RoundedRectangle(cornerRadius: 6))

            HStack(spacing: .jsSM) {
                summaryMetricSkeleton
                summaryMetricSkeleton
                summaryMetricSkeleton
            }
            .padding(.top, .jsXS)
        }
        .padding(.jsMD)
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(Color.skeletonContainer)
        )
        .overlay(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .stroke(Color.skeletonHighlight.opacity(0.16), lineWidth: 1)
        )
        .padding(.horizontal, .jsXL)
    }

    private var summaryMetricSkeleton: some View {
        VStack(spacing: .jsMicro) {
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 44.jsScaled(), height: 12.jsScaled())
                .skeleton(shape: RoundedRectangle(cornerRadius: 4))

            RoundedRectangle(cornerRadius: 6)
                .frame(width: 52.jsScaled(), height: 20.jsScaled())
                .skeleton(shape: RoundedRectangle(cornerRadius: 6))
        }
        .frame(maxWidth: .infinity, minHeight: 72.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(Color.skeletonBase.opacity(0.52))
        )
        .overlay(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .stroke(Color.skeletonHighlight.opacity(0.2), lineWidth: 1)
        )
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
