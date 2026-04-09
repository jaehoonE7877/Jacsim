# Projects/Modules/ThirdPartyLibs

**Purpose**: 외부 의존성(Dependencies) 집계 모듈입니다. 상위 모듈은 원시 `Package`를 직접 참조하지 않고 alias를 통해 사용합니다.

## Key Paths

| Task | Path |
|---|---|
| SPM package declarations | `../../../Package.swift` (repo root) |
| SPM aliases | `../../../Plugins/DependencyPlugin/ProjectDescriptionHelpers/Dependency+SPM.swift` |
| Module wiring | `Project.swift` |

## Verify

```bash
tuist generate
tuist build Jacsim
```

> 새 의존성 추가 또는 alias 변경 시 영향받는 scheme의 `tuist test <affected-scheme>`도 실행합니다.

## Rules

### ✅ Do

- 라이브러리 추가 순서는 `Package.swift` → `DependencyPlugin` alias 등록 → `Project.swift` 연동 순서를 따릅니다.
- 의존성 목록은 최소화하고 중복을 제거합니다.

### ⚠️ Ask First

- **새로운 의존성 추가**는 진행 전 사전 승인 필요

### 🚫 Do Not

- 앱/모듈 타겟에서 SPM 직접 참조를 추가하지 않음
- 라이선스와 유지관리 상태를 검증하지 않은 라이브러리를 도입하지 않음
