# 캘린더 페이지 오버라이드

> 적용 대상: `Projects/Jacsim/Sources/Presentation/Calendar/CalendarView.swift`

## 레이아웃 오버라이드

- 상단 캘린더 + 하단 날짜 기록 리스트 2단 구조
- 날짜 헤더는 선택 날짜와 기록 개수를 함께 노출

## 상태 정책

- `loading`: 캘린더 데이터 조회 중
- `empty`: 활성 작심이 없을 때 전역 empty
- `error`: 조회 실패 시 재시도 제공

## 컴포넌트 오버라이드

- 캘린더는 `JSCalendar` 단일 컴포넌트 유지
- 날짜별 상태 색상은 `TaskSuccessRate -> JSCalendarDateColor` 매핑

## 접근성 노트

- 날짜 선택 변경 시 리스트 변경이 인지되도록 라벨 문구 유지
