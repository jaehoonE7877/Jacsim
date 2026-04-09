# Tuist

**Purpose**: Tuist 기반 선언형 project/target/template 생성 계층으로, module 구조와 build config의 source of truth 역할을 합니다.

## Key Paths

| Task | Path |
|---|---|
| Project builders | `ProjectDescriptionHelpers/Project+Templates.swift` |
| Swift language version | `ProjectDescriptionHelpers/FeatureTarget.swift` |
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
- 앱 target은 `makeAppProject(...)`, 프레임워크/모듈 target은 `makeFrameworkProject(...)` 기준으로 유지한다
- 새 모듈 스캐폴드는 `Templates/**`와 두 builder 규칙을 함께 갱신한다
- build configuration 수정 시 xcconfig mapping을 반드시 동기화
- 테스트 설정 변경 시 `XCConfig.tests`와 `includeTests` 동작을 함께 검토한다

### ⚠️ Ask First

- `Tuist.swift`, `Workspace.swift`, plugin reference 변경은 전체 module에 영향을 주므로 사전 확인 필요

### 🚫 Do Not

- Tuist definitions를 갱신하지 않고 Xcode UI로만 settings 수정 금지
- 범용 flag surface를 다시 늘리기 위해 generic builder를 재도입하지 않는다
- `FeatureTarget.swift`를 target-type 정의 파일로 다시 확장하지 않는다. 현재 역할은 Swift language version 보조에 한정한다
