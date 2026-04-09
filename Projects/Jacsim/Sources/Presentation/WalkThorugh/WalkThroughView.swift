import SwiftUI
import ComposableArchitecture
import DesignSystem
import UIKit

public struct WalkThroughView: View {
    @Bindable var store: StoreOf<WalkThroughFeature>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss

    private struct Highlight: Identifiable {
        let icon: String
        let title: String
        let subtitle: String

        var id: String { title }
    }

    private struct Page: Identifiable {
        let id: Int
        let stageLabel: String
        let title: String
        let subtitle: String
        let image: UIImage
        let highlights: [Highlight]
    }

    private let pages: [Page] = [
        Page(
            id: 0,
            stageLabel: "홈",
            title: "오늘의 작심이 한눈에 보여요",
            subtitle: "가장 중요한 작심과 남은 할 일을 홈에서 바로 확인해요",
            image: DesignSystemAsset.Assets.onboardingImg1.image,
            highlights: [
                Highlight(icon: "target", title: "핵심 작심", subtitle: "가장 중요한 목표를 바로 확인"),
                Highlight(icon: "checklist", title: "남은 할 일", subtitle: "오늘 해야 할 인증을 빠르게 파악")
            ]
        ),
        Page(
            id: 1,
            stageLabel: "생성",
            title: "새 작심은 단계별로 가볍게 만들어요",
            subtitle: "제목, 기간, 사진, 알림까지 흐름대로 정하면 바로 시작할 수 있어요",
            image: DesignSystemAsset.Assets.onboardingImg2.image,
            highlights: [
                Highlight(icon: "text.cursor", title: "짧은 입력", subtitle: "제목과 기간부터 먼저 정리"),
                Highlight(icon: "photo", title: "대표 사진", subtitle: "카드에 보일 사진 한 장 선택")
            ]
        ),
        Page(
            id: 2,
            stageLabel: "기록",
            title: "기록이 쌓일수록 변화가 보여요",
            subtitle: "캘린더에서 날짜별 인증 상태와 오늘의 기록을 한눈에 살펴봐요",
            image: DesignSystemAsset.Assets.onboardingImg3.image,
            highlights: [
                Highlight(icon: "calendar", title: "날짜별 상태", subtitle: "캘린더에서 인증 흐름을 확인"),
                Highlight(icon: "camera", title: "오늘의 기록", subtitle: "그날 남긴 인증을 이어서 검토")
            ]
        ),
        Page(
            id: 3,
            stageLabel: "회고",
            title: "모든 작심의 흐름을 모아봐요",
            subtitle: "진행, 성공, 실패를 한 번에 정리하고 다음 행동을 이어가요",
            image: DesignSystemAsset.Assets.onboardingImg4.image,
            highlights: [
                Highlight(icon: "square.stack.3d.up", title: "전체 흐름", subtitle: "진행, 성공, 실패를 한 번에 정리"),
                Highlight(icon: "arrow.trianglehead.clockwise", title: "다음 행동", subtitle: "다음에 이어갈 작심을 다시 선택")
            ]
        )
    ]

