# App Page Overrides

> Applies to: `Projects/Jacsim/Sources/Presentation/App/AppView.swift`

## Layout Overrides

- 앱 루트는 onboarding/main 상태 전환만 담당
- 시각 스타일 결정은 하위 화면으로 위임

## State Policy

- 전역 loading 화면을 추가하지 않고, 하위 Feature 상태를 존중

## Component Overrides

- 테마는 `appearance_theme` 단일 소스로 유지
- 루트에서 임의 색상/폰트 스타일 추가 금지
