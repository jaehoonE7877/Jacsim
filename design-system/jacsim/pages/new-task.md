# 신규 작업 페이지 오버라이드

> 적용 대상: `Projects/Jacsim/Sources/Presentation/NewTask/NewTaskView.swift`

## 레이아웃 오버라이드

- 제목 -> 스테이지 -> 대표 사진 -> 알림 -> 하단 CTA 고정 순서
- 하단 CTA는 스티키 푸터로 유지

## 상태 정책

- 인라인 실패 메시지(`RedesignInlineErrorView`) 사용
- 저장 중 버튼 비활성 + 로딩 인디케이터 유지

## 컴포넌트 오버라이드

- 대표 사진 섹션: 사진 단계에서 기본 노출
- 알림 섹션: 알림 확인 단계에서 기본 노출

## 접근성 노트

- 필수값 미충족 상태의 CTA 비활성 이유가 시각적으로 명확해야 함
