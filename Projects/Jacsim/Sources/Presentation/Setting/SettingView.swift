import SwiftUI
import ComposableArchitecture
import DSKit

public struct SettingView: View {
    let store: StoreOf<SettingFeature>

    public init(store: StoreOf<SettingFeature>) {
        self.store = store
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "설정",
            subtitle: "테마와 알림, 앱 정보를 관리해요"
        ) {
            RedesignSectionCard(title: "테마") {
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
                subtitle: "매일 작심 알림을 받을 수 있어요"
            ) {
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
                actionRow(title: "사용법", systemImage: "book.pages") {
                    store.send(.useCaseButtonTapped)
                }

                actionRow(title: "문의하기", systemImage: "envelope") {
                    store.send(.inquiryButtonTapped)
                }

                actionRow(title: "리뷰", systemImage: "star.bubble") {
                    store.send(.reviewButtonTapped)
                }
            }

            RedesignSectionCard(title: "앱 정보") {
                HStack {
                    Text("버전 정보")
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelNormal)

                    Spacer()

                    Text(store.version)
                        .font(.jsLabelLarge)
                        .foregroundColor(.labelAlternative)
                }

                actionRow(title: "오픈소스 라이선스", systemImage: "doc.text") {
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
                text: "알림 권한이 꺼져 있어요. 시스템 설정에서 알림을 허용해 주세요",
                icon: "bell.slash.fill",
                tintColor: .destructive
            )

            HStack(spacing: .jsSM) {
                JSButton(title: "설정 열기", style: .secondary, size: .medium) {
                    store.send(.openSystemSettingsTapped)
                }
                JSButton(title: "닫기", style: .secondary, size: .medium) {
                    store.send(.notificationBannerDismissed)
                }
            }

        case .permissionError:
            RedesignStateBanner(
                text: "권한 요청 중 문제가 발생했어요. 다시 시도하거나 설정에서 확인해 주세요",
                icon: "exclamationmark.triangle.fill",
                tintColor: .destructive
            )

            HStack(spacing: .jsSM) {
                JSButton(title: "설정 열기", style: .secondary, size: .medium) {
                    store.send(.openSystemSettingsTapped)
                }
                JSButton(title: "닫기", style: .secondary, size: .medium) {
                    store.send(.notificationBannerDismissed)
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
        .accessibilityLabel(title)
        .accessibilityHint("해당 설정 화면으로 이동합니다")
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
