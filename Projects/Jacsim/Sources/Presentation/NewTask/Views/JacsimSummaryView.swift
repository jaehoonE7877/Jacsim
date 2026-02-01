import SwiftUI
import ComposableArchitecture
import DSKit

public struct JacsimSummaryView: View {
    @Bindable var store: StoreOf<NewTaskFeature>

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .jsLG) {
                Text("작심 요약")
                    .font(.jsHeadlineMedium)
                    .foregroundColor(.labelStrong)
                    .padding(.top, .jsLG)
                
                VStack(alignment: .leading, spacing: .jsXS) {
                    Text("작심 이름")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelAlternative)
                    JSCard(style: .outlined) {
                        Text(store.title)
                            .font(.jsBodyMedium)
                            .foregroundColor(.labelNormal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                VStack(alignment: .leading, spacing: .jsXS) {
                    Text("기간")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelAlternative)
                    JSCard(style: .outlined) {
                        VStack(spacing: .jsSM) {
                            DatePicker(
                                "시작일",
                                selection: $store.startDate,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                            .frame(maxWidth: .infinity)
                            
                            DatePicker(
                                "종료일",
                                selection: $store.endDate,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: .jsXS) {
                    Text("목표 횟수")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelAlternative)
                    JSCard(style: .outlined) {
                        HStack {
                            Text("\(store.successCount)회")
                                .font(.jsBodyMedium)
                                .foregroundColor(.labelNormal)
                            Spacer()
                            Stepper("", value: $store.successCount, in: 1...30)
                                .labelsHidden()
                        }
                    }
                }
                
                if store.isAlarmEnabled {
                    VStack(alignment: .leading, spacing: .jsXS) {
                        Text("알림 시간")
                            .font(.jsLabelMedium)
                            .foregroundColor(.labelAlternative)
                        JSCard(style: .outlined) {
                            DatePicker(
                                "알림 시간",
                                selection: $store.alarmDate,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                Spacer()
                
                JSButton(
                    title: "저장",
                    style: .primary,
                    size: .large
                ) {
                    store.send(.saveButtonTapped)
                }
                .padding(.bottom, .jsMD)
            }
            .padding(.horizontal, .jsMD)
        }
        .background(Color.backgroundNormal)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
