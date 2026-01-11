import SwiftUI
import ComposableArchitecture
import DSKit

public struct JacsimAlarmInputView: View {
    @Bindable var store: StoreOf<NewTaskFeature>

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("알림을 받으시겠어요?")
                .font(.pretendardSemiBold(size: 24))
                .foregroundColor(.labelStrong)
                .padding(.top, 24)
            
            Toggle("알림 설정", isOn: $store.isAlarmEnabled)
                .font(.pretendardMedium(size: 18))
                .padding()
                .background(Color.backgroundNormal)
                .cornerRadius(12)
            
            if store.isAlarmEnabled {
                DatePicker("알림 시간", selection: $store.alarmDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
            }
            
            Spacer()
            
            Button(action: { store.send(.confirmAlarmButtonTapped) }) {
                Text("다음")
                    .font(.pretendardMedium(size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.primaryNormal)
                    .cornerRadius(12)
            }
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
        .background(Color.backgroundNormal)
    }
}
