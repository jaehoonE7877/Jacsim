import Foundation
import SwiftData
import Domain
import ComposableArchitecture
import UIKit
import Photos
import PhotosUI
import SwiftUI
import Data
import Core

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
        public var isSaving: Bool = false
        public var saveFailed: Bool = false
        public var isOverwriteMode: Bool = false

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
        case dismiss
        case delegate(Delegate)

        public enum Delegate {
            case saveSuccess
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
                state.isSaving = true
                state.saveFailed = false
                let taskId = state.task.id
                let index = state.index
                let memo = state.memo.trimmingCharacters(in: .whitespacesAndNewlines)
                let image = state.image
                let imagePath = image != nil ? state.task.imageKey(for: index) : nil
                return .run { [jacsimClient, imageStore] send in
                    Logger.certificationStarted(taskId: taskId.rawValue.uuidString, memo: memo, hasImage: image != nil)
                    let certifyStartTime = Date()
                    do {
                        if let image = image {
                            let data = image.jpegData(compressionQuality: 0.4)
                            if let data, let imagePath = imagePath {
                                _ = try await imageStore.saveImage(imagePath, data)
                                Logger.imageSaved(key: imagePath)
                            }
                        }
                        try await jacsimClient.certifyToday(taskId, index, memo, imagePath)
                        Logger.certificationCompleted(
                            duration: Date().timeIntervalSince(certifyStartTime),
                            index: index,
                            check: true,
                            memo: memo,
                            imagePath: imagePath
                        )
                        await send(.saveCompleted(.success(())))
                    } catch {
                        Logger.certificationFailed(error: error)
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

            case .dismiss:
                return .none

            case .binding(\.memo):
                let trimmed = state.memo.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.count > 20 {
                    state.memo = String(trimmed.prefix(20))
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
