import Foundation
import Domain
import ComposableArchitecture
import SwiftUI

@Reducer
public struct NewTaskFeature {
    @ObservableState
    public struct State: Equatable {
        public var title: String = ""
        public var startDate: Date = Date()
        public var endDate: Date = Date().addingTimeInterval(86400 * 7)
        public var successCount: Int = 1
        public var image: UIImage?
        public var alarmDate: Date = Date()
        public var isAlarmEnabled: Bool = false
        
        public var path = StackState<Path.State>()
        @Presents public var alert: AlertState<Action.Alert>?
        
        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackAction<Path.State, Path.Action>)
        case saveButtonTapped
        case saveCompleted
        case nextButtonTapped
        case confirmAlarmButtonTapped
        case cancelButtonTapped
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)
        
        public enum Alert: Equatable {
            case dismiss
        }
        
        public enum Delegate {
            case taskCreated
        }
    }

    public struct Path: Reducer {
        @ObservableState
        @CasePathable
        @dynamicMemberLookup
        public enum State: Equatable, Hashable {
            case alarmInput
            case summary
        }
        @CasePathable
        @dynamicMemberLookup
        public enum Action: Equatable {
            case alarmInput
            case summary
        }
        public var body: some ReducerOf<Self> {
            EmptyReducer()
        }
    }

    @Dependency(\.jacsimClient) var jacsimClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .nextButtonTapped:
                state.path.append(.alarmInput)
                return .none
            case .confirmAlarmButtonTapped:
                state.path.append(.summary)
                return .none
            case .saveButtonTapped:
                return .run { [state, jacsimClient] send in
                    let task = Domain.Task(
                        id: TaskID(UUID()),
                        title: state.title,
                        startDate: state.startDate,
                        endDate: state.endDate,
                        stages: [],
                        records: []
                    )
                    try await jacsimClient.addTask(task)
                    await send(.saveCompleted)
                    await send(.delegate(.taskCreated))
                }
            case .saveCompleted:
                state.alert = AlertState {
                    TextState("저장 완료")
                } actions: {
                    ButtonState(role: .cancel, action: .send(.dismiss)) {
                        TextState("확인")
                    }
                } message: {
                    TextState("작심이 저장되었습니다")
                }
                return .none
            case .binding, .path, .cancelButtonTapped, .delegate, .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
}
