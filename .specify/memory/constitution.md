<!--
동기화 보고서(간단 요약)
- 버전: 없음 → 1.0.0
- 날짜: 2025-11-12
- 바뀐 점:
  - 수정: 최소 지원 iOS를 18+로 상향, 설계/원칙 일관화
  - 추가: SwiftData/Swift Concurrency/SwiftUI/TCA 도입 원칙 및 체크리스트
  - 삭제: RxSwift/RxCocoa/Realm 신규 코드 사용 금지, UIKit 신규 화면 금지
- 갱신해야 할 템플릿/문서:
  - templates/commands/constitution.md: ✅ 완료
  - .specify/templates/plan-template.md(Constitution Check 반영): ✅ 참고
  - README.md / 문서(요약 반영): ⚠ 보류
- TODO(마이그레이션 마감일/브릿지 삭제 일정):
  - iOS 최소 타깃 18+로 상향(빌드 설정/InfoPlist/xcconfig): 2025-11-30
  - SwiftData 모델 정의/스키마 확정: 2025-12-15
  - 핵심 화면 Rx → Concurrency 전환 완료: 2025-12-31
  - Realm → SwiftData 데이터 마이그레이션(읽기/쓰기 경로): 2026-01-31
  - UIKit 브릿지 삭제(전환 완료 화면): 2026-02-28
  - Rx/Realm 의존성 완전 제거(코드/패키지): 2026-03-31
  - DSKit‑SwiftUI 토큰/컴포넌트 1.0 배포: 2026-01-15
-->

# Jacsim 프로젝트 헌장

메타데이터
- PROJECT_NAME: Jacsim
- CONSTITUTION_VERSION: 1.0.0
- RATIFICATION_DATE: 2025-11-12
- LAST_AMENDED_DATE: 2025-11-12
- 적용 범위: App, 내부 모듈, 템플릿(.specify/plan, tasks), CI 설정, 문서 일체

변경 요약(중요)
- 최소 지원 버전: iOS 18+
- 데이터/비동기: Realm, RxSwift 제거 → SwiftData, Swift Concurrency(Async/Await, AsyncSequence)
- UI: UIKit 신규 코드 금지 → 모든 새 화면은 SwiftUI로 작성
- 아키텍처: TCA(Composable Architecture) 도입(State/Action/Reducer/Effect)
- 디자인 시스템: 기존 DSKit(UIKit 중심)은 “토큰/자산”만 참고, SwiftUI 컴포넌트로 대체

목표(짧게)
- 우리 팀과 AI가 같은 기준으로 개발한다
- 문장은 “검증 가능”하게 쓴다(숫자/체크박스 사용)
- 마이그레이션 혼선을 막기 위해 “허용/금지/예외”를 명확히 한다

핵심 원칙(8개)
1) SwiftUI 우선 (MUST)
   - 새 화면은 전부 SwiftUI로 만든다
   - UIKit은 “기존 화면 유지/임시 브릿지”에서만 허용, 새 코드 금지
   - 네비게이션/상태 관리도 SwiftUI/TCA 기준 적용
2) Swift Concurrency 우선 (MUST)
   - 비동기는 async/await, Task, AsyncSequence로 처리한다
   - RxSwift 사용 금지(임시 브릿지는 마이그레이션 구간에서만 제한 허용)
   - UI 상태 변경은 @MainActor에서만, 공유 타입은 가능하면 Sendable 고려
3) SwiftData 우선 (MUST)
   - 데이터 모델/저장은 SwiftData를 기본으로 한다
   - Realm 제거. 마이그레이션 계획을 문서화하고 추적한다
   - 데이터 변경은 트랜잭션 범위를 명확히, 대량 처리는 배치로 수행
4) TCA 기반 구조 (MUST)
   - 각 화면/기능은 TCA(Feature 단위 State/Action/Reducer/Effect)
   - Effect는 취소 가능해야 하며, 장시간 작업은 Main Actor를 막지 않는다
   - 공통 로직은 Feature 간 재사용(중복 금지)
5) 단순하게 만들기 (MUST)
   - 새 라이브러리는 꼭 필요할 때만 추가(이유/대안/비용 비교 없으면 금지)
   - 불필요한 래퍼/레이어 금지, 가능한 한 직접 사용
   - 지금 필요한 것만 만든다(YAGNI, KISS)
6) 테스트 먼저 (MUST)
   - 변경 코드에는 단위 테스트를 추가한다(Swift Testing)
   - TCA Reducer 테스트와 SwiftUI 스냅샷 테스트를 함께 고려한다
   - “레드 → 그린 → 리팩터” 순서를 지킨다
7) 성능 목표 (MUST)
   - 화면 상호작용 p95 < 100ms, 스크롤 60fps 유지
   - 이미지 캐시 히트율 ≥ 80%, 릴리스 간 메모리 증가는 +5% 이내
   - 수치는 Instruments/MetricKit으로 측정·기록한다
8) 로그/진단 기본 탑재 (MUST)
   - OSLog 카테고리: UI / DATA / NETWORK / PERF
   - 중요한 행동/실패/성능 수치를 구조화 로그로 남긴다
   - Crashlytics/MetricKit은 환경에 맞게 설정(오프라인 개발 예외 허용)

