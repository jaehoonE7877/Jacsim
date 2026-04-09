import SwiftUI
import DesignSystem

enum RedesignScreenState {
    case content
    case loading(message: String = "화면 정보를 불러오는 중이에요")
    case empty(RedesignEmptyStateModel)
    case error(RedesignErrorStateModel)
}

struct RetryActionModel {
    let title: String
    let action: () -> Void

    init(title: String = "다시 시도", action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

struct InlineErrorModel {
    let message: String
    let icon: String
    let retry: RetryActionModel?

    init(
        message: String,
        icon: String = "exclamationmark.circle.fill",
        retry: RetryActionModel? = nil
    ) {
        self.message = message
        self.icon = icon
        self.retry = retry
    }
}

struct RedesignEmptyStateModel {
    let title: String
    let message: String
    let icon: String
    let action: RetryActionModel?

    init(
        title: String,
        message: String,
        icon: String = "tray",
        action: RetryActionModel? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.action = action
    }
}

struct RedesignErrorStateModel {
    let title: String
    let message: String
    let icon: String
    let retry: RetryActionModel?

    init(
        title: String,
        message: String,
        icon: String = "exclamationmark.triangle.fill",
        retry: RetryActionModel? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.retry = retry
    }
}

struct RedesignScreenScaffold<Content: View>: View {
    let title: String
    let subtitle: String?
    let state: RedesignScreenState
    let contentBottomInset: CGFloat
    let scrollToID: AnyHashable?
    let scrollAnchor: UnitPoint
    let scrollRequestToken: Int
    let scrollAnimation: Animation?
    let content: Content
    private let stickyFooter: AnyView?
    @State private var stickyFooterHeight: CGFloat = 0

    init(
        title: String,
        subtitle: String? = nil,
        state: RedesignScreenState = .content,
        contentBottomInset: CGFloat = .jsXXL,
        scrollToID: AnyHashable? = nil,
        scrollAnchor: UnitPoint = .top,
        scrollRequestToken: Int = 0,
        scrollAnimation: Animation? = JSAnimation.navigation,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.state = state
        self.contentBottomInset = contentBottomInset
        self.scrollToID = scrollToID
        self.scrollAnchor = scrollAnchor
        self.scrollRequestToken = scrollRequestToken
        self.scrollAnimation = scrollAnimation
        self.content = content()
        self.stickyFooter = nil
    }

    init<StickyFooter: View>(
        title: String,
        subtitle: String? = nil,
        state: RedesignScreenState = .content,
        contentBottomInset: CGFloat = 132.jsScaled(),
        scrollToID: AnyHashable? = nil,
        scrollAnchor: UnitPoint = .top,
        scrollRequestToken: Int = 0,
        scrollAnimation: Animation? = JSAnimation.navigation,
        @ViewBuilder stickyFooter: () -> StickyFooter,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.state = state
        self.contentBottomInset = contentBottomInset
        self.scrollToID = scrollToID
        self.scrollAnchor = scrollAnchor
        self.scrollRequestToken = scrollRequestToken
        self.scrollAnimation = scrollAnimation
        self.content = content()
        self.stickyFooter = AnyView(stickyFooter())
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: .jsXL) {
                    header
                    stateContent
                }
                .padding(.horizontal, .jsMD)
                .padding(.top, .jsLG)
                .padding(.bottom, contentBottomInset + stickyFooterHeight)
            }
            .background(Color.backgroundNormal)
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: scrollToID) { _, newValue in
                guard scrollRequestToken == 0 else { return }
                scroll(proxy: proxy, target: newValue)
            }
            .onChange(of: scrollRequestToken) { _, _ in
                scroll(proxy: proxy, target: scrollToID)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let stickyFooter {
                stickyFooter
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(
                                    key: StickyFooterHeightPreferenceKey.self,
                                    value: proxy.size.height
                                )
                        }
                    )
                    .frame(maxWidth: .infinity, alignment: .bottom)
            }
        }
        .onPreferenceChange(StickyFooterHeightPreferenceKey.self) { stickyFooterHeight = $0 }
    }

    @ViewBuilder
    private var stateContent: some View {
        switch state {
        case .content:
            content
        case let .loading(message):
            RedesignSectionCard(title: "불러오는 중") {
                HStack(spacing: .jsSM) {
                    ProgressView()
                        .tint(.primaryNormal)
                    Text(message)
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelNormal)
                    Spacer(minLength: .jsXS)
                }
            }
        case let .empty(model):
            RedesignEmptyStateView(model: model)
        case let .error(model):
            RedesignErrorStateView(model: model)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: .jsXS) {
            Text(title)
                .font(.jsDisplaySmall)
                .foregroundColor(.labelStrong)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.jsBodySmall)
                    .foregroundColor(.labelNeutral)
            }
        }
    }

    private func scroll(proxy: ScrollViewProxy, target: AnyHashable?) {
        guard let target else { return }

        if let scrollAnimation {
            withAnimation(scrollAnimation) {
                proxy.scrollTo(target, anchor: scrollAnchor)
            }
        } else {
            proxy.scrollTo(target, anchor: scrollAnchor)
        }
    }
}

private struct StickyFooterHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
                            .foregroundColor(.labelNeutral)
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
        .overlay(
            RoundedRectangle(cornerRadius: .jsRadiusSM)
                .stroke(tintColor.opacity(0.18), lineWidth: 1)
        )
    }
}

struct RedesignInlineErrorView: View {
    let model: InlineErrorModel

    var body: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            RedesignStateBanner(
                text: model.message,
                icon: model.icon,
                tintColor: .destructive
            )

            if let retry = model.retry {
                RedesignRetryActionBar(model: retry)
            }
        }
    }
}

struct RedesignRetryActionBar: View {
    let model: RetryActionModel

    var body: some View {
        JSButton(
            title: model.title,
            style: .secondary,
            size: .medium,
            action: model.action
        )
    }
}

private struct RedesignEmptyStateView: View {
    let model: RedesignEmptyStateModel

    var body: some View {
        RedesignSectionCard(title: model.title, subtitle: model.message) {
            VStack(spacing: .jsMD) {
                Image(systemName: model.icon)
                    .font(.jsDisplaySmall)
                    .foregroundColor(.labelAlternative)

                if let action = model.action {
                    RedesignRetryActionBar(model: action)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .jsSM)
            .jsAccessibility("\(model.title), \(model.message)")
        }
    }
}

private struct RedesignErrorStateView: View {
    let model: RedesignErrorStateModel

    var body: some View {
        RedesignSectionCard(title: model.title, subtitle: model.message) {
            VStack(spacing: .jsMD) {
                Image(systemName: model.icon)
                    .font(.jsDisplaySmall)
                    .foregroundColor(.destructive)

                if let retry = model.retry {
                    RedesignRetryActionBar(model: retry)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .jsSM)
            .jsAccessibility("\(model.title), \(model.message)")
        }
    }
}
