# Projects/Modules/Core

## Overview
- 공통 유틸/확장/로깅 모듈
- 앱 비즈니스나 UI가 아닌 재사용 기반 코드 중심

## Where to Find
| Task | Location |
|---|---|
| String/Date/Array 확장 | `Projects/Modules/Core/Sources/Extension/Foundation/**` |
| Logging helper | `Projects/Modules/Core/Sources/Logger.swift` |

## Conventions
- Side effect 최소화, 순수 유틸 우선
- 도메인 규칙/화면 로직은 Core에 두지 않음

## Anti-Patterns
- SwiftUI/View 코드 추가
- 앱 전용 정책을 Core에 배치
