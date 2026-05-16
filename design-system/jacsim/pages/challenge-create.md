# 챌린지 생성 페이지 오버라이드

> 적용 대상: `Projects/Jacsim/Sources/Presentation/ChallengeCreate/ChallengeCreateView.swift`

## 레이아웃 오버라이드

- 신규 화면 확장 없이 `NewTaskView` 흐름을 재사용
- 모달 맥락에서 CTA 우선순위(저장 > 취소) 유지

## 컴포넌트 오버라이드

- 별도 시각 규칙 추가 금지
- `new-task` override를 그대로 상속
