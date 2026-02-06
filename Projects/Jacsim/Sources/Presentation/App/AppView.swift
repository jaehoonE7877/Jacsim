import SwiftUI
import ComposableArchitecture
import UIKit
import DSKit

private enum StartupTransitionPolicy {
    static let splashMinimumDuration: UInt64 = 1_100_000_000
    static let splashMaximumDuration: UInt64 = 2_500_000_000
    static let splashDismissAnimationDuration: Double = 0.3
}

public struct AppView: View {
    let store: StoreOf<AppFeature>
    @AppStorage("appearance_theme") private var themeRaw: String = "system"
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isSplashVisible = true
    @State private var hasPlayedSplash = false
    @State private var minDurationPassed = false
    @State private var didObserveHomeFetchStart = false
    @State private var canDismissFromLoad = false

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    private var colorScheme: ColorScheme? {
        switch themeRaw {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    public var body: some View {
        Group {
            switch store.state {
            case .onboarding:
                if let onboardingStore = store.scope(state: \.onboarding, action: \.onboarding) {
                    WalkThroughView(store: onboardingStore)
                }
            case .main:
                if let mainStore = store.scope(state: \.main, action: \.main) {
                    NavigationStack {
                        MainView(store: mainStore)
                    }
                }
            }
        }
        .overlay {
            if isSplashVisible {
                AppStartupSplashView(
                    reduceMotion: reduceMotion,
                    hasLogo: UIImage(named: "jacsimMonotone") != nil
                )
                .transition(.opacity)
                .zIndex(1000)
            }
        }
        .onAppear {
            startSplashIfNeeded()
            updateSplashEligibility(for: store.state)
        }
        .onChange(of: store.state) { _, newState in
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

    private func startSplashIfNeeded() {
        guard !hasPlayedSplash else { return }

        hasPlayedSplash = true
        isSplashVisible = true
        minDurationPassed = false
        didObserveHomeFetchStart = false
        canDismissFromLoad = false

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: StartupTransitionPolicy.splashMinimumDuration)
            minDurationPassed = true
            dismissSplashIfPossible()
        }

        Task { @MainActor in
            // Fallback to avoid lingering splash in unexpected states.
            try? await Task.sleep(nanoseconds: StartupTransitionPolicy.splashMaximumDuration)
            canDismissFromLoad = true
            dismissSplashIfPossible()
        }
    }

    private func updateSplashEligibility(for state: AppFeature.State) {
        switch state {
        case .onboarding:
            canDismissFromLoad = true

        case let .main(mainState):
            let isFetching = mainState.home.isFetching
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
            withAnimation(.easeOut(duration: StartupTransitionPolicy.splashDismissAnimationDuration)) {
                isSplashVisible = false
            }
        }
    }
}

private struct AppStartupSplashView: View {
    let reduceMotion: Bool
    let hasLogo: Bool

    @State private var showLogo = false
    @State private var showGlow = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .overlay {
                    LinearGradient(
                        colors: [
                            Color.backgroundNormal.opacity(0.72),
                            Color.backgroundStrong.opacity(0.54)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }

            Circle()
                .fill(Color.primaryNormal.opacity(showGlow ? 0.1 : 0.0))
                .frame(width: 280.jsScaled(), height: 280.jsScaled())
                .blur(radius: 24.jsScaled())
                .scaleEffect(reduceMotion ? 1 : (showGlow ? 1 : 0.84))

            Circle()
                .fill(Color.backgroundAlternative.opacity(showGlow ? 0.22 : 0.12))
                .frame(width: 220.jsScaled(), height: 220.jsScaled())
                .blur(radius: 18.jsScaled())
                .scaleEffect(reduceMotion ? 1 : (showGlow ? 1 : 0.92))

            ZStack {
                Circle()
                    .fill(Color.backgroundAlternative.opacity(0.74))
                    .frame(width: 184.jsScaled(), height: 184.jsScaled())
                    .overlay(
                        Circle()
                            .stroke(Color.labelDisable.opacity(0.28), lineWidth: 1.jsScaled())
                    )
                    .shadow(
                        color: Color.surfaceOverlay.opacity(0.24),
                        radius: 16.jsScaled(),
                        x: 0,
                        y: 7.jsScaled()
                    )

                if hasLogo {
                    Image("jacsimMonotone")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 128.jsScaled(), height: 128.jsScaled())
                } else {
                    Image(systemName: "checklist")
                        .font(.system(size: 64.jsScaled(.displayTypography), weight: .semibold))
                        .foregroundColor(.primaryNormal)
                }
            }
            .opacity(showLogo ? 1 : 0)
            .scaleEffect(reduceMotion ? 1 : (showLogo ? 1 : 0.96))
            .onAppear {
                if reduceMotion {
                    showGlow = true
                    showLogo = true
                } else {
                    withAnimation(.easeOut(duration: 0.28)) {
                        showGlow = true
                    }
                    withAnimation(.easeOut(duration: 0.3).delay(0.04)) {
                        showLogo = true
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }
}
