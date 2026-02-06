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

    public init(store: StoreOf<WalkThroughFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $store.currentPage) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, .jsMD)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            pageControl
                .padding(.vertical, .jsLG)
            
            if !store.fromSetting {
                if store.currentPage == 2, store.notificationPermissionStatus == .denied {
                    Text("알림 권한이 꺼져 있어요. 설정 > 알림에서 허용해 주세요.")
                        .font(.pretendardMedium(size: 14))
                        .foregroundColor(.labelNeutral)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
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
                .padding(.bottom, 40)
            }
        }
        .background(Color.backgroundNormal)
    }
    
    private var pageControl: some View {
        HStack(spacing: .jsXS) {
            ForEach(0..<store.totalPages, id: \.self) { index in
                Circle()
                    .fill(index == store.currentPage ? Color.primaryNormal : Color.labelNeutral.opacity(0.3))
                    .frame(width: .jsXS, height: .jsXS)
            }
        }
    }
}

#Preview {
    WalkThroughView(
        store: Store(initialState: WalkThroughFeature.State(fromSetting: false)) {
            WalkThroughFeature()
        }
    )
}