    public init(store: StoreOf<WalkThroughFeature>) {
        self.store = store
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Color.backgroundNormal.ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar

                    TabView(selection: $store.currentPage) {
                        ForEach(pages) { page in
                            pageContent(page, availableSize: proxy.size)
                                .tag(page.id)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                    pageControl
                        .padding(.top, .jsMD)
                        .padding(.bottom, .jsLG)

                    primaryAction
                }
            }
        }
        .navigationTitle(store.fromSetting ? "사용법" : "")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var topBar: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: .jsMicro) {
                if !store.fromSetting {
                    Text("Jacsim 시작하기")
                        .font(.jsHeadlineSmall)
                        .foregroundColor(.labelStrong)
                }

                Text("지금은 \(currentStageLabel) 흐름을 보고 있어요")
                    .font(.jsLabelLarge)
                    .foregroundColor(.labelNeutral)
            }

            Spacer()

            if !store.fromSetting && store.currentPage < pages.count - 1 {
                Button("건너뛰기") {
                    store.send(.skipButtonTapped)
                }
                .font(.jsButtonSmall)
                .foregroundColor(.labelNeutral)
                .accessibilityLabel("온보딩 건너뛰기")
                .accessibilityHint("현재 \(store.currentPage + 1)단계에서 온보딩을 마치고 홈으로 이동합니다")
            }
        }
        .padding(.horizontal, .jsXL)
        .padding(.top, store.fromSetting ? .jsXS : .jsSM)
        .padding(.bottom, .jsXS)
    }

    private func pageContent(_ page: Page, availableSize: CGSize) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: .jsLG) {
                stageOverviewCard(page)

                Image(uiImage: page.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: imageHeight(for: availableSize))
                    .padding(.horizontal, .jsLG)
                    .accessibilityHidden(true)

                VStack(spacing: .jsXS) {
                    Text(page.title)
                        .font(.jsHeadlineLarge)
                        .foregroundColor(.labelStrong)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(page.subtitle)
                        .font(.jsBodySmall)
                        .foregroundColor(.labelNeutral)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, .jsXL)

                highlightSection(page.highlights)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: availableSize.height * (store.fromSetting ? 0.58 : 0.54), alignment: .center)
            .padding(.top, .jsXS)
            .padding(.bottom, .jsSM)
        }
    }

    private func imageHeight(for availableSize: CGSize) -> CGFloat {
        let heightRatio = store.fromSetting ? 0.50 : 0.46
        let proposedHeight = availableSize.height * heightRatio
        return min(max(proposedHeight, 360.jsScaled()), 460.jsScaled())
    }

    private var pageControl: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            HStack(alignment: .firstTextBaseline) {
                Text("온보딩 여정")
                    .font(.jsLabelLarge)
                    .foregroundColor(.labelStrong)

                Spacer()

                Text("\(store.currentPage + 1) / \(pages.count)")
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelNeutral)
            }

            HStack(alignment: .top, spacing: .jsXS) {
                ForEach(pages.indices, id: \.self) { index in
                    stageNode(for: index)

                    if index < pages.count - 1 {
                        Capsule()
                            .fill(index < store.currentPage ? Color.primaryNormal : Color.labelNeutral.opacity(0.3))
                            .frame(maxWidth: .infinity)
                            .frame(height: 2)
                            .padding(.top, 9.jsScaled())
                    }
                }
            }

            Text(nextStageCaption)
                .font(.jsBodySmall)
                .foregroundColor(.labelNeutral)
        }
        .padding(.horizontal, .jsXL)
        .padding(.vertical, .jsMD)
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusLG, style: .continuous)
                .fill(Color.backgroundAlternative)
        )
        .padding(.horizontal, .jsXL)
        .animation(reduceMotion ? .none : JSAnimation.navigation, value: store.currentPage)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("온보딩 진행 상태")
        .accessibilityValue("\(store.currentPage + 1) / \(pages.count)")
    }

    private var isLastPage: Bool {
        store.currentPage == pages.count - 1
    }

    private var currentPageData: Page {
        pages[store.currentPage]
    }

    private var currentStageLabel: String {
        currentPageData.stageLabel
    }

    private var nextStageCaption: String {
        if isLastPage {
            return store.fromSetting ? "마지막 단계예요. 확인을 누르면 이전 화면으로 돌아가요." : "마지막 단계예요. 시작하기를 누르면 홈으로 이동해요."
        }
        return "다음은 \(pages[store.currentPage + 1].stageLabel) 흐름으로 이어져요."
    }

    private var primaryButtonTitle: String {
        if store.fromSetting {
            return isLastPage ? "확인했어요" : "다음"
        }
        return isLastPage ? "시작하기" : "계속하기"
    }

    private var primaryButtonAccessibilityLabel: String {
        if store.fromSetting {
            return isLastPage ? "온보딩 확인 완료" : "다음 안내 보기"
        }
        if isLastPage {
            return "온보딩 시작하기"
        }
        return "다음 단계로 계속하기"
    }

    private var primaryButtonAccessibilityHint: String {
        if store.fromSetting {
            if isLastPage {
                return "온보딩 안내를 닫고 이전 화면으로 돌아갑니다"
            }
            return "온보딩 \(store.currentPage + 2)단계로 이동합니다"
        }
        if isLastPage {
            return "온보딩을 마치고 홈으로 이동합니다"
        }
        return "온보딩 \(store.currentPage + 2)단계로 이동합니다"
    }

    private var primaryAction: some View {
        JSButton(
            title: primaryButtonTitle,
            style: .primary,
            size: .large,
            action: primaryButtonTapped
        )
        .padding(.horizontal, .jsXL)
        .padding(.bottom, 24.jsScaled())
        .accessibilityLabel(primaryButtonAccessibilityLabel)
        .accessibilityHint(primaryButtonAccessibilityHint)
    }

    private func primaryButtonTapped() {
        if store.fromSetting {
            if isLastPage {
                dismiss()
            } else {
                store.send(.continueButtonTapped)
            }
            return
        }

        store.send(.continueButtonTapped)
    }

    private func stageOverviewCard(_ page: Page) -> some View {
        HStack(spacing: .jsSM) {
            VStack(alignment: .leading, spacing: .jsMicro) {
                Text("STEP \(page.id + 1)")
                    .font(.jsLabelMedium)
                    .foregroundColor(.primaryNormal)

                Text(page.stageLabel)
                    .font(.jsHeadlineSmall)
                    .foregroundColor(.labelStrong)
            }

            Spacer()

            if page.id < pages.count - 1 {
                HStack(spacing: .jsMicro) {
                    Text("다음")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelNeutral)
                    Image(systemName: "arrow.right")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelNeutral)
                    Text(pages[page.id + 1].stageLabel)
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelStrong)
                }
            } else {
                HStack(spacing: .jsMicro) {
                    Image(systemName: "flag.fill")
                        .font(.jsLabelMedium)
                        .foregroundColor(.positive)
                    Text(store.fromSetting ? "안내 마무리" : "시작 준비 완료")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelStrong)
                }
            }
        }
        .padding(.horizontal, .jsLG)
        .padding(.vertical, .jsMD)
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusLG, style: .continuous)
                .fill(Color.backgroundAlternative)
        )
        .padding(.horizontal, .jsXL)
    }

    private func highlightSection(_ highlights: [Highlight]) -> some View {
        VStack(spacing: .jsXS) {
            ForEach(highlights) { highlight in
                HStack(alignment: .top, spacing: .jsSM) {
                    Image(systemName: highlight.icon)
                        .font(.jsHeadlineSmall)
                        .foregroundColor(.primaryNormal)
                        .frame(width: 24.jsScaled(), height: 24.jsScaled())

                    VStack(alignment: .leading, spacing: .jsMicro) {
                        Text(highlight.title)
                            .font(.jsBodyMedium)
                            .foregroundColor(.labelStrong)

                        Text(highlight.subtitle)
                            .font(.jsLabelLarge)
                            .foregroundColor(.labelNeutral)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, .jsMD)
                .padding(.vertical, .jsSM)
                .background(
                    RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                        .fill(Color.backgroundAlternative)
                )
            }
        }
        .padding(.horizontal, .jsXL)
    }

    private func stageNode(for index: Int) -> some View {
        let isCurrent = index == store.currentPage
        let isCompleted = index < store.currentPage

        return VStack(spacing: .jsXS) {
            Circle()
                .fill(isCurrent || isCompleted ? Color.primaryNormal : Color.labelNeutral.opacity(0.3))
                .frame(width: 20.jsScaled(), height: 20.jsScaled())
                .overlay {
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.jsLabelSmall)
                            .foregroundColor(.white)
                    }
                }

            Text(pages[index].stageLabel)
                .font(.jsLabelMedium)
                .foregroundColor(isCurrent ? .labelStrong : .labelNeutral)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

#Preview {
    WalkThroughView(
        store: Store(initialState: WalkThroughFeature.State(fromSetting: false)) {
            WalkThroughFeature()
        }
    )
}
