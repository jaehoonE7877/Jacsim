import Foundation
import Domain
import ComposableArchitecture
import UIKit
import Photos
import SwiftUI
import Core

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
        case saveCompleted(Result<Void, Error>)
        case toastDismissed
        case dismiss
        case delegate(Delegate)

        public enum Delegate {
            case saveSuccess
        }
    }

    @Dependency(\.certificationClient) var certificationClient
    @Dependency(\.imageStore) var imageStore
    @Dependency(\.notificationScheduler) var notificationScheduler
    @Dependency(\.userSettingsRepository) var userSettingsRepository

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.lastAcceptedMemo = state.memo
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
                return .run { [certificationClient, imageStore, notificationScheduler, userSettingsRepository] send in
                    Logger.certificationStarted(taskId: taskId.rawValue.uuidString, memo: memo, hasImage: image != nil)
                    let certifyStartTime = Date()
                    do {
                        if let image = image {
                            let data = try makeImageStoreInputData(from: image)
                            guard let imagePath else {
                                throw ImageStoreInputEncodingError.jpegEncodingFailed
                            }
                            _ = try await imageStore.saveImage(imagePath, data)
                            Logger.imageSaved(key: imagePath)
                        }
                        await certificationClient.certifyToday(taskId, index, memo, imagePath)
                        Logger.certificationCompleted(
                            duration: Date().timeIntervalSince(certifyStartTime),
                            index: index,
                            check: true,
                            memo: memo,
                            imagePath: imagePath
                        )
                        let isGlobalNotificationEnabled = await userSettingsRepository.isNotificationEnabled()
                        let reminders = await userSettingsRepository.getAllReminders()
                        let reminderUseCase = ReminderSchedulingUseCase()
                        await reminderUseCase.syncGlobalReminders(
                            isEnabled: isGlobalNotificationEnabled,
                            reminders: reminders,
                            notificationScheduler: notificationScheduler
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

            case .binding, .delegate:
                return .none
            }
        }
    }
}
