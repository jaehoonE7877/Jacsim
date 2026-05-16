import SwiftUI
import DSKit

enum TaskStatusChipState {
    case completed
    case pending
    case failed
    case notStarted

    var icon: String {
        switch self {
        case .completed:
            return "checkmark.circle.fill"
        case .pending:
            return "clock.fill"
        case .failed:
            return "xmark.circle.fill"
        case .notStarted:
            return "circle"
        }
    }

    var title: String {
        switch self {
        case .completed:
            return "인증 완료"
        case .pending:
            return "인증 대기"
        case .failed:
            return "인증 실패"
        case .notStarted:
            return "시작 전"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .completed:
            return .positive.opacity(0.12)
        case .pending:
            return .primaryNormal.opacity(0.12)
        case .failed:
            return .destructive.opacity(0.12)
        case .notStarted:
            return .labelNeutral.opacity(0.12)
        }
    }

    var foregroundColor: Color {
        switch self {
        case .completed:
            return .positive
        case .pending:
            return .primaryNormal
        case .failed:
            return .destructive
        case .notStarted:
            return .labelNeutral
        }
    }
}

struct TaskStatusChip: View {
    let state: TaskStatusChipState
    let count: Int?
    let onTap: (() -> Void)?

    init(
        state: TaskStatusChipState,
        count: Int? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.state = state
        self.count = count
        self.onTap = onTap
    }

    var body: some View {
        let content = HStack(spacing: 6.jsScaled()) {
            Image(systemName: state.icon)
                .font(.jsButtonSmall)

            Text(state.title)
                .font(.jsLabel12Medium)

            if let count {
                Text("\(count)")
                    .font(.jsLabel10Regular)
                    .padding(.horizontal, 6.jsScaled())
                    .padding(.vertical, 2.jsScaled())
                    .background(
                        Capsule()
                            .fill(state.foregroundColor.opacity(0.2))
                    )
            }
        }
        .foregroundColor(state.foregroundColor)
        .padding(.horizontal, 12.jsScaled())
        .padding(.vertical, 6.jsScaled())
        .background(
            Capsule()
                .fill(state.backgroundColor)
        )

        if let onTap {
            Button(action: onTap) {
                content
            }
            .buttonStyle(.plain)
            .frame(minWidth: 44.jsScaled(.touchTarget), minHeight: 44.jsScaled(.touchTarget))
            .contentShape(Rectangle())
        } else {
            content
        }
    }
}
