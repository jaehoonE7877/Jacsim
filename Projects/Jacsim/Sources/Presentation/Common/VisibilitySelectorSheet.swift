import SwiftUI
import DSKit
import Domain

struct VisibilitySelectorSheet: View {
    @Binding var selectedVisibility: TaskVisibility
    @Binding var isPresented: Bool
    let onSave: (TaskVisibility) -> Void

    var body: some View {
        JSBottomSheet(
            isPresented: $isPresented,
            style: .contentHeight,
            allowsInteractiveDismiss: true,
            glass: true
        ) {
            VStack(alignment: .leading, spacing: .jsLG) {
                VStack(alignment: .leading, spacing: .jsXS) {
                    Text("공개 범위 변경")
                        .font(.jsSerifTitle)
                        .foregroundColor(.labelStrong)

                    Text("기존 작심은 기본적으로 나만 볼 수 있어요")
                        .font(.jsBodySmall)
                        .foregroundColor(.labelAlternative)
                }

                VStack(spacing: .jsXS) {
                    ForEach(TaskVisibility.allCases, id: \.self) { visibility in
                        Button {
                            selectedVisibility = visibility
                        } label: {
                            HStack(alignment: .top, spacing: .jsSM) {
                                Image(systemName: selectedVisibility == visibility ? "checkmark.circle.fill" : "circle")
                                    .font(.jsHeadlineMedium)
                                    .foregroundColor(selectedVisibility == visibility ? .forestAccent : .labelAlternative)

                                VStack(alignment: .leading, spacing: .jsMicro) {
                                    Text(title(for: visibility))
                                        .font(.jsBodyMedium)
                                        .foregroundColor(.labelStrong)

                                    Text(description(for: visibility))
                                        .font(.jsLabelMedium)
                                        .foregroundColor(.labelAlternative)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer(minLength: .jsXS)
                            }
                            .padding(.jsSM)
                            .background(
                                RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                                    .fill(selectedVisibility == visibility ? Color.forestAccent.opacity(0.12) : Color.surfaceElevated.opacity(0.22))
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(title(for: visibility))
                        .accessibilityHint(description(for: visibility))
                    }
                }

                JSButton(title: "저장", style: .primary, size: .large) {
                    onSave(selectedVisibility)
                }
                .accessibilityLabel("공개 범위 저장")
            }
            .padding(.horizontal, .jsLG)
            .padding(.bottom, .jsLG)
        }
    }

    private func title(for visibility: TaskVisibility) -> String {
        switch visibility {
        case .private:
            return "나만 보기"
        case .followers:
            return "팔로워 공개"
        case .public:
            return "전체 공개"
        }
    }

    private func description(for visibility: TaskVisibility) -> String {
        switch visibility {
        case .private:
            return "작심과 기록을 나만 확인합니다."
        case .followers:
            return "서로 연결된 친구에게 진행 상황을 보여줍니다."
        case .public:
            return "프로필과 공유 화면에서 누구나 볼 수 있습니다."
        }
    }
}
