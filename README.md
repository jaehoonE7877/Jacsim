# Jacsim

[![iOS](https://img.shields.io/badge/iOS-18%2B-0A84FF)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6-F05138)](https://swift.org)
[![Tuist](https://img.shields.io/badge/Tuist-4.x-6E56CF)](https://tuist.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Port%20%26%20Adapter-1F9D55)](#아키텍처)

SwiftUI + TCA 기반 iOS 앱입니다.  
멀티모듈 구조와 Port & Adapter 아키텍처를 적용해, UI/도메인/인프라 관심사를 분리합니다.

## 핵심 포인트
- **SwiftUI + TCA**: 화면 상태와 액션 흐름을 예측 가능하게 관리
- **Port & Adapter**: 도메인/애플리케이션이 인프라 구현체에 직접 의존하지 않도록 분리
- **Tuist 멀티모듈**: 빌드·의존성·설정을 모듈 단위로 관리

## 아키텍처
```text
Presentation(App) ──▶ Application UseCases ──▶ ExternalInterface(Ports)
      ▲                                                   │
      │                                                   ▼
      └────────────── Domain Rules ◀────────────── Data Adapters
```

### 모듈 책임
| Module | Responsibility |
|---|---|
| `Projects/Jacsim` | App entry, Presentation(TCA), Application use case orchestration |
| `Projects/Domain` | 비즈니스 규칙, 엔티티, 도메인 서비스 |
| `Projects/ExternalInterface` | Port(프로토콜) 계약 정의 |
| `Projects/Data` | SwiftData/UserDefaults/알림 등 외부 I/O Adapter 구현 |
| `Projects/Modules/Core` | 공통 유틸/확장 |
| `Projects/Modules/DSKit` | 디자인 토큰/공통 UI 컴포넌트 |
| `Projects/Modules/ThirdPartyLibs` | 외부 라이브러리 집약 |

## 빠른 시작
### 요구사항
- Xcode
- Tuist
- iOS 18+ 시뮬레이터 또는 디바이스

### 로컬 빌드
```bash
tuist install
tuist generate
tuist build Jacsim
```

### 테스트
```bash
tuist test Jacsim
tuist test Domain
tuist test Data
tuist test ExternalInterface
```

## CI/CD 운영
- **배포 경로 단일화**: TestFlight 배포는 **Xcode Cloud**만 사용
- **GitHub Actions 역할**: 보조 CI(`lint/test`) 전용
- **Xcode Cloud 트리거 기본값**: `develop` 브랜치 변경 시 자동 실행
- **배포 스킴**: `Jacsim-Release`
- **TestFlight 대상**: Internal Tester
- **빌드 번호**: Xcode Cloud 자동 증가

### Xcode Cloud/App Store Connect 콘솔 설정값
1. App Store Connect > 앱 > Xcode Cloud에서 워크플로를 생성하고, 스킴은 `Jacsim-Release`를 선택
2. Start Condition은 `Branch Changes`, 브랜치는 `develop`으로 설정 (Develop 머지 시 자동 실행)
3. Action은 `Archive - iOS App` + `Distribute to TestFlight`를 사용하고 Internal Tester로 배포
4. Environment Variables/Secrets에 `GOOGLE_SERVICE_INFO_PLIST_BASE64`를 등록
5. Custom Build Script의 Post-clone 경로를 `ci_scripts/ci_post_clone.sh`로 등록

### Xcode Cloud 자동 빌드 번호 동작
- Xcode Cloud의 `CI_BUILD_NUMBER`를 Post-clone에서 `TUIST_APP_BUILD_NUMBER`로 전달
- Tuist 생성 시 `CURRENT_PROJECT_VERSION`이 `TUIST_APP_BUILD_NUMBER`로 설정
- `CFBundleVersion`은 `$(CURRENT_PROJECT_VERSION)`를 사용하므로 매 빌드마다 자동 증가

### 공식 문서
- Getting started with Xcode Cloud: https://developer.apple.com/documentation/xcode/getting-started-with-xcode-cloud
- Add Xcode Cloud workflows: https://developer.apple.com/help/app-store-connect/manage-builds/add-xcode-cloud-workflows/
- Configure workflow actions: https://developer.apple.com/help/app-store-connect/manage-builds/configure-actions-for-xcode-cloud-workflows/
- Custom build scripts: https://developer.apple.com/documentation/xcode/writing-custom-build-scripts
- Xcode Cloud environment variables: https://developer.apple.com/documentation/xcode/environment-variable-reference
- TestFlight internal testers: https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-internal-testers

### Tuist Cache (CAS) 트러블슈팅
- 기본값은 Xcode cache 비활성화(`TUIST_XCODE_CACHE` 미설정)
- 필요할 때만 `TUIST_XCODE_CACHE=1`로 활성화하고 `tuist setup cache`를 실행
- 캐시 소켓 이슈가 발생하면 `TUIST_XCODE_CACHE`를 비워 다시 생성하면 됨

## 프로젝트 구조
```text
Projects/
├── Jacsim/              # App(Presentation/Application)
├── Domain/              # Domain logic
├── ExternalInterface/   # Port contracts
├── Data/                # Adapter implementations
└── Modules/
    ├── Core/
    ├── DSKit/
    └── ThirdPartyLibs/
```

## 개발 원칙
- 신규 화면은 **SwiftUI + TCA**로 구현
- Domain은 UI/인프라 구현에 의존하지 않음
- Data는 Port 구현 중심, 비즈니스 규칙은 Domain에 배치
- 생성 산출물(`Derived`, `.build`, `build`) 직접 수정 금지

## Contributing
- 브랜치/PR/커밋 규칙은 `AGENTS.md`의 컨벤션을 따릅니다.
- 커밋 타입: `Feat`, `Fix`, `Docs`, `Style`, `Refactor`, `Test`, `Chore`

## 공개 저장소 문서 정책
- README와 AGENTS에는 **비밀값, 인증 키, 개인 식별자, 내부 운영 절차**를 기재하지 않습니다.
- 실행에 필요한 민감 설정은 로컬/CI의 비밀 저장소에서 관리합니다.
