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

    private var filteredTasks: [Domain.Task] {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: store.selectedDate)
        
        return store.tasks.filter { task in
            let start = calendar.startOfDay(for: task.startDate)
            let end = calendar.startOfDay(for: task.endDate)
            return targetDate >= start && targetDate <= end
        }
    }
    
    private var eventDates: [Date] {
        let calendar = Calendar.current
        var dates = Set<Date>()
        
        for task in store.tasks {
            let start = calendar.startOfDay(for: task.startDate)
            let end = calendar.startOfDay(for: task.endDate)
            
            var currentDate = start
            while currentDate <= end {
                dates.insert(currentDate)
                guard let next = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = next
            }
        }
        return Array(dates)
    }
    
    private var totalCount: Int {
        filteredTasks.count
    }
    
    private var completedCount: Int {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: store.selectedDate)
        
        return filteredTasks.filter { task in
            if let dailyRecord = task.records.first(where: {
                calendar.isDate($0.date, inSameDayAs: targetDate)
            }) {
                return dailyRecord.check
            }
            return false
        }.count
    }
    
    private var progressPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
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
            contentVStack
            floatButtons
            
            if store.isLoading {
                loadingOverlay
            }
        }
        .background(Color.backgroundNormal)
        .navigationTitle("작심")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { 
                    store.send(.settingButtonTapped)
                    triggerTapFeedback()
                }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.labelStrong)
                }
            }
        }
        .onAppear { store.send(.onAppear) }
        .sheet(item: $store.scope(state: \.destination?.newTask, action: \.destination.newTask)) { store in
            NewTaskView(store: store)
        }
        .alert($store.scope(state: \.migrationAlert, action: \.migrationAlert))
        .sensoryFeedback(.selection, trigger: store.selectedDate)
        .sensoryFeedback(.impact(weight: .light), trigger: completedCount)
        .sensoryFeedback(.impact(weight: .light), trigger: tapFeedbackTrigger)
    }
    
    private func triggerTapFeedback() {
        tapFeedbackTrigger += 1
    }
    
    private var contentVStack: some View {
        VStack(spacing: 0) {
            JSCalendar(
                selectedDate: $store.selectedDate,
                scope: store.calendarScope,
                eventDates: eventDates
            )
            .onChange(of: store.selectedDate) {
                store.send(.dateSelected(store.selectedDate))
            }
            .frame(height: UIScreen.main.bounds.height / 2.8)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            taskListHeader
                .padding(.horizontal, 20)
                .padding(.top, 8)
            
            taskListContent
        }
    }
    
    private var floatButtons: some View {
        JSFloatButton(items: [
            JSFloatButtonItem(
                title: "새로운 작심",
                icon: Image(systemName: "pencil"),
                action: { 
                    store.send(.addButtonTapped)
                    triggerTapFeedback()
                }
            ),
            JSFloatButtonItem(
                title: "작심 모아보기",
                icon: Image(systemName: "list.bullet"),
                action: { 
                    store.send(.allTasksButtonTapped)
                    triggerTapFeedback()
                }
            )
        ])
        .padding(.bottom, 12)
        .padding(.trailing, 12)
    }
    
    @ViewBuilder
    private var taskListContent: some View {
        ScrollView {
            if filteredTasks.isEmpty {
                emptyStateView
                    .padding(.top, 60)
            } else {
                LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                    Section {
                        ForEach(filteredTasks, id: \.id) { task in
                            taskRow(task: task)
                                .onTapGesture {
                                    store.send(.taskTapped(task))
                                    triggerTapFeedback()
                                }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 120)
            }
        }
        .refreshable {
            await store.send(.refreshTriggered).finish()
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)
                Text("불러오는 중...")
                    .font(.pretendardMedium(size: 14))
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "square.text.square.fill")
                .font(.system(size: 56))
                .foregroundColor(Color.labelDisable.opacity(0.4))

            VStack(spacing: 8) {
                Text(store.tasks.isEmpty ? "오늘의 작심이 없어요" : "선택한 날짜에 작심이 없어요")
                    .font(.pretendardSemiBold(size: 18))
                    .foregroundColor(.labelStrong)

                Text("새로운 작심을 추가필요가 있으신가요?")
                    .font(.pretendardRegular(size: 14))
                    .foregroundColor(.labelNeutral)
            }

            Button(action: {
                store.send(.addButtonTapped)
                triggerTapFeedback()
            }) {
                Text("작심 추가하기")
                    .font(.pretendardSemiBold(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.primaryNormal)
                            .shadow(
                                color: Color.primaryNormal.opacity(0.35),
                                radius: 10, x: 0, y: 5
                            )
                    )
            }
            .padding(.top, 8)
        }
    }

    private var taskListHeader: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Text("나의 작심 리스트")
                    .font(.pretendardBold(size: 20))
                    .foregroundColor(.labelStrong)

                if totalCount > 0 {
                    Text("\(completedCount)/\(totalCount)")
                        .font(.pretendardSemiBold(size: 13))
                        .foregroundColor(.primaryNormal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.primaryNormal.opacity(0.12))
                        )
                }

                Spacer()
            }

            if totalCount > 0 {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.labelDisable.opacity(0.15))
                            .frame(height: 6)

                        Capsule()
                            .fill(Color.primaryNormal)
                            .frame(width: geometry.size.width * progressPercentage, height: 6)
                            .shadow(
                                color: Color.primaryNormal.opacity(0.3),
                                radius: 4, x: 0, y: 2
                            )
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progressPercentage)
                    }
                }
                .frame(height: 6)
            }
        }
    }

    private func taskRow(task: Domain.Task) -> some View {
        let isCompletedToday = isTaskCompletedToday(task)

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .strokeBorder(
                        isCompletedToday ? Color.primaryNormal : Color.labelDisable.opacity(0.4),
                        lineWidth: 2
                    )
                    .background(
                        Circle()
                            .fill(isCompletedToday ? Color.primaryNormal : Color.clear)
                    )
                    .frame(width: 26, height: 26)

                if isCompletedToday {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.pretendardSemiBold(size: 16))
                    .foregroundColor(isCompletedToday ? .labelDisable : .labelStrong)
                    .lineLimit(1)


            }
            Spacer()

            if isCompletedToday {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.primaryNormal)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.labelNeutral)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(
                    color: Color.black.opacity(0.06),
                    radius: 12, x: 0, y: 4
                )
        )
    }

    private func isTaskCompletedToday(_ task: Domain.Task) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: store.selectedDate)
        
        if let dailyRecord = task.records.first(where: {
            calendar.isDate($0.date, inSameDayAs: targetDate)
        }) {
            return dailyRecord.check
        }
        return false
    }
}
