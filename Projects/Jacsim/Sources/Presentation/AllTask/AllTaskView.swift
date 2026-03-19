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
            subtitle: "지금 어디까지 왔는지 빠르게 확인해요",
            state: screenState
        ) {
            summaryCard

            sectionView(
                kind: .ongoing,
                tasks: store.ongoingTasks,
                isExpanded: store.isOngoingExpanded,
                toggleAction: { store.send(.toggleOngoing) }
            )

            sectionView(
                kind: .success,
                tasks: store.successTasks,
                isExpanded: store.isSuccessExpanded,
                toggleAction: { store.send(.toggleSuccess) }
            )

            sectionView(
                kind: .fail,
                tasks: store.failTasks,
                isExpanded: store.isFailExpanded,
                toggleAction: { store.send(.toggleFail) }
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
                    message: "첫 작심을 만들면 진행 상태가 바로 정리돼요",
                    icon: "square.and.pencil",
                    action: RetryActionModel(title: "새 작심 만들기") {
                        store.send(.createTaskButtonTapped)
                    }
                )
            )
        }

        return .content
    }

    private var summaryCard: some View {
        RedesignSectionCard(
            title: "요약",
            subtitle: "총 \(totalCount)개의 작심을 상태별로 정리했어요"
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
        kind: AllTaskSectionKind,
        tasks: [Domain.Task],
        isExpanded: Bool,
        toggleAction: @escaping () -> Void
    ) -> some View {
        JSCard(style: .elevated, padding: .jsMD) {
            VStack(alignment: .leading, spacing: .jsSM) {
                Button {
                    withAnimation(foldAnimation) {
                        toggleAction()
                    }
                } label: {
                    HStack(spacing: .jsSM) {
                        Image(systemName: kind.icon)
                            .foregroundColor(kind.iconColor)
                            .font(.jsBodySmall)
                            .frame(width: 32.jsScaled(), height: 32.jsScaled())
                            .background(kind.iconColor.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: .jsRadiusSM))

                        VStack(alignment: .leading, spacing: .jsMicro) {
                            Text(kind.title)
                                .font(.jsHeadlineSmall)
                                .foregroundColor(.labelStrong)

                            Text(kind.subtitle)
                                .font(.jsLabelMedium)
                                .foregroundColor(.labelNeutral)
                        }

                        Spacer(minLength: .jsSM)

                        Text("\(tasks.count)")
                            .font(.jsButtonSmall)
                            .foregroundColor(.labelStrong)
                            .padding(.horizontal, .jsSM)
                            .padding(.vertical, .jsMicro)
                            .background(
                                Capsule()
                                    .fill(Color.backgroundAlternative)
                            )

                        Image(systemName: "chevron.down")
                            .font(.jsButtonSmall)
                            .foregroundColor(.labelNeutral)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(foldAnimation, value: isExpanded)
                    }
                    .padding(.vertical, .jsMicro)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel("\(kind.title) 작심 \(tasks.count)개")
                .accessibilityValue(isExpanded ? "펼쳐짐" : "접힘")
                .accessibilityHint(isExpanded ? "두 번 탭해 접습니다" : "두 번 탭해 펼칩니다")

                if isExpanded {
                    VStack(spacing: .jsSM) {
                        if tasks.isEmpty {
                            emptyRow(text: kind.emptyMessage)
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
        reduceMotion ? .linear(duration: 0.12) : JSAnimation.navigation
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
            subtitle: taskSummary(task),
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
                .foregroundColor(.labelAlternative)
            Text(text)
                .font(.jsBodySmall)
                .foregroundColor(.labelNeutral)
            Spacer()
        }
        .padding(.jsSM)
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusSM)
                .fill(Color.backgroundAlternative)
        )
    }

    private func summaryPill(title: String, count: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: .jsMicro) {
            Text(title)
                .font(.jsLabelMedium)
                .foregroundColor(.labelNeutral)
            Text("\(count)")
                .font(.jsHeadlineSmall)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, minHeight: 72.jsScaled(), alignment: .leading)
        .padding(.horizontal, .jsSM)
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

    private func taskSummary(_ task: Domain.Task) -> String {
        "\(taskDateRange(task)) · \(task.completedDays)/\(max(task.dayArray.count, 1))일 완료"
    }
}

private enum AllTaskSectionKind {
    case ongoing
    case success
    case fail

    var title: String {
        switch self {
        case .ongoing:
            return "진행 중"
        case .success:
            return "성공"
        case .fail:
            return "실패"
        }
    }

    var subtitle: String {
        switch self {
        case .ongoing:
            return "지금 이어가는 작심"
        case .success:
            return "끝까지 해낸 작심"
        case .fail:
            return "다시 시작할 수 있는 작심"
        }
    }

    var emptyMessage: String {
        switch self {
        case .ongoing:
            return "진행 중인 작심이 아직 없어요"
        case .success:
            return "성공한 작심이 아직 없어요"
        case .fail:
            return "실패한 작심이 아직 없어요"
        }
    }

    var icon: String {
        switch self {
        case .ongoing:
            return "circle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .fail:
            return "xmark.circle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .ongoing:
            return .primaryNormal
        case .success:
            return .positive
        case .fail:
            return .destructive
        }
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
