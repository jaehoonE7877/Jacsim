# Jacsim HIG Redesign Audit

## 기준

- Apple HIG Typography: https://developer.apple.com/design/human-interface-guidelines/typography
- Apple HIG Dark Mode: https://developer.apple.com/design/human-interface-guidelines/dark-mode
- UIKit Dynamic Type: https://developer.apple.com/documentation/uikit/scaling-fonts-automatically
- Mobbin reference: Plenty of Fish iOS page is used only as mood and interaction-pattern reference, not as a visual copy source.

## 목표

Jacsim의 화면은 iOS-native 습관/인증 앱처럼 즉시 이해되어야 한다. 설명 문장을 먼저 읽게 만들기보다 사진, 상태, 숫자, 짧은 CTA가 먼저 보이고, 자세한 보조 정보는 placeholder, chip, accessibility label/hint, progressive disclosure로 보완한다.

## DSKit 감사

| 영역 | 현재 상태 | HIG 관점 문제 | 개선 방향 |
| --- | --- | --- | --- |
| 색상 | `primary*`, `label*`, `background*`, `surface*`, status token 보유 | 토큰은 semantic에 가깝지만 카드가 `backgroundNormal`에 고정되어 surface hierarchy가 약함 | card/surface는 `surfaceElevated`, outline은 보조 separator 성격으로 사용 |
| 다크 모드 | UIColor dynamic provider 사용 | 단순 반전은 아니지만 elevation/shadow는 light 기준 영향이 남음 | shadow 의존을 줄이고 surface/background 단계로 위계를 만든다 |
| 타이포그래피 | Pretendard 고정 size token 다수 | Dynamic Type 반응성이 약하고 작은 label token이 많음 | Pretendard 유지, `UIFontMetrics` 기반 scaling 적용, 화면 텍스트는 lineLimit/minScale 보강 |
| 간격 | 4/8/12/16/20/24/32 + 44 touch target | layout scale은 있으나 큰 글자에서 3열 metric이 좁아질 수 있음 | accessibility Dynamic Type에서는 metric을 세로 전환 |
| radius | 8/12/16/20/circular | 카드 radius는 iOS 앱 기준에서 과하지 않음 | 카드 8-12 중심, full-bleed image card만 20 허용 |
| shadow | small/medium/large token | 어두운 surface에서 그림자보다 surface 단계가 더 중요 | elevated card는 surface token 우선, 과한 shadow 사용 축소 |
| 버튼 | primary/secondary/destructive/ghost, 44pt min | icon/label 조합과 accessibility hint가 부족함 | 짧은 동사형 label, optional SF Symbol, disabled hint 적용 |
| 카드 | `JSCard`, hero/mini card 존재 | 카드 배경과 screen background가 붙어 보일 수 있음 | `surfaceElevated`로 분리, hero card는 image-first 유지 |
| 탭바 | custom `JSTabBar` | iOS `TabView` 기대와 일부 다름, label 10pt가 작음 | 추후 Native TabView 또는 accessibility/selection label 보강 |
| 입력 필드 | `JSInputField`, TextField 직접 구현 혼재 | helper text가 화면을 장황하게 차지함 | helper는 placeholder/accessibilityHint로 이동, 에러만 노출 |
| bottom sheet | custom drag sheet, DatePicker sheet | SwiftUI `.presentationDetents` 기대와 다를 수 있음 | 신규 sheet는 native sheet 우선, 기존 sheet는 dismiss/accessibility 보강 |
| empty/error/loading | scaffold에 공통 상태 있음 | empty/error subtitle이 길어질 수 있음 | 제목 + 짧은 행동, 상세 원인은 retry/accessibility hint |
| hero/mini card | 이미지 중심 card 구현 있음 | status text가 길고 VoiceOver label이 부족함 | 짧은 visual badge + 풍부한 accessibility label |

## 화면별 감사

