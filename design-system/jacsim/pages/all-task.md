# All Task Page Overrides

> Applies to: `Projects/Jacsim/Sources/Presentation/AllTask/AllTaskView.swift`

## Layout Overrides

- 상태 그룹(진행/성공/실패) 3섹션을 카드 형태로 유지
- 섹션 접기/펼치기 토글은 섹션 헤더 내에서만 처리

## State Policy

- `loading`: 목록 fetch 중 전체 로딩 상태
- `empty`: 전체 작심 0개일 때 전역 empty 상태
- `error`: fetch 실패 시 retry 버튼 제공

## Component Overrides

- 요약 카드 노출은 `PresentationSectionKey.allTaskSummary`
- 리스트 아이템은 `JSListItem` + semantic status color

## Accessibility Notes

- 토글 버튼 라벨에 섹션명 + 개수 포함
