import SwiftUI
import DSKit

public struct WalkThroughView: View {
    @Bindable var model: WalkThroughModel
    
    private let images = [
        DSKitAsset.Assets.onboardingImg1.image,
        DSKitAsset.Assets.onboardingImg2.image,
        DSKitAsset.Assets.onboardingImg3.image,
        DSKitAsset.Assets.onboardingImg4.image
    ]
    private let titles = [
        "작게 시작",
        "사진으로 인증",
        "리듬 지키기",
        "바로 시작"
    ]
    private let subtitles = [
        "3일, 7일, 15일, 30일 중 하나를 골라요",
        "오늘의 한 장이 기록이 돼요",
        "원하는 시간에 살짝 알려드려요",
        "첫 작심을 만들어 볼까요?"
    ]

    public init(model: WalkThroughModel) {
        self.model = model
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.v2Background.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                TabView(selection: $model.currentPage) {
                    ForEach(0..<images.count, id: \.self) { index in
                        VStack(spacing: .jsLG) {
                            Image(uiImage: images[index])
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 360.jsScaled())
                                .clipShape(RoundedRectangle(cornerRadius: 30.jsScaled(), style: .continuous))
                                .padding(.horizontal, .jsLG)
                                .accessibilityHidden(true)

                            VStack(spacing: .jsXS) {
                                Text(titles[index])
                                    .font(.jsHeadlineLarge)
                                    .foregroundColor(.labelStrong)
                                    .multilineTextAlignment(.center)

                                Text(subtitles[index])
                                    .font(.jsBodySmall)
                                    .foregroundColor(.labelAlternative)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, .jsLG)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                pageControl
                    .padding(.vertical, .jsLG)

                if !model.fromSetting {
                    if model.currentPage == 2, model.notificationPermissionStatus == .denied {
                        Text("설정에서 알림을 허용해 주세요")
                            .font(.jsBodySmall)
                            .foregroundColor(.labelAlternative)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .jsLG)
                            .padding(.bottom, .jsSM)
                    }

                    VStack(spacing: .jsSM) {
                        JSButton(
                            title: primaryButtonTitle,
                            systemImage: primaryButtonIcon,
                            style: .primary,
                            size: .large
                        ) {
                            if model.currentPage == 2 {
                                model.requestNotificationPermission()
                            } else {
                                model.continueButtonTapped()
                            }
                        }

                        if model.currentPage == 2 {
                            Button("나중에") {
                                model.continueButtonTapped()
                            }
                            .font(.jsButtonMedium)
                            .foregroundColor(.labelAlternative)
                            .frame(minHeight: .jsTouchTarget)
                        }
                    }
                    .padding(.horizontal, .jsXL)
                    .padding(.bottom, 40.jsScaled())
                }
            }
        }
    }
    
    @ViewBuilder
    private var topBar: some View {
        HStack {
            Text("작심")
                .font(.jsLabelLarge)
                .foregroundColor(.v2BrandBlue)

            Spacer()

            if !model.fromSetting && model.currentPage < model.totalPages - 1 {
                Button("건너뛰기") {
                    model.skipButtonTapped()
                }
                .font(.jsButtonSmall)
                    .foregroundColor(.labelAlternative)
            }
        }
        .padding(.horizontal, .jsXL)
        .padding(.top, .jsSM)
    }

    private var pageControl: some View {
        HStack(spacing: .jsXS) {
            ForEach(0..<model.totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == model.currentPage ? Color.v2BrandBlue : Color.labelNeutral.opacity(0.3))
                    .frame(width: index == model.currentPage ? 20.jsScaled() : .jsXS, height: .jsXS)
            }
        }
        .animation(.easeInOut(duration: JSAnimation.durationNormal), value: model.currentPage)
    }

    private var primaryButtonTitle: String {
        if model.currentPage == 2 {
            return model.notificationPermissionStatus == .denied ? "계속하기" : "알림 허용하기"
        }
        return model.currentPage == model.totalPages - 1 ? "시작하기" : "다음"
    }

    private var primaryButtonIcon: String {
        if model.currentPage == 2 {
            return model.notificationPermissionStatus == .denied ? "arrow.right" : "bell.fill"
        }
        return model.currentPage == model.totalPages - 1 ? "sparkles" : "arrow.right"
    }
}

#Preview {
    WalkThroughView(
        model: WalkThroughModel(fromSetting: false, dependencies: .test)
    )
}
