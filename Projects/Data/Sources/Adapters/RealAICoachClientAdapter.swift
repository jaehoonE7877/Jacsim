import Domain
import ExternalInterface
import Foundation

public struct RealAICoachClientAdapter: AICoachClientPort {
    public init() {}

    public func sendMessage(history: [CoachMessage], userInput: String) async throws -> CoachMessage {
        fatalError("Not yet implemented")
    }

    public func weeklyReflection(tasks: [Task]) async throws -> CoachMessage {
        fatalError("Not yet implemented")
    }
}

