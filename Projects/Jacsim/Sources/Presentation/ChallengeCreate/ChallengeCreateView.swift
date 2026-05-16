import DSKit
import SwiftUI

public struct ChallengeCreateView: View {
    let model: ChallengeCreateModel

    public init(model: ChallengeCreateModel) {
        self.model = model
    }

    public var body: some View {
        NewTaskView(model: model.newTask)
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(true)
    }
}
