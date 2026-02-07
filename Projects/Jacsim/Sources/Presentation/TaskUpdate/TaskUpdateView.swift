import SwiftUI
import ComposableArchitecture
import DSKit
import PhotosUI
import _Concurrency

public struct TaskUpdateView: View {
    @Bindable var store: StoreOf<TaskUpdateFeature>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(store: StoreOf<TaskUpdateFeature>) {
        self.store = store
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "오늘 인증",
            subtitle: store.dateText,
            stickyFooter: {
                bottomCTASection
            }
        ) {
            if store.isOverwriteMode {
                overwriteBanner
            }

            if store.saveFailed {
                errorMessage
            }

            if PresentationRedesignFlags.isSectionEnabled(.taskFormPhoto) {
                photoPickerSection
            }

            memoInputSection
        }
        .navigationTitle("오늘 인증")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.send(.onAppear) }
        .overlay {
            if store.isSaving {
                loadingOverlay
            }
        }
        .overlay(alignment: .bottom) {
            if let message = store.toastMessage {
                RedesignToastView(message: message, style: .error)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task(id: message) {
                        try? await _Concurrency.Task.sleep(
                            nanoseconds: RedesignToastView.defaultDismissNanoseconds
                        )
                        store.send(.toastDismissed)
                    }
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: store.toastMessage)
    }
    
    private var overwriteBanner: some View {
        RedesignStateBanner(
            text: "오늘 인증은 다시 저장하면 덮어써져요",
            icon: "info.circle.fill",
            tintColor: .primaryNormal
        )
    }
    
    private var photoPickerSection: some View {
        let photoHeight: CGFloat = 300.jsScaled()
        let cardShape = RoundedRectangle(cornerRadius: .jsRadiusLG, style: .continuous)

        return RedesignSectionCard(
            title: "인증 사진",
            subtitle: "오늘의 진행 상황을 남겨요"
        ) {
            VStack(spacing: .jsSM) {
                ZStack {
                    if let image = store.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: .jsXS) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.jsDisplayMedium)
                                .foregroundColor(.labelAlternative)

                            Text("인증 사진을 추가해 주세요")
                                .font(.jsBodyMedium)
                                .foregroundColor(.labelStrong)

                            Text("가로·세로 비율은 자동으로 맞춰져요")
                                .font(.jsLabelMedium)
                                .foregroundColor(.labelAlternative)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.backgroundStrong)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: photoHeight, maxHeight: photoHeight)
                .clipShape(cardShape)
                .overlay {
                    cardShape
                        .stroke(
                            store.image == nil ? Color.primaryNormal.opacity(0.35) : Color.labelDisable.opacity(0.24),
                            style: StrokeStyle(
                                lineWidth: 1,
                                dash: store.image == nil ? [8, 6] : []
                            )
                        )
                }
                .overlay(alignment: .topTrailing) {
                    if store.image != nil {
                        HStack(spacing: .jsMicro) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.positive)

                            Text("선택됨")
                                .font(.jsLabelMedium)
                                .foregroundColor(.labelStrong)
                        }
                        .padding(.horizontal, .jsXS)
                        .padding(.vertical, .jsMicro)
                        .background(Color.backgroundNormal.opacity(0.92))
                        .clipShape(Capsule())
                        .padding(.jsSM)
                    }
                }

                let hasImage = store.image != nil
                PhotosPicker(selection: $store.photoPickerItem, matching: .images) {
                    HStack(spacing: .jsXS) {
                        Image(systemName: hasImage ? "arrow.triangle.2.circlepath" : "photo.badge.plus")
                            .font(.jsHeadlineSmall)
                            .foregroundColor(.primaryNormal)

                        Text(hasImage ? "인증 사진 변경" : "인증 사진 선택")
                            .font(.jsButtonMedium)
                            .foregroundColor(.labelStrong)

                        Spacer(minLength: .jsXS)

                        Image(systemName: "chevron.right")
                            .font(.jsButtonSmall)
                            .foregroundColor(.labelAlternative)
                    }
                    .padding(.horizontal, .jsMD)
                    .padding(.vertical, .jsSM)
                    .background(
                        RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                            .fill(Color.backgroundStrong)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                            .stroke(Color.labelDisable.opacity(0.24), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .onChange(of: store.photoPickerItem) { _, newItem in
                    store.send(.photoPickerItemChanged(newItem))
                }
            }
        }
    }
    
    private var memoInputSection: some View {
        RedesignSectionCard(
            title: "한 줄 메모",
            subtitle: "선택사항 · 최대 30자"
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
                
                Text("\(store.memo.count)/\(TextInputFieldPolicy.memo.maxLength)")
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelAssistive)

                Text("공백 포함 · 저장 시 앞뒤 공백은 자동 정리돼요")
                    .font(.jsLabelSmall)
                    .foregroundColor(.labelAssistive)
            }
        }
    }
    
    private var errorMessage: some View {
        RedesignInlineErrorView(
            model: InlineErrorModel(
                message: "저장에 실패했어요. 다시 시도해 주세요."
            )
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
