# Home Page Overrides

> Applies to: `Projects/Jacsim/Sources/Presentation/Home/HomeView.swift`

## Layout Overrides

- 헤더(브랜드/날짜/설정) + Hero + Mini Carousel + FAB 구조 고정
- 요약 카드와 미니 카드 영역은 주 행동 전환을 방해하지 않도록 분리

## State Policy

- `loading`: 스켈레톤 구조와 로드 완료 구조 높이 정렬
- `empty`: CTA를 즉시 노출해 생성 플로우로 이동

## Component Overrides

- 요약 카드: `PresentationSectionKey.homeSummary`
- 미니 카드: `PresentationSectionKey.homeMiniCards`
- Hero 카드는 `JSUnifiedHeroCard` 우선

## Accessibility Notes

- 상단 설정 버튼, FAB, 카드 탭 영역에 명확한 라벨 유지
