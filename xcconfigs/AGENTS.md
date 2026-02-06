# xcconfigs

## Overview
- Build settings separated into `.xcconfig` files referenced by Tuist

## Structure
```
xcconfigs/
├── Base/Projects/                  # Project-Debug/Release.xcconfig
└── targets/                        # iOS-Framework/Demo/Tests.xcconfig
```

## Where to Find
| Task | Location | Notes |
|------|----------|-------|
| xcconfig path mapping | `Plugins/ConfigurationPlugin/ProjectDescriptionHelpers/Configurations.swift` | `XCConfig.Path.*` |
| Framework settings | `xcconfigs/targets/iOS-Framework.xcconfig` | Module common |
| Framework+Tests settings | `xcconfigs/targets/iOS-FrameworkTests.xcconfig` | Framework tests (if exists) |
| Tests settings | `xcconfigs/targets/iOS-Tests.xcconfig` | Test target common |
| Demo settings | `xcconfigs/targets/iOS-Demo.xcconfig` | Demo app target (if exists) |
| App (Project) settings | `xcconfigs/Base/Projects/Project-Debug.xcconfig` | Debug/Release |

## Anti-Patterns
- Changing build settings only in Xcode GUI and leaving them out of sync with `.xcconfig`
