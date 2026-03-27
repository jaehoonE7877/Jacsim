import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct ChallengeCreateView: View {
    @Bindable var store: StoreOf<ChallengeCreateFeature>

    public init(store: StoreOf<ChallengeCreateFeature>) {
        self.store = store
    }

    public var body: some View {
        let newTaskStore = store.scope(state: \.newTask, action: \.newTask)

        NavigationStack {
            NewTaskView(store: newTaskStore)
        }
        .interactiveDismissDisabled(newTaskStore.hasUnsavedChanges || newTaskStore.isSaving)
        .presentationBackground(Color.backgroundNormal)
        .presentationBackgroundInteraction(.disabled)
        .presentationCornerRadius(32)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
