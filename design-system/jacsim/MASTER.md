# Jacsim Design System Master File

> **LOGIC:** `04-Final.html` is the visual ground truth. This file pins the repo-facing implementation contract, and `pages/<screen>.md` may only add screen-specific constraints.

---

**Project:** Jacsim  
**Design source:** `claude.ai/design/p/019e2e13-a875-74ad-b477-d10f9a82f4d7`  
**Canonical files:** `04-Final.html` > `02-DesignSystem.html` > `03-Screens.html` > `01-AsIs.html` > `index.html`  
**Updated:** 2026-05-16

---

## Global Direction

- Direction: focus.mode redesign with calm progress, social proof, and iOS 26 Liquid Glass depth.
- First screen: usable product UI, not a landing page.
- Layout density: quiet and scannable; avoid marketing-style hero/card stacking.
- Motion: use meaningful state feedback only; disable tab/screen transition animation when `accessibilityReduceMotion` is true.
- Implementation: SwiftUI + `@Observable`, DSKit tokens only, no RxSwift/Realm additions.

## Claude Design Audit Anchors

- `01-AsIs.html`: current design audit and legacy blue/teal mismatch reference.
- `02-DesignSystem.html`: focus.mode token system, Newsreader/Pretendard/JetBrains Mono typography, Liquid Glass component catalog.
- `03-Screens.html`: redesigned walkthrough/home/calendar/task flows.
- `04-Final.html`: final palette, wallpaper anchors, Liquid Glass components, social model, Visibility Matrix, notification rules.
- Browser caveat: Claude renders the HTML preview inside a cross-origin iframe. The in-app browser can inspect file tabs and screenshots, but exact table DOM extraction may be blocked. When table-level certainty matters, prefer exported HTML/source or a readable screenshot before changing code behavior.

## DSKit Token Contract

- Colors: use `Color.primaryNormal`, `Color.forestAccent`, semantic label/background/surface tokens, streak/progress tokens, and the three wallpaper gradients.
- Fonts: use Pretendard semantic text tokens for Korean/body UI, Newsreader semantic serif tokens for display/quote moments, and JetBrains Mono tokens for D-day, time, and numeric counts.
- Serif policy: Newsreader has no Hangul glyphs. SwiftUI system fallback is allowed; split English/Korean runs only when visual composition is visibly uneven.
- Spacing: use DSKit spacing constants. Floating tab bar margin is `.jsTabBarMargin`.
- Liquid Glass: use `JSGlassFloatingTabBar`, `JSGlassCard`, `JSGlassSearchField`, `JSGlassToast`, `JSBottomSheet(glass: true)`, `jsGlassNavBar()`, and `JSWidgetSurface` before adding a new glass primitive.

## Screen Architecture Contract

- Root: `MainView` owns the 5-tab shell: today, calendar, plus, feed, me.
- Today: `HomeView` has no scroll-driven FAB; primary create flow moves to the center plus tab.
- Plus: plus sheet starts `NewTaskView` for "새 작심 만들기"; brag composer and AI coach remain disabled until later goals.
- Calendar: Goal 6 may adopt `JSCalendarV2` visuals, but must not change persistence rules.
- Feed/Me: placeholders exist only; real social UI belongs to Goal 7.

## Accessibility Rules

- Every new/changed component needs a default VoiceOver label.
- Dynamic Type must be checked at accessibility XXXLarge for token previews and major screens.
- Avoid text overlap in compact width; prefer wrapping and stable container dimensions.
- Keep interactive hit targets at least `.jsTouchTarget`.
- Do not encode state by color only.

## Anti-Patterns

- Hardcoded SwiftUI colors such as `Color.blue`, `Color.red`, `Color.gray`, `Color.white`, `Color.black`.
- Direct `.system(...)` fonts inside new UI.
- New component abstractions that duplicate existing DSKit Liquid Glass components.
- Screen-level networking or social repository calls in Goal 6.
- Making private migrated tasks visible by default.

## Delivery Checklist

- [ ] Match `04-Final.html` first, then `02-DesignSystem.html`.
- [ ] Use DSKit color/font/spacing tokens only.
- [ ] Preserve existing model/repository behavior unless the goal explicitly asks for it.
- [ ] Verify Light, Dark, and accessibility XXXLarge where UI changed.
- [ ] Run the agreed build/test baseline before handoff.
