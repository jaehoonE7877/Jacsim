# Projects/JacsimClient

**Purpose**: App composition bridge. `Jacsim` app target와 하위 레이어(`Ports`, `Adapters`) 사이의 연결 지점을 담당한다.

## Key Paths

| Task | Path |
|---|---|
| Composition root | `Sources/DependencyAssembly.swift` |
| Port dependency keys | `Sources/*Client.swift` |
| Workflow dependency keys | `Sources/UseCaseClients.swift` |
| Workflow assembly | `Sources/UseCaseAssembly.swift` |
| Module project | `Project.swift` |

## Test

```bash
tuist test JacsimClient
```

## Rules

- `Ports` / `Adapters` import는 이 모듈 안에서만 유지한다
- `Jacsim` Presentation에서 concrete adapter를 직접 참조하지 않게 하는 bridge 역할만 담당한다
- `Workflows` import와 `DependencyValues` use case 등록도 이 모듈에서만 유지한다
- `Domain` service를 직접 `DependencyValues`로 노출하지 않고 workflow/use case로 감싼다
- 새로운 비즈니스 로직은 추가하지 않고, wiring과 dependency exposure만 다룬다
