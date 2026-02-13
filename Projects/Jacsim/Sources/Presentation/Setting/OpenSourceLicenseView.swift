import SwiftUI
import ComposableArchitecture
import AcknowList

public struct OpenSourceLicenseView: View {
    let store: StoreOf<OpenSourceLicenseFeature>

    public init(store: StoreOf<OpenSourceLicenseFeature>) {
        self.store = store
    }

    public var body: some View {
        AcknowListSwiftUIView()
            .navigationTitle("오픈소스 라이선스")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { store.send(.onAppear) }
    }
}

#Preview {
    NavigationStack {
        OpenSourceLicenseView(
            store: Store(initialState: OpenSourceLicenseFeature.State()) {
                OpenSourceLicenseFeature()
            }
        )
    }
}
