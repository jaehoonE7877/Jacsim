# Projects/Features

## Overview
- Directory containing individual Feature unit projects and experimental traces
- Multiple `*Feature.xcodeproj` exist, but new features should prioritize Tuist templates and current app structure

## Where to Find
| Task | Location | Notes |
|------|----------|-------|
| Feature template (generation rules) | `Tuist/Templates/Feature/**` | Stencil-based |
| Feature dependency rules | `Tuist/ProjectDescriptionHelpers/Project+Templates.swift` | `Project.makeModule` |
| Feature dependency helpers | `Plugins/DependencyPlugin/ProjectDescriptionHelpers/Dependency+Project.swift` | `Dep.Features.*` |

## Conventions
- `Derived/` and `.xcodeproj/xcuserdata` are treated as generated artifacts (do not modify)
- New features follow SwiftUI + TCA + SwiftData + Concurrency standards (`memory/constitution.md`)

## Anti-Patterns
- Manually adding xcodeproj in Xcode and diverging from Tuist definitions
