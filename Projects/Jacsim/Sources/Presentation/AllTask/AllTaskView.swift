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
            VStack(spacing: .jsMD) {
                sectionView(
                    title: "진행중인 작심",
                    tasks: store.ongoingTasks,
                    isExpanded: store.isOngoingExpanded,
                    toggleAction: { store.send(.toggleOngoing) },
                    icon: "circle.fill",
                    iconColor: .primaryNormal
                )
                
                sectionView(
                    title: "성공한 작심",
                    tasks: store.successTasks,
                    isExpanded: store.isSuccessExpanded,
                    toggleAction: { store.send(.toggleSuccess) },
                    icon: "checkmark.circle.fill",
                    iconColor: .positive
                )
                
                sectionView(
                    title: "실패한 작심",
                    tasks: store.failTasks,
                    isExpanded: store.isFailExpanded,
                    toggleAction: { store.send(.toggleFail) },
                    icon: "xmark.circle.fill",
                    iconColor: .destructive
                )
            }
            .padding(.jsMD)
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
        toggleAction: @escaping () -> Void,
        icon: String,
        iconColor: Color
    ) -> some View {
        JSCard(style: .elevated) {
            VStack(spacing: .jsXS) {
                Button(action: toggleAction) {
                    HStack(spacing: .jsSM) {
                        Image(systemName: icon)
                            .foregroundColor(iconColor)
                            .font(.jsLabelSmall)

                        Text(title)
                            .font(.jsHeadlineSmall)
                            .foregroundColor(.labelStrong)

                        Text("\(tasks.count)")
                            .font(.jsLabelMedium)
                            .foregroundColor(.labelAlternative)

                        Spacer()

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.jsButtonSmall)
                            .foregroundColor(.labelNeutral)
                    }
                    .padding(.vertical, .jsXS)
                }
                .jsAccessibility("\(title), \(tasks.count)개의 작심", traits: .isButton)
                
                if isExpanded {
                    VStack(spacing: .jsSM) {
                        ForEach(tasks, id: \.id) { task in
                            taskRow(task: task)
                        }
                    }
                    .padding(.top, .jsXS)
                }
            }
        }
    }

    private func taskRow(task: Domain.Task) -> some View {
        JSListItem(
            title: task.title,
            subtitle: taskDateRange(task),
            accessory: .disclosure
        ) {
            store.send(.taskTapped(task))
        }
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(Color.backgroundAlternative)
        )
    }

    private func taskDateRange(_ task: Domain.Task) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        let start = formatter.string(from: task.startDate)
        let end = formatter.string(from: task.endDate)
        return "\(start) - \(end)"
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
