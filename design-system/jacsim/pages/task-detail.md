# 작업 상세 페이지 오버라이드

> 적용 대상: `Projects/Jacsim/Sources/Presentation/TaskDetail/TaskDetailView.swift`

## 레이아웃 오버라이드

- 커버 이미지 + 축소 헤더 + 본문 섹션 + 하단 CTA 구조 고정
- 본문은 Stage -> Today Status -> Record List 순서 유지

## 상태 정책

- 기록 리스트 스크롤 이동 요청 시 anchor id를 유지
- Stage popup은 작업 흐름을 막지 않는 짧은 모션 사용

## 컴포넌트 오버라이드

- 본문 섹션은 Stage -> Today Status -> Record List를 고정 노출

## 접근성 노트

- 삭제/편집/알림 메뉴 액션의 의미를 라벨로 명확히 전달
