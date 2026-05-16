import DSKit
import SwiftUI

public struct PlusActionSheet: View {
    @Binding private var isPresented: Bool
    private let onCreateTask: () -> Void
    @State private var toastText: String?
    @State private var isToastPresented = false

    public init(
        isPresented: Binding<Bool>,
        onCreateTask: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self.onCreateTask = onCreateTask
    }

    public var body: some View {
        JSBottomSheet(
            isPresented: $isPresented,
            style: .contentHeight,
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
                    isEnabled: false,
                    accessibilityHint: "아직 사용할 수 없습니다. 탭하면 출시 예정 안내가 표시됩니다",
                    action: showComingSoonToast
                )

                PlusActionCardButton(
                    title: "AI 코치 열기",
                    subtitle: "작심 흐름을 보고 다음 행동을 제안받아요",
                    icon: "sparkles",
                    isEnabled: false,
                    accessibilityHint: "아직 사용할 수 없습니다. 탭하면 출시 예정 안내가 표시됩니다",
                    action: showComingSoonToast
                )
            }
            .padding(.horizontal, .jsLG)
            .padding(.top, .jsXS)
            .padding(.bottom, .jsXL)
        }
        .jsGlassToast(text: $toastText, isPresented: $isToastPresented)
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

    private func showComingSoonToast() {
        toastText = "곧 출시"
        isToastPresented = true
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
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .overlay {
            if !isEnabled {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.clear)
                    .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .onTapGesture(perform: action)
            }
        }
        .opacity(isEnabled ? 1 : 0.62)
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint)
        .accessibilityValue(isEnabled ? "" : "비활성")
    }

    private var iconColor: Color {
        isEnabled ? Color.forestAccent : Color.labelDisable
    }

    private var titleColor: Color {
        isEnabled ? Color.labelStrong : Color.labelAlternative
    }
}

#Preview("PlusActionSheet") {
    PlusActionSheet(isPresented: .constant(true), onCreateTask: {})
}
