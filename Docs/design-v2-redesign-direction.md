# Jacsim v2.0 Redesign Direction

## v1 현재 문제

Jacsim v1 UI는 기능을 설명하는 화면에 가깝다. Home은 오늘 해야 할 작심을 발견하고 바로 인증하는 첫 화면이라기보다 요약 카드와 관리 CTA가 쌓인 dashboard처럼 보인다. TaskDetail은 작심의 정체성과 진행 흐름보다 단계 정보, 상태 문장, 기록 목록이 먼저 읽힌다. NewTask/TaskUpdate는 행동 흐름보다 form 설명과 helper text가 많아 인증 앱의 속도가 떨어진다.

핵심 문제는 세 가지다.

1. 이미지보다 설명이 먼저 보인다.
2. CTA가 길고 같은 무게로 경쟁한다.
3. 카드, chip, feed, profile 같은 consumer app 구조가 화면 전반에 일관되게 쓰이지 않는다.

## v2 Visual Direction

Jacsim v2는 "작심 관리 앱"이 아니라 "오늘 이어갈 작심을 발견하고 바로 인증하는 앱"처럼 보여야 한다.

- Tone: 밝고 활동적인 consumer app, white surface, 선명한 blue accent, 가벼운 secondary surface.
- Structure: full-bleed image card, profile-style detail, feed-like records, chip-first state.
- Copy: 긴 안내문 제거. 버튼은 짧은 동사형. 설명은 placeholder, badge, preview, accessibility hint로 이동.
- Motion: 카드 tap, 인증 완료, bottom CTA 전환에만 짧은 feedback.
- Accessibility: 화면 텍스트를 줄인 만큼 VoiceOver label/hint는 더 구체적으로 제공.

## Reference Pattern

Mobbin Plenty of Fish iOS 공개 HTML에서는 `Plenty of Fish iOS | Mobbin` 식별만 확인된다. 구현에는 사용자가 제공한 레퍼런스 관찰을 적용한다.

가져올 패턴:

- 큰 사진 카드가 첫 인상을 만든다.
- 카드 안에 상태 badge와 짧은 CTA가 들어간다.
- profile/feed-like 구조로 다음 행동을 쉽게 고른다.
- 흰 배경과 blue accent가 기본 리듬을 만든다.
- 보조 액션은 menu, sheet, compact action으로 숨긴다.

가져오지 않을 것:

- POF 브랜드, 문구, dating app 기능, 정확한 레이아웃 복제.
- Jacsim의 작심/습관/인증 맥락과 맞지 않는 decorative UI.

## DSKit v2 Plan

| 영역 | v2 정의 |
| --- | --- |
| Color | `v2BrandBlue`, `v2BrandBlueSoft`, `v2Background`, `v2Surface`, `v2SurfaceElevated`를 brand surface hierarchy로 사용 |
| Typography | display는 짧고 bold, body 설명은 줄이고 chip/label 중심으로 전환 |
| Card | `jsv2CardSurface`를 기본 elevated surface로 사용, image card는 full-bleed 유지 |
| Chip | `JSV2StatusChip`로 상태, 기간, 완료 여부를 짧게 표현 |
| Metric | `JSV2MetricPill`로 진행률, 완료일, 남은일을 숫자 중심으로 표시 |
| Section | `JSV2SectionHeader`로 title + compact action 구조 통일 |
| Accessibility | visual text는 짧게, label/hint에는 상태와 행동 의미를 포함 |

## 화면별 전면 개편안

### Home

- 첫 화면의 주인공은 "오늘 대표 작심 카드"다.
- 요약 dashboard보다 hero image card, 상태 chip, primary CTA를 먼저 둔다.
- 나머지 작심은 horizontal card feed로 보여준다.
- 빈 상태도 설명 대신 큰 starter card + "시작하기" action으로 처리한다.

### TaskDetail

- 정보 페이지가 아니라 작심 profile이다.
- cover image 아래에 stage/profile metric pill을 둔다.
- 오늘 상태는 문장이 아니라 chip + short CTA로 표현한다.
- 기록은 feed card로 읽히게 한다.
- 삭제/수정/알림은 상단 menu 또는 edit sheet로 숨긴다.

### NewTask / TaskUpdate

- form이 아니라 onboarding/check-in flow다.
- 한 단계에 하나의 결정만 요구한다.
- 입력 중에도 만들 작심 카드 preview가 보여야 한다.
- helper text는 화면에서 제거하고 validation error만 노출한다.

### Calendar / AllTask

- 관리 table이 아니라 탐색 feed다.
- Calendar는 날짜 선택 + 해당 날짜의 task card feed.
- AllTask는 status rail + status별 card feed.
- 색만으로 상태를 전달하지 않고 icon/label/shape를 함께 사용한다.

### Setting / WalkThrough

- Setting은 조용한 iOS-native list tone으로 유지한다.
- WalkThrough는 이미지와 한 문장 headline 중심으로 줄인다.

## Implementation Slices

1. DSKit v2 primitive 추가.
2. Home을 representative task card 중심으로 재구성.
3. TaskDetail을 profile/feed 구조로 정리.
4. NewTask/TaskUpdate에서 preview card와 short form flow 적용.
5. Calendar/AllTask를 card feed 탐색 화면으로 변경.
6. Setting/WalkThrough copy와 surface tone 정리.

## Verification

- `tuist build Jacsim`
- Simulator Home, TaskDetail, NewTask, Calendar, AllTask smoke check
- light/dark, Dynamic Type, empty/loading/image-missing 상태 확인
