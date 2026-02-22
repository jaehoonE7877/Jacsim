# xcconfigs

**Purpose**: 모든 project와 target의 `.xcconfig` build settings를 중앙 관리합니다.

## Key Paths

| Task | Path |
|---|---|
| xcconfig → Tuist mapping | `../Plugins/ConfigurationPlugin/ProjectDescriptionHelpers/Configurations.swift` |
| Project-level settings | `Base/Projects/**` |
| Target-type settings | `targets/**` |

## Rules

### ✅ Do

- build setting 변경은 Xcode GUI 대신 xcconfig 파일에서 수행
- 변경 시 ConfigurationPlugin mapping을 즉시 동기화

### ⚠️ Ask First

- xcconfig 변경은 전체 target에 영향을 줄 수 있어 수정 범위를 먼저 확인

### 🚫 Do Not

- Xcode GUI에서 build settings를 바꾼 뒤 여기에 반영하지 않기
