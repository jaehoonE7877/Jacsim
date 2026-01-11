import SwiftUI
import ComposableArchitecture
import DSKit

public struct JacsimNameInputView: View {
    @Bindable var store: StoreOf<NewTaskFeature>

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("무엇을 작심하셨나요?")
                .font(.pretendardSemiBold(size: 24))
                .foregroundColor(.labelStrong)
                .padding(.top, 24)
            
            VStack(alignment: .trailing, spacing: 8) {
                TextField("예시 - 아침에 일어나서 물 마시기", text: $store.title)
                    .font(.pretendardMedium(size: 16))
                    .padding()
                    .background(Color.backgroundNormal)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primaryNormal, lineWidth: 1)
                    )
                
                Text("\(store.title.count) / 20")
                    .font(.pretendardMedium(size: 14))
                    .foregroundColor(.labelAssistive)
            }
            
            Spacer()
            
            Button(action: { store.send(.nextButtonTapped) }) {
                Text("다음")
                    .font(.pretendardMedium(size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(store.title.isEmpty ? Color.labelDisable : Color.primaryNormal)
                    .cornerRadius(12)
            }
            .disabled(store.title.isEmpty)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
        .background(Color.backgroundNormal)
        .navigationBarTitleDisplayMode(.inline)
    }
}
