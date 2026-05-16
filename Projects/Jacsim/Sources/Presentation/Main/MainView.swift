import DSKit
import SwiftUI

public struct MainView: View {
    @Bindable var model: MainModel

    public init(model: MainModel) {
        self.model = model
    }

    public var body: some View {
        HomeView(model: model.home)
    }
}
