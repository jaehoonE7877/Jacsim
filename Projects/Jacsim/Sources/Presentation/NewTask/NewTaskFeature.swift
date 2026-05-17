import Core
import Domain
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
public final class NewTaskModel {
    public enum CreateChallengeStep: Int, CaseIterable, Equatable {
        case basicInfo
        case photo
        case alarmConfirm

        var title: String {
            switch self {
            case .basicInfo:
                return "기본 정보"
            case .photo:
                return "대표 사진"
            case .alarmConfirm:
                return "알림 및 확인"
            }
        }

        var description: String {
            switch self {
            case .basicInfo:
                return "제목과 기간을 먼저 정해요"
            case .photo:
                return "대표 사진은 필수예요"
            case .alarmConfirm:
                return "알림을 선택하고 시작해요"
            }
        }

        var next: CreateChallengeStep? {
            switch self {
            case .basicInfo:
                return .photo
            case .photo:
                return .alarmConfirm
            case .alarmConfirm:
                return nil
            }
        }

        var previous: CreateChallengeStep? {
            switch self {
            case .basicInfo:
                return nil
            case .photo:
                return .basicInfo
            case .alarmConfirm:
                return .photo
            }
        }
    }

    public enum StepValidationError: Equatable {
        case emptyTitle
        case missingPhoto

        var message: String {
            switch self {
            case .emptyTitle:
                return "작심 제목을 입력해 주세요"
            case .missingPhoto:
                return "대표 사진을 선택해 주세요"
            }
        }
    }

