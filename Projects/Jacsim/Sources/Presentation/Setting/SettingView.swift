import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct SettingView: View {
    let store: StoreOf<SettingFeature>

    public init(store: StoreOf<SettingFeature>) {
        self.store = store
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "설정",
            subtitle: "루틴에 집중할 수 있도록 앱 환경을 정리해요"
        ) {
            RedesignSectionCard(
                title: "테마",
                subtitle: "집중이 오래 이어지는 화면 분위기로 맞춰요"
            ) {
                summaryRow(
                    title: currentThemeTitle,
                    subtitle: currentThemeDescription,
                    systemImage: currentThemeIcon,
                    accentColor: .primaryNormal
                )

                Picker("테마", selection: Binding(
                    get: { store.theme },
                    set: { store.send(.themeChanged($0)) }
                )) {
                    Text("시스템").tag(ThemeMode.system)
                    Text("라이트").tag(ThemeMode.light)
                    Text("다크").tag(ThemeMode.dark)
                }
                .pickerStyle(.segmented)
            }

            RedesignSectionCard(
                title: "알림",
                subtitle: "하루에 꼭 필요한 작심 리마인더만 보내드려요"
            ) {
                summaryRow(
                    title: notificationSummaryTitle,
                    subtitle: notificationSummaryDescription,
                    systemImage: notificationSummaryIcon,
                    accentColor: store.isNotificationEnabled ? .primaryNormal : .labelNeutral
                )

                Toggle(
                    "알림 설정",
                    isOn: Binding(
                        get: { store.isNotificationEnabled },
                        set: { store.send(.notificationToggleChanged($0)) }
                    )
                )
                .font(.jsBodyMedium)
                .foregroundColor(.labelNormal)
                .disabled(store.isLoading)

                if store.isLoading {
                    RedesignStateBanner(
                        text: "알림 설정을 반영하는 중이에요",
                        icon: "clock.arrow.circlepath",
                        tintColor: .primaryNormal
                    )
                }

                if let banner = store.notificationBanner {
                    notificationBanner(banner)
                }
            }

            RedesignSectionCard(title: "도움말") {
                VStack(spacing: .jsXS) {
                    actionRow(
                        title: "사용법",
                        subtitle: "챌린지 생성부터 인증 흐름까지 빠르게 훑어봐요",
                        systemImage: "book.pages",
                        accessibilityHint: "작심 사용법 안내 화면으로 이동합니다"
                    ) {
                        store.send(.useCaseButtonTapped)
                    }

                    rowDivider

                    actionRow(
                        title: "문의하기",
                        subtitle: "문제가 있거나 제안이 있다면 메일로 바로 남겨요",
                        systemImage: "envelope",
                        accessorySystemImage: "arrow.up.right",
                        accessibilityHint: "메일 앱으로 문의 작성을 시작합니다"
                    ) {
                        store.send(.inquiryButtonTapped)
                    }

                    rowDivider

                    actionRow(
                        title: "리뷰",
                        subtitle: "App Store에서 작심 경험을 평가해 주세요",
                        systemImage: "star.bubble",
                        accessorySystemImage: "arrow.up.right",
                        accessibilityHint: "앱스토어 리뷰 작성 화면을 엽니다"
                    ) {
                        store.send(.reviewButtonTapped)
                    }
                }
            }

            RedesignSectionCard(title: "앱 정보") {
                HStack(alignment: .center, spacing: .jsSM) {
                    VStack(alignment: .leading, spacing: .jsMicro) {
                        Text("버전 정보")
                            .font(.jsBodyMedium)
                            .foregroundColor(.labelStrong)

                        Text("현재 설치된 앱 버전")
                            .font(.jsLabelMedium)
                            .foregroundColor(.labelNeutral)
                    }

                    Spacer(minLength: .jsSM)

                    Text(store.version)
                        .font(.jsButtonSmall)
                        .foregroundColor(.primaryStrong)
                        .padding(.horizontal, .jsSM)
                        .padding(.vertical, CGFloat.jsMicro)
                        .background(
                            Capsule()
                                .fill(Color.primaryNormal.opacity(0.1))
                        )
                }

                rowDivider

                actionRow(
                    title: "오픈소스 라이선스",
                    subtitle: "앱에 포함된 오픈소스 구성요소와 라이선스를 확인해요",
                    systemImage: "doc.text",
                    accessibilityHint: "오픈소스 라이선스 화면으로 이동합니다"
                ) {
                    store.send(.licenceButtonTapped)
                }
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            store.send(.loadNotificationSettings)
        }
    }

    @ViewBuilder
    private func notificationBanner(_ banner: SettingFeature.NotificationBanner) -> some View {
        switch banner {
        case .permissionDenied:
            RedesignStateBanner(
                text: "시스템 알림 권한이 꺼져 있어요. 권한을 허용한 뒤 앱 알림도 다시 켜 주세요",
                icon: "bell.slash.fill",
                tintColor: .destructive
            )

            HStack(spacing: .jsSM) {
                JSButton(title: "설정 열기", style: .secondary, size: .medium) {
                    store.send(.openSystemSettingsTapped)
                }
                JSButton(title: "나중에", style: .secondary, size: .medium) {
                    store.send(.notificationBannerDismissed)
                }
            }

        case .permissionError:
            RedesignStateBanner(
                text: "권한 상태를 확인하지 못했어요. 다시 시도하거나 시스템 설정에서 확인해 주세요",
                icon: "exclamationmark.triangle.fill",
                tintColor: .destructive
            )

            HStack(spacing: .jsSM) {
                JSButton(title: "설정 열기", style: .secondary, size: .medium) {
                    store.send(.openSystemSettingsTapped)
                }
                JSButton(title: "나중에", style: .secondary, size: .medium) {
                    store.send(.notificationBannerDismissed)
                }
            }
        }
    }

    private func actionRow(
        title: String,
        subtitle: String,
        systemImage: String,
        accessorySystemImage: String = "chevron.right",
        accessibilityHint: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: .jsSM) {
                Image(systemName: systemImage)
                    .foregroundColor(.primaryNormal)
                    .frame(width: .jsTouchTarget, height: .jsTouchTarget)
                    .background(
                        RoundedRectangle(cornerRadius: .jsCornerSmall)
                            .fill(Color.primaryNormal.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: .jsMicro) {
                    Text(title)
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelStrong)

                    Text(subtitle)
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelNeutral)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: accessorySystemImage)
                    .font(.jsButtonSmall)
                    .foregroundColor(.labelAlternative)
                    .padding(.top, .jsXS)
            }
            .contentShape(Rectangle())
            .padding(.vertical, CGFloat.jsMicro)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint)
    }

    private func summaryRow(
        title: String,
        subtitle: String,
        systemImage: String,
        accentColor: Color
    ) -> some View {
        HStack(alignment: .center, spacing: .jsSM) {
            Image(systemName: systemImage)
                .font(.jsButtonMedium)
                .foregroundColor(accentColor)
                .frame(width: .jsTouchTarget, height: .jsTouchTarget)
                .background(
                    RoundedRectangle(cornerRadius: .jsCornerSmall)
                        .fill(accentColor.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: .jsMicro) {
                Text(title)
                    .font(.jsBodyMedium)
                    .foregroundColor(.labelStrong)

                Text(subtitle)
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelNeutral)
            }

            Spacer(minLength: .jsXS)
        }
    }

    private var rowDivider: some View {
        Divider()
            .overlay(Color.backgroundAlternative)
            .padding(.leading, .jsTouchTarget + .jsSM)
    }

    private var currentThemeTitle: String {
        switch store.theme {
        case .system:
            return "시스템 모드를 따르고 있어요"
        case .light:
            return "라이트 모드가 적용되어 있어요"
        case .dark:
            return "다크 모드가 적용되어 있어요"
        }
    }

    private var currentThemeDescription: String {
        switch store.theme {
        case .system:
            return "기기 설정에 맞춰 밝기와 대비를 자동으로 조정해요"
        case .light:
            return "밝고 선명한 화면으로 빠르게 정보를 확인할 수 있어요"
        case .dark:
            return "어두운 환경에서도 눈의 피로를 줄이도록 도와줘요"
        }
    }

    private var currentThemeIcon: String {
        switch store.theme {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.stars.fill"
        }
    }

    private var notificationSummaryTitle: String {
        store.isNotificationEnabled ? "리마인드가 켜져 있어요" : "리마인드가 꺼져 있어요"
    }

    private var notificationSummaryDescription: String {
        if store.isLoading {
            return "설정을 확인하는 중이에요"
        }
        return store.isNotificationEnabled
        ? "매일 챌린지를 놓치지 않도록 알림으로 알려드려요"
        : "필요한 순간에만 다시 켜서 사용할 수 있어요"
    }

    private var notificationSummaryIcon: String {
        if store.isLoading {
            return "clock.arrow.circlepath"
        }
        return store.isNotificationEnabled ? "bell.badge.fill" : "bell.slash.fill"
    }
}

#Preview {
    NavigationStack {
        SettingView(
            store: Store(initialState: SettingFeature.State()) {
                SettingFeature()
            }
        )
    }
}
