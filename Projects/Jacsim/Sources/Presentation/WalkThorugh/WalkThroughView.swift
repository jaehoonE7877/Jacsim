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
        "작심을 작게 시작해요",
        "사진으로 인증하면 더 쉬워요",
        "알림으로 흐름을 지켜요",
        "작은 성공을 쌓아가요"
    ]
    private let subtitles = [
        "짧은 스테이지를 선택해 시작할 수 있어요",
        "기록이 쌓일수록 변화가 눈에 보여요",
        "원하는 시간에 인증 리마인드를 받을 수 있어요. 알림은 나중에 켤 수도 있어요",
        "지금 바로 첫 작심을 시작해 볼까요?"
    ]

    public init(model: WalkThroughModel) {
        self.model = model
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.backgroundNormal.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                TabView(selection: $model.currentPage) {
                    ForEach(0..<images.count, id: \.self) { index in
                        VStack(spacing: .jsLG) {
                            Image(uiImage: images[index])
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 320.jsScaled())
                                .padding(.horizontal, .jsMD)

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
                        Text("알림 권한이 꺼져 있어요. 설정 > 알림에서 허용해 주세요.")
                            .font(.jsBodySmall)
                            .foregroundColor(.labelAlternative)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .jsLG)
                            .padding(.bottom, .jsSM)
                    }

                    VStack(spacing: .jsSM) {
                        JSButton(
                            title: primaryButtonTitle,
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
            Text("온보딩")
                .font(.jsLabelLarge)
                .foregroundColor(.labelAlternative)

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
                    .fill(index == model.currentPage ? Color.primaryNormal : Color.labelNeutral.opacity(0.3))
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
}

#Preview {
    WalkThroughView(
        model: WalkThroughModel(fromSetting: false, dependencies: .test)
    )
}
