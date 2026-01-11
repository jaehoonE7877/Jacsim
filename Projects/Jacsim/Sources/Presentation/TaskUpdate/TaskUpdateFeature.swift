import Foundation
import ComposableArchitecture
import UIKit
import AVFoundation
import Photos
import PhotosUI
import SwiftUI

@Reducer
public struct TaskUpdateFeature {
    @ObservableState
    public struct State: Equatable {
        public var task: UserJacsim
        public var index: Int
        public var memo: String = ""
        public var image: UIImage?
        public var dateText: String
        public var isShowingCamera = false
        public var isShowingPhotoPicker = false
        public var photoPickerItem: PhotosPickerItem?

        public init(task: UserJacsim, index: Int) {
            self.task = task
            self.index = index
            self.dateText = DateFormatType.toString(task.jacsimDayArray[index], to: .fullWithoutYear)
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case imageLoaded(UIImage?)
        case certifyButtonTapped
        case cameraButtonTapped
        case galleryButtonTapped
        case cameraAuthorizationFinished(Bool)
        case photoLibraryAuthorizationFinished(Bool)
        case imageSelected(UIImage)
        case photoPickerItemChanged(PhotosPickerItem?)
        case delegate(Delegate)
        
        public enum Delegate {
            case memoUpdated
        }
    }

    @Dependency(\.jacsimClient) var jacsimClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                let fileName = "\(state.task.id)_\(state.dateText).jpg"
                return .run { send in
                    let image = await DocumentManager.shared.loadImage(fileName: fileName)
                    await send(.imageLoaded(image))
                }

            case let .imageLoaded(image):
                state.image = image
                return .none

            case .certifyButtonTapped:
                let task = state.task
                let index = state.index
                let memo = state.memo.trimmingCharacters(in: .whitespacesAndNewlines)
                let image = state.image
                let dateText = state.dateText
                return .run { send in
                    await jacsimClient.updateMemo(task, index, memo)
                    if let image = image {
                        DocumentManager.shared.saveImageToDocument(fileName: "\(task.id)_\(dateText).jpg", image: image)
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

            case .cameraButtonTapped:
                return .run { send in
                    let status = AVCaptureDevice.authorizationStatus(for: .video)
                    switch status {
                    case .authorized:
                        await send(.cameraAuthorizationFinished(true))
                    case .notDetermined:
                        let granted = await requestCameraAccess()
                        await send(.cameraAuthorizationFinished(granted))
                    default:
                        await send(.cameraAuthorizationFinished(false))
                    }
                }

            case let .cameraAuthorizationFinished(isAuthorized):
                state.isShowingCamera = isAuthorized
                return .none

            case .galleryButtonTapped:
                return .run { send in
                    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                    switch status {
                    case .authorized, .limited:
                        await send(.photoLibraryAuthorizationFinished(true))
                    case .notDetermined:
                        let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                        await send(.photoLibraryAuthorizationFinished(newStatus == .authorized || newStatus == .limited))
                    default:
                        await send(.photoLibraryAuthorizationFinished(false))
                    }
                }

            case let .photoLibraryAuthorizationFinished(isAuthorized):
                state.isShowingPhotoPicker = isAuthorized
                return .none

            case let .photoPickerItemChanged(item):
                guard let item = item else {
                    state.isShowingPhotoPicker = false
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

private func requestCameraAccess() async -> Bool {
    await withCheckedContinuation { continuation in
        AVCaptureDevice.requestAccess(for: .video) { granted in
            continuation.resume(returning: granted)
        }
    }
}
