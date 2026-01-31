import SwiftUI
import ComposableArchitecture
import DSKit
import PhotosUI

public struct TaskUpdateView: View {
    @Bindable var store: StoreOf<TaskUpdateFeature>

    public init(store: StoreOf<TaskUpdateFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .bottomTrailing) {
                if let image = store.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.labelDisable)
                        .frame(height: 300)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "camera")
                                .font(.system(size: 40))
                                .foregroundColor(.labelNeutral)
                        )
                }
                
                PhotosPicker(
                    selection: Binding(
                        get: { store.photoPickerItem ?? PhotosPickerItem(itemIdentifier: "") },
                        set: { store.photoPickerItem = $0 }
                    ),
                    matching: .images
                ) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.primaryNormal)
                        .background(Color.white)
                        .clipShape(Circle())
                        .padding(8)
                }
                .onChange(of: store.photoPickerItem) { newItem in
                    store.send(.photoPickerItemChanged(newItem))
                }
            }
            .padding(.horizontal, 16)
            
            VStack(alignment: .trailing, spacing: 8) {
                TextField("인증 메모를 입력해주세요 (선택, 50자 이내)", text: $store.memo)
                    .font(.pretendardMedium(size: 16))
                    .padding()
                    .background(Color.backgroundNormal)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primaryNormal.opacity(0.5), lineWidth: 1)
                    )
                
                Text("\(store.memo.trimmingCharacters(in: .whitespacesAndNewlines).count) / 50")
                    .font(.pretendardMedium(size: 14))
                    .foregroundColor(.labelAssistive)
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            Button(action: { store.send(.certifyButtonTapped) }) {
                Text("인증 완료")
                    .font(.pretendardMedium(size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(isButtonEnabled ? Color.primaryNormal : Color.labelDisable)
                    .cornerRadius(12)
            }
            .disabled(!isButtonEnabled)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.backgroundNormal)
        .navigationTitle("\(store.dateText)의 작심")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.send(.onAppear) }
    }
    
    private var isButtonEnabled: Bool {
        let trimmedCount = store.memo.trimmingCharacters(in: .whitespacesAndNewlines).count
        return store.image != nil && trimmedCount <= 50
    }
}