추가 규칙(쉬운 말)
- 플랫폼/도구
  - iOS 18+, Swift 6, iOS 18 SDK(Xcode 26 이상)
  - 새 코드는 SwiftUI + TCA + SwiftData + Swift Concurrency 조합을 따른다
- 금지/제거
  - RxSwift/RxCocoa, Realm: 새 코드 금지. 마이그레이션 이후 전면 제거
  - 생성물/외부 코드(`Projects/**/Derived`, `.build/**`) 수정 금지
- 디자인 시스템
  - 색/폰트/아이콘 등 “토큰/자산”은 재사용
  - SwiftUI 컴포넌트는 새로 만든다(필요 시 DSKit‑SwiftUI 서브모듈/패키지로 분리)
- 보안/비밀
  - 키/토큰은 코드에 넣지 않는다(.xcconfig 또는 CI 시크릿 사용)
  - GoogleService-Info.plist는 타깃 리소스로만 포함하고 경로 고정
- 접근성
  - Dynamic Type/VoiceOver, 대비, 터치 영역 기준 준수
- 커밋/PR
  - 1커밋=1변경, 포맷팅/기능을 섞지 않는다
  - 메시지 형식: `type: subject` (한글 현재형)

마이그레이션 규칙(UIKit/Rx/Realm → SwiftUI/Concurrency/SwiftData/TCA)
- 단계(기한 포함)
  1) 최소 타깃 iOS 18+로 상향(Tuist/빌드 설정/InfoPlist/xcconfig) — 2025-11-30
  2) 새 기능은 모두 SwiftUI+TCA로 구현(UIKit 새 코드 금지) — 2025-11-12 즉시 시행
  3) 데이터는 SwiftData 모델을 만든다(마이그레이션 스크립트/가이드 준비) — 2025-12-15
  4) 기존 Rx 흐름은 AsyncSequence/await로 교체, 임시 브릿지는 Feature 경계에서만 — 2025-12-31(핵심 화면)
  5) 완료된 화면/데이터의 UIKit/Rx/Realm 의존 제거 — 2026-02-28(브릿지 삭제)
  6) Rx/Realm 패키지/코드 완전 제거 — 2026-03-31
- 금지/예외
  - “임시 브릿지”는 새 기능에 사용 금지, 기존 코드 교체 완료 시 즉시 삭제
  - 일정·범위는 스프린트 계획에 명시하고, 본 문서 상단 동기화 보고서에 최신화

성능 기준(숫자로 짧게)
- 화면 전환/탭 반응 p95 < 100ms, 첫 의미 있는 페인트 < 400ms
- 스크롤 60fps, 셀 재사용/프리패치 사용
- SwiftUI 성능: 불필요한 State/Binding/Effect 제거, View 갱신 범위 최소화
- 측정: Time Profiler / Allocations / Core Animation / MetricKit

로그/진단(간단 예시)
- OSLog 예시: `[cat]=UI [screen]=Home [action]=Tap [latency_ms]=87`
- 주간 단위로 Crash/ANR/메모리 지표를 확인한다

개발 흐름 & 체크리스트(짧고 명확)
- 구현 전 체크(사전 구현)
  - [ ] 새 의존성 0~1개인지, 꼭 필요한지 근거가 있는지
  - [ ] UIKit/Rx/Realm 미사용(예외는 기존 코드 한정)
  - [ ] SwiftData 모델/저장 구조 확정(마이그레이션 계획 포함)
  - [ ] TCA 구조(State/Action/Reducer/Effect) 설계 완료
  - [ ] 로그·성능 측정 지점 정의(OSLog/MetricKit)
- PR/CI 체크
  - [ ] `tuist generate` 후 빌드/스킴 OK
  - [ ] 단위 테스트(TCA Reducer/SwiftData) 통과
  - [ ] 스냅샷/스펙 테스트(SwiftUI) 통과(해당 시)
  - [ ] 마이그레이션 TODO/브릿지 삭제 계획 반영
  - [ ] 커밋 규칙/리뷰 체크리스트 충족

거버넌스(바꾸는 법)
- 본 헌장은 설계/구현/리뷰의 “최상위 기준”입니다
- 바꿀 때는 “왜/영향/필요 조치”를 명시하고 유지자 승인(Approver 승인)을 받는다
- 버전 규칙
  - MAJOR: iOS/기술 스택/아키텍처처럼 큰 방향 변경
  - MINOR: 원칙/섹션 추가 또는 의미 있는 확장
  - PATCH: 오탈자/표현 다듬기(의미 불변)
- 템플릿/문서 동기화: plan/spec/tasks 템플릿과 README.md/문서의 관련 부분을 함께 갱신

마지막 확인(필수)
- [ ] 남은 빈칸 없음, 모든 날짜는 YYYY-MM-DD
- [ ] “버전” 라인과 동기화 보고서의 버전이 동일
- [ ] 핵심 원칙이 정확히 8개
- [ ] 금지/제거에 Rx/Realm/새 UIKit 코드 금지가 명시됨
- [ ] 마이그레이션 TODO에 기한이 정확히 기입됨

부칙
- 시행일: 2025-11-12
