# Projects/Modules/ThirdPartyLibs

## Overview
- Centralizes external dependencies (Framework target) for other modules to depend on indirectly
- Tuist `DependencyPlugin` `TargetDependency.SPM.*` aliases point here

## Where to Find
| Task | Location | Notes |
|------|----------|-------|
| SPM package declarations | `Package.swift` | URL/version management |
| SPM alias list | `Plugins/DependencyPlugin/ProjectDescriptionHelpers/Dependency+SPM.swift` | `TargetDependency.SPM.*` |
| External deps in ThirdPartyLibs | `Projects/Modules/ThirdPartyLibs/Project.swift` | Lists `.SPM.*` |

## Recommended New Dependency Procedure
1) Add `.package(...)` to `Package.swift`
2) Add alias in `Plugins/DependencyPlugin/.../Dependency+SPM.swift`
3) Include in `externalDependencies` in `Projects/Modules/ThirdPartyLibs/Project.swift`
4) Upper modules add `Dep.Modules.thirdPartyLibs` or only needed module dependencies

## Anti-Patterns
- Adding direct SPM dependencies in apps/modules, scattering the dependency graph
- Adding unused external libraries without reason/alternative/cost comparison (prohibited: `memory/constitution.md`)
