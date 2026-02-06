# Task Edit Page Overrides

> Applies to: `Projects/Jacsim/Sources/Presentation/TaskDetail/TaskEditView.swift`

## Layout Overrides

- 사진/기본정보/성공목표/알림 + 하단 저장 CTA 구조
- 하단 버튼은 sticky footer로 유지

## State Policy

- 저장 버튼은 제목 유효성 만족 시에만 활성

## Component Overrides

- 사진 섹션 토글: `PresentationSectionKey.taskFormPhoto`
- 알림 섹션 토글: `PresentationSectionKey.taskFormAlarm`
