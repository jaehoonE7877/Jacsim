# Projects/Modules/DSKit

## Overview
- 디자인 토큰 + 공통 SwiftUI 컴포넌트 모듈
- 화면 로직이 아닌 UI 표현 계층만 담당

## Where to Find
| Task | Location |
|---|---|
| Design assets | `Projects/Modules/DSKit/Resources/**` |
| 공통 UI 컴포넌트 | `Projects/Modules/DSKit/Sources/SwiftUI/Components/**` |
| 디자인 확장 유틸 | `Projects/Modules/DSKit/Sources/Extension/**` |

## Conventions
- UI 스타일/재사용성 중심, 비즈니스 규칙 배치 금지
- 화면 상태 전이는 Jacsim Presentation에서 처리

## Anti-Patterns
- 네트워크/DB/도메인 로직 추가
- 앱 개별 화면을 DSKit에 직접 구현
