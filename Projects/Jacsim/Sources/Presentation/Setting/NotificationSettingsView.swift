import Domain
import DSKit
import SwiftUI
import UIKit
import UserNotifications

public struct NotificationSettingsView: View {
    @Bindable var model: NotificationSettingsModel
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined

    public init(model: NotificationSettingsModel) {
        self.model = model
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: .jsLG) {
                if authorizationStatus == .denied {
                    permissionBanner
                }

                socialTriggerSection
                coachWeeklySection
            }
            .padding(.horizontal, .jsMD)
            .padding(.top, .jsLG)
            .padding(.bottom, .jsXXL)
        }
        .background(Color.backgroundNormal)
        .navigationTitle("알림 설정")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            model.onAppear()
            await refreshAuthorizationStatus()
        }
    }

    private var permissionBanner: some View {
        JSGlassCard(accessibilityLabel: "알림 권한 꺼짐") {
            HStack(alignment: .top, spacing: .jsMD) {
                Image(systemName: "bell.slash.fill")
                    .font(.jsHeadline20Bold)
                    .foregroundStyle(Color.cautionary)

                VStack(alignment: .leading, spacing: .jsXS) {
                    Text("알림 권한이 꺼져 있어요")
                        .font(.jsBodyLarge)
                        .foregroundStyle(Color.labelStrong)

                    Text("소셜 알림을 받으려면 iOS 설정에서 알림을 허용해 주세요.")
                        .font(.jsBodySmall)
                        .foregroundStyle(Color.labelAlternative)

                    Button("설정 열기") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    .font(.jsButtonMedium)
                    .foregroundStyle(Color.forestAccent)
                    .accessibilityLabel("iOS 설정 열기")
                }

                Spacer(minLength: .jsXS)
            }
        }
    }

    private var socialTriggerSection: some View {
        settingsGroup(title: "소셜 알림") {
            ForEach(SocialNotificationTrigger.allCases) { trigger in
                Toggle(
                    isOn: Binding(
                        get: { model.isEnabled(trigger) },
                        set: { model.setEnabled($0, for: trigger) }
                    )
                ) {
                    VStack(alignment: .leading, spacing: .jsMicro) {
                        Text(trigger.title)
                            .font(.jsBodyMedium)
                            .foregroundStyle(Color.labelStrong)
                        Text(trigger.description)
                            .font(.jsLabelMedium)
                            .foregroundStyle(Color.labelAlternative)
                    }
                }
                .tint(Color.forestAccent)
                .accessibilityLabel(trigger.title)
            }
        }
    }

    private var coachWeeklySection: some View {
        settingsGroup(title: "주간 코치") {
            DatePicker(
                "회고 시간",
                selection: Binding(
                    get: { model.coachWeeklyTime },
                    set: { model.coachWeeklyTime = $0 }
                ),
                displayedComponents: .hourAndMinute
            )
            .font(.jsBodyMedium)
            .foregroundStyle(Color.labelStrong)
            .accessibilityLabel("주간 코치 회고 시간")

            Picker(
                "요일",
                selection: Binding(
                    get: { model.settings.coachWeeklyWeekday },
                    set: { model.weekdayChanged($0) }
                )
            ) {
                ForEach(weekdayOptions, id: \.value) { option in
                    Text(option.title).tag(option.value)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("주간 코치 회고 요일")
        }
    }

    private func settingsGroup<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            Text(title)
                .font(.jsSerifTitle)
                .foregroundStyle(Color.labelStrong)

            VStack(alignment: .leading, spacing: .jsMD) {
                content()
            }
            .padding(.jsLG)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surfaceElevated.opacity(0.2))
            .jsGlassCard(cornerRadius: 24)
        }
    }

    private var weekdayOptions: [(value: Int, title: String)] {
        [
            (1, "일"),
            (2, "월"),
            (3, "화"),
            (4, "수"),
            (5, "목"),
            (6, "금"),
            (7, "토")
        ]
    }

    private func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
}

private extension SocialNotificationTrigger {
    var title: String {
        switch self {
        case .followRequested:
            return "친구 요청"
        case .followAccepted:
            return "친구 수락"
        case .friendPosted:
            return "친구의 새 자랑"
        case .friendGraduated:
            return "친구의 스테이지 졸업"
        case .postCheered:
            return "내 글 응원"
        case .postFollowed:
            return "내 글 따라하기"
        case .postCommented:
            return "내 글 댓글"
        case .coachWeekly:
            return "AI 코치 주간 회고"
        }
    }

    var description: String {
        switch self {
        case .followRequested:
            return "새 친구 요청이 오면 알려줍니다."
        case .followAccepted:
            return "친구 요청이 수락되면 알려줍니다."
        case .friendPosted:
            return "팔로우한 친구가 자랑을 올리면 알려줍니다."
        case .friendGraduated:
            return "친구가 스테이지를 완주하면 알려줍니다."
        case .postCheered:
            return "내 자랑 글에 응원이 달리면 알려줍니다."
        case .postFollowed:
            return "누군가 내 기록을 따라 시작하면 알려줍니다."
        case .postCommented:
            return "내 자랑 글에 댓글이 달리면 알려줍니다."
        case .coachWeekly:
            return "매주 정해진 시간에 회고를 제안합니다."
        }
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView(model: NotificationSettingsModel(dependencies: .test))
    }
}
