import SwiftUI
import ComposableArchitecture
import DSKit

public struct JacsimAlarmInputView: View {
    @Bindable var store: StoreOf<NewTaskFeature>

    public var body: some View {
        VStack(alignment: .leading, spacing: .jsLG) {
            Text("알림을 받으시겠어요?")
                .font(.jsHeadlineMedium)
                .foregroundColor(.labelStrong)
                .padding(.top, .jsLG)
            
            JSCard(style: .elevated) {
                JSListItem(
                    title: "알림 설정",
                    icon: "bell",
                    accessory: .toggle(isOn: $store.isAlarmEnabled)
                )
            }
            
            if store.isAlarmEnabled {
                JSCard(style: .elevated) {
                    DatePicker("알림 시간", selection: $store.alarmDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }
            }
            
            Spacer()
            
            JSButton(
                title: "다음",
                style: .primary,
                size: .large
            ) {
                store.send(.confirmAlarmButtonTapped)
            }
            .padding(.bottom, .jsMD)
        }
        .padding(.horizontal, .jsMD)
        .background(Color.backgroundNormal)
    }
}
