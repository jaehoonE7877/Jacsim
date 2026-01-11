import SwiftUI
import ComposableArchitecture
import DSKit

public struct NewTaskView: View {
    @Bindable var store: StoreOf<NewTaskFeature>

    public init(store: StoreOf<NewTaskFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            JacsimNameInputView(store: store)
        } destination: { store in
            switch store.state {
            case .alarmInput:
                if let _ = store.scope(state: \.alarmInput, action: \.alarmInput) {
                    JacsimAlarmInputView(store: self.store)
                }
            case .summary:
                if let _ = store.scope(state: \.summary, action: \.summary) {
                    JacsimSummaryView(store: self.store)
                }
            }
        }
    }
}
