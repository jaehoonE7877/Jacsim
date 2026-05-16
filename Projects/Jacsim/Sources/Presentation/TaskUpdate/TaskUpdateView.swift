import SwiftUI
import DSKit
import _Concurrency

public struct TaskUpdateView: View {
    @Bindable var model: TaskUpdateModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(model: TaskUpdateModel) {
        self.model = model
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "오늘 인증",
            subtitle: model.dateText,
            stickyFooter: {
                bottomCTASection
            }
        ) {
            if model.isOverwriteMode {
                overwriteBanner
            }

            if model.saveFailed {
                errorMessage
            }

            if PresentationRedesignFlags.isSectionEnabled(.taskFormPhoto) {
                photoPickerSection
            }

            memoInputSection
        }
        .navigationTitle("오늘 인증")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { model.onAppear() }
        .overlay {
            if model.isSaving {
                loadingOverlay
            }
        }
        .overlay(alignment: .bottom) {
            if let message = model.toastMessage {
                RedesignToastView(message: message, style: .error)
                    .transition(reduceMotion ? .identity : .move(edge: .bottom).combined(with: .opacity))
                    .task(id: message) {
                        try? await _Concurrency.Task.sleep(
                            nanoseconds: RedesignToastView.defaultDismissNanoseconds
                        )
                        model.toastDismissed()
                    }
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: model.toastMessage)
        .sensoryFeedback(.success, trigger: model.certificationFeedbackTrigger)
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
            ImageAttachmentPicker(
                image: model.image,
                emptyTitle: "인증 사진을 추가해 주세요",
                emptySubtitle: "가로·세로 비율은 자동으로 맞춰져요",
                height: 300.jsScaled()
            ) { image in
                model.imageSelected(image)
            }
        }
    }
    
    private var memoInputSection: some View {
        RedesignSectionCard(
            title: "한 줄 메모",
            subtitle: "선택사항 · 최대 30자"
        ) {
            VStack(alignment: .trailing, spacing: .jsXS) {
                TextField("짧게 기록해요 (선택)", text: $model.memo, axis: .vertical)
                    .font(.jsBodyMedium)
                    .padding()
                    .background(Color.backgroundStrong)
                    .cornerRadius(.jsRadiusMD)
                    .overlay(
                        RoundedRectangle(cornerRadius: .jsRadiusMD)
                            .stroke(Color.primaryNormal.opacity(0.5), lineWidth: 1)
                    )
                    .lineLimit(2...4)
                
                Text("\(model.memo.count)/\(TextInputFieldPolicy.memo.maxLength)")
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
                isEnabled: isButtonEnabled && !model.isSaving
            ) {
                model.certifyButtonTapped()
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
        model.image != nil
    }
}
