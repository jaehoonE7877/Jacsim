# Plugins

**Purpose**: Tuist Plugin (Dependency / Environment / Configuration)은 dependency alias, environment value, xcconfig mapping을 관리하는 단일 진실 출처입니다.

## Key Paths

| Task | Path |
|---|---|
| Dependency aliases | `DependencyPlugin/ProjectDescriptionHelpers/**` |
| App environment values | `EnvironmentPlugin/ProjectDescriptionHelpers/Enviroment.swift` |
| xcconfig mapping | `ConfigurationPlugin/ProjectDescriptionHelpers/Configurations.swift` |

## Rules

### ✅ Do

- 프로젝트에서는 하드코딩된 path/value 대신 Plugin alias 사용
- bundle ID와 deployment target은 EnvironmentPlugin에서 일괄 관리

### ⚠️ Ask First

- Plugin 변경은 모든 module에 전파되므로 수정 범위를 먼저 확인

### 🚫 Do Not

- 개별 project 파일에서 target-specific 설정을 중복 정의하지 않기