    public var title: String = "" {
        didSet { enforceTitleLimit() }
    }
    public var lastAcceptedTitle: String = ""
    public var image: UIImage?
    public var stageType: StageType = .three
    public var startDate: Date = Calendar.current.startOfDay(for: Date())
    public var endDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: Calendar.current.startOfDay(for: Date())) ?? Date()
    public var visibility: TaskVisibility = .private
    public var alarmDate: Date = NewTaskModel.defaultAlarmDate()
    public var isAlarmEnabled: Bool = false
    public var isSaving: Bool = false
    public var saveFailed: Bool = false
    public var toastMessage: String?
    public var currentStep: CreateChallengeStep = .basicInfo
    public var stepValidationError: StepValidationError?
    public var isDiscardingDraft: Bool = false
    public var isDiscardAlertPresented: Bool = false

    @ObservationIgnored private let dependencies: JacsimDependencies
    @ObservationIgnored private let onTaskCreated: () -> Void
    @ObservationIgnored private let onTaskCreatedWithTask: (Domain.Task) -> Void
    @ObservationIgnored private let onCancelled: () -> Void
    @ObservationIgnored private var isEnforcingTitle = false

    public init(
        dependencies: JacsimDependencies,
        prefillTitle: String? = nil,
        onTaskCreated: @escaping () -> Void = {},
        onTaskCreatedWithTask: @escaping (Domain.Task) -> Void = { _ in },
        onCancelled: @escaping () -> Void = {}
    ) {
        self.dependencies = dependencies
        self.onTaskCreated = onTaskCreated
        self.onTaskCreatedWithTask = onTaskCreatedWithTask
        self.onCancelled = onCancelled
        self.alarmDate = Self.defaultAlarmDate()
        if let prefillTitle {
            let title = String(
                prefillTitle
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .prefix(TextInputFieldPolicy.title.maxLength)
            )
            if !title.isEmpty {
                self.title = title
                self.lastAcceptedTitle = title
            }
        }
    }

    public var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var canProceedCurrentStep: Bool {
        switch currentStep {
        case .basicInfo:
            return !trimmedTitle.isEmpty
        case .photo:
            return image != nil
        case .alarmConfirm:
            return true
        }
    }

    public var canSubmit: Bool {
        !trimmedTitle.isEmpty
    }

    public var hasDraftContent: Bool {
        !trimmedTitle.isEmpty || image != nil || stageType != .three || isAlarmEnabled || visibility != .private
    }

    public func nextStepTapped() {
        guard let next = currentStep.next else { return }
        guard let validationError = validationError(for: currentStep) else {
            stepValidationError = nil
            currentStep = next
            return
        }
        stepValidationError = validationError
    }

    public func previousStepTapped() {
        guard let previous = currentStep.previous else { return }
        currentStep = previous
        stepValidationError = nil
    }

    public func saveButtonTapped() {
        let trimmedTitle = trimmedTitle

        if trimmedTitle.isEmpty {
            currentStep = .basicInfo
            stepValidationError = .emptyTitle
            return
        }

        isSaving = true
        saveFailed = false
        stepValidationError = nil
        let stageType = stageType
        let startDate = Calendar.current.startOfDay(for: startDate)
        let endDate = Calendar.current.startOfDay(for: endDate)

        let isAlarmEnabled = isAlarmEnabled
        let alarmDate = alarmDate
        let visibility = visibility
        let createTaskUseCase = CreateTaskUseCase()
        var task = createTaskUseCase.createTask(
            title: trimmedTitle,
            startDate: startDate,
            endDate: endDate,
            stageType: stageType
        )
        task.isNotificationEnabled = isAlarmEnabled
        task.alarm = isAlarmEnabled ? alarmDate : nil
        task.visibility = visibility
        let taskToSave = task

        Logger.taskCreated(
            title: taskToSave.title,
            taskId: taskToSave.id.rawValue.uuidString,
            startDate: taskToSave.startDate,
            endDate: taskToSave.endDate
        )

        _Concurrency.Task { [dependencies] in
            do {
                if let image {
                    let data = try makeImageStoreInputData(from: image)
                    _ = try await dependencies.imageStore.saveImage(taskToSave.mainImageKey, data)
                }
                try await dependencies.taskCommandClient.addTask(taskToSave)
                let reminderUseCase = ReminderSchedulingUseCase()
                let isNotificationEnabled = await dependencies.userSettingsRepository.isNotificationEnabled()
                let reminders = await dependencies.userSettingsRepository.getAllReminders()
                await reminderUseCase.syncGlobalReminders(
                    isEnabled: isNotificationEnabled,
                    reminders: reminders,
                    notificationScheduler: dependencies.notificationScheduler
                )
                saveCompleted(.success(taskToSave))
            } catch {
                saveCompleted(.failure(error))
            }
        }
    }

    public func suggestionTapped(_ suggestion: String) {
        title = suggestion
    }

    public func startDateChanged(_ date: Date) {
        startDate = Calendar.current.startOfDay(for: date)
        let minimumEndDate = Calendar.current.date(
            byAdding: .day,
            value: stageType.durationDays - 1,
            to: startDate
        ) ?? startDate
        if endDate < startDate || endDate < minimumEndDate {
            endDate = minimumEndDate
        }
    }

    public func endDateChanged(_ date: Date) {
        let normalized = Calendar.current.startOfDay(for: date)
        endDate = max(normalized, startDate)
    }

    public func stageTypeChanged(_ stageType: StageType) {
        self.stageType = stageType
        endDate = Calendar.current.date(
            byAdding: .day,
            value: stageType.durationDays - 1,
            to: startDate
        ) ?? startDate
    }

    public func imageSelected(_ image: UIImage) {
        self.image = image
        saveFailed = false
        if currentStep == .photo {
            stepValidationError = nil
        }
    }

    public func toastDismissed() {
        toastMessage = nil
    }

    public func cancelButtonTapped() {
        guard !isDiscardingDraft else { return }
        guard hasDraftContent else {
            onCancelled()
            return
        }
        isDiscardAlertPresented = true
    }

    public func confirmDiscardDraft() {
        isDiscardAlertPresented = false
        isDiscardingDraft = true
        onCancelled()
    }

    private static func defaultAlarmDate() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 21
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    private func saveCompleted(_ result: Result<Domain.Task, Error>) {
        switch result {
        case let .success(task):
            isSaving = false
            onTaskCreated()
            onTaskCreatedWithTask(task)
        case .failure:
            isSaving = false
            saveFailed = true
        }
    }

    private func validationError(for step: CreateChallengeStep) -> StepValidationError? {
        switch step {
        case .basicInfo:
            return trimmedTitle.isEmpty ? .emptyTitle : nil
        case .photo:
            return image == nil ? .missingPhoto : nil
        case .alarmConfirm:
            return nil
        }
    }

    private func enforceTitleLimit() {
        guard !isEnforcingTitle else { return }
        saveFailed = false
        let result = TextInputLimiter.enforce(
            previousAcceptedText: lastAcceptedTitle,
            candidateText: title,
            policy: .title
        )
        isEnforcingTitle = true
        switch result {
        case let .accepted(text):
            title = text
            lastAcceptedTitle = text
            if currentStep == .basicInfo, !trimmedTitle.isEmpty {
                stepValidationError = nil
            }
        case let .rejected(keep):
            title = keep
            toastMessage = TextInputFieldPolicy.title.exceededToastMessage
        }
        isEnforcingTitle = false
    }
}
