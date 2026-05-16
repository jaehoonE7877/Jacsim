import SwiftUI
import DSKit
import StoreKit

public struct SettingView: View {
    @Bindable var model: SettingScreenModel
    @Environment(\.requestReview) private var requestReview
    @Environment(\.openURL) private var openURL
    @State private var isWalkThroughPresented = false

    public init(model: SettingScreenModel) {
        self.model = model
    }

    public var body: some View {
        ZStack {
            LinearGradient.wallpaperMorning
                .ignoresSafeArea()
            Color.backgroundNormal.opacity(0.2)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: .jsLG) {
                    header
                    appearanceSection
                    notificationSection
                    socialSection
                    helpSection
                    appInfoSection
                }
                .padding(.horizontal, .jsMD)
                .padding(.top, .jsLG)
                .padding(.bottom, .jsXXL)
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            model.loadNotificationSettings()
        }
        .sheet(isPresented: $isWalkThroughPresented) {
            NavigationStack {
                WalkThroughView(
                    model: WalkThroughModel(fromSetting: true, dependencies: model.dependencies)
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("닫기") {
                            isWalkThroughPresented = false
                        }
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: .jsXS) {
            Text("설정")
                .font(.jsSerifDisplay)
                .foregroundColor(.labelStrong)
            Text("알림, 배경, 앱 정보를 관리합니다")
                .font(.jsBodySmall)
                .foregroundColor(.labelAlternative)
        }
    }

    private var appearanceSection: some View {
        settingsGroup(title: "화면") {
            Picker("테마", selection: Binding(
                get: { model.theme },
                set: { model.themeChanged($0) }
            )) {
                Text("시스템").tag(ThemeMode.system)
                Text("라이트").tag(ThemeMode.light)
                Text("다크").tag(ThemeMode.dark)
            }
            .pickerStyle(.segmented)

            Picker("벽지", selection: Binding(
                get: { model.wallpaperRaw },
                set: { model.wallpaperChanged($0) }
            )) {
                Text("Morning").tag("morning")
                Text("Forest").tag("forest")
                Text("Dusk").tag("dusk")
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("홈 배경 선택")
        }
    }

    private var notificationSection: some View {
        settingsGroup(title: "알림") {
            JSListItem(
                title: "알림 설정",
                subtitle: model.isLoading ? "설정을 반영하는 중" : "매일 작심 리마인드",
                icon: "bell.badge",
                accessory: .toggle(
                    isOn: Binding(
                        get: { model.isNotificationEnabled },
                        set: { model.notificationToggleChanged($0) }
                    )
                )
            )

            if model.notificationPermissionDenied {
                RedesignStateBanner(
                    text: "알림 권한이 꺼져 있어요. iOS 설정에서 알림을 허용한 뒤 다시 켜 주세요.",
                    icon: "bell.slash.fill",
                    tintColor: .cautionary
                )
            }
        }
    }

    private var socialSection: some View {
        settingsGroup(title: "소셜") {
            JSListItem(
                title: "친구 요청",
                subtitle: model.pendingFollowRequests.isEmpty ? "대기 중인 요청 없음" : "\(model.pendingFollowRequests.count)개 대기 중",
                icon: "person.crop.circle.badge.questionmark",
                accessory: .detail("\(model.pendingFollowRequests.count)")
            )

            ForEach(model.pendingFollowRequests) { row in
                HStack(spacing: .jsSM) {
                    VStack(alignment: .leading, spacing: .jsMicro) {
                        Text(row.user.displayName)
                            .font(.jsBodyMedium)
                            .foregroundColor(.labelStrong)
                        Text("@\(row.user.handle)")
                            .font(.jsMonoSmall)
                            .foregroundColor(.labelAlternative)
                    }
                    Spacer()
                    Button("거절") {
                        model.rejectFollowRequest(row)
                    }
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelAlternative)
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(row.user.displayName) 친구 요청 거절")

                    Button("수락") {
                        model.acceptFollowRequest(row)
                    }
                    .font(.jsLabelMedium)
                    .foregroundColor(.backgroundNormal)
                    .padding(.horizontal, .jsSM)
                    .padding(.vertical, .jsXS)
                    .background(Color.forestAccent, in: Capsule())
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(row.user.displayName) 친구 요청 수락")
                }
                .padding(.horizontal, .jsMD)
                .padding(.vertical, .jsXS)
            }
        }
    }

    private var helpSection: some View {
        settingsGroup(title: "도움말") {
            settingAction(title: "사용법", subtitle: "온보딩 다시 보기", icon: "book.pages") {
                isWalkThroughPresented = true
            }

            settingAction(title: "문의하기", subtitle: AppSupport.supportEmail, icon: "envelope") {
                openURL(AppSupport.inquiryMailURL)
            }

            settingAction(title: "리뷰", subtitle: "App Store 리뷰 남기기", icon: "star.bubble") {
                requestReview()
            }

            JSListItem(
                title: "공개/팔로우 설정",
                subtitle: "곧 출시",
                icon: "person.2",
                iconColor: .labelAlternative,
                accessory: .disclosure
            )
            .opacity(0.52)
            .disabled(true)
            .accessibilityLabel("공개 팔로우 설정, 곧 출시")
        }
    }

    private var appInfoSection: some View {
        settingsGroup(title: "앱 정보") {
            JSListItem(
                title: "버전 정보",
                icon: "number",
                accessory: .detail(model.version)
            )

            settingAction(title: "개인정보 처리방침", subtitle: "외부 문서 열기", icon: "hand.raised") {
                openURL(AppSupport.privacyPolicyURL)
            }

            NavigationLink {
                OpenSourceLicenseTextView()
            } label: {
                JSListItem(
                    title: "오픈소스 라이선스",
                    subtitle: "Newsreader, JetBrains Mono OFL",
                    icon: "doc.text",
                    accessory: .disclosure
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func settingsGroup<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            Text(title)
                .font(.jsSerifTitle)
                .foregroundColor(.labelStrong)

            JSGlassCard(accessibilityLabel: "\(title) 설정") {
                VStack(spacing: .jsXS) {
                    content()
                }
            }
        }
    }

    private func settingAction(
        title: String,
        subtitle: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        JSListItem(
            title: title,
            subtitle: subtitle,
            icon: icon,
            accessory: .disclosure,
            action: action
        )
    }
}

private struct OpenSourceLicenseTextView: View {
    private let documents = LicenseDocument.loadAll()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .jsLG) {
                ForEach(documents) { document in
                    VStack(alignment: .leading, spacing: .jsSM) {
                        Text(document.title)
                            .font(.jsSerifTitle)
                            .foregroundColor(.labelStrong)
                        Text(document.body)
                            .font(.jsMonoSmall)
                            .foregroundColor(.labelNeutral)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.jsMD)
        }
        .background(Color.backgroundNormal)
        .navigationTitle("오픈소스 라이선스")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LicenseDocument: Identifiable {
    let id = UUID()
    let title: String
    let body: String

    static func loadAll() -> [LicenseDocument] {
        [
            LicenseDocument(
                title: "Newsreader OFL",
                body: read(resource: "Newsreader-OFL")
            ),
            LicenseDocument(
                title: "JetBrains Mono OFL",
                body: read(resource: "JetBrainsMono-OFL")
            )
        ]
    }

    private static func read(resource: String) -> String {
        let bundle = DSKitResources.bundle
        let candidates = [
            bundle.url(forResource: resource, withExtension: "txt", subdirectory: "Font/Licenses"),
            bundle.url(forResource: resource, withExtension: "txt", subdirectory: "Licenses"),
            bundle.url(forResource: resource, withExtension: "txt")
        ]

        for url in candidates.compactMap({ $0 }) {
            if let text = try? String(contentsOf: url, encoding: .utf8) {
                return text
            }
        }
        return "라이선스 파일을 찾을 수 없습니다."
    }
}

#Preview {
    NavigationStack {
        SettingView(
            model: SettingScreenModel(dependencies: .test)
        )
    }
}

private enum AppSupport {
    static let supportEmail = "sjh7877@naver.com"
    static let privacyPolicyURL = URL(string: "https://sjh7877.tistory.com/19")!

    static var inquiryMailURL: URL {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = supportEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: "작심 앱 문의"),
            URLQueryItem(name: "body", value: "문의 내용을 적어 주세요.\n\n앱 버전: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "2.0.0")")
        ]
        return components.url ?? URL(string: "mailto:\(supportEmail)")!
    }
}
