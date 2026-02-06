import SwiftUI
import DSKit

struct RedesignScreenScaffold<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: .jsLG) {
                header
                content
            }
            .padding(.horizontal, .jsMD)
            .padding(.top, .jsLG)
            .padding(.bottom, .jsXXL)
        }
        .background(Color.backgroundNormal)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: .jsXS) {
            Text(title)
                .font(.jsDisplaySmall)
                .foregroundColor(.labelStrong)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.jsBodySmall)
                    .foregroundColor(.labelAlternative)
            }
        }
    }
}

struct RedesignSectionCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        JSCard(style: .elevated, padding: .jsMD) {
            VStack(alignment: .leading, spacing: .jsSM) {
                VStack(alignment: .leading, spacing: .jsMicro) {
                    Text(title)
                        .font(.jsHeadlineSmall)
                        .foregroundColor(.labelStrong)

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.jsLabelMedium)
                            .foregroundColor(.labelAlternative)
                    }
                }

                content
            }
        }
    }
}

struct RedesignStateBanner: View {
    let text: String
    let icon: String
    let tintColor: Color

    var body: some View {
        HStack(spacing: .jsXS) {
            Image(systemName: icon)
                .foregroundColor(tintColor)

            Text(text)
                .font(.jsBodySmall)
                .foregroundColor(.labelStrong)

            Spacer(minLength: .jsXS)
        }
        .padding(.horizontal, .jsSM)
        .padding(.vertical, .jsXS)
        .background(tintColor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: .jsRadiusSM))
    }
}
