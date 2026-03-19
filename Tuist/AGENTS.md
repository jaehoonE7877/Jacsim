# Tuist

**Purpose**: Tuist 기반 선언형 project/target/template 생성 계층으로, module 구조와 build config의 source of truth 역할을 합니다.

## Key Paths

| Task | Path |
|---|---|
| Module templates | `ProjectDescriptionHelpers/Project+Templates.swift` |
| Target type definitions | `ProjectDescriptionHelpers/FeatureTarget.swift` |
| Scaffold templates | `Templates/**` |
| Workspace config | `../Workspace.swift` |

## Verify

```bash
tuist generate
tuist build Jacsim
```

> 템플릿 또는 helper 변경으로 영향받는 module이 있으면 해당 scheme의 `tuist test <affected-scheme>`도 실행합니다.

## Rules

### ✅ Do

- 템플릿과 helper에 target/structure 변경을 우선 반영
- build configuration 수정 시 xcconfig mapping을 반드시 동기화

### ⚠️ Ask First

- `Tuist.swift`, `Workspace.swift`, plugin reference 변경은 전체 module에 영향을 주므로 사전 확인 필요

### 🚫 Do Not

- Tuist definitions를 갱신하지 않고 Xcode UI로만 settings 수정 금지
