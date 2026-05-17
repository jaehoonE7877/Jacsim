import Domain
import ExternalInterface
import Foundation

public struct RealAICoachClientAdapter: AICoachClientPort {
    public init() {}

    public func sendMessage(history: [CoachMessage], userInput: String) async throws -> CoachMessage {
        let text = response(for: userInput, historyCount: history.count)
        return CoachMessage(role: .coach, text: text)
    }

    public func weeklyReflection(tasks: [Task]) async throws -> CoachMessage {
        guard !tasks.isEmpty else {
            return CoachMessage(
                role: .coach,
                text: "이번 주에는 아직 작심 기록이 없어요. 다음 주는 3일짜리 작심 하나를 작게 시작해보세요."
            )
        }

        let activeCount = tasks.filter { $0.currentStage != nil }.count
        let completedCount = tasks.reduce(0) { $0 + $1.completedDays }
        let totalDays = tasks.reduce(0) { $0 + $1.dayArray.count }
        let completionRate = totalDays == 0 ? 0 : Int((Double(completedCount) / Double(totalDays) * 100).rounded())
        let strongestTask = tasks.max { $0.completedDays < $1.completedDays }
        let focusTitle = strongestTask?.title ?? "가장 쉬운 작심"
        let text = "이번 주에는 \(activeCount)개의 작심이 움직였고 인증률은 약 \(completionRate)%예요. 다음 주는 '\(focusTitle)'의 인증 시간을 먼저 고정하면 흐름을 이어가기 좋습니다."
        return CoachMessage(role: .coach, text: text)
    }

    private func response(for userInput: String, historyCount: Int) -> String {
        let input = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = input.lowercased()

        if normalized.contains("실패") || normalized.contains("못") || normalized.contains("포기") {
            return "오늘은 기준을 낮춰서 다시 이어가는 날로 잡아도 됩니다. 5분짜리 인증 하나만 남기면 실패 흐름을 끊을 수 있어요."
        }

        if normalized.contains("알림") || normalized.contains("시간") || normalized.contains("언제") {
            return "인증 시간은 의지가 아니라 반복 가능한 생활 리듬에 붙이는 게 좋아요. 이미 매일 하는 행동 직후로 10분만 예약해보세요."
        }

        if normalized.contains("친구") || normalized.contains("공유") || normalized.contains("자랑") {
            return "공유할 기록은 거창할 필요가 없어요. 오늘 완료한 한 장면과 다음 행동 하나를 같이 남기면 친구가 응원하기 쉬워집니다."
        }

        if historyCount > 4 {
            return "지금 대화에서 계속 나온 핵심은 작게 유지하는 거예요. 오늘은 가장 쉬운 인증 하나를 끝내고, 내일 같은 시간에 반복해보세요."
        }

        return input.isEmpty
            ? "지금 가장 쉬운 작심 하나를 골라 10분만 시작해보세요. 작게 끝내는 기록이 다음 행동을 만듭니다."
            : "'\(input)'라면 오늘 할 수 있는 최소 단위부터 정하는 게 좋아요. 10분, 한 번, 한 장처럼 바로 인증 가능한 기준으로 낮춰보세요."
    }
}
