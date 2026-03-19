import SwiftUI
import ComposableArchitecture
import AcknowList
import DesignSystem

public struct OpenSourceLicenseView: View {
    let store: StoreOf<OpenSourceLicenseFeature>

    public init(store: StoreOf<OpenSourceLicenseFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            Color.backgroundAlternative
                .ignoresSafeArea()

            AcknowListSwiftUIView()
                .tint(.primaryNormal)
        }
        .safeAreaInset(edge: .top, spacing: .jsSM) {
            RedesignSectionCard(
                title: "오픈소스와 라이선스",
                subtitle: "Jacsim은 검증된 오픈소스 구성요소를 기반으로 동작해요"
            ) {
                HStack(alignment: .top, spacing: .jsSM) {
                    Image(systemName: "shippingbox.fill")
                        .font(.jsButtonMedium)
                        .foregroundColor(.primaryNormal)
                        .frame(width: .jsTouchTarget, height: .jsTouchTarget)
                        .background(
                            RoundedRectangle(cornerRadius: .jsCornerSmall)
                                .fill(Color.primaryNormal.opacity(0.1))
                        )

                    VStack(alignment: .leading, spacing: .jsMicro) {
                        Text("사용 중인 패키지와 라이선스 정보를 한 곳에서 확인할 수 있어요.")
                            .font(.jsBodySmall)
                            .foregroundColor(.labelStrong)

                        Text("세부 조항은 각 항목을 눌러 바로 확인할 수 있습니다.")
                            .font(.jsLabelMedium)
                            .foregroundColor(.labelNeutral)
                    }
                }
            }
            .padding(.horizontal, .jsMD)
            .padding(.top, .jsXS)
            .background(Color.backgroundAlternative)
        }
        .navigationTitle("오픈소스 라이선스")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.backgroundNormal, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear { store.send(.onAppear) }
    }
}

#Preview {
    NavigationStack {
        OpenSourceLicenseView(
            store: Store(initialState: OpenSourceLicenseFeature.State()) {
                OpenSourceLicenseFeature()
            }
        )
    }
}
