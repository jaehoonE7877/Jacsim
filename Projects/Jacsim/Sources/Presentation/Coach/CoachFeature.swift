import Domain
import ExternalInterface
import Foundation
import Observation

@MainActor
@Observable
public final class CoachModel {
    public var messages: [CoachMessage] = []
    public var draft: String = ""
    public var isSending: Bool = false
    public var toastMessage: String?

    @ObservationIgnored private let dependencies: JacsimDependencies
    @ObservationIgnored private var sendTask: _Concurrency.Task<Void, Never>?

    public init(dependencies: JacsimDependencies) {
        self.dependencies = dependencies
    }

    deinit {
        sendTask?.cancel()
    }

    public var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    public func sendTapped() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }

        let userMessage = CoachMessage(role: .user, text: text)
        messages.append(userMessage)
        draft = ""
        requestCoachReply(userInput: text)
    }

    public func weeklyReflectionTapped() {
        guard !isSending else { return }
        isSending = true
        toastMessage = nil
        sendTask?.cancel()
        sendTask = _Concurrency.Task { [dependencies] in
            do {
                let active = try await dependencies.taskQueryClient.fetchActiveTasks()
                let done = try await dependencies.taskQueryClient.fetchTasksByStatus(.done)
                let reply = try await dependencies.aiCoachClient.weeklyReflection(tasks: active + done)
                messages.append(reply)
                isSending = false
            } catch {
                isSending = false
                toastMessage = "회고를 만들지 못했어요"
            }
        }
    }

    public func dismissToast() {
        toastMessage = nil
    }

    private func requestCoachReply(userInput: String) {
        isSending = true
        toastMessage = nil
        let history = messages
        sendTask?.cancel()
        sendTask = _Concurrency.Task { [dependencies] in
            do {
                let reply = try await dependencies.aiCoachClient.sendMessage(
                    history: history,
                    userInput: userInput
                )
                messages.append(reply)
                isSending = false
            } catch {
                isSending = false
                toastMessage = "답변을 받지 못했어요"
            }
        }
    }
}
