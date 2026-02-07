# Tuist

## Overview
- 프로젝트/타깃/템플릿을 코드로 생성하는 기준 레이어
- 모듈 구조와 빌드 구성을 선언적으로 유지

## Where to Find
| Task | Location |
|---|---|
| 모듈 생성 템플릿 | `Tuist/ProjectDescriptionHelpers/Project+Templates.swift` |
| 타깃 종류 정의 | `Tuist/ProjectDescriptionHelpers/FeatureTarget.swift` |
| 템플릿 파일 | `Tuist/Templates/**` |
| 워크스페이스 구성 | `Workspace.swift` |

## Conventions
- 타깃 구조 변경은 템플릿/헬퍼에 먼저 반영
- xcconfig 매핑과 함께 변경해 드리프트 방지

## Anti-Patterns
- Xcode UI에서만 설정 수정 후 Tuist 정의 미반영
