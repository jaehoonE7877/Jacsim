import SwiftUI
import ComposableArchitecture
import UIKit
import DSKit

private enum StartupTransitionPolicy {
    static var splashMinimumDuration: UInt64 {
        UInt64(StartupDisplayPolicy.splashMinimumDuration * 1_000_000_000)
    }
    static var splashMaximumDuration: UInt64 {
        UInt64(StartupDisplayPolicy.splashMaximumDuration * 1_000_000_000)
    }
    static let splashDismissAnimationDuration: Double = 0.24
    static let splashDismissScale: CGFloat = 0.985
    static let launchFrameHoldDuration: Double = 0.12
    static let ambientAnimationDuration: Double = 0.32
    static let launchLogoWidthRatio: CGFloat = 0.615385
}

public struct AppView: View {
    let store: StoreOf<AppFeature>
    @Dependency(\.appPreferences) private var appPreferences
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var themeRaw: String = ThemeMode.system.rawValue
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

    private var splashOverlayTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }
        return .opacity.combined(with: .scale(scale: StartupTransitionPolicy.splashDismissScale))
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
                .transition(splashOverlayTransition)
                .zIndex(1000)
            }
        }
        .onAppear {
            store.send(.onAppear)
            refreshThemeFromPreferences()
            startSplashIfNeeded(for: store.state)
            updateSplashEligibility(for: store.state)
        }
        .onReceive(NotificationCenter.default.publisher(for: .jacsimThemeChanged)) { _ in
            refreshThemeFromPreferences()
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

        switch state {
        case .onboarding:
            // Startup splash is intentionally skipped for onboarding flow.
            hasPlayedSplash = true
            isSplashVisible = false
            minDurationPassed = true
            didObserveHomeFetchStart = false
            canDismissFromLoad = true
            return

        case .main:
            break
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

    private func refreshThemeFromPreferences() {
        if let raw = appPreferences.getThemeModeRaw(),
           ThemeMode(rawValue: raw) != nil {
            themeRaw = raw
            return
        }
        themeRaw = ThemeMode.system.rawValue
    }

    private func updateSplashEligibility(for state: AppFeature.State) {
        guard isSplashVisible else { return }

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

    @State private var showAmbientHighlight = false
    @State private var logoScale: CGFloat = 1
    @State private var didStartAnimation = false

    var body: some View {
        GeometryReader { proxy in
            let logoSize = proxy.size.width * StartupTransitionPolicy.launchLogoWidthRatio

            ZStack {
                Color.backgroundNormal
                    .ignoresSafeArea()

                Circle()
                    .fill(Color.primaryNormal.opacity(0.08))
                    .frame(width: logoSize * 1.08, height: logoSize * 1.08)
                    .blur(radius: 18)
                    .opacity(showAmbientHighlight ? 1 : 0)
                    .scaleEffect(showAmbientHighlight ? 1.02 : 0.96)

                if hasLogo {
                    Image("jacsimMonotone")
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoSize, height: logoSize)
                } else {
                    Image(systemName: "checklist")
                        .font(.system(size: logoSize * 0.32, weight: .semibold))
                        .foregroundColor(.primaryNormal)
                        .frame(width: logoSize, height: logoSize)
                }
            }
            .scaleEffect(logoScale)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                guard !didStartAnimation else { return }
                didStartAnimation = true
                guard !reduceMotion else { return }

                withAnimation(
                    .easeOut(duration: StartupTransitionPolicy.ambientAnimationDuration)
                        .delay(StartupTransitionPolicy.launchFrameHoldDuration)
                ) {
                    showAmbientHighlight = true
                    logoScale = 1.012
                }
            }
        }
        .accessibilityHidden(true)
    }
}
