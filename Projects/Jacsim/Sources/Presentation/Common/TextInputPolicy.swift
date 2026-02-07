import Foundation

enum TextInputFieldPolicy {
    case title
    case memo

    var maxLength: Int {
        switch self {
        case .title:
            return 20
        case .memo:
            return 30
        }
    }

    var exceededToastMessage: String {
        switch self {
        case .title:
            return "제목은 최대 20자까지 입력할 수 있어요"
        case .memo:
            return "메모는 최대 30자까지 입력할 수 있어요"
        }
    }
}

enum TextInputLimiter {
    static func enforce(
        previousAcceptedText: String,
        candidateText: String,
        policy: TextInputFieldPolicy
    ) -> TextInputLimitResult {
        guard candidateText.count <= policy.maxLength else {
            // Reject the whole change to keep typing and paste behavior predictable.
            return .rejected(keep: previousAcceptedText)
        }
        return .accepted(candidateText)
    }
}

enum TextInputLimitResult: Equatable {
    case accepted(String)
    case rejected(keep: String)
}
