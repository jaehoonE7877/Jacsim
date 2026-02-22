# Projects/Features

**Purpose**: legacy/experimental 기능 모듈입니다. 실제 활성 화면 개발은 `Projects/Jacsim/Sources/Presentation`에서 진행합니다.

## Key Paths

| Task | Path |
|---|---|
| Feature template | `../Tuist/Templates/Feature/**` |
| Module generation rules | `../Tuist/ProjectDescriptionHelpers/Project+Templates.swift` |

## Rules

### ✅ Do

- 이 디렉터리는 과거/레거시 context 참조 용도로만 사용
- 신규 기능은 앱 본체 구조와 Tuist 템플릿 규칙을 따라 추가

### 🚫 Do Not

- 여기에 신규 활성 기능을 추가하지 않음 — `Projects/Jacsim/Sources/Presentation/`에 구현
- `.xcodeproj` 파일을 수동 생성하지 않음 (`tuist generate` 사용)
