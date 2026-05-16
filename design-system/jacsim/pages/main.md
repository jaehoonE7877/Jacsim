# Main Page Overrides

> Applies to: `Projects/Jacsim/Sources/Presentation/Main/MainView.swift`

## Layout Overrides

- `MainView`는 5-tab root shell을 유지합니다: 오늘, 달력, 추가, 피드, 나.
- 하단 탭은 `safeAreaInset(edge: .bottom)` 안의 `JSGlassFloatingTabBar`를 사용합니다.
- center `plus` item은 콘텐츠 탭이 아니라 sheet trigger입니다.
- 탭 전환 애니메이션은 `accessibilityReduceMotion`이 켜져 있으면 비활성화합니다.

## Component Overrides

- Main 레벨에서 중복 네비게이션 컨테이너 생성 금지.
- `PlusActionSheet`는 `JSBottomSheet(glass: true)`와 `JSGlassCard` 기반 액션 3개만 노출합니다.
- "새 작심 만들기"만 실제 플로우를 열고, "자랑 글 쓰기"와 "AI 코치 열기"는 Goal 6에서도 출시 전 상태를 유지합니다.

## Goal 6 Guardrails

- Feed/Me placeholder를 실제 소셜 화면으로 채우지 않습니다. Goal 7 범위입니다.
- Plus sheet 라우팅과 탭 상태는 유지하고 화면별 시각 재정렬만 수행합니다.
