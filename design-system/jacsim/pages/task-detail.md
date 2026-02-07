# Task Detail Page Overrides

> Applies to: `Projects/Jacsim/Sources/Presentation/TaskDetail/TaskDetailView.swift`

## Layout Overrides

- 커버 이미지 + 축소 헤더 + 본문 섹션 + 하단 CTA 구조 고정
- 본문은 Stage -> Today Status -> Record List 순서 유지

## State Policy

- 기록 리스트 스크롤 이동 요청 시 anchor id를 유지
- Stage popup은 작업 흐름을 막지 않는 짧은 모션 사용

## Component Overrides

- 개요 배너 토글: `PresentationSectionKey.taskDetailOverview`
- 오늘 상태 토글: `PresentationSectionKey.taskDetailTodayStatus`
- 기록 목록 토글: `PresentationSectionKey.taskDetailRecordList`

## Accessibility Notes

- 삭제/편집/알림 메뉴 액션의 의미를 라벨로 명확히 전달
