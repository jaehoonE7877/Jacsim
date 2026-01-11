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
                        .padding(.horizontal, 16)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            pageControl
                .padding(.vertical, 20)
            
            if !store.fromSetting {
                Button(action: { store.send(.continueButtonTapped) }) {
                    Text(store.currentPage == store.totalPages - 1 ? "시작하기" : "계속하기")
                        .font(.pretendardMedium(size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.primaryNormal)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color.backgroundNormal)
    }
    
    private var pageControl: some View {
        HStack(spacing: 8) {
            ForEach(0..<store.totalPages, id: \.self) { index in
                Circle()
                    .fill(index == store.currentPage ? Color.primaryNormal : Color.labelNeutral.opacity(0.3))
                    .frame(width: 8, height: 8)
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
