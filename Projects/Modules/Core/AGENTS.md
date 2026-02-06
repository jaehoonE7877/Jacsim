# Projects/Modules/Core

## Overview
- Common utilities/extensions module
- Houses Foundation extensions/helpers repeated across modules

## Structure
```
Projects/Modules/Core/
└── Sources/
    └── Extension/                  # Foundation-centric extensions
```

## Where to Find
| Task | Location | Notes |
|------|----------|-------|
| Date/format/utils | `Projects/Modules/Core/Sources/Extension/Foundation/**` | Common extension location |
| Tests | `Projects/Modules/Core/Tests/Sources/**` | Module unit tests |

## Conventions
- Keep `Core` as pure as possible (minimal side effects)
- External libraries should be introduced via `ThirdPartyLibs` (avoid direct SPM dependency)

## Anti-Patterns
- Adding UI (views/components) code
- Putting app-specific business rules in Core
