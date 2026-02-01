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
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    if store.isOverwriteMode {
                        overwriteBanner
                    }
                    
                    photoPickerSection
                    
                    memoInputSection
                    
                    if store.saveFailed {
                        errorMessage
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            
            bottomCTASection
        }
        .background(Color.backgroundNormal)
        .navigationTitle("오늘 인증")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.send(.onAppear) }
        .overlay {
            if store.isSaving {
                loadingOverlay
            }
        }
    }
    
    private var overwriteBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.primaryNormal)
                .font(.system(size: 16))
            
            Text("오늘 인증은 수정할 수 있어요")
                .font(.jsBodySmall)
                .foregroundColor(.labelNormal)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.primaryNormal.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var photoPickerSection: some View {
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
                    .fill(Color.backgroundStrong)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.labelAlternative)
                            
                            Text("사진을 추가해주세요")
                                .font(.jsBodyMedium)
                                .foregroundColor(.labelAlternative)
                        }
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
                    .padding(.jsXS)
            }
            .onChange(of: store.photoPickerItem) { _, newItem in
                store.send(.photoPickerItemChanged(newItem))
            }
        }
    }
    
    private var memoInputSection: some View {
        VStack(alignment: .trailing, spacing: 8) {
            TextField("짧게 기록해요 (선택)", text: $store.memo, axis: .vertical)
                .font(.jsBodyMedium)
                .padding()
                .background(Color.backgroundStrong)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryNormal.opacity(0.5), lineWidth: 1)
                )
                .lineLimit(2...4)
            
            Text("\(store.memo.trimmingCharacters(in: .whitespacesAndNewlines).count)/20")
                .font(.jsLabelMedium)
                .foregroundColor(.labelAssistive)
        }
    }
    
    private var errorMessage: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 14))
            
            Text("저장에 실패했어요. 다시 시도해주세요")
                .font(.jsBodySmall)
                .foregroundColor(.red)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var bottomCTASection: some View {
        VStack(spacing: 0) {
            JSButton(
                title: "오늘 작심 완료했어요",
                style: .primary,
                size: .large,
                isEnabled: isButtonEnabled && !store.isSaving
            ) {
                store.send(.certifyButtonTapped)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.backgroundNormal.opacity(0),
                    Color.backgroundNormal,
                    Color.backgroundNormal
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("저장 중...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.jsXL)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
    }
    
    private var isButtonEnabled: Bool {
        store.image != nil
    }
}
