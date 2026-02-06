import SwiftUI
import ComposableArchitecture
import DSKit

public struct WalkThroughView: View {
    @Bindable var store: StoreOf<WalkThroughFeature>
    
    private let images = [
        DSKitAsset.Assets.onboardingImg1.image,
        DSKitAsset.Assets.onboardingImg2.image,
        DSKitAsset.Assets.onboardingImg3.image,
        DSKitAsset.Assets.onboardingImg4.image
    ]
    private let titles = [
        "작심을 루틴으로 만들어요",
        "하루 한 번, 사진으로 기록해요",
        "매일 알림으로 흐름을 지켜요",
        "작은 성공을 쌓아가요"
    ]
    private let subtitles = [
        "짧은 스테이지를 선택해 시작할 수 있어요",
        "기록이 쌓일수록 변화가 눈에 보여요",
        "원하는 시간에 인증 리마인드를 받을 수 있어요",
        "지금 바로 첫 작심을 시작해 볼까요?"
    ]

    public init(store: StoreOf<WalkThroughFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.backgroundNormal.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                TabView(selection: $store.currentPage) {
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

                if !store.fromSetting {
                    if store.currentPage == 2, store.notificationPermissionStatus == .denied {
                        Text("알림 권한이 꺼져 있어요. 설정 > 알림에서 허용해 주세요.")
                            .font(.jsBodySmall)
                            .foregroundColor(.labelAlternative)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .jsLG)
                            .padding(.bottom, .jsSM)
                    }

                    JSButton(
                        title: store.currentPage == store.totalPages - 1 ? "시작하기" : "계속하기",
                        style: .primary,
                        size: .large
                    ) {
                        if store.currentPage == 2 {
                            store.send(.requestNotificationPermission)
                        } else {
                            store.send(.continueButtonTapped)
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

            if !store.fromSetting && store.currentPage < store.totalPages - 1 {
                Button("건너뛰기") {
                    store.send(.skipButtonTapped)
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
            ForEach(0..<store.totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == store.currentPage ? Color.primaryNormal : Color.labelNeutral.opacity(0.3))
                    .frame(width: index == store.currentPage ? 20.jsScaled() : .jsXS, height: .jsXS)
            }
        }
        .animation(.easeInOut(duration: JSAnimation.durationNormal), value: store.currentPage)
    }
}

#Preview {
    WalkThroughView(
        store: Store(initialState: WalkThroughFeature.State(fromSetting: false)) {
            WalkThroughFeature()
        }
    )
}
