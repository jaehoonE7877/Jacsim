import Foundation
import ComposableArchitecture

@Reducer
public struct SettingFeature {
    @ObservableState
    public struct State: Equatable {
        public var version: String = "1.0.0"
        public init() {}
    }

    public enum Action {
        case useCaseButtonTapped
        case inquiryButtonTapped
        case reviewButtonTapped
        case licenceButtonTapped
        
        case delegate(Delegate)
        public enum Delegate {
            case navigateToWalkThrough
            case presentMailCompose
            case openReviewURL
            case navigateToLicence
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .useCaseButtonTapped:
                return .send(.delegate(.navigateToWalkThrough))
            case .inquiryButtonTapped:
                return .send(.delegate(.presentMailCompose))
            case .reviewButtonTapped:
                return .send(.delegate(.openReviewURL))
            case .licenceButtonTapped:
                return .send(.delegate(.navigateToLicence))
            case .delegate:
                return .none
            }
        }
    }
}
