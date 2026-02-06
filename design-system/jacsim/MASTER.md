# Design System Master File

> **LOGIC:** Build screens using `design-system/jacsim/MASTER.md` first.
> Then apply per-screen overrides from `design-system/jacsim/pages/[page-name].md` if present.

---

**Project:** Jacsim
**Generated:** 2026-02-06
**Product Type:** Habit challenge tracking app (daily certification, stage progression, reminder)

---

## Global Rules

### Color Tokens (Use DSKit semantic tokens only)

| Purpose | SwiftUI Token | UIKit Token |
|---|---|---|
| Brand primary | `Color.primaryNormal` | `UIColor.primaryNormal` |
| Brand emphasis | `Color.primaryStrong` | `UIColor.primaryStrong` |
| Text strong | `Color.labelStrong` | `UIColor.labelStrong` |
| Text default | `Color.labelNormal` | `UIColor.labelNormal` |
| Text secondary | `Color.labelAlternative` | `UIColor.labelAlternative` |
| Disabled text | `Color.labelDisable` | `UIColor.labelDisable` |
| Surface base | `Color.backgroundNormal` | `UIColor.backgroundNormal` |
| Surface elevated | `Color.backgroundStrong` | `UIColor.backgroundStrong` |
| Surface alt | `Color.backgroundAlternative` | `UIColor.backgroundAlternative` |
| Success | `Color.positive` | `UIColor.positive` |
| Warning | `Color.cautionary` | `UIColor.cautionary` |
| Error | `Color.destructive` | `UIColor.destructive` |

### Typography Tokens

Use existing Pretendard token set. Do not introduce per-screen hard-coded fonts.

- Display: `Font.jsDisplayLarge`, `Font.jsDisplayMedium`, `Font.jsDisplaySmall`
- Headline: `Font.jsHeadlineLarge`, `Font.jsHeadlineMedium`, `Font.jsHeadlineSmall`
- Body: `Font.jsBodyLarge`, `Font.jsBodyMedium`, `Font.jsBodySmall`
- Label: `Font.jsLabelLarge`, `Font.jsLabelMedium`, `Font.jsLabelSmall`
- Button: `Font.jsButtonLarge`, `Font.jsButtonMedium`, `Font.jsButtonSmall`

### Spacing Tokens

Use DSKit spacing scale.

| Token | Value |
|---|---|
| `JSSpacing.micro` / `.jsMicro` | 4 |
| `JSSpacing.xs` / `.jsXS` | 8 |
| `JSSpacing.sm` / `.jsSM` | 12 |
| `JSSpacing.md` / `.jsMD` | 16 |
| `JSSpacing.lg` / `.jsLG` | 20 |
| `JSSpacing.xl` / `.jsXL` | 24 |
| `JSSpacing.xxl` / `.jsXXL` | 32 |
| `JSSpacing.touchTarget` / `.jsTouchTarget` | 44 |

### Visual Direction

- Primary direction: calm utility + progress clarity (not decorative showcase)
- Card style: subtle elevation, soft radius, strong readability
- Motion: short and meaningful (`0.2s` to `0.3s`) for transitions, sheet, feedback
- State color policy: success=`positive`, caution=`cautionary`, fail=`destructive`

---

## Component Specs (SwiftUI/DSKit)

### Buttons

- Prefer `JSButton(style:size:)` for CTA and secondary actions
- Primary CTA: `style: .primary`, minimum height aligned with touch target (44+)
- Secondary CTA: `style: .secondary`
- Disabled/Loading: preserve layout while showing `JSProgressIndicator`

### Cards

- Prefer `JSCard` / `JSUnifiedHeroCard` / `JSMiniHeroCard` variants
- Use semantic background (`backgroundStrong` or `backgroundAlternative`)
- Keep progress indicators visible in both light/dark mode

### Inputs

- Prefer `JSInputField` and DSKit input wrappers
- Error state uses `destructive` token only
- Keep helper text as `labelAssistive` and validation text as `destructive`

### Modal / Sheet

- Prefer DSKit bottom sheet/modal components (`JSBottomSheet`, `JSModal`)
- Maintain clear dismissal affordance and stable keyboard behavior

---

## Anti-Patterns (Do NOT Use)

- Hard-coded brand colors (`.blue`, `.green`, `.red`) in production screens when semantic tokens exist
- Mixed typography (`.system(...)`) in core screen copy where JS font tokens are available
- Web-specific checklist items in iOS docs (e.g., `cursor-pointer`, CSS hover-centric guidance)
- Decorative 3D/WebGL/landing-page recommendations unrelated to app task flows

---

## Delivery Checklist

- [ ] New/updated UI uses DSKit color tokens (`Color+DSKit`, `UIColor+Extension`)
- [ ] New/updated UI uses DSKit typography and spacing tokens
- [ ] Success/fail/pending states use semantic status tokens
- [ ] Add/edit/detail flows keep CTA hierarchy consistent (primary then secondary)
- [ ] Contrast is readable in both light and dark mode
- [ ] No new UIKit view controllers for feature screens (SwiftUI + TCA only)
