import SwiftUI
import ComposableArchitecture
import DSKit

public struct JacsimSummaryView: View {
    @Bindable var store: StoreOf<NewTaskFeature>

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("작심 요약")
                    .font(.pretendardSemiBold(size: 24))
                    .foregroundColor(.labelStrong)
                    .padding(.top, 24)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("작심 이름")
                        .font(.pretendardMedium(size: 14))
                        .foregroundColor(.labelNeutral)
                    Text(store.title)
                        .font(.pretendardMedium(size: 18))
                        .foregroundColor(.labelNormal)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.backgroundNormal)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primaryNormal.opacity(0.5), lineWidth: 1)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("기간")
                        .font(.pretendardMedium(size: 14))
                        .foregroundColor(.labelNeutral)
                    VStack(spacing: 12) {
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
                    .padding()
                    .background(Color.backgroundNormal)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primaryNormal.opacity(0.5), lineWidth: 1)
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("목표 횟수")
                        .font(.pretendardMedium(size: 14))
                        .foregroundColor(.labelNeutral)
                    HStack {
                        Text("\(store.successCount)회")
                            .font(.pretendardMedium(size: 18))
                            .foregroundColor(.labelNormal)
                        Spacer()
                        Stepper("", value: $store.successCount, in: 1...30)
                    }
                    .padding()
                    .background(Color.backgroundNormal)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primaryNormal.opacity(0.5), lineWidth: 1)
                    )
                }
                
                if store.isAlarmEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("알림 시간")
                            .font(.pretendardMedium(size: 14))
                            .foregroundColor(.labelNeutral)
                        DatePicker(
                            "알림 시간",
                            selection: $store.alarmDate,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.backgroundNormal)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primaryNormal.opacity(0.5), lineWidth: 1)
                        )
                    }
                }
                
                Spacer()
                
                Button(action: { store.send(.saveButtonTapped) }) {
                    Text("저장")
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
        }
        .background(Color.backgroundNormal)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
