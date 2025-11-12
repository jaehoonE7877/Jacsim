### /speckit.constitution — 프로젝트 헌장 생성/업데이트 플로우

본 명령은 `.specify/memory/constitution.md`를 생성 또는 업데이트합니다. 아래 체크리스트를 모두 충족해야 하며, 빈칸/미정 표기는 금지합니다.

## 입력 메타데이터(필수)
- PROJECT_NAME: <string>
- CONSTITUTION_VERSION: <semver>
- RATIFICATION_DATE: <YYYY-MM-DD>
- LAST_AMENDED_DATE: <YYYY-MM-DD>

## 생성 규칙
- 문서 맨 위에 HTML 주석 형태의 “동기화 보고서(간단 요약)”를 작성합니다.
- 모든 문장은 수치/체크박스로 검증 가능하게 작성합니다.
- iOS/기술 스택/아키텍처 등 상위 정책 변경 시 MAJOR를 올립니다.
- 날짜는 모두 `YYYY-MM-DD` 형식으로 고정합니다.

## 문서 구조(섹션 순서 고정)
1) 동기화 보고서(HTML 주석)
2) 제목: `<PROJECT_NAME> 프로젝트 헌장`
3) 메타데이터 블록(표 또는 리스트)
4) 변경 요약(중요)
5) 목표(짧게)
6) 핵심 원칙(정확히 8개)
7) 추가 규칙(플랫폼/금지/디자인/보안/접근성/커밋)
8) 마이그레이션 규칙(단계/금지·예외)
9) 성능 기준(숫자)
10) 로그/진단(예시 포함)
11) 개발 흐름 & 체크리스트(Pre-Implementation, PR/CI)
12) 거버넌스(버전 규칙 포함)
13) 마지막 확인(검증용 체크리스트)

## 동기화 보고서 포맷(문서 맨 위 HTML 주석)
```
<!--
동기화 보고서(간단 요약)
- 버전: <이전 버전> → <현재 버전>
- 날짜: <LAST_AMENDED_DATE>
- 바뀐 점: 
  - 수정: …
  - 추가: …
  - 삭제: …
- 갱신해야 할 템플릿/문서: 
  - templates/commands/constitution.md: ✅/⚠
  - plan/spec/tasks 템플릿: ✅/⚠
  - README/docs: ✅/⚠
- TODO(마이그레이션 마감일/브릿지 삭제 일정): 
  - 항목A: <YYYY-MM-DD>
  - 항목B: <YYYY-MM-DD>
-->
```

## 검증 규칙(자동/수동)
- [ ] “버전” 라인의 현재 버전이 CONSTITUTION_VERSION와 동일함
- [ ] 모든 날짜가 YYYY-MM-DD
- [ ] “핵심 원칙”이 정확히 8개
- [ ] 체크리스트 항목이 1개 이상 존재
- [ ] “금지/제거”에 Rx/Realm/새 UIKit 코드 금지가 명시됨

## 산출물
- 파일: `.specify/memory/constitution.md`
- 커밋 메시지 권장: `Docs: Jacsim 헌장 v<CONSTITUTION_VERSION> 제정/개정`

## 예외
- 생성물/외부 코드 경로(예: `Projects/**/Derived`, `.build/**`)는 수정하지 않습니다.
- 조직/제품 정책상 필요한 경우에만 본 플로우를 커스터마이즈합니다(거버넌스 기준 참조).
