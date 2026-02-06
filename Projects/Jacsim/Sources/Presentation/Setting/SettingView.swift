import SwiftUI
import ComposableArchitecture
import DSKit

public struct SettingView: View {
    let store: StoreOf<SettingFeature>

    public init(store: StoreOf<SettingFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            Section(header: Text("테마").font(.pretendardMedium(size: 14))) {
                Picker("테마", selection: Binding(
                    get: { store.theme },
                    set: { store.send(.themeChanged($0)) }
                )) {
                    Text("시스템").tag(ThemeMode.system)
                    Text("라이트").tag(ThemeMode.light)
                    Text("다크").tag(ThemeMode.dark)
                }
                .pickerStyle(.segmented)
                .font(.pretendardMedium(size: 16))
                .listRowBackground(Color.backgroundNormal)
            }
            
            Section {
                Toggle(
                    "알림 설정",
                    isOn: Binding(
                        get: { store.isNotificationEnabled },
                        set: { store.send(.notificationToggleChanged($0)) }
                    )
                )
                .font(.pretendardMedium(size: 16))
                .foregroundColor(.labelNormal)
                .listRowBackground(Color.backgroundNormal)

                Button(action: { store.send(.useCaseButtonTapped) }) {
                    rowView(title: "사용법")
                }
                
                Button(action: { store.send(.inquiryButtonTapped) }) {
                    rowView(title: "문의하기")
                }
                
                Button(action: { store.send(.reviewButtonTapped) }) {
                    rowView(title: "리뷰")
                }
                
                HStack {
                    Text("버전정보")
                        .font(.pretendardMedium(size: 16))
                        .foregroundColor(.labelNormal)
                    Spacer()
                    Text(store.version)
                        .font(.pretendardMedium(size: 14))
                        .foregroundColor(.labelNeutral)
                }
                .listRowBackground(Color.backgroundNormal)
                
                Button(action: { store.send(.licenceButtonTapped) }) {
                    rowView(title: "오픈소스 라이선스")
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.backgroundNormal)
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            store.send(.loadNotificationSettings)
        }
    }

    private func rowView(title: String) -> some View {
        HStack {
            Text(title)
                .font(.pretendardMedium(size: 16))
                .foregroundColor(.labelNormal)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.jsButtonSmall)
                .foregroundColor(.labelNeutral)
        }
        .contentShape(Rectangle())
        .listRowBackground(Color.backgroundNormal)
    }
}

#Preview {
    NavigationStack {
        SettingView(
            store: Store(initialState: SettingFeature.State()) {
                SettingFeature()
            }
        )
    }
}
