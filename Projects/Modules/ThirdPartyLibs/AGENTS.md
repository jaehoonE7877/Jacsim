# Projects/Modules/ThirdPartyLibs

## Overview
- 외부 라이브러리 의존성을 한 곳에서 관리하는 집약 모듈
- 상위 모듈은 직접 패키지 참조보다 alias 의존을 우선 사용

## Where to Find
| Task | Location |
|---|---|
| 패키지 선언 | `Package.swift` |
| SPM alias | `Plugins/DependencyPlugin/ProjectDescriptionHelpers/Dependency+SPM.swift` |
| ThirdPartyLibs 연결 | `Projects/Modules/ThirdPartyLibs/Project.swift` |

## Conventions
- 라이브러리 추가 시 `Package.swift` + alias + ThirdPartyLibs 순으로 반영
- 중복/불필요 의존성 추가 금지

## Anti-Patterns
- 앱/모듈에서 SPM 직접 참조를 분산 추가
- 검토 없는 라이브러리 도입
