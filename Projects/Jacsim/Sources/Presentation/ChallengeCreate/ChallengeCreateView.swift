import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct ChallengeCreateView: View {
    @Bindable var store: StoreOf<ChallengeCreateFeature>

    public init(store: StoreOf<ChallengeCreateFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            NewTaskView(store: store.scope(state: \.newTask, action: \.newTask))
        }
        .interactiveDismissDisabled(store.newTask.hasUnsavedChanges || store.newTask.isSaving)
        .presentationBackground(Color.backgroundNormal)
        .presentationBackgroundInteraction(.disabled)
        .presentationCornerRadius(32)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
