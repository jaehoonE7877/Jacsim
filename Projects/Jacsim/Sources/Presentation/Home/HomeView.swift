import SwiftUI
import ComposableArchitecture
import Domain
import DSKit
import _Concurrency

public struct HomeView: View {
     @Bindable var store: StoreOf<HomeFeature>
     @State private var tapFeedbackTrigger = 0
     @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
        ZStack(alignment: .bottom) {
            Color.backgroundNormal.ignoresSafeArea()

            contentVStack

            addButton
        }
        .onAppear { store.send(.onAppear) }
        .overlay(alignment: .bottom) {
            if let message = store.toastMessage {
                toastView(message: message)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task {
                        try? await _Concurrency.Task.sleep(nanoseconds: 2_000_000_000)
                        store.send(.toastDismissed)
                    }
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: store.toastMessage)
        .sheet(item: $store.scope(state: \.destination?.challengeCreate, action: \.destination.challengeCreate)) { store in
            ChallengeCreateView(store: store)
        }
        .alert($store.scope(state: \.migrationAlert, action: \.migrationAlert))
        .sensoryFeedback(.impact(weight: .light), trigger: tapFeedbackTrigger)
    }

    private var addButton: some View {
        Button(action: {
            store.send(.addButtonTapped)
            triggerTapFeedback()
        }) {
            Image(systemName: "plus")
                .font(.jsDisplaySmall)
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Color.primaryNormal)
                .clipShape(Circle())
                .shadow(color: .primaryNormal.opacity(0.3), radius: 12, x: 0, y: 6)
                .contentShape(Circle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.trailing, .jsMD)
        .padding(.bottom, .jsMD)
        .pressEffect()
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
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .zIndex(10)
                }
                .padding(.horizontal, .jsXL)
                .padding(.top, .jsXS)

                if store.isLoading && store.tasks.isEmpty {
                    skeletonContent
                } else if let heroTask = store.heroTask {
                    let remainingTasks = Array(store.activeTasks.dropFirst())
                    if PresentationRedesignFlags.isEnabled(.home) &&
                        PresentationRedesignFlags.isSectionEnabled(.homeSummary) {
                        homeSummaryCard
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
                        .pressEffect()
                    }
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
                                onCardTap: { index in
                                    guard remainingTasks.indices.contains(index) else { return }
                                    let task = remainingTasks[index]
                                    store.send(.taskTapped(task))
                                    triggerTapFeedback()
                                }
                            )
                            .padding(.horizontal, 0)
                        }
                    }
                } else {
                    emptyStateView
                        .padding(.top, 40)
                        .padding(.horizontal, .jsXL)
                }
                
                Spacer(minLength: 100)
            }
            .padding(.bottom, .jsXL)
        }
    }



    private var emptyStateView: some View {
        VStack(spacing: .jsXL) {
            Image(systemName: "square.text.square.fill")
                .font(.pretendardBold(size: 64))
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
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.primaryNormal)
                    .cornerRadius(.jsRadiusMD)
            }
            .padding(.horizontal, .jsXL)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.backgroundStrong)
                .shadow(color: Color.labelStrong.opacity(0.05), radius: 10, x: 0, y: 4)
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
        .frame(maxWidth: .infinity, minHeight: 72)
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
        VStack(alignment: .leading, spacing: 24) {
            JSHeroCardSkeleton()
                .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 140, height: 20)
                        .skeleton(shape: RoundedRectangle(cornerRadius: 8))

                    Spacer()

                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 60, height: 16)
                        .skeleton(shape: RoundedRectangle(cornerRadius: 6))
                }
                .padding(.horizontal, 24)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        JSMiniCardSkeleton()
                        JSMiniCardSkeleton()
                        JSMiniCardSkeleton()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }
                .padding(.horizontal, 0)
            }
        }
    }

    private func toastView(message: String) -> some View {
        Text(message)
            .font(.jsBodyMedium)
            .foregroundColor(.labelStrong)
            .padding(.horizontal, .jsMD)
            .padding(.vertical, 10)
            .background(Color.backgroundAlternative.opacity(0.95))
            .cornerRadius(.jsRadiusLG)
            .padding(.bottom, .jsXL)
            .padding(.horizontal, .jsXL)
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

#Preview {
    HomeView(
        store: Store(
            initialState: HomeFeature.State()
        ) {
            HomeFeature()
        }
    )
}
