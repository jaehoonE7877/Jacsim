import DSKit
import SwiftUI

public struct PlusActionSheet: View {
    @Binding private var isPresented: Bool
    private let onCreateTask: () -> Void
    private let onCreateBrag: () -> Void
    private let onComingSoon: () -> Void

    public init(
        isPresented: Binding<Bool>,
        onCreateTask: @escaping () -> Void,
        onCreateBrag: @escaping () -> Void = {},
        onComingSoon: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self.onCreateTask = onCreateTask
        self.onCreateBrag = onCreateBrag
        self.onComingSoon = onComingSoon
    }

    public var body: some View {
        bottomSheet
    }

    private var bottomSheet: some View {
        JSBottomSheet(
            isPresented: $isPresented,
            style: .fixed(height: 390.jsScaled()),
            showDragIndicator: true,
            allowsInteractiveDismiss: true,
            glass: true
        ) {
            VStack(alignment: .leading, spacing: .jsMD) {
                header

                PlusActionCardButton(
                    title: "새 작심 만들기",
                    subtitle: "오늘부터 이어갈 목표를 시작해요",
                    icon: "plus.circle.fill",
                    accessibilityHint: "새 작심 만들기 화면으로 이동합니다",
                    action: onCreateTask
                )

                PlusActionCardButton(
                    title: "자랑 글 쓰기",
                    subtitle: "완주와 연속 기록을 친구들에게 공유해요",
                    icon: "megaphone.fill",
                    accessibilityHint: "자랑 글 쓰기 화면으로 이동합니다",
                    action: onCreateBrag
                )

                PlusActionCardButton(
                    title: "AI 코치 열기",
                    subtitle: "작심 흐름을 보고 다음 행동을 제안받아요",
                    icon: "sparkles",
                    isEnabled: false,
                    accessibilityHint: "아직 사용할 수 없습니다. 탭하면 출시 예정 안내가 표시됩니다",
                    action: onComingSoon
                )
            }
            .padding(.horizontal, .jsLG)
            .padding(.top, .jsXS)
            .padding(.bottom, .jsXL)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: .jsMicro) {
            Text("추가")
                .font(.jsSerifTitle)
                .foregroundStyle(Color.labelStrong)

            Text("지금 필요한 작업을 선택해요")
                .font(.jsBodySmall)
                .foregroundStyle(Color.labelAlternative)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("추가 작업 선택")
    }
}

private struct PlusActionCardButton: View {
    let title: String
    let subtitle: String
    let icon: String
    var isEnabled: Bool = true
    let accessibilityHint: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            cardContent
        }
        .buttonStyle(.plain)
        .disabled(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint)
    }

    private var cardContent: some View {
        JSGlassCard(cornerRadius: 20, accessibilityLabel: title) {
            HStack(spacing: .jsMD) {
                Image(systemName: icon)
                    .font(.jsHeadline20Bold)
                    .foregroundStyle(iconColor)
                    .frame(width: 40.jsScaled(), height: 40.jsScaled())
                    .background(
                        Circle()
                            .fill(iconColor.opacity(isEnabled ? 0.14 : 0.08))
                    )

                VStack(alignment: .leading, spacing: .jsMicro) {
                    Text(title)
                        .font(.jsBodyLarge)
                        .foregroundStyle(titleColor)

                    Text(subtitle)
                        .font(.jsBodySmall)
                        .foregroundStyle(Color.labelAlternative)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: .jsXS)

                Image(systemName: isEnabled ? "chevron.right" : "clock.fill")
                    .font(.jsBodySmall)
                    .foregroundStyle(Color.labelAssistive)
            }
        }
        .accessibilityHidden(true)
    }

    private var iconColor: Color {
        isEnabled ? Color.forestAccent : Color.labelDisable
    }

    private var titleColor: Color {
        isEnabled ? Color.labelStrong : Color.labelAlternative
    }
}

#Preview("PlusActionSheet") {
    PlusActionSheet(isPresented: .constant(true), onCreateTask: {}, onComingSoon: {})
}
