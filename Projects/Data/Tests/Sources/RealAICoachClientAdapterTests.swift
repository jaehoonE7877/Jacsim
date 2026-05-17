import Data
import Domain
import Foundation
import Testing

@Test("RealAICoachClientAdapter는 일반 메시지에 대해 크래시 없이 코치 응답을 반환한다")
func realAICoachClientSendMessageReturnsCoachReply() async throws {
    let adapter = RealAICoachClientAdapter()

    let reply = try await adapter.sendMessage(history: [], userInput: "오늘 실패한 것 같아요")

    #expect(reply.role == .coach)
    #expect(reply.text.isEmpty == false)
}

@Test("RealAICoachClientAdapter는 주간 회고를 크래시 없이 반환한다")
func realAICoachClientWeeklyReflectionReturnsCoachReply() async throws {
    let adapter = RealAICoachClientAdapter()
    let task = Domain.Task(
        id: TaskID(UUID()),
        title: "매일 산책",
        startDate: Date(),
        endDate: Date()
    )

    let reply = try await adapter.weeklyReflection(tasks: [task])

    #expect(reply.role == .coach)
    #expect(reply.text.contains("매일 산책"))
}
