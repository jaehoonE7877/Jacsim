import SwiftUI
import ComposableArchitecture
import UIKit
import DesignSystem

private enum StartupTransitionPolicy {
    static var splashMinimumDuration: UInt64 {
        UInt64(StartupDisplayPolicy.splashMinimumDuration * 1_000_000_000)
    }
    static var splashMaximumDuration: UInt64 {
        UInt64(StartupDisplayPolicy.splashMaximumDuration * 1_000_000_000)
    }
    static let splashDismissScale: CGFloat = 0.985
    static let launchFrameHoldDuration: Double = 0.12
    static let launchLogoWidthRatio: CGFloat = 0.615385
}

public struct AppView: View {
    let store: StoreOf<AppFeature>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    @State private var isSplashVisible = true
    @State private var hasPlayedSplash = false
    @State private var minDurationPassed = false
    @State private var didObserveHomeFetchStart = false
    @State private var canDismissFromLoad = false

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    private var colorScheme: ColorScheme? {
        switch store.state.themeRaw {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    private var splashOverlayTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }
        return .opacity.combined(with: .scale(scale: StartupTransitionPolicy.splashDismissScale))
    }

    public var body: some View {
        Group {
            if let onboardingStore = store.scope(state: \.onboarding, action: \.onboarding) {
                WalkThroughView(store: onboardingStore)
            } else if let homeStore = store.scope(state: \.home, action: \.home) {
                HomeView(store: homeStore)
            }
        }
        .allowsHitTesting(!isSplashVisible)
        .accessibilityHidden(isSplashVisible)
        .overlay {
            if isSplashVisible {
                AppStartupSplashView(
                    reduceMotion: reduceMotion,
                    hasLogo: UIImage(named: "jacsimMonotone") != nil
                )
                .transition(splashOverlayTransition)
                .zIndex(1000)
            }
        }
        .onAppear {
            store.send(.onAppear)
            startSplashIfNeeded(for: store.state)
            updateSplashEligibility(for: store.state)
        }
        .onReceive(NotificationCenter.default.publisher(for: .jacsimThemeChanged)) { _ in
            store.send(.themePreferenceRefreshRequested)
        }
        .onChange(of: scenePhase) { _, newPhase in
            store.send(.scenePhaseChanged(newPhase))
        }
        .onChange(of: store.state) { _, newState in
            startSplashIfNeeded(for: newState)
            updateSplashEligibility(for: newState)
        }
        .onChange(of: minDurationPassed) { _, _ in
            dismissSplashIfPossible()
        }
        .onChange(of: canDismissFromLoad) { _, _ in
            dismissSplashIfPossible()
        }
        .preferredColorScheme(colorScheme)
    }

    private func startSplashIfNeeded(for state: AppFeature.State) {
        guard !hasPlayedSplash else { return }

        if state.onboarding != nil {
            // Startup splash is intentionally skipped for onboarding flow.
            hasPlayedSplash = true
            isSplashVisible = false
            minDurationPassed = true
            didObserveHomeFetchStart = false
            canDismissFromLoad = true
            return
        }

        hasPlayedSplash = true
        isSplashVisible = true
        minDurationPassed = false
        didObserveHomeFetchStart = false
        canDismissFromLoad = false

        Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: StartupTransitionPolicy.splashMinimumDuration)
            } catch is CancellationError {
                return
            } catch {
                return
            }
            minDurationPassed = true
            dismissSplashIfPossible()
        }

        Task { @MainActor in
            // Fallback to avoid lingering splash in unexpected states.
            do {
                try await Task.sleep(nanoseconds: StartupTransitionPolicy.splashMaximumDuration)
            } catch is CancellationError {
                return
            } catch {
                return
            }
            canDismissFromLoad = true
            dismissSplashIfPossible()
        }
    }

    private func updateSplashEligibility(for state: AppFeature.State) {
        guard isSplashVisible else { return }

        if state.onboarding != nil {
            canDismissFromLoad = true

        } else if let homeState = state.home {
            let isFetching = homeState.isFetching
            if isFetching {
                didObserveHomeFetchStart = true
                canDismissFromLoad = true
                return
            }

            if didObserveHomeFetchStart && !isFetching {
                canDismissFromLoad = true
            }
        }
    }

    private func dismissSplashIfPossible() {
        guard isSplashVisible else { return }
        guard minDurationPassed, canDismissFromLoad else { return }

        if reduceMotion {
            isSplashVisible = false
        } else {
            withAnimation(JSAnimation.easeOut) {
                isSplashVisible = false
            }
        }
    }
}

