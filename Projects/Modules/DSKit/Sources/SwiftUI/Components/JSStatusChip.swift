import SwiftUI

public enum JSStatusChipState {
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
            return Color.green.opacity(0.12)
        case .pending:
            return Color.blue.opacity(0.12)
        case .failed:
            return Color.red.opacity(0.12)
        case .notStarted:
            return Color.gray.opacity(0.12)
        }
    }

    var foregroundColor: Color {
        switch self {
        case .completed:
            return Color.green
        case .pending:
            return Color.blue
        case .failed:
            return Color.red
        case .notStarted:
            return Color.gray
        }
    }
}

public struct JSStatusChip: View {
    let state: JSStatusChipState
    let count: Int?
    let onTap: (() -> Void)?

    public init(
        state: JSStatusChipState,
        count: Int? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.state = state
        self.count = count
        self.onTap = onTap
    }

    public var body: some View {
        let content = HStack(spacing: 6) {
            Image(systemName: state.icon)
                .font(.system(size: 14, weight: .medium))

            Text(displayTitle)
                .font(.system(size: 13, weight: .medium))

            if let count = count {
                Text("\(count)")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(state.foregroundColor.opacity(0.2))
                    )
            }
        }
        .foregroundColor(state.foregroundColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(state.backgroundColor)
        )

        if let onTap = onTap {
            Button(action: onTap) {
                content
            }
            .buttonStyle(PlainButtonStyle())
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
        } else {
            content
        }
    }

    private var displayTitle: String {
        state.title
    }
}

public struct JSStatusChipGroup: View {
    let completedCount: Int
    let pendingCount: Int
    let failedCount: Int
    let onChipTap: (JSStatusChipState) -> Void

    public init(
        completedCount: Int,
        pendingCount: Int,
        failedCount: Int,
        onChipTap: @escaping (JSStatusChipState) -> Void
    ) {
        self.completedCount = completedCount
        self.pendingCount = pendingCount
        self.failedCount = failedCount
        self.onChipTap = onChipTap
    }

    public var body: some View {
        HStack(spacing: 8) {
            if completedCount > 0 {
                JSStatusChip(
                    state: .completed,
                    count: completedCount,
                    onTap: { onChipTap(.completed) }
                )
            }

            if pendingCount > 0 {
                JSStatusChip(
                    state: .pending,
                    count: pendingCount,
                    onTap: { onChipTap(.pending) }
                )
            }

            if failedCount > 0 {
                JSStatusChip(
                    state: .failed,
                    count: failedCount,
                    onTap: { onChipTap(.failed) }
                )
            }

            if completedCount == 0 && pendingCount == 0 && failedCount == 0 {
                JSStatusChip(state: .notStarted)
            }
        }
    }
}

struct JSStatusChip_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Individual Chips")
                        .font(.system(size: 18, weight: .semibold))

                    HStack(spacing: 8) {
                        JSStatusChip(state: .completed)
                        JSStatusChip(state: .pending)
                        JSStatusChip(state: .failed)
                        JSStatusChip(state: .notStarted)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("With Count")
                        .font(.system(size: 18, weight: .semibold))

                    HStack(spacing: 8) {
                        JSStatusChip(state: .completed, count: 3)
                        JSStatusChip(state: .pending, count: 2)
                        JSStatusChip(state: .failed, count: 1)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Chip Group")
                        .font(.system(size: 18, weight: .semibold))

                    JSStatusChipGroup(
                        completedCount: 2,
                        pendingCount: 1,
                        failedCount: 0,
                        onChipTap: { state in
                            print("Tapped: \(state)")
                        }
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Empty State")
                        .font(.system(size: 18, weight: .semibold))

                    JSStatusChipGroup(
                        completedCount: 0,
                        pendingCount: 0,
                        failedCount: 0,
                        onChipTap: { _ in }
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Tappable Chips")
                        .font(.system(size: 18, weight: .semibold))

                    HStack(spacing: 8) {
                        JSStatusChip(state: .completed, count: 5) {
                            print("Completed tapped")
                        }

                        JSStatusChip(state: .pending, count: 2) {
                            print("Pending tapped")
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}
