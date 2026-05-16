import SwiftUI

public struct JSGlassSearchField: View {
    @Binding private var text: String
    private let placeholder: String
    private let accessibilityLabel: String

    public init(
        text: Binding<String>,
        placeholder: String = "검색",
        accessibilityLabel: String = "Liquid Glass search field"
    ) {
        self._text = text
        self.placeholder = placeholder
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        HStack(spacing: .jsSM) {
            Image(systemName: "magnifyingglass")
                .font(.jsBodyMedium)
                .foregroundStyle(Color.labelAlternative)
            TextField(placeholder, text: $text)
                .font(.jsBodyMedium)
                .foregroundStyle(Color.labelNormal)
                .textInputAutocapitalization(.never)
                .accessibilityLabel(accessibilityLabel)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.jsBodyMedium)
                        .foregroundStyle(Color.labelAssistive)
                }
                .accessibilityLabel("검색어 지우기")
            }
        }
        .frame(height: 44)
        .padding(.horizontal, .jsMD)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

private struct JSGlassSearchFieldPreview: View {
    @State private var text = "친구"

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.wallpaperMorning
                    .ignoresSafeArea()
                JSGlassSearchField(text: $text, placeholder: "친구 검색")
                    .padding(.jsXL)
            }
            .navigationTitle("검색")
        }
    }
}

#Preview("JSGlassSearchField - Light") {
    JSGlassSearchFieldPreview()
        .preferredColorScheme(.light)
}

#Preview("JSGlassSearchField - Dark") {
    JSGlassSearchFieldPreview()
        .preferredColorScheme(.dark)
}

#Preview("JSGlassSearchField - Accessibility") {
    JSGlassSearchFieldPreview()
        .dynamicTypeSize(.accessibility3)
}
