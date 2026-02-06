# Projects/Modules/DSKit

## Overview
- Design system (tokens/assets) + some SwiftUI components
- Provides UI reuse units without business logic for apps/Features

## Structure
```
Projects/Modules/DSKit/
├── Resources/
│   ├── Colors/                     # Color assets
│   ├── Font/                       # Font files
│   └── Images/                     # Image Assets.xcassets
└── Sources/
    ├── Extension/                  # UIColor/Font extensions
    └── SwiftUI/                    # SwiftUI components (buttons, calendars, etc.)
```

## Where to Find
| Task | Location | Notes |
|------|----------|-------|
| Add tokens (color/font/icon) | `Projects/Modules/DSKit/Resources/**` | Use Tuist resource synthesizer (assets/fonts) |
| SwiftUI shared components | `Projects/Modules/DSKit/Sources/SwiftUI/**` | Component-level, not screen-level |
| Card components | `Projects/Modules/DSKit/Sources/SwiftUI/Components/JSUnifiedHeroCard.swift` | Hero card with unified design |
| Mini cards | `Projects/Modules/DSKit/Sources/SwiftUI/Components/JSMiniHeroCard.swift` | Mini hero cards for carousel |
| Skeleton UI | `Projects/Modules/DSKit/Sources/SwiftUI/Components/AnimatedSkeletonModifier.swift` | Shimmer animation skeleton |
| Press effect | `Projects/Modules/DSKit/Sources/SwiftUI/Components/PressEffectModifier.swift` | Touch press animation |
| UIKit compatibility extensions | `Projects/Modules/DSKit/Sources/Extension/**` | Keep minimal |

## Conventions
- DSKit depends only on `Core` (no direct dependency from app/Feature)
- Add resources under `Resources` and avoid hardcoding paths

## Anti-Patterns
- Adding network/DB/domain logic
- Implementing app-specific screens/flows in DSKit
- Modifying `Derived/` or generated `.xcodeproj` internal files
