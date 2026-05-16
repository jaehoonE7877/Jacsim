# Setting Page Overrides

> Applies to: `Projects/Jacsim/Sources/Presentation/Setting/SettingView.swift`

## Layout Overrides

- 계정/공개 범위/알림/도움말/오픈소스 라이선스/앱정보를 분리합니다.
- 환경 설정은 즉시 반영되도록 피드백 배너 유지
- Liquid Glass surface를 사용하되 card-in-card 구조는 피합니다.

## State Policy

- 설정 반영 중에는 상태 배너로 진행 상태를 표시

## Component Overrides

- 도움말/문의/리뷰 액션은 동일 row 패턴 유지
- 우측 디스클로저/아이콘 크기 일관성 유지
- Newsreader/JetBrains Mono OFL 파일은 DSKit 리소스에 준비되어 있으며, Goal 6에서 "오픈소스 라이선스" 화면/row가 이를 읽도록 연결합니다.
- 공개 범위 기본값은 `.private`입니다. 기존 작심을 공개로 바꾸는 기본 UI를 만들지 않습니다.

## Goal 6 Guardrails

- Follow/Feed/Notification 실제 데이터 연동은 Goal 7/8 범위입니다.
- 설정 화면에서는 공개 범위와 라이선스 진입점의 시각/정보 구조까지만 정리합니다.
