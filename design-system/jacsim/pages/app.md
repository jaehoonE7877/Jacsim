# 앱 페이지 오버라이드

> 적용 대상: `Projects/Jacsim/Sources/Presentation/App/AppView.swift`

## 레이아웃 오버라이드

- 앱 루트는 onboarding/main 상태 전환만 담당
- 시각 스타일 결정은 하위 화면으로 위임

## 상태 정책

- 전역 로딩 화면을 추가하지 않고, 하위 기능 상태를 존중

## 컴포넌트 오버라이드

- 테마는 `appearance_theme` 단일 소스로 유지
- 루트에서 임의 색상/폰트 스타일 추가 금지
