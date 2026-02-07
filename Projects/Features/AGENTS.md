# Projects/Features

## Overview
- 과거/실험용 Feature 프로젝트 보관 영역
- 현재 실사용 화면 개발은 `Projects/Jacsim/Sources/Presentation` 중심

## Where to Find
| Task | Location |
|---|---|
| Feature 템플릿 | `Tuist/Templates/Feature/**` |
| 모듈 생성 규칙 | `Tuist/ProjectDescriptionHelpers/Project+Templates.swift` |
| 의존성 alias | `Plugins/DependencyPlugin/ProjectDescriptionHelpers/Dependency+Project.swift` |

## Conventions
- 신규 기능은 현재 앱 구조와 Tuist 규칙을 우선 적용
- 생성 산출물(`Derived`, `xcuserdata`)은 소스 관리 대상에서 제외

## Anti-Patterns
- 수동 xcodeproj 추가로 Tuist 정의와 불일치 발생
