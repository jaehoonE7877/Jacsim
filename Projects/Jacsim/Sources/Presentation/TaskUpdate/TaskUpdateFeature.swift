import Foundation
import Domain
import ComposableArchitecture
import UIKit
import Photos
import PhotosUI
import SwiftUI
import Shared

@Reducer
public struct TaskUpdateFeature {
    @ObservableState
    public struct State: Equatable {
        public var task: Domain.Task
        public var index: Int
        public var memo: String = ""
        public var lastAcceptedMemo: String = ""
        public var image: UIImage?
        public var dateText: String
        public var photoPickerItem: PhotosPickerItem?
        public var isSaving: Bool = false
        public var saveFailed: Bool = false
        public var isOverwriteMode: Bool = false
        public var toastMessage: String? = nil

        public init(task: Domain.Task, index: Int) {
            self.task = task
            self.index = index
            self.dateText = DateFormatType.toString(task.dayArray[index], to: .fullWithoutYear)
            self.isOverwriteMode = task.records.indices.contains(index) && task.records[index].check
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case imageLoaded(UIImage?)
        case certifyButtonTapped
        case imageSelected(UIImage)
        case photoPickerItemChanged(PhotosPickerItem?)
        case saveCompleted(Result<Void, Error>)
        case toastDismissed
        case dismiss
        case delegate(Delegate)

        public enum Delegate {
            case saveSuccess
        }
    }

    @Dependency(\.certifyTaskTodayUseCase) var certifyTaskTodayUseCase
    @Dependency(\.loadImageUseCase) var loadImageUseCase

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.lastAcceptedMemo = state.memo
                guard let key = state.task.imageKey(for: state.index) else { return .none }
                return .run { [loadImageUseCase] send in
                    let imageData = await loadImageUseCase.loadImage(key)
                    let image = imageData.flatMap { UIImage(data: $0) }
                    await send(.imageLoaded(image))
                }

            case let .imageLoaded(image):
                state.image = image
                return .none

            case .certifyButtonTapped:
                state.isSaving = true
                state.saveFailed = false
                let memo = state.memo.trimmingCharacters(in: .whitespacesAndNewlines)
                let imageData = state.image?.jpegData(compressionQuality: 0.4)
                let input = CertifyTaskTodayUseCase.Input(
                    task: state.task,
                    index: state.index,
                    memo: memo,
                    imageData: imageData
                )
                return .run { [certifyTaskTodayUseCase] send in
                    do {
                        try await certifyTaskTodayUseCase.execute(input)
                        await send(.saveCompleted(.success(())))
                    } catch {
                        await send(.saveCompleted(.failure(error)))
                    }
                }

            case .saveCompleted(.success):
                state.isSaving = false
                return .send(.delegate(.saveSuccess))

            case .saveCompleted(.failure):
                state.isSaving = false
                state.saveFailed = true
                return .none

            case .toastDismissed:
                state.toastMessage = nil
                return .none

            case .dismiss:
                return .none

            case .binding(\.memo):
                let result = TextInputLimiter.enforce(
                    previousAcceptedText: state.lastAcceptedMemo,
                    candidateText: state.memo,
                    policy: .memo
                )
                switch result {
                case let .accepted(text):
                    state.memo = text
                    state.lastAcceptedMemo = text
                case let .rejected(keep):
                    state.memo = keep
                    state.toastMessage = TextInputFieldPolicy.memo.exceededToastMessage
                }
                return .none

            case let .imageSelected(image):
                state.image = image
                state.saveFailed = false
                return .none

            case let .photoPickerItemChanged(item):
                guard let item = item else {
                    return .none
                }
                return .run { send in
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await send(.imageSelected(image))
                    }
                }

            case .binding, .delegate:
                return .none
            }
        }
    }
}
