import Testing

@testable import Jacsim

@Test("최대 글자수 이하 입력은 허용된다")
func inputLimitAcceptsWithinLimit() {
    let result = TextInputLimiter.enforce(
        previousAcceptedText: "작심",
        candidateText: "오늘도 작심",
        policy: .memo
    )

    #expect(result == .accepted("오늘도 작심"))
}

@Test("최대 글자수를 초과하면 전체 입력을 거부하고 이전 값을 유지한다")
func inputLimitRejectsExcessInput() {
    let previous = "기존값"
    let candidate = String(repeating: "가", count: TextInputFieldPolicy.title.maxLength + 1)

    let result = TextInputLimiter.enforce(
        previousAcceptedText: previous,
        candidateText: candidate,
        policy: .title
    )

    #expect(result == .rejected(keep: previous))
}

@Test("입력 정책의 최대 글자수와 안내 문구가 설정되어 있다")
func inputFieldPolicyMetadata() {
    #expect(TextInputFieldPolicy.title.maxLength == 20)
    #expect(TextInputFieldPolicy.memo.maxLength == 30)
    #expect(TextInputFieldPolicy.title.exceededToastMessage == "제목은 최대 20자까지 입력할 수 있어요")
    #expect(TextInputFieldPolicy.memo.exceededToastMessage == "메모는 최대 30자까지 입력할 수 있어요")
}