| 화면 | 텍스트/흐름 문제 | 우선순위 | 제안 |
| --- | --- | --- | --- |
| Home | CTA 2개가 같은 무게로 경쟁, summary 3열이 큰 글자에서 취약, status badge가 장문 | P0 | primary CTA 하나를 강하게, secondary는 ghost, badge는 짧게, VoiceOver label 보강 |
| TaskDetail | 큰 cover image는 좋지만 bottom CTA의 보조 문장과 popup 문장이 길다 | P1 | stage state는 chip/metric으로, 실패/삭제 설명은 progressive popup 단계로 최소화 |
| NewTask | step subtitle, section subtitle, helper text가 반복됨 | P1 | 제목/기간/사진/알림을 짧은 label + placeholder로 정리, trimming 설명은 accessibilityHint로 이동 |
| TaskUpdate | memo helper와 overwrite 안내가 동시에 보일 수 있음 | P1 | 사진 인증이 primary, memo는 optional affordance로 낮추고 helper text 제거 |
| Calendar | "탭해서 날짜를 빠르게 이동" 같은 사용법 문장이 노출됨 | P2 | 날짜 버튼 affordance와 accessibilityHint로 대체 |
| AllTask | 상태별 fold section은 명확하지만 summary subtitle이 설명형 | P2 | count chip 중심, empty row는 더 짧게 |
| Setting | 알림 권한 안내가 화면에서 길게 노출됨 | P2 | 짧은 banner + 설정 열기 CTA를 분리 |
| WalkThrough | 온보딩 subtitle이 일부 장문 | P2 | 페이지당 한 문장, 이미지와 primary action 우선 |

## 개선 원칙

1. 화면당 primary action은 명확히 하나만 둔다.
2. 설명 문장은 상태, 숫자, icon, placeholder, accessibilityLabel/Hint로 대체한다.
3. 버튼 문구는 짧은 동사형 한국어를 사용한다.
4. Pretendard는 유지하되 Dynamic Type scaling과 legibility를 기본값으로 둔다.
5. 다크 모드는 surface hierarchy로 구분하고 shadow만으로 위계를 만들지 않는다.
6. DSKit은 표현 계층만 담당하며 Domain/Data 변경을 만들지 않는다.
7. 이미지 중심 카드는 시각적으로 짧게, VoiceOver는 자세하게 제공한다.

## 구현 우선순위

### 1차: DSKit + Home

- [x] Pretendard token을 `UIFontMetrics` 기반으로 scaling.
- [x] `JSButton`에 optional SF Symbol, line limit, disabled accessibility hint 추가.
- [x] `JSCard` 배경을 elevated surface token으로 정리.
- [x] Home hero/mini card의 visual status badge 축약 및 VoiceOver label 보강.
- [x] Home CTA row에서 primary action을 우선하고 secondary action을 ghost로 낮춤.
- [x] Home summary metric은 accessibility Dynamic Type에서 세로 layout으로 전환.
- [x] Home empty state 문구를 짧은 action 중심으로 축소.

### 2차: TaskDetail

- [ ] Today status 문장을 chip/metric 위주로 축소.
- [ ] Stage success/fail CTA 문구를 짧게 정리.
- [ ] Delete guard popup의 장문 설명을 단계별 핵심 문장으로 축소.
- [ ] Daily record row에 image/status accessibility label 추가.

### 3차: NewTask / TaskUpdate

- [ ] title/memo helper text를 화면에서 제거하고 placeholder 또는 accessibilityHint로 이동.
- [ ] section subtitle은 필요한 맥락만 남기고 반복 안내 제거.
- [ ] sticky footer는 primary action 하나를 중심으로 유지.
- [ ] validation error만 화면에 명시적으로 노출.

### 4차: Calendar / AllTask / Setting / WalkThrough

- [ ] Calendar selected date helper text를 hint로 이동.
- [ ] AllTask section header에 count chip을 사용해 설명 subtitle 축소.
- [ ] Setting notification denied banner를 짧게 만들고 설정 CTA를 분리.
- [ ] WalkThrough subtitle을 페이지당 한 문장으로 축소.

## 검증 체크리스트

- [x] `tuist build Jacsim`
- [ ] Home light/dark visual check
- [ ] Home small/large Dynamic Type text clipping check
- [ ] Home VoiceOver label sanity check for hero card, mini card, FAB, CTA
- [ ] Empty/loading/normal states check

## 현재 검증 메모

- `tuist install` 후 `tuist build Jacsim` 통과.
- XcodeBuildMCP로 simulator build/install/launch까지 성공했지만, 런타임에서 `GoogleService-Info.plist` 누락으로 `FirebaseApp.configure()`가 종료되어 화면 검증은 진행하지 못했다.
