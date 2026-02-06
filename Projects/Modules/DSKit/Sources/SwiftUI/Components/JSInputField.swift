import SwiftUI

public struct JSInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let isEnabled: Bool
    let errorMessage: String?

    public init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        isEnabled: Bool = true,
        errorMessage: String? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.isEnabled = isEnabled
        self.errorMessage = errorMessage
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelAlternative)
            }

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.jsBodyMedium)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: .jsCornerSmall)
                    .fill(Color.backgroundNormal)
            )
            .overlay(
                RoundedRectangle(cornerRadius: .jsCornerSmall)
                    .stroke(borderColor, lineWidth: 1)
            )
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1.0 : 0.5)
            .frame(minHeight: 44)

            if let error = errorMessage {
                Text(error)
                    .font(.jsLabelSmall)
                    .foregroundColor(.destructive)
            }
        }
    }

    private var borderColor: Color {
        if errorMessage != nil {
            return .destructive
        }
        return .labelAlternative
    }
}

struct JSInputField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            JSInputField(
                title: "작심 이름",
                placeholder: "예: 매일 30분 운�",
                text: .constant("")
            )

            JSInputField(
                title: "메모",
                placeholder: "메모를 입력하세요",
                text: .constant("테스트 메모"),
                errorMessage: "최대 20자까지 입력 가능합니다"
            )

            JSInputField(
                title: "비밀번호",
                placeholder: "비밀번호 입력",
                text: .constant(""),
                isSecure: true
            )

            JSInputField(
                title: "비활성화",
                placeholder: "입력 불가",
                text: .constant(""),
                isEnabled: false
            )
        }
        .padding()
    }
}
