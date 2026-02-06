# Calendar Page Overrides

> Applies to: `Projects/Jacsim/Sources/Presentation/Calendar/CalendarView.swift`

## Layout Overrides

- 상단 캘린더 + 하단 날짜 기록 리스트 2단 구조
- 날짜 헤더는 선택 날짜와 기록 개수를 함께 노출

## State Policy

- `loading`: 캘린더 데이터 fetch 중
- `empty`: 활성 작심이 없을 때 전역 empty
- `error`: fetch 실패 시 retry 제공

## Component Overrides

- 캘린더는 `JSCalendar` 단일 컴포넌트 유지
- 날짜별 상태 색상은 `TaskSuccessRate -> JSCalendarDateColor` 매핑

## Accessibility Notes

- 날짜 선택 변경 시 리스트 변경이 인지되도록 라벨 문구 유지
