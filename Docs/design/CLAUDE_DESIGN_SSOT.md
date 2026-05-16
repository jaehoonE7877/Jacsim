# Claude Design SSoT

This document pins how Jacsim implementation work should read the Claude Design project before Goal 6.

## Source Hierarchy

1. `04-Final.html` - final palette, wallpaper anchors, Liquid Glass catalog, final screens, social model, Visibility Matrix, notification rules.
2. `02-DesignSystem.html` - focus.mode token tables and component rules.
3. `03-Screens.html` - redesigned screen flows.
4. `01-AsIs.html` - current-state audit and legacy mismatch reference.
5. `index.html` - navigation wrapper only.

If these files disagree, `04-Final.html` wins unless the goal explicitly says otherwise.

## Browser Audit Status

- The current Claude Design project is open at `https://claude.ai/design/p/019e2e13-a875-74ad-b477-d10f9a82f4d7`.
- The browser exposes the file tabs, but the rendered design body is inside a cross-origin preview iframe.
- Available visual evidence covers the top-level 04-Final sections, Liquid Glass catalog, Home A, Social data model, and the presence of the Visibility Matrix section.
- Exact table-cell extraction from the iframe is blocked in the in-app browser. For any future behavior change that depends on a hidden table cell, first obtain exported HTML/source or a legible screenshot crop.

## Implemented Baseline Before Goal 6

- Goal 1: iOS 26 deployment target and Liquid Glass DSKit helpers.
- Goal 2: focus.mode DSKit tokens, wallpaper gradients, Newsreader serif tokens, JetBrains Mono numeric tokens, spacing token `.jsTabBarMargin`.
- Goal 3: Liquid Glass DSKit components and new design components.
- Goal 4: 5-tab `MainView` root with `JSGlassFloatingTabBar` and plus sheet routing to `NewTaskView`.
- Goal 5: SwiftData V2 social schema, local-only repositories, DI wiring, and pure Domain `VisibilityMatrix`.

## Goal 6 Design Boundary

Goal 6 should redesign existing app screens against the above baseline. It may consume the new DSKit tokens/components, but it must not introduce new social behavior, notification delivery, network calls, or widget targets.

In scope:

- Walkthrough/onboarding visual update.
- Home A visual update without reintroducing Home FAB.
- Calendar visual update using `JSCalendarV2` where practical.
- Task create/detail/update visual update with DSKit tokens.
- Setting visual update, including open-source license entry and visibility/default-privacy copy.

Out of scope:

- Feed and Me real content.
- Follow request flows.
- Brag composer enablement.
- AI coach enablement.
- Notifications and widgets.
- Changing local social repository behavior.
