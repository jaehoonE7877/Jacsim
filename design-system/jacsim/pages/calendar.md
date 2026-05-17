# 캘린더 페이지 오버라이드

> 적용 대상: `Projects/Jacsim/Sources/Presentation/Calendar/CalendarView.swift`

## 레이아웃 오버라이드

- `04-Final.html`의 month view + year heatmap toggle 방향을 기준으로 합니다.
- 상단 캘린더/히트맵 + 하단 날짜 기록 리스트 2단 구조
- 날짜 헤더는 선택 날짜와 기록 개수를 함께 노출

## 상태 정책

- `loading`: 캘린더 데이터 조회 중
- `empty`: 활성 작심이 없을 때 전역 empty
- `error`: 조회 실패 시 재시도 제공

## 컴포넌트 오버라이드

- 새 구현은 `JSCalendarV2`를 우선 사용합니다.
- 기존 `JSCalendar`는 삭제하지 않고 호환/점진 교체용으로만 둡니다.
- 날짜별 상태 색상은 `TaskSuccessRate -> JSCalendarDateColor` 매핑
- year heatmap은 streak/progress/label 토큰을 사용하고 하드코딩 색상을 추가하지 않습니다.

## 접근성 노트

- 날짜 선택 변경 시 리스트 변경이 인지되도록 라벨 문구 유지
- month/year toggle은 현재 선택 모드가 VoiceOver로 읽혀야 합니다.
