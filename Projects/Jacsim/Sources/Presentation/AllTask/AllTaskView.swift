import SwiftUI
import ComposableArchitecture
import Domain
import DSKit

public struct AllTaskView: View {
    let store: StoreOf<AllTaskFeature>

    public init(store: StoreOf<AllTaskFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                sectionView(
                    title: "진행중인 작심",
                    tasks: store.ongoingTasks,
                    isExpanded: store.isOngoingExpanded,
                    toggleAction: { store.send(.toggleOngoing) }
                )
                
                sectionView(
                    title: "성공한 작심",
                    tasks: store.successTasks,
                    isExpanded: store.isSuccessExpanded,
                    toggleAction: { store.send(.toggleSuccess) }
                )
                
                sectionView(
                    title: "실패한 작심",
                    tasks: store.failTasks,
                    isExpanded: store.isFailExpanded,
                    toggleAction: { store.send(.toggleFail) }
                )
            }
            .padding(16)
        }
        .background(Color.backgroundNormal)
        .navigationTitle("작심 모아보기")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.send(.onAppear) }
    }

    private func sectionView(
        title: String,
        tasks: [Domain.Task],
        isExpanded: Bool,
        toggleAction: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 8) {
            Button(action: toggleAction) {
                HStack {
                    Text(title)
                        .font(.pretendardSemiBold(size: 18))
                        .foregroundColor(.labelStrong)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.labelNeutral)
                }
                .padding(.vertical, 8)
            }
            
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(tasks, id: \.id) { task in
                        taskRow(task: task)
                    }
                }
            }
        }
    }

    private func taskRow(task: Domain.Task) -> some View {
        HStack {
            Text(task.title)
                .font(.pretendardMedium(size: 16))
                .foregroundColor(.labelNormal)
            Spacer()
        }
        .padding(16)
        .background(Color.backgroundNormal)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onTapGesture {
            store.send(.taskTapped(task))
        }
    }
}

#Preview {
    NavigationStack {
        AllTaskView(
            store: Store(initialState: AllTaskFeature.State()) {
                AllTaskFeature()
            }
        )
    }
}
