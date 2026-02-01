# Plugins

## Overview
- Tuist plugins: Centralized management of dependencies, environment, xcconfig via code

## Where to Find
| Task | Location | Notes |
|------|----------|-------|
| SPM dependency aliases | `Plugins/DependencyPlugin/ProjectDescriptionHelpers/Dependency+SPM.swift` | `TargetDependency.SPM.*` |
| Internal module dependency aliases | `Plugins/DependencyPlugin/ProjectDescriptionHelpers/Dependency+Project.swift` | `Dep.Modules.*` |
| App environment (version/bundle/target) | `Plugins/EnvironmentPlugin/ProjectDescriptionHelpers/Enviroment.swift` | iOS 18, bundle prefix |
| xcconfig connections | `Plugins/ConfigurationPlugin/ProjectDescriptionHelpers/Configurations.swift` | `XCConfig.*` |

## Conventions
- Add aliases first when adding dependencies; projects should only use aliases
- Version/bundle/target (18.0) managed in one place via EnvironmentPlugin

## Anti-Patterns
- Hardcoding bundleId/target version per target, scattering configuration
