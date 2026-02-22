# Projects/Modules/DSKit (DesignSystem)

**목적**: Design system — 토큰 기반의 일관된 UI를 제공하는 `Component`, `Token`, 공통 `SwiftUI` 구성요소를 관리합니다. 비즈니스 로직은 포함하지 않습니다.

## 주요 경로

| 항목 | 경로 |
|---|---|
| 디자인 자산 | `Resources/**` |
| 공통 UI Component | `Sources/SwiftUI/Components/**` |
| UI extensions | `Sources/Extension/**` |

## 규칙

### ✅ 수행

- 재사용 가능한, 스타일 중심의 `Component` 중심으로 작성
- `State` 변경/전환 로직은 DSKit이 아닌 Jacsim `Presentation`에 둡니다

### 🚫 금지

- 네트워킹, 데이터베이스, 도메인 로직 추가 금지
- 앱 전용 화면(`View`)을 DSKit에서 직접 구현하지 않음
