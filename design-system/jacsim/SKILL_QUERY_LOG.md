# Jacsim UI/UX Skill Query Log

- Skill: `ui-ux-pro-max`
- Source: `.agents/skills/ui-ux-pro-max`
- Scope: Presentation 전면 리디자인 기준 산출

## Baseline Query (Raw Recommendation)

```bash
python3 .agents/skills/ui-ux-pro-max/scripts/search.py \
  "habit tracker productivity enterprise mobile brand expressive" \
  --design-system -p "Jacsim" -f markdown
```

## Page Queries (Raw Recommendation)

```bash
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "jacsim home dashboard hero tasks quick actions" --design-system -p "Jacsim" -f markdown
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "jacsim all tasks list grouped status enterprise" --design-system -p "Jacsim" -f markdown
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "jacsim calendar daily completion timeline" --design-system -p "Jacsim" -f markdown
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "jacsim create challenge form title stage photo alarm" --design-system -p "Jacsim" -f markdown
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "jacsim daily certification update photo memo" --design-system -p "Jacsim" -f markdown
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "jacsim challenge detail progress stage records" --design-system -p "Jacsim" -f markdown
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "jacsim edit challenge form notification target" --design-system -p "Jacsim" -f markdown
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "jacsim settings theme notification help app info" --design-system -p "Jacsim" -f markdown
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "jacsim onboarding walkthrough education permission" --design-system -p "Jacsim" -f markdown
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "jacsim challenge create modal flow" --design-system -p "Jacsim" -f markdown
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "jacsim main container navigation root" --design-system -p "Jacsim" -f markdown
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "jacsim app shell onboarding main switch" --design-system -p "Jacsim" -f markdown
```

## Adoption Rules

- 스킬 원본 출력은 `design-system/jacsim/raw/`에 저장한다.
- `MASTER.md`를 기본 규칙으로 사용한다.
- `pages/<screen>.md`가 존재하면 해당 파일 규칙이 우선한다.
- 스킬 제안이 코드에 반영되지 않으면 PR 본문에 이유를 남긴다.
