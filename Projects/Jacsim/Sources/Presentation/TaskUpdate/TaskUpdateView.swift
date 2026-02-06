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
        ZStack(alignment: .bottom) {
            RedesignScreenScaffold(
                title: "오늘 인증",
                subtitle: store.dateText
            ) {
                if store.isOverwriteMode {
                    overwriteBanner
                }

                if store.saveFailed {
                    errorMessage
                }

                photoPickerSection
                memoInputSection

                Spacer(minLength: 120)
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
        RedesignStateBanner(
            text: "오늘 인증은 다시 저장하면 덮어써져요",
            icon: "info.circle.fill",
            tintColor: .primaryNormal
        )
    }
    
    private var photoPickerSection: some View {
        RedesignSectionCard(
            title: "인증 사진",
            subtitle: "오늘의 진행 상황을 남겨요"
        ) {
            ZStack(alignment: .bottomTrailing) {
                if let image = store.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                        .cornerRadius(.jsRadiusMD)
                } else {
                    Rectangle()
                        .fill(Color.backgroundStrong)
                        .frame(height: 300)
                        .cornerRadius(.jsRadiusMD)
                        .overlay(
                            VStack(spacing: .jsSM) {
                                Image(systemName: "photo")
                                    .font(.pretendardSemiBold(size: 40))
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
                        .font(.pretendardSemiBold(size: 44))
                        .foregroundColor(.primaryNormal)
                        .background(Color.backgroundNormal)
                        .clipShape(Circle())
                        .padding(.jsXS)
                }
                .onChange(of: store.photoPickerItem) { _, newItem in
                    store.send(.photoPickerItemChanged(newItem))
                }
            }
        }
    }
    
    private var memoInputSection: some View {
        RedesignSectionCard(
            title: "한 줄 메모",
            subtitle: "선택사항 · 최대 20자"
        ) {
            VStack(alignment: .trailing, spacing: .jsXS) {
                TextField("짧게 기록해요 (선택)", text: $store.memo, axis: .vertical)
                    .font(.jsBodyMedium)
                    .padding()
                    .background(Color.backgroundStrong)
                    .cornerRadius(.jsRadiusMD)
                    .overlay(
                        RoundedRectangle(cornerRadius: .jsRadiusMD)
                            .stroke(Color.primaryNormal.opacity(0.5), lineWidth: 1)
                    )
                    .lineLimit(2...4)
                
                Text("\(store.memo.trimmingCharacters(in: .whitespacesAndNewlines).count)/20")
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelAssistive)
            }
        }
    }
    
    private var errorMessage: some View {
        RedesignStateBanner(
            text: "저장에 실패했어요. 다시 시도해주세요",
            icon: "exclamationmark.circle.fill",
            tintColor: .destructive
        )
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
            .padding(.horizontal, .jsMD)
            .padding(.vertical, .jsMD)
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
            Color.backgroundStrong.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: .jsSM) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryNormal))
                    .scaleEffect(1.5)
                
                Text("저장 중...")
                    .font(.jsButtonSmall)
                    .foregroundColor(.labelStrong)
            }
            .padding(.jsXL)
            .background(.ultraThinMaterial)
            .cornerRadius(.jsRadiusLG)
        }
    }
    
    private var isButtonEnabled: Bool {
        store.image != nil
    }
}
