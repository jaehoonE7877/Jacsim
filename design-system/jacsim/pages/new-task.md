# New Task Page Overrides

> **PROJECT:** Jacsim
> **Generated:** 2026-02-06 20:34:21
> **Page Type:** New challenge creation flow

> ⚠️ **IMPORTANT:** Rules in this file **override** `design-system/jacsim/MASTER.md`.
> Only deviations from the Master are documented here. For all other rules, refer to the Master.

---

## Page-Specific Rules

### Layout Overrides

- **Layout:** Single-column form stack for fast completion
- **Sections:** title -> stage selection -> representative photo -> alarm option -> action buttons
- **Flow:** keep save path linear and clear (no marketing sections)

### Spacing Overrides

- Use `.jsMD` / `.jsLG` between form blocks
- Keep primary and secondary buttons grouped in fixed bottom action area

### Typography Overrides

- Form section labels use `jsHeadlineSmall`
- Field helper and validation text use label/body small tokens

### Color Overrides

- Save CTA: `primaryNormal`
- Validation error text/background: `destructive`
- Form background: `backgroundNormal` with elevated field surfaces

### Component Overrides

- Use `JSInputField` for title input and keep helper text visible
- Use DSKit button variants for submit/cancel (`JSButton`)
- Show loading state with `JSProgressIndicator` while saving

---

## Page-Specific Components

- No unique components for this page

---

## Recommendations

- Keep required fields minimal: title + image should remain explicit preconditions
- Keep alarm toggle and time picker progressive (show picker only when enabled)
- If token migration is done, replace remaining raw `.red` and `.white` references with DS semantic tokens
