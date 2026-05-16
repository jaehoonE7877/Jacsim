# Jacsim v2.0.0 Onboarding Research

## 목적

- 구버전 annotated screenshot 기반 온보딩 이미지를 v2 리디자인 화면 구조에 맞게 교체한다.
- 첫 실행 온보딩은 `핵심 가치 전달`에 집중하고, 설정·권한·보조 기능은 이후 맥락형 도움말로 분리한다.
- 결과물은 `4장 walkthrough copy`, `4개 hybrid onboarding asset`, `후속 실험 가이드`로 정리한다.

## 멀티에이전트 조사 요약

### Explorer Findings

- `Home`은 오늘 해야 할 작심, 대표 작심, 진행률, 즉시 시작 CTA를 한 화면에 모아 첫 인상에 가장 적합하다.
  - 근거: `Projects/Jacsim/Sources/Presentation/Home/HomeView.swift`
- `NewTask`는 제목, 기간, 사진, 알림을 단계형으로 분리해 첫 작심 생성 장벽을 낮춘다.
  - 근거: `Projects/Jacsim/Sources/Presentation/NewTask/NewTaskView.swift`
- `Calendar`는 날짜별 인증 상태와 선택 날짜의 기록 목록을 함께 보여줘 지속성과 변화 축적을 설명하기 좋다.
  - 근거: `Projects/Jacsim/Sources/Presentation/Calendar/CalendarView.swift`
- `AllTask`는 진행/성공/실패를 요약해 전체 흐름과 현재 위치를 정리해 준다.
  - 근거: `Projects/Jacsim/Sources/Presentation/AllTask/AllTaskView.swift`
- `Setting`은 중요하지만 첫 실행의 코어 루프보다는 운영/개인화 성격이 강해 메인 4장보다 후행 도움말에 가깝다.
  - 근거: `Projects/Jacsim/Sources/Presentation/Setting/SettingView.swift`

### Applied Decision

- v2 온보딩 메인 4단계는 `Home -> NewTask -> Calendar -> AllTask`로 잡는다.
- 알림 권한, 테마, 도움말은 설정에서 관리하되 메인 walkthrough의 중심 메시지에서는 제외한다.
- walkthrough는 추상 설명보다 실제 화면 구조를 먼저 보여주고, 텍스트는 보조 설명만 담당한다.

## 현재 Walkthrough의 핵심 mismatch

- 구 자산은 화살표와 긴 주석 중심이라 현재 리디자인의 간결한 카드/섹션 언어와 맞지 않는다.
- 기존 3번째 메시지는 알림 권한과 리마인드에 치우쳐 있어 현재 정책인 `앱 시작 요청 + 설정 복구`와 맞지 않는다.
- 홈의 hero card, 새 작심의 단계형 flow, 캘린더의 기록 축적, 모아보기의 상태 그룹화가 자산에 반영되어 있지 않다.
- 화면별 설명이 기능 이름보다 추상 문장에 치우쳐 실제 사용 흐름을 예측하기 어렵다.
- 비주얼이 v2 토큰보다 구버전 컴포넌트와 강한 annotation에 묶여 있어 브랜드 일관성이 약하다.

## v2 온보딩 원칙

### Copy

1. 오늘의 작심이 한눈에 보여요
   - 가장 중요한 작심과 남은 할 일을 홈에서 바로 확인해요
2. 새 작심은 단계별로 가볍게 만들어요
   - 제목, 기간, 사진, 알림까지 흐름대로 정하면 바로 시작할 수 있어요
3. 기록이 쌓일수록 변화가 보여요
   - 캘린더에서 날짜별 인증 상태와 오늘의 기록을 한눈에 살펴봐요
4. 모든 작심의 흐름을 모아봐요
   - 진행, 성공, 실패를 한 번에 정리하고 다음 행동을 이어가요

### Visual

- 실제 v2 화면 구조를 반영한 hybrid illustration을 사용한다.
- 상단은 단순 `온보딩` 라벨보다 브랜드 타이틀과 현재 단계 pill을 함께 보여준다.
- 장면당 강조 포인트는 하나만 둔다.
- 검은 화살표, 긴 말풍선, 다중 callout은 쓰지 않는다.
- DSKit의 blue primary와 neutral surface 체계를 유지한다.
- 각 장면은 `홈 가치 -> 생성 흐름 -> 기록 축적 -> 전체 회고` 순서로 이어진다.
- 인디케이터는 dot만 두지 않고 `1 / 4` 같은 텍스트 단계값도 함께 보여준다.

