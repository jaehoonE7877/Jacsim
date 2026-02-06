# Design System Master File

> **LOGIC:** `MASTER.md`를 기본으로 적용하고, 화면별 규칙은 `pages/<screen>.md`가 override 합니다.

---

**Project:** Jacsim
**Generated:** 2026-02-07
**Source:** `ui-ux-pro-max` 추천값을 Jacsim(iOS/SwiftUI/DSKit) 기준으로 정규화

---

## Global Rules

### Visual Direction

- Direction: Brand-Expressive + Enterprise Clarity
- Base tone: 높은 가독성, 낮은 장식 밀도, 즉시 행동 가능한 정보 우선
- Motion: 핵심 피드백에만 0.2~0.3s 모션 사용, `reduceMotion` 활성 시 정적 전환

### Color Token Mapping (DSKit only)

| Skill Role | Hex Hint | Jacsim Token |
|---|---|---|
| Primary | `#0D9488` | `Color.primaryNormal` |
| Secondary | `#14B8A6` | `Color.primaryStrong` |
| CTA Accent | `#F97316` | `Color.cautionary` |
| Surface | `#F0FDFA` | `Color.backgroundNormal` |
| Text | `#134E4A` | `Color.labelStrong` |
| Success | - | `Color.positive` |
| Warning | - | `Color.cautionary` |
| Error | - | `Color.destructive` |

### Typography Rules

- Display: `Font.jsDisplayLarge/Medium/Small`
- Headline: `Font.jsHeadlineLarge/Medium/Small`
- Body: `Font.jsBodyLarge/Medium/Small`
- Label: `Font.jsLabelLarge/Medium/Small`
- Button: `Font.jsButtonLarge/Medium/Small`
- 금지: 화면 레벨에서 `.system(...)` 하드코딩

### Layout/Spacing Rules

- Screen padding: 기본 수평 `.jsMD`, 강조 화면 `.jsXL`
- Section gap: `.jsLG` ~ `.jsXXL`
- Touch target: 최소 `.jsTouchTarget` (44pt)
- Bottom CTA가 있는 화면은 스크롤 콘텐츠 하단 여백 최소 `120pt`

### State Model (Mandatory)

모든 핵심 화면은 아래 상태를 가져야 합니다.

- `content`
- `loading`
- `empty`
- `error` (+ retry action 권장)

공통 구현: `RedesignScreenState`, `RedesignInlineErrorView`, `RetryActionModel`

### Component Rules

- CTA: `JSButton` 우선 사용
- Section surface: `RedesignSectionCard` 또는 `JSCard`
- Input: `JSInputField` 우선, 오류는 인풋 근처에 표시
- Status: `JSStatusChip`, `RedesignStateBanner`
- Calendar/List: `JSCalendar`, `JSListItem`

---

## Accessibility Rules

- VoiceOver 라벨/힌트 누락 금지
- Dynamic Type 큰 사이즈에서 잘림/겹침 금지
- 텍스트 대비 4.5:1 이상 유지
- 모션 효과는 `@Environment(\.accessibilityReduceMotion)`로 분기

---

## Anti-Patterns (Do NOT Use)

- SwiftUI 화면에서 CSS/Web 체크리스트 직접 적용
- 하드코딩 색상(`.blue/.red/.gray/.white`) 남용
- 실패 상태에서 사용자 복구 경로 부재
- 의미 없는 장식 애니메이션

---

## Delivery Checklist

- [ ] DSKit 토큰만 사용 (`Color/Font/Spacing`)
- [ ] `loading/empty/error` 상태 확인
- [ ] 주요 액션에 접근성 라벨 제공
- [ ] `reduceMotion` 대응 확인
- [ ] 플래그(`PresentationRedesignFlags`)로 롤백 가능
