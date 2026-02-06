# Task Detail Page Overrides

> **PROJECT:** Jacsim
> **Generated:** 2026-02-06 20:34:21
> **Page Type:** Challenge detail and daily certification timeline

> ⚠️ **IMPORTANT:** Rules in this file **override** `design-system/jacsim/MASTER.md`.
> Only deviations from the Master are documented here. For all other rules, refer to the Master.

---

## Page-Specific Rules

### Layout Overrides

- **Header:** Large cover image with collapsible minimized header
- **Body sections:** Stage info -> today's status -> record list -> bottom CTA
- **Bottom area:** Gradient-backed persistent CTA zone

### Spacing Overrides

- Keep card and section gaps to `.jsMD` / `.jsLG`
- Preserve minimum bottom breathing room above CTA zone

### Typography Overrides

- Task title: Display or headline token depending on header mode
- Progress and metadata: body/label token hierarchy only

### Color Overrides

- Stage progress pending: `primaryNormal`
- Stage success: `positive`
- Stage fail: `destructive`
- Status surfaces should use `backgroundStrong`/`backgroundAlternative`

### Component Overrides

- Use `JSCard` for stage summary and contextual feedback blocks
- Use `JSProgress` for stage progress indicator
- Use `JSStatusChip` for today/state chips

---

## Page-Specific Components

- No unique components for this page

---

## Recommendations

- Keep stage result pop-up motion lightweight and readable; avoid ornamental animation that delays action
- Ensure failed/success state CTAs are visually distinct but token-consistent
- If token migration is done, remove remaining raw system colors in row/status visuals
