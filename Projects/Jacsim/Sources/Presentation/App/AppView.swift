import SwiftUI
import ComposableArchitecture

public struct AppView: View {
    let store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
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
    }
}
