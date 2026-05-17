# Goal 6 Preflight

Goal 6 can begin after the following baseline remains green.

## Required Baseline

- `tuist clean`
- `tuist generate`
- `tuist build Jacsim`
- `tuist test Jacsim`
- `tuist test Domain`
- `tuist test Data`
- `tuist test ExternalInterface`
- `git diff --check`

## Screen Scope

Goal 6 should update the visual layer of these existing surfaces:

- Walkthrough
- Main shell polish only
- Home
- Calendar
- Task create
- Task detail
- Task update
- Settings

Do not implement real Feed/Me content. They are placeholders until Goal 7.

## Design Inputs

- `design-system/jacsim/MASTER.md`
- `design-system/jacsim/pages/*.md`
- `docs/design/CLAUDE_DESIGN_SSOT.md`
- `docs/design/VISIBILITY_MATRIX.md`
- Claude Design `04-Final.html` and `02-DesignSystem.html`

## Non-Negotiables

- Use DSKit semantic colors, fonts, spacing, and Liquid Glass components.
- Keep Home FAB removed.
- Keep plus sheet disabled actions disabled.
- Keep existing migrated tasks private by default.
- Do not introduce network-backed social behavior.
- Do not add a widget target.
