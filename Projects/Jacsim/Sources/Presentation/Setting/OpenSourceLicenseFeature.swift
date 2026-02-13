import ComposableArchitecture

@Reducer
public struct OpenSourceLicenseFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case onAppear
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}
