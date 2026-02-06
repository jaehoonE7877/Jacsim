# Home Page Overrides

> **PROJECT:** Jacsim
> **Generated:** 2026-02-06 20:34:21
> **Page Type:** Home dashboard (active challenges + quick actions)

> ⚠️ **IMPORTANT:** Rules in this file **override** `design-system/jacsim/MASTER.md`.
> Only deviations from the Master are documented here. For all other rules, refer to the Master.

---

## Page-Specific Rules

### Layout Overrides

- **Layout:** Top summary + hero challenge + mini-card carousel + floating add CTA
- **Navigation:** Keep settings and "all tasks" as secondary actions in top area

### Spacing Overrides

- **Section rhythm:** Use `.jsLG` to `.jsXXL` between major sections
- **Horizontal padding:** Keep major content at `24pt` equivalent (`.jsXL` where possible)

### Typography Overrides

- **Title:** "작심" title uses Display/Headline tier, not raw `.system(...)`
- **Section header:** Use headline token family consistently

### Color Overrides

- **Background:** `Color.backgroundNormal`
- **Primary action:** `Color.primaryNormal`
- **Secondary text:** `Color.labelAlternative`
- **Avoid:** Plain `Color.white`, `.gray`, `.blue` in screen-level styles when DS tokens exist

### Component Overrides

- Use `JSUnifiedHeroCard` as first challenge surface
- Use `JSMiniHeroCardCarousel` for remaining active challenges
- Keep floating add button visual tied to `primaryNormal`

---

## Page-Specific Components

- No unique components for this page

---

## Recommendations

- Prioritize immediate daily action discovery: hero card should keep today's certification status visible
- If token migration is done, replace remaining hard-coded `.system` font usage with JS font tokens
- Keep skeleton state and loaded state layout-identical to reduce visual jump
