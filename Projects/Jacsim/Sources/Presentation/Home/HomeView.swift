import SwiftUI
import ComposableArchitecture
import Domain
import DSKit
import _Concurrency

public struct HomeView: View {
     @Bindable var store: StoreOf<HomeFeature>
     @State private var tapFeedbackTrigger = 0

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            mainContent
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
        .navigationBarHidden(true)
        .onAppear { store.send(.onAppear) }
        .overlay(alignment: .bottom) {
            if let message = store.toastMessage {
                toastView(message: message)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task {
//                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        store.send(.toastDismissed)
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: store.toastMessage)
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
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Color.primaryNormal)
                .clipShape(Circle())
                .shadow(color: .primaryNormal.opacity(0.3), radius: 12, x: 0, y: 6)
                .contentShape(Circle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.trailing, 16)
        .padding(.bottom, 16)
        .pressEffect()
    }

    private func triggerTapFeedback() {
        tapFeedbackTrigger += 1
    }

    private var contentVStack: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                HStack {
                    Text("작심")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.labelStrong)
                    
                    Spacer()
                    
                    Button(action: {
                        store.send(.settingButtonTapped)
                        triggerTapFeedback()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.labelAlternative)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                if store.isLoading && store.tasks.isEmpty {
                    skeletonContent
                } else if let heroTask = store.heroTask {
                    let remainingTasks = Array(store.activeTasks.dropFirst())
                    VStack(alignment: .leading, spacing: 16) {
                        let heroImage = store.heroTaskImageData.flatMap { UIImage(data: $0) }.map { Image(uiImage: $0) }
                        JSUnifiedHeroCard(
                            title: heroTask.title,
                            subtitle: "\(heroTask.startDate.formatted(.dateTime.month().day())) ~ \(heroTask.endDate.formatted(.dateTime.month().day()))",
                            progress: calculateProgress(for: heroTask),
                            totalDays: heroTask.dayArray.count,
                            completedDays: heroTask.records.filter { $0.check }.count,
                            image: heroImage,
                            isTodayCertified: isTaskCompletedToday(heroTask),
                            onTap: {
                                store.send(.taskTapped(heroTask))
                                triggerTapFeedback()
                            }
                        )
                        .pressEffect()
                    }
                    .padding(.horizontal, 24)
                    
                    if !remainingTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("진행 중인 작심들")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.labelStrong)
                                
                                Spacer()
                                
                                Button(action: {
                                    store.send(.allTasksButtonTapped)
                                    triggerTapFeedback()
                                }) {
                                    Text("전첵보기")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.labelAlternative)
                                }
                            }
                            .padding(.horizontal, 24)
                            
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
                        .padding(.horizontal, 24)
                }
                
                Spacer(minLength: 100)
            }
            .padding(.bottom, 24)
        }
    }

    private func calculateProgress(for task: Domain.Task) -> Double {
        let completed = task.records.filter { $0.check }.count
        let total = task.dayArray.count
        return total > 0 ? Double(completed) / Double(total) : 0
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "square.text.square.fill")
                .font(.system(size: 64))
                .foregroundColor(Color.gray.opacity(0.3))

            VStack(spacing: 8) {
                Text("진행 중인 작심이 없어요")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.labelStrong)

                Text("새로운 작심을 시작해보세요!")
                    .font(.system(size: 15))
                    .foregroundColor(.labelAlternative)
            }

            Button(action: {
                store.send(.addButtonTapped)
                triggerTapFeedback()
            }) {
                Text("작심 시작하기")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.primaryNormal)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }

    private func isTaskCompletedToday(_ task: Domain.Task) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let dailyRecord = task.records.first(where: {
            calendar.isDate($0.date, inSameDayAs: today)
        }) {
            return dailyRecord.check
        }
        return false
    }

    private func makeMiniHeroCardData(
        from displayData: [HomeFeature.State.MiniCardDisplayData]
    ) -> [JSMiniHeroCardData] {
        displayData.map { data in
            let image = data.imageData.flatMap { UIImage(data: $0) }.map { Image(uiImage: $0) }
            return JSMiniHeroCardData(
                title: data.title,
                progress: data.progress,
                totalDays: data.totalDays,
                completedDays: data.completedDays,
                image: image
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
                        .skeleton(cornerRadius: 8)

                    Spacer()

                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 60, height: 16)
                        .skeleton(cornerRadius: 6)
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
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.85))
            .cornerRadius(16)
            .padding(.bottom, 24)
            .padding(.horizontal, 24)
            .animation(.easeInOut(duration: 0.25), value: message)
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
