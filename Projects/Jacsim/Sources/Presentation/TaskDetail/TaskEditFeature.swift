import Foundation
import ComposableArchitecture
import UIKit
import AVFoundation
import Photos

@Reducer
public struct TaskEditFeature {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: UUID { task.id }
        public var task: UserJacsim
        public var title: String
        public var successTarget: Int
        public var maxSuccessTarget: Int
        public var image: UIImage?
        public var isAlarmEnabled: Bool
        public var alarmDate: Date
        public var isShowingCamera = false
        public var isShowingPhotoPicker = false

        public init(task: UserJacsim, maxSuccessTarget: Int) {
            self.task = task
            self.title = task.title
            self.successTarget = task.success
            self.maxSuccessTarget = maxSuccessTarget
            self.isAlarmEnabled = task.alarm != nil
            self.alarmDate = task.alarm ?? Date()
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case imageLoaded(UIImage?)
        case saveButtonTapped
        case cancelButtonTapped
        case cameraButtonTapped
        case galleryButtonTapped
        case cameraAuthorizationFinished(Bool)
        case photoLibraryAuthorizationFinished(Bool)
        case imageSelected(UIImage)
        case delegate(Delegate)

        public enum Delegate {
            case saved(String, Int, UIImage?, Bool, Date)
            case cancelled
        }
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                let fileName = state.task.mainImageURL
                return .run { send in
                    let image = await DocumentManager.shared.loadImage(fileName: fileName)
                    await send(.imageLoaded(image))
                }

            case let .imageLoaded(image):
                state.image = image
                return .none

            case .saveButtonTapped:
                let title = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
                return .send(.delegate(.saved(title, state.successTarget, state.image, state.isAlarmEnabled, state.alarmDate)))

            case .cancelButtonTapped:
                return .send(.delegate(.cancelled))

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
