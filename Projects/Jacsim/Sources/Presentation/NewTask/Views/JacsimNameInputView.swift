import SwiftUI
import ComposableArchitecture
import DSKit

public struct JacsimNameInputView: View {
    @Bindable var store: StoreOf<NewTaskFeature>

    public var body: some View {
        VStack(alignment: .leading, spacing: .jsLG) {
            Text("무엇을 작심하셨나요?")
                .font(.jsHeadlineMedium)
                .foregroundColor(.labelStrong)
                .padding(.top, .jsLG)
            
            VStack(alignment: .trailing, spacing: .jsXS) {
                JSInputField(
                    title: "",
                    placeholder: "예시 - 아침에 일어나서 물 마시기",
                    text: $store.title
                )
                
                Text("\(store.title.count) / 20")
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelAssistive)
            }
            
            Spacer()
            
            JSButton(
                title: "다음",
                style: .primary,
                size: .large,
                isEnabled: !store.title.isEmpty
            ) {
                store.send(.nextButtonTapped)
            }
            .padding(.bottom, .jsMD)
        }
        .padding(.horizontal, .jsMD)
        .background(Color.backgroundNormal)
        .navigationBarTitleDisplayMode(.inline)
    }
}
