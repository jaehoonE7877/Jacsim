import Foundation
import struct Domain.Task

public enum CoachMessageRole: String, Codable, Sendable {
    case coach
    case user
}

public struct CoachMessage: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public var role: CoachMessageRole
    public var text: String
    public var timestamp: Date

    public init(
        id: UUID = UUID(),
        role: CoachMessageRole,
        text: String,
        timestamp: Date = .now
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
    }
}

public protocol AICoachClientPort: Sendable {
    func sendMessage(history: [CoachMessage], userInput: String) async throws -> CoachMessage
    func weeklyReflection(tasks: [Task]) async throws -> CoachMessage
}

