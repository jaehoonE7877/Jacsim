import SwiftUI
import ComposableArchitecture
import DSKit

public struct MainView: View {
    @Bindable var store: StoreOf<MainFeature>

    public init(store: StoreOf<MainFeature>) {
        self.store = store
    }

    public var body: some View {
        HomeView(store: store.scope(state: \.home, action: \.home))
    }
}
