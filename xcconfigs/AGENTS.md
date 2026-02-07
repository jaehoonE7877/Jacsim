# xcconfigs

## Overview
- 빌드 설정을 `.xcconfig`로 분리해 중앙 관리
- 프로젝트/타깃 공통 설정을 명시적으로 관리

## Where to Find
| Task | Location |
|---|---|
| xcconfig 경로 매핑 | `Plugins/ConfigurationPlugin/ProjectDescriptionHelpers/Configurations.swift` |
| 프로젝트 공통 설정 | `xcconfigs/Base/Projects/**` |
| 타깃 타입별 설정 | `xcconfigs/targets/**` |

## Conventions
- 설정 변경은 xcconfig 기준으로 수행
- Tuist ConfigurationPlugin 매핑과 항상 동기화

## Anti-Patterns
- Xcode GUI에서만 설정 변경 후 xcconfig 미반영
