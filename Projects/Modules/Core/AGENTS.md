# Projects/Modules/Core (Shared)

**목적**: `Shared` 모듈의 공통 `Utility`와 `Extension`, 로깅 기능 모음입니다. `Business` `Logic`이나 UI는 포함하지 않습니다.

## Key Paths

| 작업 | 경로 |
|---|---|
| Foundation `Extension` | `Sources/Extension/Foundation/**` |
| 로깅 `Helper methods` | `Sources/Logger.swift` |

## Rules

### ✅ Do

- 가능한 범위에서 `Common functions`를 순수하게 유지하고 side-effect를 최소화합니다.
- 재사용 가능하고 `domain-agnostic`인 `Utility`만 이 모듈에 둡니다.

### 🚫 Do Not

- SwiftUI 뷰 또는 UI 코드를 추가하지 않습니다.
- 앱 특화 `Business Logic`을 Core에 배치하지 않습니다.
