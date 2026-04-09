# 전체 작업 페이지 오버라이드

> 적용 대상: `Projects/Jacsim/Sources/Presentation/AllTask/AllTaskView.swift`

## 레이아웃 오버라이드

- 상태 그룹(진행/성공/실패) 3섹션을 카드 형태로 유지
- 섹션 접기/펼치기 토글은 섹션 헤더 내에서만 처리

## 상태 정책

- `loading`: 목록 조회 중 전체 로딩 상태
- `empty`: 전체 작심 0개일 때 전역 empty 상태
- `error`: 조회 실패 시 재시도 버튼 제공

## 컴포넌트 오버라이드

- 요약 카드는 기본 노출
- 리스트 아이템은 `JSListItem` + 의미론적 상태 색상

## 접근성 노트

- 토글 버튼 라벨에 섹션명 + 개수 포함
