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
            stickyFooter: {
                bottomCTASection
            }
        ) {
            checkInHeroCard

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
            text: "다시 저장하면 오늘 기록이 바뀌어요",
            icon: "info.circle.fill",
            tintColor: .v2BrandBlue
        )
    }

    private var checkInHeroCard: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color.v2BrandBlue.opacity(0.86),
                    Color.v2BrandBlueStrong.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.16))
                .frame(width: 132.jsScaled(), height: 132.jsScaled())
                .offset(x: 220.jsScaled(), y: -72.jsScaled())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: .jsMD) {
                HStack(spacing: .jsXS) {
                    JSV2StatusChip(model.dateText, systemImage: "calendar", style: .neutral)
                    JSV2StatusChip(
                        model.image == nil ? "사진 필요" : "사진 준비",
                        systemImage: model.image == nil ? "camera.fill" : "checkmark.circle.fill",
                        style: model.image == nil ? .warning : .success
                    )
                    Spacer(minLength: .jsXS)
                }

                Spacer(minLength: .jsMD)

                VStack(alignment: .leading, spacing: .jsXS) {
                    Text(model.task.title)
                        .font(.jsDisplay26Bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text("\(model.task.completedDays)일 인증 · \(Int(model.task.progress * 100))%")
                        .font(.jsBodySmall)
                        .foregroundColor(.white.opacity(0.84))
                        .lineLimit(1)
                }
            }
            .padding(.jsLG)
        }
        .frame(height: 220.jsScaled())
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 28.jsScaled(), style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("오늘 인증, \(model.task.title), \(model.dateText), \(model.image == nil ? "사진 미선택" : "사진 선택됨")")
    }
    
    private var photoPickerSection: some View {
        RedesignSectionCard(title: "사진으로 인증") {
            ImageAttachmentPicker(
                image: model.image,
                emptyTitle: "오늘 사진",
                emptySubtitle: "한 장이면 충분해요",
                selectedBadgeTitle: "준비됨",
                cameraButtonTitle: "촬영",
                libraryButtonTitle: "앨범",
                height: 336.jsScaled()
            ) { image in
                model.imageSelected(image)
            }
        }
    }
    
    private var memoInputSection: some View {
        RedesignSectionCard(title: "메모") {
            VStack(alignment: .trailing, spacing: .jsXS) {
                TextField("한 줄만 남겨요", text: $model.memo, axis: .vertical)
                    .font(.jsBodyMedium)
                    .padding()
                    .background(Color.v2Surface)
                    .cornerRadius(.jsRadiusMD)
                    .overlay(
                        RoundedRectangle(cornerRadius: .jsRadiusMD)
                            .stroke(Color.labelAssistive.opacity(0.22), lineWidth: 1)
                    )
                    .lineLimit(2...4)
                    .accessibilityHint("선택 사항입니다")
                
                Text("\(model.memo.count)/\(TextInputFieldPolicy.memo.maxLength)")
                    .font(.jsLabelMedium)
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
                title: "인증 완료",
                systemImage: "checkmark.circle.fill",
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
                    Color.v2Background.opacity(0),
                    Color.v2Background,
                    Color.v2Background
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
                    .progressViewStyle(CircularProgressViewStyle(tint: .v2BrandBlue))
                    .scaleEffect(1.5)
                
                Text("저장 중")
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