private struct AppStartupSplashView: View {
    let reduceMotion: Bool
    let hasLogo: Bool

    @State private var showAmbientHighlight = false
    @State private var logoScale: CGFloat = 1
    @State private var showStatusLockup = false
    @State private var didStartAnimation = false

    var body: some View {
        GeometryReader { proxy in
            let logoSize = proxy.size.width * StartupTransitionPolicy.launchLogoWidthRatio
            let fallbackIconSize = max(logoSize * 0.18, 28)

            VStack(spacing: .jsLG) {
                ZStack {
                    Circle()
                        .fill(Color.primaryNormal.opacity(0.08))
                        .frame(width: logoSize * 1.08, height: logoSize * 1.08)
                        .blur(radius: 18)
                        .opacity(showAmbientHighlight ? 1 : 0)
                        .scaleEffect(showAmbientHighlight ? 1.02 : 0.96)

                    Circle()
                        .fill(Color.primaryNormal.opacity(0.05))
                        .frame(width: logoSize * 0.9, height: logoSize * 0.9)

                    if hasLogo {
                        Image("jacsimMonotone")
                            .resizable()
                            .scaledToFit()
                            .frame(width: logoSize, height: logoSize)
                    } else {
                        Image(systemName: "checklist")
                            .font(.pretendardSemiBold(size: fallbackIconSize, relativeTo: .title1))
                            .foregroundColor(.primaryNormal)
                            .frame(width: logoSize, height: logoSize)
                    }
                }
                .frame(width: logoSize * 1.18, height: logoSize * 1.18)

                VStack(spacing: .jsXS) {
                    Text("작심")
                        .font(.jsDisplaySmall)
                        .foregroundColor(.labelStrong)

                    Text("오늘의 루틴을 준비하고 있어요")
                        .font(.jsBodySmall)
                        .foregroundColor(.labelNeutral)
                }
                .opacity(showStatusLockup ? 1 : 0.68)
                .offset(y: showStatusLockup ? 0 : 6)

                HStack(spacing: .jsXS) {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.primaryNormal)

                    Text("홈 화면을 정리하는 중")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelStrong)
                }
                .padding(.horizontal, .jsSM)
                .padding(.vertical, .jsXS)
                .background(
                    Capsule()
                        .fill(Color.backgroundNormal.opacity(0.92))
                        .overlay(
                            Capsule()
                                .stroke(Color.primaryNormal.opacity(0.14), lineWidth: 1)
                        )
                )
                .shadow(color: Color.primaryNormal.opacity(0.08), radius: 14, y: 6)
                .opacity(showStatusLockup ? 1 : 0)
                .offset(y: showStatusLockup ? 0 : 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Color.backgroundAlternative,
                        Color.backgroundNormal
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                    .ignoresSafeArea()
            )
            .scaleEffect(logoScale)
            .onAppear {
                guard !didStartAnimation else { return }
                didStartAnimation = true
                guard !reduceMotion else { return }

                withAnimation(
                    JSAnimation.easeOut
                        .delay(StartupTransitionPolicy.launchFrameHoldDuration)
                ) {
                    showAmbientHighlight = true
                    logoScale = 1.012
                    showStatusLockup = true
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("작심을 준비하는 중")
        .accessibilityValue("홈 화면을 정리하는 중")
        .accessibilityHint("잠시 후 홈 화면으로 이동합니다")
    }
}
