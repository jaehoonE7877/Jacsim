import Foundation
import Domain
import ComposableArchitecture
import UIKit
import Photos
import PhotosUI
import SwiftUI

@Reducer
public struct TaskUpdateFeature {
    @ObservableState
    public struct State: Equatable {
        public var task: Domain.Task
        public var index: Int
        public var memo: String = ""
        public var image: UIImage?
        public var dateText: String
        public var photoPickerItem: PhotosPickerItem?

        public init(task: Domain.Task, index: Int) {
            self.task = task
            self.index = index
            self.dateText = DateFormatType.toString(task.dayArray[index], to: .fullWithoutYear)
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case imageLoaded(UIImage?)
        case certifyButtonTapped
        case imageSelected(UIImage)
        case photoPickerItemChanged(PhotosPickerItem?)
        case delegate(Delegate)
        
        public enum Delegate {
            case memoUpdated
        }
    }

    @Dependency(\.jacsimClient) var jacsimClient
    @Dependency(\.imageStore) var imageStore

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let key = state.task.imageKey(for: state.index) else { return .none }
                return .run { [imageStore] send in
                    let imageData = await imageStore.loadImage(key)
                    let image = imageData.flatMap { UIImage(data: $0) }
                    await send(.imageLoaded(image))
                }

            case let .imageLoaded(image):
                state.image = image
                return .none

            case .certifyButtonTapped:
                let taskId = state.task.id
                let index = state.index
                let memo = state.memo.trimmingCharacters(in: .whitespacesAndNewlines)
                let image = state.image
                let dateText = state.dateText
                return .run { [jacsimClient, imageStore] send in
                    await jacsimClient.updateMemo(taskId, index, memo)
                    if let image = image {
                        let data = image.jpegData(compressionQuality: 0.4)
                        if let data {
                            _ = try? await imageStore.saveImage("\(taskId.rawValue)_\(dateText).jpg", data)
                        }
                    }
                    await send(.delegate(.memoUpdated))
                }

            case .binding(\.memo):
                let trimmed = state.memo.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.count > 50 {
                    state.memo = String(trimmed.prefix(50))
                }
                return .none

            case let .imageSelected(image):
                state.image = image
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
