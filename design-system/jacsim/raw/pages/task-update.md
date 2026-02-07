## Design System: Jacsim

### Pattern
- **Name:** Hero + Testimonials + CTA
- **Conversion Focus:** Social proof before CTA. Use 3-5 testimonials. Include photo + name + role. CTA after social proof.
- **CTA Placement:** Hero (sticky) + Post-testimonials
- **Color Strategy:** Hero: Brand color. Testimonials: Light bg #F5F5F5. Quotes: Italic, muted color #666. CTA: Vibrant
- **Sections:** 1. Hero, 2. Problem statement, 3. Solution overview, 4. Testimonials carousel, 5. CTA

### Style
- **Name:** Claymorphism
- **Keywords:** Soft 3D, chunky, playful, toy-like, bubbly, thick borders (3-4px), double shadows, rounded (16-24px)
- **Best For:** Educational apps, children's apps, SaaS platforms, creative tools, fun-focused, onboarding, casual games
- **Performance:** ⚡ Good | **Accessibility:** ⚠ Ensure 4.5:1

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
- **Mood:** Friendly + Playful typography

### Key Effects
Inner+outer shadows (subtle, no hard lines), soft press (200ms ease-out), fluffy elements, smooth transitions

### Avoid (Anti-patterns)
- Generic design
- No personality

### Pre-Delivery Checklist
- [ ] No emojis as icons (use SVG: Heroicons/Lucide)
- [ ] cursor-pointer on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Focus states visible for keyboard nav
- [ ] prefers-reduced-motion respected
- [ ] Responsive: 375px, 768px, 1024px, 1440px