## 더 좋은 온보딩 경험을 위한 권장안

### 1. Walkthrough는 코어 루프만 설명

- 첫 실행 walkthrough는 `왜 Jacsim을 써야 하는지`와 `첫 작심을 어떻게 시작하는지`만 설명한다.
- 설정, 권한, 리뷰 요청, 부가 기능은 walkthrough 완료 후 필요한 순간에 보여준다.

### 2. 후속 안내는 contextual discovery로 분리

- `Home` 첫 진입 후: FAB 주변에 첫 작심 생성 팁
- `NewTask` 첫 진입 후: 단계 카드나 footer CTA 주변에 진행 힌트
- `AllTask` 첫 진입 후: 진행/성공/실패 섹션 구조 설명
- `Setting` 첫 진입 후: 알림 토글과 시스템 설정 복구 안내

### 3. Permission은 walkthrough의 주제가 아님

- 알림은 현재 정책대로 앱 시작에서 요청하고, 거부 복구는 Setting에서 처리한다.
- walkthrough는 권한 요청을 약속하거나 강하게 유도하지 않는다.

### 4. 계측이 필요함

- 권장 이벤트:
  - `walkthrough_started`
  - `walkthrough_completed`
  - `walkthrough_skipped`
  - `first_task_started`
  - `first_task_saved`
  - `calendar_opened_after_onboarding`
  - `all_tasks_opened_after_onboarding`
  - `notification_permission_granted`
- 이 이벤트로 완료율, 첫 작심 생성률, 기록 화면 진입률을 묶어서 본다.

## 웹 리서치와 적용

### Apple

- Apple은 온보딩에서 코어 루프를 짧고 단계적으로 가르치고, 건너뛰기 선택지도 제공하라고 안내한다.
- 또한 비핵심 과업과 푸시 opt-in 같은 요소는 온보딩 이후로 미루라고 권장한다.
- 반복 방문의 이점도 초기에 보여 주되, 주된 제품 목표와 연결돼야 한다.

적용:

- `Home -> NewTask -> Calendar -> AllTask` 순서로 코어 루프를 설명한다.
- `건너뛰기`는 유지한다.
- 알림/설정/리뷰 유도는 walkthrough 메인 메시지에서 제외한다.

출처:

- https://developer.apple.com/app-store/onboarding-for-games/

### TipKit

- Apple의 TipKit 설명은 기능 소개를 앱 안의 적절한 순간에 맞춰 노출하고, 표시 빈도와 자격 규칙을 제어할 수 있게 설계돼 있다.

적용:

- 첫 실행 walkthrough에 모든 설명을 몰지 않는다.
- 후속 안내는 필요한 화면에서 짧은 맥락형 tip으로 나눈다.

출처:

- https://developer.apple.com/documentation/tipkit
- https://developer.apple.com/kr/videos/play/wwdc2024/10070/

### Appcues

- Appcues는 첫 몇 화면 안에서 즉시 가치를 보여 주고, 브랜드 일관성을 유지하며, progress indicator와 progressive disclosure를 쓰라고 권장한다.
- 또한 사용자가 압도되지 않도록 핵심만 먼저 보여주고, 이후 툴팁과 contextual help로 확장하는 방식을 제안한다.

적용:

- 4장 모두 현재 DSKit 어휘에 맞춘 시각 언어로 통일한다.
- 기존 page indicator는 유지한다.
- 화면당 한 가지 가치만 강조하고 긴 설명은 제거한다.

출처:

- https://www.appcues.com/blog/mobile-onboarding-best-practices

## 이번 구현 범위

- `Projects/Jacsim/Sources/Presentation/WalkThorugh/WalkThroughView.swift`
  - v2 메시지로 title/subtitle 갱신
- `Projects/Modules/DSKit/Resources/Images/Assets.xcassets/Onboarding Image/**`
  - 4개 asset을 최신 화면 구조 기반 hybrid 이미지로 교체
- `Projects/Jacsim/OnboardingV2Research.md`
  - 멀티에이전트 조사 + 웹 근거 + 후속 UX 권장안 정리

## 다음 실험 후보

1. 마지막 CTA를 `시작하기`와 `첫 작심 보러가기` 중 무엇이 더 나은지 비교한다.
2. walkthrough 완료 직후 `Home`의 FAB에 1회성 tip을 붙인다.
3. `NewTask` 진입 후 첫 저장까지 걸리는 시간과 이탈 지점을 계측한다.
4. `Setting`의 알림 복구 배너를 walkthrough 이후 도움말 흐름과 연결한다.
