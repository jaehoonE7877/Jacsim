import ComposableArchitecture
import DSKit
import SwiftUI

public struct ChallengeCreateView: View {
    @Bindable var store: StoreOf<ChallengeCreateFeature>

    public init(store: StoreOf<ChallengeCreateFeature>) {
        self.store = store
    }

    public var body: some View {
        NewTaskView(store: store.scope(state: \.newTask, action: \.newTask))
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
    }
}
