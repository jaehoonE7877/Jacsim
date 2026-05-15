import SwiftUI
import DSKit
import AcknowList
import StoreKit

public struct SettingView: View {
     var model: SettingScreenModel
    @Environment(\.requestReview) private var requestReview
    @Environment(\.openURL) private var openURL
    @State private var isWalkThroughPresented = false
    @State private var isLicencePresented = false

    public init(model: SettingScreenModel) {
        self.model = model
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "설정",
            subtitle: "테마와 알림, 앱 정보를 관리해요"
        ) {
            RedesignSectionCard(title: "테마") {
                Picker("테마", selection: Binding(
                    get: { model.theme },
                    set: { model.themeChanged($0) }
                )) {
                    Text("시스템").tag(ThemeMode.system)
                    Text("라이트").tag(ThemeMode.light)
                    Text("다크").tag(ThemeMode.dark)
                }
                .pickerStyle(.segmented)
            }

            RedesignSectionCard(
                title: "알림",
                subtitle: "매일 작심 알림을 받을 수 있어요"
            ) {
                Toggle(
                    "알림 설정",
                    isOn: Binding(
                        get: { model.isNotificationEnabled },
                        set: { model.notificationToggleChanged($0) }
                    )
                )
                .font(.jsBodyMedium)
                .foregroundColor(.labelNormal)

                if model.isLoading {
                    RedesignStateBanner(
                        text: "알림 설정을 반영하는 중이에요",
                        icon: "clock.arrow.circlepath",
                        tintColor: .primaryNormal
                    )
                }

                if model.notificationPermissionDenied {
                    RedesignStateBanner(
                        text: "알림 권한이 꺼져 있어요. iOS 설정에서 알림을 허용한 뒤 다시 켜 주세요.",
                        icon: "bell.slash.fill",
                        tintColor: .cautionary
                    )
                }
            }

            RedesignSectionCard(title: "도움말") {
                actionRow(title: "사용법", systemImage: "book.pages") {
                    isWalkThroughPresented = true
                }

                actionRow(title: "문의하기", systemImage: "envelope") {
                    openURL(AppSupport.inquiryMailURL)
                }

                actionRow(title: "리뷰", systemImage: "star.bubble") {
                    requestReview()
                }
            }

            RedesignSectionCard(title: "앱 정보") {
                HStack {
                    Text("버전 정보")
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelNormal)

                    Spacer()

                    Text(model.version)
                        .font(.jsLabelLarge)
                        .foregroundColor(.labelAlternative)
                }

                actionRow(title: "개인정보 처리방침", systemImage: "hand.raised") {
                    openURL(AppSupport.privacyPolicyURL)
                }

                actionRow(title: "오픈소스 라이선스", systemImage: "doc.text") {
                    isLicencePresented = true
                }
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
        .sheet(isPresented: $isLicencePresented) {
            NavigationStack {
                AcknowListSwiftUIView()
                    .navigationTitle("오픈소스 라이선스")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("닫기") {
                                isLicencePresented = false
                            }
                        }
                    }
            }
        }
    }

    private func actionRow(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: .jsSM) {
                Image(systemName: systemImage)
                    .foregroundColor(.primaryNormal)
                    .frame(width: .jsTouchTarget, height: .jsTouchTarget)
                    .background(
                        Circle()
                            .fill(Color.primaryNormal.opacity(0.1))
                    )

                Text(title)
                    .font(.jsBodyMedium)
                    .foregroundColor(.labelStrong)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.jsButtonSmall)
                    .foregroundColor(.labelNeutral)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
