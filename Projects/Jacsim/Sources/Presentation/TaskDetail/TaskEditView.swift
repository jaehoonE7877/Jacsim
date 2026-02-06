import SwiftUI
import ComposableArchitecture
import DSKit
import PhotosUI

public struct TaskEditView: View {
    @Bindable var store: StoreOf<TaskEditFeature>
    @State private var photoPickerItem: PhotosPickerItem?

    public init(store: StoreOf<TaskEditFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: .jsXL) {
            ZStack(alignment: .bottomTrailing) {
                if let image = store.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                        .cornerRadius(.jsRadiusMD)
                } else {
                    Rectangle()
                        .fill(Color.labelDisable)
                        .frame(height: 220)
                        .cornerRadius(.jsRadiusMD)
                        .overlay(
                            Image(systemName: "camera")
                                .font(.jsDisplaySmall)
                                .scaleEffect(1.6)
                                .foregroundColor(.labelNeutral)
                        )
                }

                PhotosPicker(
                    selection: $photoPickerItem,
                    matching: .images
                ) {
                    Image(systemName: "plus.circle.fill")
                        .font(.jsDisplayLarge)
                        .scaleEffect(1.3)
                        .foregroundColor(.primaryNormal)
                        .background(Color.backgroundNormal)
                        .clipShape(Circle())
                        .padding(.jsXS)
                }
                .onChange(of: photoPickerItem) { _, newItem in
                    guard let newItem else { return }
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            store.send(.imageSelected(image))
                        }
                    }
                }
            }
            .padding(.horizontal, .jsMD)

            VStack(alignment: .leading, spacing: .jsSM) {
                TextField("작심 이름", text: $store.title)
                    .font(.jsBodyMedium)
                    .padding()
                    .background(Color.backgroundNormal)
                    .cornerRadius(.jsRadiusMD)
                    .overlay(
                        RoundedRectangle(cornerRadius: .jsRadiusMD)
                            .stroke(Color.primaryNormal.opacity(0.5), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: .jsMicro) {
                    Text("성공 목표")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelNeutral)
                    Stepper("\(store.successTarget)회", value: $store.successTarget, in: 1...store.maxSuccessTarget)
                        .font(.jsBodyMedium)
                }

                VStack(alignment: .leading, spacing: .jsXS) {
                    Toggle("알림 설정", isOn: $store.isAlarmEnabled)
                        .font(.jsBodyMedium)

                    if store.isAlarmEnabled {
                        DatePicker(
                            "알림 시간",
                            selection: $store.alarmDate,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                    }
                }
            }
            .padding(.horizontal, .jsMD)

            Spacer()

            HStack(spacing: .jsSM) {
                Button(action: { store.send(.cancelButtonTapped) }) {
                    Text("취소")
                        .font(.jsButtonMedium)
                        .foregroundColor(.labelStrong)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.backgroundNormal)
                        .cornerRadius(.jsRadiusMD)
                }

                Button(action: { store.send(.saveButtonTapped) }) {
                    Text("저장")
                        .font(.jsButtonMedium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(isSaveEnabled ? Color.primaryNormal : Color.labelDisable)
                        .cornerRadius(.jsRadiusMD)
                }
                .disabled(!isSaveEnabled)
            }
            .padding(.horizontal, .jsMD)
            .padding(.bottom, .jsMD)
        }
        .background(Color.backgroundNormal)
        .navigationTitle("작심 수정")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.send(.onAppear) }
    }

    private var isSaveEnabled: Bool {
        !store.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
