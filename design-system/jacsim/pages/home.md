# Home Page Overrides

> Applies to: `Projects/Jacsim/Sources/Presentation/Home/HomeView.swift`

## Layout Overrides

- `04-Final.html`의 Home A를 기준으로 합니다.
- 헤더(브랜드/날짜/설정) + wallpaper + Liquid Glass hero + active task/progress sections 구조를 우선합니다.
- Home 화면은 더 이상 scroll-driven FAB를 렌더링하지 않습니다. 생성 진입점은 Main의 center plus tab입니다.
- 마지막 콘텐츠가 floating tab bar에 가려지지 않도록 하단 padding을 유지합니다.

## State Policy

- `loading`: 스켈레톤 구조와 로드 완료 구조 높이 정렬
- `empty`: CTA를 즉시 노출해 생성 플로우로 이동

## Component Overrides

- 요약 카드: `PresentationSectionKey.homeSummary`
- 미니 카드: `PresentationSectionKey.homeMiniCards`
- Hero/section surface는 새 DSKit glass token/component를 우선 사용합니다.
- D-day, streak, count 류 숫자는 `Font.jsMonoLarge/Medium/Small`을 사용합니다.
- 인용/격려 문구는 `Font.jsSerifQuote`를 우선합니다.

## Accessibility Notes

- 상단 설정 버튼, 카드 탭 영역에 명확한 라벨 유지
- Dynamic Type 접근성 크기에서 hero/summary 텍스트가 겹치지 않아야 합니다.
