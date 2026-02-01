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
        VStack(spacing: 24) {
            ZStack(alignment: .bottomTrailing) {
                if let image = store.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.labelDisable)
                        .frame(height: 220)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "camera")
                                .font(.system(size: 40))
                                .foregroundColor(.labelNeutral)
                        )
                }

                PhotosPicker(
                    selection: $photoPickerItem,
                    matching: .images
                ) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.primaryNormal)
                        .background(Color.white)
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
            .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 12) {
                TextField("작심 이름", text: $store.title)
                    .font(.pretendardMedium(size: 16))
                    .padding()
                    .background(Color.backgroundNormal)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primaryNormal.opacity(0.5), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("성공 목표")
                        .font(.pretendardMedium(size: 14))
                        .foregroundColor(.labelNeutral)
                    Stepper("\(store.successTarget)회", value: $store.successTarget, in: 1...store.maxSuccessTarget)
                        .font(.pretendardMedium(size: 16))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Toggle("알림 설정", isOn: $store.isAlarmEnabled)
                        .font(.pretendardMedium(size: 16))

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
            .padding(.horizontal, 16)

            Spacer()

            HStack(spacing: 12) {
                Button(action: { store.send(.cancelButtonTapped) }) {
                    Text("취소")
                        .font(.pretendardMedium(size: 16))
                        .foregroundColor(.labelStrong)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.backgroundNormal)
                        .cornerRadius(12)
                }

                Button(action: { store.send(.saveButtonTapped) }) {
                    Text("저장")
                        .font(.pretendardMedium(size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(isSaveEnabled ? Color.primaryNormal : Color.labelDisable)
                        .cornerRadius(12)
                }
                .disabled(!isSaveEnabled)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
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
