# 작업 갱신 페이지 오버라이드

> 적용 대상: `Projects/Jacsim/Sources/Presentation/TaskUpdate/TaskUpdateView.swift`

## 레이아웃 오버라이드

- 인증 사진 + 메모 + 하단 인증 CTA 구조
- 덮어쓰기 안내 배너는 콘텐츠 상단 고정

## 상태 정책

- 저장 실패 시 인라인 오류 표시
- 저장 중에는 화면 오버레이 + CTA 비활성 유지

## 컴포넌트 오버라이드

- 사진 섹션: 기본 노출
