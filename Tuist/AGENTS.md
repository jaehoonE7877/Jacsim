# Tuist

## Overview
- Tuist-based project generation, rules, templates

## Where to Find
| Task | Location | Notes |
|------|----------|-------|
| Module generation rules | `Tuist/ProjectDescriptionHelpers/Project+Templates.swift` | `Project.makeModule(...)` |
| Target type definitions | `Tuist/ProjectDescriptionHelpers/FeatureTarget.swift` | app/framework/tests/demo |
| Templates (Feature/Module) | `Tuist/Templates/**` | Stencil + scaffolding |
| Workspace | `Workspace.swift` | `projects: ["Projects/**"]` |

## Conventions
- Build settings connected via `ConfigurationPlugin` `XCConfig.*` and `xcconfigs/**`
- New target types/scheme rules managed consistently in `Project+Templates.swift`

## Anti-Patterns
- Adding per-project schemes/settings inconsistently, breaking uniformity
