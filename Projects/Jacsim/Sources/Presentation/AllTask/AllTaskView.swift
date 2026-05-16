import SwiftUI
import Domain
import DSKit

public struct AllTaskView: View {
    var model: AllTaskModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(model: AllTaskModel) {
        self.model = model
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "전체 작심",
            state: screenState
        ) {
            if PresentationRedesignFlags.isEnabled(.allTask) &&
                PresentationRedesignFlags.isSectionEnabled(.allTaskSummary) {
                summaryCard
            }

            sectionView(
                title: "진행 중",
                tasks: model.ongoingTasks,
                isExpanded: model.isOngoingExpanded,
                toggleAction: model.toggleOngoing,
                icon: "circle.fill",
                iconColor: .primaryNormal
            )

            sectionView(
                title: "성공",
                tasks: model.successTasks,
                isExpanded: model.isSuccessExpanded,
                toggleAction: model.toggleSuccess,
                icon: "checkmark.circle.fill",
                iconColor: .positive
            )

            sectionView(
                title: "실패",
                tasks: model.failTasks,
                isExpanded: model.isFailExpanded,
                toggleAction: model.toggleFail,
                icon: "xmark.circle.fill",
                iconColor: .destructive
            )
        }
        .navigationTitle("작심 모아보기")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { model.loadTasks() }
    }

    private var screenState: RedesignScreenState {
        if model.isLoading {
            return .loading(message: "작심을 불러오는 중")
        }

        if model.loadFailed {
            return .error(
                RedesignErrorStateModel(
                    title: "작심을 불러오지 못했어요",
                    message: "다시 시도해 주세요",
                    retry: RetryActionModel {
                        model.loadTasks()
                    }
                )
            )
        }

        if totalCount == 0 {
            return .empty(
                RedesignEmptyStateModel(
                    title: "아직 작심이 없어요",
                    message: "첫 작심을 시작해 보세요",
                    icon: "square.and.pencil"
                )
            )
        }

        return .content
    }

    private var summaryCard: some View {
        RedesignSectionCard(title: "흐름") {
            HStack(spacing: .jsSM) {
                JSV2MetricPill(
                    title: "진행",
                    value: "\(model.ongoingTasks.count)",
                    systemImage: "circle.fill",
                    style: .accent
                )
                JSV2MetricPill(
                    title: "성공",
                    value: "\(model.successTasks.count)",
                    systemImage: "checkmark.circle.fill",
                    style: .success
                )
                JSV2MetricPill(
                    title: "실패",
                    value: "\(model.failTasks.count)",
                    systemImage: "xmark.circle.fill",
                    style: .danger
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

                        Text(isExpanded ? "접기" : "보기")
                            .font(.jsButtonSmall)
                            .foregroundColor(.v2BrandBlue)

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
        Button {
            model.taskTapped(task)
        }
        label: {
            HStack(spacing: .jsSM) {
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 18.jsScaled(), style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: statusGradientColors(task),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image(systemName: statusIcon(task))
                        .font(.jsHeadlineMedium)
                        .foregroundColor(.white)
                        .padding(.jsSM)
                }
                .frame(width: 86.jsScaled(), height: 86.jsScaled())
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: .jsXS) {
                    Text(task.title)
                        .font(.jsHeadlineSmall)
                        .foregroundColor(.labelStrong)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(taskDateRange(task))
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelAlternative)
                        .lineLimit(1)

                    JSV2StatusChip(
                        statusTitle(task),
                        systemImage: statusIcon(task),
                        style: statusStyle(task)
                    )
                }

                Spacer(minLength: .jsXS)

                Image(systemName: "chevron.right")
                    .font(.jsButtonSmall)
                    .foregroundColor(.labelNeutral)
            }
            .padding(.jsSM)
            .jsv2CardSurface(cornerRadius: 20.jsScaled(), shadowOpacity: 0.05)
            .contentShape(RoundedRectangle(cornerRadius: 20.jsScaled(), style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(task.title), \(statusTitle(task)), \(taskDateRange(task))")
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
                .fill(Color.v2Surface)
        )
    }

    private var totalCount: Int {
        model.ongoingTasks.count + model.successTasks.count + model.failTasks.count
    }

    private func statusStyle(_ task: Domain.Task) -> JSV2StatusStyle {
        if model.successTasks.contains(where: { $0.id == task.id }) {
            return .success
        }
        if model.failTasks.contains(where: { $0.id == task.id }) {
            return .danger
        }
        return .accent
    }

    private func statusTitle(_ task: Domain.Task) -> String {
        if model.successTasks.contains(where: { $0.id == task.id }) {
            return "성공"
        }
        if model.failTasks.contains(where: { $0.id == task.id }) {
            return "실패"
        }
        return "진행 중"
    }

    private func statusIcon(_ task: Domain.Task) -> String {
        if model.successTasks.contains(where: { $0.id == task.id }) {
            return "checkmark.circle.fill"
        }
        if model.failTasks.contains(where: { $0.id == task.id }) {
            return "xmark.circle.fill"
        }
        return "circle.fill"
    }

    private func statusGradientColors(_ task: Domain.Task) -> [Color] {
        switch statusStyle(task) {
        case .success:
            return [Color.positive.opacity(0.86), Color.v2BrandBlue.opacity(0.78)]
        case .danger:
            return [Color.destructive.opacity(0.84), Color.cautionary.opacity(0.68)]
        case .accent, .warning, .neutral:
            return [Color.v2BrandBlue.opacity(0.86), Color.v2BrandBlueStrong.opacity(0.82)]
        }
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
            model: AllTaskModel(dependencies: .test)
        )
    }
}
