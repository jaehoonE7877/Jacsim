## Design System: Jacsim

### Pattern
- **Name:** Immersive/Interactive Experience
- **Conversion Focus:** 40% higher engagement. Performance trade-off. Provide skip option. Mobile fallback essential.
- **CTA Placement:** After interaction complete + Skip option for impatient users
- **Color Strategy:** Immersive experience colors. Dark background for focus. Highlight interactive elements.
- **Sections:** 1. Full-screen interactive element, 2. Guided product tour, 3. Key benefits revealed, 4. CTA after completion

### Style
- **Name:** Exaggerated Minimalism
- **Keywords:** Bold minimalism, oversized typography, high contrast, negative space, loud minimal, statement design
- **Best For:** Fashion, architecture, portfolios, agency landing pages, luxury brands, editorial
- **Performance:** ⚡ Excellent | **Accessibility:** ✓ WCAG AA

### Colors
| Role | Hex |
|------|-----|
| Primary | #2563EB |
| Secondary | #3B82F6 |
| CTA | #F97316 |
| Background | #F8FAFC |
| Text | #1E293B |

### Typography
- **Heading:** Inter
- **Body:** Inter
- **Mood:** Professional + Bold typography

### Key Effects
font-size: clamp(3rem 10vw 12rem), font-weight: 900, letter-spacing: -0.05em, massive whitespace

### Avoid (Anti-patterns)
- 2D-only layouts
- Poor image quality
- AI purple/pink gradients

### Pre-Delivery Checklist
- [ ] No emojis as icons (use SVG: Heroicons/Lucide)
- [ ] cursor-pointer on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Focus states visible for keyboard nav
- [ ] prefers-reduced-motion respected
- [ ] Responsive: 375px, 768px, 1024px, 1440px

