# Task Update Page Overrides

> Applies to: `Projects/Jacsim/Sources/Presentation/TaskUpdate/TaskUpdateView.swift`

## Layout Overrides

- 인증 사진 + 메모 + 하단 인증 CTA 구조
- overwrite 안내 배너는 콘텐츠 상단 고정

## State Policy

- 저장 실패 시 인라인 오류 표시
- 저장 중에는 화면 overlay + CTA 비활성 유지

## Component Overrides

- 사진 섹션 토글: `PresentationSectionKey.taskFormPhoto`
