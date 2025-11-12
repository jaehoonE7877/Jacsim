# 개발 일지
***
### [Notion Link](https://meadow-caravan-6e7.notion.site/df7a4511ff71499a80dfa5bf1c991b83) 

## 프로젝트 헌장 요약 (v1.0.0, 2025-11-12)
- 최소 지원: iOS 18+
- 데이터/비동기: Realm, RxSwift 제거 → SwiftData, Swift Concurrency(Async/Await, AsyncSequence)
- UI: UIKit 신규 코드 금지, 모든 새 화면은 SwiftUI로 작성
- 아키텍처: TCA(Composable Architecture)로 Feature 단위(State/Action/Reducer/Effect)
- 디자인 시스템: DSKit은 “토큰/자산”만 재사용, SwiftUI 컴포넌트 신규 구축

주요 마이그레이션 기한
- iOS 18 타깃 상향: 2025-11-30
- SwiftData 스키마 확정: 2025-12-15
- 핵심 화면 Rx → Concurrency: 2025-12-31
- Realm → SwiftData 전환(읽기/쓰기): 2026-01-31
- UIKit 브릿지 삭제: 2026-02-28 / Rx·Realm 완전 제거: 2026-03-31

빠른 체크리스트
- [ ] 새 기능은 SwiftUI+TCA, Rx/Realm/새 UIKit 코드 금지
- [ ] SwiftData 모델/저장 구조 정의 및 테스트 포함
- [ ] OSLog/MetricKit 측정 지점 정의, 단위/스냅샷 테스트 통과

전체 문서: `memory/constitution.md`
생성 플로우: `templates/commands/constitution.md`
