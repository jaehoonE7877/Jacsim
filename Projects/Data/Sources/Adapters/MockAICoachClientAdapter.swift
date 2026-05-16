import Domain
import ExternalInterface
import Foundation

public struct MockAICoachClientAdapter: AICoachClientPort {
    private let replies = [
        "오늘은 10분만 해도 충분해요. 작게 시작하면 흐름이 남습니다.",
        "지금 가장 쉬운 한 걸음을 골라볼까요? 성공률은 작게 반복할수록 올라가요.",
        "완벽한 하루보다 이어지는 하루가 더 강해요.",
        "오늘 인증할 시간을 하나만 정해두면 선택 피로가 줄어들어요.",
        "지금까지 이어온 기록을 보면 이미 시작할 힘은 충분해요.",
        "막히는 날에는 목표를 낮추고, 인증은 남겨두는 게 좋아요.",
        "친구에게 공유할 만큼 작고 분명한 성공을 하나 만들어봐요.",
        "오늘의 작심은 내일의 기준이 아니라, 다음 행동의 신호예요."
    ]

    public init() {}

    public func sendMessage(history: [CoachMessage], userInput: String) async throws -> CoachMessage {
        let index = history.count % replies.count
        return CoachMessage(role: .coach, text: replies[index])
    }

    public func weeklyReflection(tasks: [Task]) async throws -> CoachMessage {
        let completed = tasks.reduce(0) { $0 + $1.completedDays }
        let activeCount = tasks.filter { $0.currentStage != nil }.count
        let text = "이번 주에는 \(activeCount)개의 작심 흐름이 있었고, 총 \(completed)번의 인증이 쌓였어요. 다음 주는 가장 작은 작심 하나만 먼저 고정해봐요."
        return CoachMessage(role: .coach, text: text)
    }
}

