import Core
import Domain
import Foundation
import Observation
import Photos
import SwiftUI
import UIKit

@MainActor
@Observable
public final class TaskUpdateModel {
    public var task: Domain.Task
    public var index: Int
    public var memo: String = "" {
        didSet { enforceMemoLimit() }
    }
    public var lastAcceptedMemo: String = ""
    public var image: UIImage?
    public var dateText: String
    public var isSaving: Bool = false
    public var saveFailed: Bool = false
    public var isOverwriteMode: Bool = false
    public var toastMessage: String?

    @ObservationIgnored private let dependencies: JacsimDependencies
    @ObservationIgnored private let onSaveSuccess: () -> Void
    @ObservationIgnored private var loadImageTask: _Concurrency.Task<Void, Never>?
    @ObservationIgnored private var saveTask: _Concurrency.Task<Void, Never>?
    @ObservationIgnored private var isEnforcingMemo = false

    public init(
        task: Domain.Task,
        index: Int,
        dependencies: JacsimDependencies,
        onSaveSuccess: @escaping () -> Void = {}
    ) {
        self.task = task
        self.index = index
        self.dependencies = dependencies
        self.onSaveSuccess = onSaveSuccess
        self.dateText = DateFormatType.toString(task.dayArray[index], to: .fullWithoutYear)
        self.isOverwriteMode = task.records.indices.contains(index) && task.records[index].check
    }

    deinit {
        loadImageTask?.cancel()
        saveTask?.cancel()
    }

    public func onAppear() {
        lastAcceptedMemo = memo
        guard let key = task.imageKey(for: index) else { return }
        loadImageTask?.cancel()
        loadImageTask = _Concurrency.Task { [dependencies] in
            let imageData = await dependencies.imageStore.loadImage(key)
            let image = imageData.flatMap { UIImage(data: $0) }
            imageLoaded(image)
        }
    }

    public func certifyButtonTapped() {
        isSaving = true
        saveFailed = false
        let taskId = task.id
        let index = index
        let memo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let image = image
        let imagePath = image != nil ? task.imageKey(for: index) : nil

        saveTask?.cancel()
        saveTask = _Concurrency.Task { [dependencies] in
            Logger.certificationStarted(taskId: taskId.rawValue.uuidString, memo: memo, hasImage: image != nil)
            let certifyStartTime = Date()
            do {
                if let image {
                    let data = try makeImageStoreInputData(from: image)
                    guard let imagePath else {
                        throw ImageStoreInputEncodingError.jpegEncodingFailed
                    }
                    _ = try await dependencies.imageStore.saveImage(imagePath, data)
                    Logger.imageSaved(key: imagePath)
                }
                await dependencies.certificationClient.certifyToday(taskId, index, memo, imagePath)
                Logger.certificationCompleted(
                    duration: Date().timeIntervalSince(certifyStartTime),
                    index: index,
                    check: true,
                    memo: memo,
                    imagePath: imagePath
                )
                let isGlobalNotificationEnabled = await dependencies.userSettingsRepository.isNotificationEnabled()
                let reminders = await dependencies.userSettingsRepository.getAllReminders()
                let reminderUseCase = ReminderSchedulingUseCase()
                await reminderUseCase.syncGlobalReminders(
                    isEnabled: isGlobalNotificationEnabled,
                    reminders: reminders,
                    notificationScheduler: dependencies.notificationScheduler
                )
                saveCompleted(.success(()))
            } catch {
                Logger.certificationFailed(error: error)
                saveCompleted(.failure(error))
            }
        }
    }

    public func imageSelected(_ image: UIImage) {
        self.image = image
        saveFailed = false
    }

    public func toastDismissed() {
        toastMessage = nil
    }

    private func imageLoaded(_ image: UIImage?) {
        self.image = image
    }

    private func saveCompleted(_ result: Result<Void, Error>) {
        switch result {
        case .success:
            isSaving = false
            onSaveSuccess()
        case .failure:
            isSaving = false
            saveFailed = true
        }
    }

    private func enforceMemoLimit() {
        guard !isEnforcingMemo else { return }
        let result = TextInputLimiter.enforce(
            previousAcceptedText: lastAcceptedMemo,
            candidateText: memo,
            policy: .memo
        )
        isEnforcingMemo = true
        switch result {
        case let .accepted(text):
            memo = text
            lastAcceptedMemo = text
        case let .rejected(keep):
            memo = keep
            toastMessage = TextInputFieldPolicy.memo.exceededToastMessage
        }
        isEnforcingMemo = false
    }
}
