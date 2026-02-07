# Plugins

## Overview
- Tuist 플러그인(Dependency/Environment/Configuration) 관리 영역
- 의존성 alias, 환경값, 설정 매핑의 단일 소스

## Where to Find
| Task | Location |
|---|---|
| 내부/외부 의존 alias | `Plugins/DependencyPlugin/ProjectDescriptionHelpers/**` |
| 앱 환경값(번들/타깃/버전) | `Plugins/EnvironmentPlugin/ProjectDescriptionHelpers/Enviroment.swift` |
| xcconfig 매핑 | `Plugins/ConfigurationPlugin/ProjectDescriptionHelpers/Configurations.swift` |

## Conventions
- 프로젝트에서는 직접 경로 대신 플러그인 alias 우선 사용
- 번들 ID/배포 타깃은 중앙에서 관리

## Anti-Patterns
- 타깃별 설정을 각 프로젝트에서 중복 하드코딩
