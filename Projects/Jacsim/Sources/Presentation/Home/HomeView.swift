import SwiftUI
import ComposableArchitecture
import DSKit

public struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    JSCalendar(
                        selectedDate: $store.selectedDate,
                        scope: store.calendarScope
                    )
                    .onChange(of: store.selectedDate) { oldDate, newDate in
                        store.send(.dateSelected(newDate))
                    }
                    .frame(height: UIScreen.main.bounds.height / 2.8)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    taskListHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    ScrollView {
                        LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                            Section {
                                ForEach(store.tasks, id: \.id) { task in
                                    taskRow(task: task)
                                        .onTapGesture {
                                            store.send(.taskTapped(task))
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 120)
                    }
                }
                
                JSFloatButton(items: [
                    JSFloatButtonItem(
                        title: "새로운 작심",
                        icon: Image(systemName: "pencil"),
                        action: { store.send(.addButtonTapped) }
                    ),
                    JSFloatButtonItem(
                        title: "작심 모아보기",
                        icon: Image(systemName: "list.bullet"),
                        action: { store.send(.allTasksButtonTapped) }
                    )
                ])
                .padding(.bottom, 12)
                .padding(.trailing, 12)
            }
            .background(Color.backgroundNormal)
            .navigationTitle("작심")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { store.send(.settingButtonTapped) }) {
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
        } destination: { store in
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
    }

    private var taskListHeader: some View {
        HStack {
            Text("나의 작심 리스트")
                .font(.pretendardSemiBold(size: 18))
                .foregroundColor(.labelStrong)
            Spacer()
            Button(action: { /* Info logic */ }) {
                Image(systemName: "info.circle")
                .foregroundColor(.labelNeutral)
            }
        }
    }

    private func taskRow(task: UserJacsim) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .strokeBorder(task.isDone ? Color.primaryNormal : Color.labelDisable, lineWidth: 2)
                    .frame(width: 26, height: 26)
                if task.isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.primaryNormal))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.pretendardSemiBold(size: 16))
                    .foregroundColor(task.isDone ? .labelDisable : .labelStrong)
                    .lineLimit(1)
                
                if let alarm = task.alarm {
                    Text(alarm.convertToString(withFormat: .ahhmm))
                        .font(.pretendardRegular(size: 12))
                        .foregroundColor(.labelNeutral)
                }
            }
            Spacer()
            
            if task.isDone {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.primaryNormal)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.labelNeutral)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}
