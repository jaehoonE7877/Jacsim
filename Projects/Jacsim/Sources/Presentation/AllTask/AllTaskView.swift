import SwiftUI
import ComposableArchitecture
import Domain
import DesignSystem

public struct AllTaskView: View {
    let store: StoreOf<AllTaskFeature>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(store: StoreOf<AllTaskFeature>) {
        self.store = store
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "작심 모아보기",
            subtitle: "진행 상태별로 모든 작심을 확인해요",
            state: screenState
        ) {
            summaryCard

            sectionView(
                title: "진행 중",
                tasks: store.ongoingTasks,
                isExpanded: store.isOngoingExpanded,
                toggleAction: { store.send(.toggleOngoing) },
                icon: "circle.fill",
                iconColor: .primaryNormal
            )

            sectionView(
                title: "성공",
                tasks: store.successTasks,
                isExpanded: store.isSuccessExpanded,
                toggleAction: { store.send(.toggleSuccess) },
                icon: "checkmark.circle.fill",
                iconColor: .positive
            )

            sectionView(
                title: "실패",
                tasks: store.failTasks,
                isExpanded: store.isFailExpanded,
                toggleAction: { store.send(.toggleFail) },
                icon: "xmark.circle.fill",
                iconColor: .destructive
            )
        }
        .navigationTitle("작심 모아보기")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.send(.onAppear) }
    }

    private var screenState: RedesignScreenState {
        if store.isLoading {
            return .loading(message: "작심 목록을 불러오는 중이에요")
        }

        if store.loadFailed {
            return .error(
                RedesignErrorStateModel(
                    title: "작심 목록을 불러오지 못했어요",
                    message: "네트워크 상태를 확인하고 다시 시도해 주세요",
                    retry: RetryActionModel {
                        store.send(.onAppear)
                    }
                )
            )
        }

        if totalCount == 0 {
            return .empty(
                RedesignEmptyStateModel(
                    title: "아직 작심이 없어요",
                    message: "첫 작심을 만들면 진행 상태가 여기에 표시돼요",
                    icon: "square.and.pencil"
                )
            )
        }

        return .content
    }

    private var summaryCard: some View {
        RedesignSectionCard(
            title: "요약",
            subtitle: "총 \(totalCount)개의 작심을 기록 중이에요"
        ) {
            HStack(spacing: .jsSM) {
                summaryPill(
                    title: "진행",
                    count: store.ongoingTasks.count,
                    color: .primaryNormal
                )
                summaryPill(
                    title: "성공",
                    count: store.successTasks.count,
                    color: .positive
                )
                summaryPill(
                    title: "실패",
                    count: store.failTasks.count,
                    color: .destructive
                )
            }
        }
    }

    private func sectionView(
        title: String,
        tasks: [Domain.Task],
        isExpanded: Bool,
        toggleAction: @escaping () -> Void,
        icon: String,
        iconColor: Color
    ) -> some View {
        RedesignSectionCard(
            title: title,
            subtitle: "\(tasks.count)개"
        ) {
            VStack(spacing: .jsXS) {
                Button {
                    withAnimation(foldAnimation) {
                        toggleAction()
                    }
                } label: {
                    HStack(spacing: .jsSM) {
                        Image(systemName: icon)
                            .foregroundColor(iconColor)
                            .font(.jsLabelSmall)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.jsButtonSmall)
                            .foregroundColor(.labelNeutral)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(foldAnimation, value: isExpanded)
                    }
                    .padding(.vertical, .jsXS)
                }
                .jsAccessibility("\(title), \(tasks.count)개의 작심", traits: .isButton)

                if isExpanded {
                    VStack(spacing: .jsSM) {
                        if tasks.isEmpty {
                            emptyRow(text: "\(title) 작심이 아직 없어요")
                        } else {
                            ForEach(tasks, id: \.id) { task in
                                taskRow(task: task)
                            }
                        }
                    }
                    .padding(.top, .jsXS)
                    .clipped()
                    .transition(foldTransition)
                }
            }
        }
    }

    private var foldAnimation: Animation {
        reduceMotion ? .linear(duration: 0.12) : .easeInOut(duration: 0.24)
    }

    private var foldTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }

        return .asymmetric(
            insertion: .modifier(
                active: FoldTransitionModifier(opacity: 0.0, scaleY: 0.96, yOffset: -8),
                identity: FoldTransitionModifier(opacity: 1.0, scaleY: 1.0, yOffset: 0)
            ),
            removal: .modifier(
                active: FoldTransitionModifier(opacity: 0.0, scaleY: 0.96, yOffset: -8),
                identity: FoldTransitionModifier(opacity: 1.0, scaleY: 1.0, yOffset: 0)
            )
        )
    }

    private func taskRow(task: Domain.Task) -> some View {
        JSListItem(
            title: task.title,
            subtitle: taskDateRange(task),
            icon: "flag.fill",
            iconColor: statusColor(task),
            accessory: .disclosure
        ) {
            store.send(.taskTapped(task))
        }
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(Color.backgroundAlternative)
        )
    }

    private func emptyRow(text: String) -> some View {
        HStack(spacing: .jsXS) {
            Image(systemName: "tray")
                .foregroundColor(.labelAssistive)
            Text(text)
                .font(.jsBodySmall)
                .foregroundColor(.labelAlternative)
            Spacer()
        }
        .padding(.jsSM)
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusSM)
                .fill(Color.backgroundAlternative)
        )
    }

    private func summaryPill(title: String, count: Int, color: Color) -> some View {
        VStack(spacing: .jsMicro) {
            Text(title)
                .font(.jsLabelMedium)
                .foregroundColor(.labelAlternative)
            Text("\(count)")
                .font(.jsHeadlineSmall)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, minHeight: 72.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(color.opacity(0.1))
        )
    }

    private var totalCount: Int {
        store.ongoingTasks.count + store.successTasks.count + store.failTasks.count
    }

    private func statusColor(_ task: Domain.Task) -> Color {
        if store.successTasks.contains(where: { $0.id == task.id }) {
            return .positive
        }
        if store.failTasks.contains(where: { $0.id == task.id }) {
            return .destructive
        }
        return .primaryNormal
    }

    private func taskDateRange(_ task: Domain.Task) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        let start = formatter.string(from: task.startDate)
        let end = formatter.string(from: task.endDate)
        return "\(start) - \(end)"
    }
}

private struct FoldTransitionModifier: ViewModifier {
    let opacity: CGFloat
    let scaleY: CGFloat
    let yOffset: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .scaleEffect(x: 1.0, y: scaleY, anchor: .top)
            .offset(y: yOffset)
            .clipped()
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
