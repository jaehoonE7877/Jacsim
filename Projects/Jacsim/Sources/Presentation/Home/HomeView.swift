import SwiftUI
import ComposableArchitecture
import Domain
import DSKit

public struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    @State private var tapFeedbackTrigger = 0

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    private var activeTasks: [Domain.Task] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return store.tasks.filter { task in
            let end = calendar.startOfDay(for: task.endDate)
            return today <= end
        }.sorted { $0.startDate > $1.startDate }
    }

    private var heroTask: Domain.Task? {
        activeTasks.first
    }

    private var remainingTasks: [Domain.Task] {
        Array(activeTasks.dropFirst())
    }

    private var miniCardData: [JSMiniCardData] {
        remainingTasks.map { task in
            let completedDays = task.records.filter { $0.check }.count
            let totalDays = task.dayArray.count
            let progress = totalDays > 0 ? Double(completedDays) / Double(totalDays) : 0

            return JSMiniCardData(
                title: task.title,
                progress: progress,
                totalDays: totalDays,
                completedDays: completedDays
            )
        }
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
        ZStack(alignment: .bottomTrailing) {
            Color.backgroundNormal.ignoresSafeArea()
            
            contentVStack
            
            Button(action: {
                store.send(.addButtonTapped)
                triggerTapFeedback()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.primaryNormal)
                    .clipShape(Circle())
                    .shadow(color: .primaryNormal.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)

            if store.isLoading {
                loadingOverlay
            }
        }
        .navigationBarHidden(true)
        .onAppear { store.send(.onAppear) }
        .sheet(item: $store.scope(state: \.destination?.challengeCreate, action: \.destination.challengeCreate)) { store in
            ChallengeCreateView(store: store)
        }
        .alert($store.scope(state: \.migrationAlert, action: \.migrationAlert))
        .sensoryFeedback(.impact(weight: .light), trigger: tapFeedbackTrigger)
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

                if let heroTask = heroTask {
                    VStack(alignment: .leading, spacing: 16) {
                        JSGlassHeroCard(
                            title: heroTask.title,
                            subtitle: "\(heroTask.startDate.formatted(.dateTime.month().day())) ~ \(heroTask.endDate.formatted(.dateTime.month().day()))",
                            progress: calculateProgress(for: heroTask),
                            totalDays: heroTask.dayArray.count,
                            completedDays: heroTask.records.filter { $0.check }.count,
                            isTodayCertified: isTaskCompletedToday(heroTask),
                            onTap: {
                                store.send(.taskTapped(heroTask))
                                triggerTapFeedback()
                            }
                        )
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
                                    Text("전체보기")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.labelAlternative)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            JSMiniCardCarousel(
                                cards: miniCardData,
                                onCardTap: { index in
                                    let task = remainingTasks[index]
                                    store.send(.taskTapped(task))
                                    triggerTapFeedback()
                                }
                            )
                            .padding(.horizontal, -24)
                        }
                    }
                } else {
                    emptyStateView
                        .padding(.top, 40)
                        .padding(.horizontal, 24)
                }
                
                Spacer(minLength: 100)
            }
            .padding(.bottom, 20)
        }
    }

    private func calculateProgress(for task: Domain.Task) -> Double {
        let completed = task.records.filter { $0.check }.count
        let total = task.dayArray.count
        return total > 0 ? Double(completed) / Double(total) : 0
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                Text("불러오는 중...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.jsXL)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
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
