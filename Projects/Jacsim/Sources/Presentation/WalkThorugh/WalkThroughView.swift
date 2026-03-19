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

    private let images = [
        DesignSystemAsset.Assets.onboardingImg1.image,
        DesignSystemAsset.Assets.onboardingImg2.image,
        DesignSystemAsset.Assets.onboardingImg3.image,
        DesignSystemAsset.Assets.onboardingImg4.image
    ]
    private let titles = [
        "오늘의 작심이 한눈에 보여요",
        "새 작심은 단계별로 가볍게 만들어요",
        "기록이 쌓일수록 변화가 보여요",
        "모든 작심의 흐름을 모아봐요"
    ]
    private let subtitles = [
        "가장 중요한 작심과 남은 할 일을 홈에서 바로 확인해요",
        "제목, 기간, 사진, 알림까지 흐름대로 정하면 바로 시작할 수 있어요",
        "캘린더에서 날짜별 인증 상태와 오늘의 기록을 한눈에 살펴봐요",
        "진행, 성공, 실패를 한 번에 정리하고 다음 행동을 이어가요"
    ]
    private let stageLabels = [
        "홈",
        "생성",
        "기록",
        "회고"
    ]
    private let highlights: [[Highlight]] = [
        [
            Highlight(icon: "target", title: "핵심 작심", subtitle: "가장 중요한 목표를 바로 확인"),
            Highlight(icon: "checklist", title: "남은 할 일", subtitle: "오늘 해야 할 인증을 빠르게 파악")
        ],
        [
            Highlight(icon: "text.cursor", title: "짧은 입력", subtitle: "제목과 기간부터 먼저 정리"),
            Highlight(icon: "photo", title: "대표 사진", subtitle: "카드에 보일 사진 한 장 선택")
        ],
        [
            Highlight(icon: "calendar", title: "날짜별 상태", subtitle: "캘린더에서 인증 흐름을 확인"),
            Highlight(icon: "camera", title: "오늘의 기록", subtitle: "그날 남긴 인증을 이어서 검토")
        ],
        [
            Highlight(icon: "square.stack.3d.up", title: "전체 흐름", subtitle: "진행, 성공, 실패를 한 번에 정리"),
            Highlight(icon: "arrow.trianglehead.clockwise", title: "다음 행동", subtitle: "다음에 이어갈 작심을 다시 선택")
        ]
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
                        ForEach(0..<images.count, id: \.self) { index in
                            pageContent(at: index, availableSize: proxy.size)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                    pageControl
                        .padding(.top, .jsMD)
                        .padding(.bottom, .jsLG)

                    JSButton(
                        title: primaryButtonTitle,
                        style: .primary,
                        size: .large
                    ) {
                        primaryButtonTapped()
                    }
                    .padding(.horizontal, .jsXL)
                    .padding(.bottom, 24.jsScaled())
                    .accessibilityLabel(primaryButtonAccessibilityLabel)
                    .accessibilityHint(primaryButtonAccessibilityHint)
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

            if !store.fromSetting && store.currentPage < store.totalPages - 1 {
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

    private func pageContent(at index: Int, availableSize: CGSize) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: .jsLG) {
                stageOverviewCard(at: index)

                Image(uiImage: images[index])
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: imageHeight(for: availableSize))
                    .padding(.horizontal, .jsLG)
                    .accessibilityHidden(true)

                VStack(spacing: .jsXS) {
                    Text(titles[index])
                        .font(.jsHeadlineLarge)
                        .foregroundColor(.labelStrong)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(subtitles[index])
                        .font(.jsBodySmall)
                        .foregroundColor(.labelNeutral)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, .jsXL)

                highlightSection(for: index)
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

                Text("\(store.currentPage + 1) / \(store.totalPages)")
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelNeutral)
            }

            HStack(alignment: .top, spacing: .jsXS) {
                ForEach(0..<store.totalPages, id: \.self) { index in
                    stageNode(for: index)

                    if index < store.totalPages - 1 {
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
        .accessibilityValue("\(store.currentPage + 1) / \(store.totalPages)")
    }

    private var isLastPage: Bool {
        store.currentPage == store.totalPages - 1
    }

    private var currentStageLabel: String {
        stageLabels[store.currentPage]
    }

    private var nextStageCaption: String {
        if isLastPage {
            return store.fromSetting ? "마지막 단계예요. 확인을 누르면 이전 화면으로 돌아가요." : "마지막 단계예요. 시작하기를 누르면 홈으로 이동해요."
        }
        return "다음은 \(stageLabels[store.currentPage + 1]) 흐름으로 이어져요."
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

    private func stageOverviewCard(at index: Int) -> some View {
        HStack(spacing: .jsSM) {
            VStack(alignment: .leading, spacing: .jsMicro) {
                Text("STEP \(index + 1)")
                    .font(.jsLabelMedium)
                    .foregroundColor(.primaryNormal)

                Text(stageLabels[index])
                    .font(.jsHeadlineSmall)
                    .foregroundColor(.labelStrong)
            }

            Spacer()

            if index < stageLabels.count - 1 {
                HStack(spacing: .jsMicro) {
                    Text("다음")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelNeutral)
                    Image(systemName: "arrow.right")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelNeutral)
                    Text(stageLabels[index + 1])
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

    private func highlightSection(for index: Int) -> some View {
        VStack(spacing: .jsXS) {
            ForEach(highlights[index]) { highlight in
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

            Text(stageLabels[index])
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
