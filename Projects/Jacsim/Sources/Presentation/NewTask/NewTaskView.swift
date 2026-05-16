import SwiftUI
import DSKit
import Domain
import _Concurrency
import Combine
import UIKit

public struct NewTaskView: View {
    @Bindable var model: NewTaskModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isKeyboardVisible = false
    @State private var scrollTargetID: AnyHashable?

    private enum FooterLayout {
        static let contentBottomInset: CGFloat = 108.jsScaled()
        static let compactContentBottomInset: CGFloat = 72.jsScaled()
        static let toastBottomPadding: CGFloat = 104.jsScaled()
        static let compactToastBottomPadding: CGFloat = 72.jsScaled()
        static let secondaryActionSpacing: CGFloat = 18.jsScaled()
        static let buttonActionSpacing: CGFloat = 6.jsScaled()
        static let horizontalPadding: CGFloat = .jsMD
        static let topPadding: CGFloat = .jsXS
        static let compactTopPadding: CGFloat = .jsMicro
        static let bottomPadding: CGFloat = .jsXS
        static let compactBottomPadding: CGFloat = .jsXS
        static let topFadeHeight: CGFloat = 14.jsScaled()
        static let compactTopFadeHeight: CGFloat = 12.jsScaled()
    }

    private enum ScrollTarget {
        static let alarmPicker = "newTask.alarmPicker"
    }

    private enum AlarmScrollPolicy {
        static let expandedDelayNanoseconds: UInt64 = 360_000_000
        static let reducedMotionDelayNanoseconds: UInt64 = 120_000_000
        static let settleDelayNanoseconds: UInt64 = 120_000_000
    }

    public init(model: NewTaskModel) {
        self.model = model
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "새 작심",
            contentBottomInset: contentBottomInset,
            scrollToID: scrollTargetID,
            scrollAnchor: .center,
            stickyFooter: {
                buttonSection
            }
        ) {
            stepProgressSection
            challengePreviewCard

            if model.saveFailed && model.currentStep == .alarmConfirm {
                saveFailedBanner
            }

            if let validationError = model.stepValidationError {
                RedesignInlineErrorView(
                    model: InlineErrorModel(message: validationError.message)
                )
            }

            switch model.currentStep {
            case .basicInfo:
                titleSection
                stageSection
            case .photo:
                if PresentationRedesignFlags.isSectionEnabled(.taskFormPhoto) {
                    photoSection
                }
            case .alarmConfirm:
                challengeSummarySection
                if PresentationRedesignFlags.isSectionEnabled(.taskFormAlarm) {
                    alarmSection
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if let message = model.toastMessage {
                RedesignToastView(
                    message: message,
                    style: .error,
                    bottomPadding: toastBottomPadding
                )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task(id: message) {
                        try? await _Concurrency.Task.sleep(
                            nanoseconds: RedesignToastView.defaultDismissNanoseconds
                        )
                        model.toastDismissed()
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("취소") {
                    model.cancelButtonTapped()
                }
                .font(.jsButtonMedium)
                .foregroundColor(.labelAlternative)
                .disabled(model.isSaving)
            }

            if isFooterCompacted, model.currentStep.previous != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("이전") {
                        model.previousStepTapped()
                    }
                    .font(.jsButtonMedium)
                    .foregroundColor(.labelAlternative)
                    .disabled(model.isSaving)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            let visible = frame.minY < UIScreen.main.bounds.height - 8
            updateKeyboardVisibility(visible)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            updateKeyboardVisibility(false)
        }
        .onChange(of: model.isAlarmEnabled) { _, isEnabled in
            guard isEnabled, model.currentStep == .alarmConfirm else { return }
            let delay = reduceMotion
                ? AlarmScrollPolicy.reducedMotionDelayNanoseconds
                : AlarmScrollPolicy.expandedDelayNanoseconds
            requestAlarmPickerScroll(delayNanoseconds: delay)
        }
        .alert("작심 만들기를 그만둘까요?", isPresented: $model.isDiscardAlertPresented) {
            Button("계속 작성", role: .cancel) {}
            Button("그만두기", role: .destructive) {
                model.confirmDiscardDraft()
            }
        } message: {
            Text("입력한 제목과 사진은 저장되지 않아요.")
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: model.toastMessage)
    }

    private var stepProgressSection: some View {
        let steps = NewTaskModel.CreateChallengeStep.allCases
        let currentIndex = model.currentStep.rawValue + 1

        return VStack(alignment: .leading, spacing: .jsSM) {
            HStack {
                JSV2StatusChip("단계 \(currentIndex)/\(steps.count)", systemImage: "sparkles", style: .accent)
                Spacer()
                Text(model.currentStep.title)
                    .font(.jsButtonSmall)
                    .foregroundColor(.labelAlternative)
            }

            HStack(spacing: .jsXS) {
                ForEach(steps, id: \.rawValue) { step in
                    Capsule()
                        .fill(step.rawValue <= model.currentStep.rawValue ? Color.v2BrandBlue : Color.v2Surface)
                        .frame(maxWidth: .infinity)
                        .frame(height: 7.jsScaled())
                }
            }
        }
        .padding(.horizontal, .jsMD)
    }

    private var challengePreviewCard: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = model.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [.v2BrandBlue.opacity(0.76), .v2BrandBlueStrong.opacity(0.92)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: "camera.fill")
                    .font(.jsDisplayMedium)
                    .foregroundColor(.white.opacity(0.72))
            }

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.68)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: .jsSM) {
                HStack(spacing: .jsXS) {
                    JSV2StatusChip("\(model.stageType.durationDays)일", systemImage: "calendar", style: .neutral)
                    JSV2StatusChip(model.isAlarmEnabled ? "알림" : "알림 없음", systemImage: "bell.fill", style: model.isAlarmEnabled ? .accent : .neutral)
                }

                Text(model.trimmedTitle.isEmpty ? "오늘 시작할 작심" : model.trimmedTitle)
                    .font(.jsDisplay26Bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }
            .padding(.jsLG)
        }
        .frame(height: 240.jsScaled())
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 28.jsScaled(), style: .continuous))
        .padding(.horizontal, .jsMD)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("새 작심 미리보기, \(model.trimmedTitle.isEmpty ? "제목 미입력" : model.trimmedTitle), \(model.stageType.durationDays)일")
    }

    private var titleSection: some View {
        RedesignSectionCard(title: "무엇을 이어갈까요?") {
            VStack(alignment: .trailing, spacing: .jsXS) {
                JSInputField(
                    title: "",
                    placeholder: "예: 매일 10분 독서",
                    text: $model.title
                )

                Text("\(model.title.count)/\(TextInputFieldPolicy.title.maxLength)")
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelAssistive)
            }
        }
    }

    private var stageSection: some View {
        RedesignSectionCard(title: "기간") {
            JSStageSelector(
                selectedStage: stageDayBinding,
                stages: [3, 7, 15, 30]
            ) { selected in
                if !reduceMotion {
                    withAnimation(.easeInOut(duration: JSAnimation.durationNormal)) {
                        model.stageType = stageType(for: selected)
                    }
                } else {
                    model.stageType = stageType(for: selected)
                }
            }

            HStack {
                Spacer()
                JSV2StatusChip("\(model.stageType.durationDays)일", systemImage: "calendar", style: .accent)
            }
        }
    }

    private var photoSection: some View {
        RedesignSectionCard(title: "대표 사진") {
            ImageAttachmentPicker(
                image: model.image,
                emptyTitle: "카드 사진",
                emptySubtitle: "작심이 한눈에 보이게",
                selectedBadgeTitle: "대표",
                cameraButtonTitle: "촬영",
                libraryButtonTitle: "앨범",
                height: 232.jsScaled()
            ) { image in
                model.imageSelected(image)
            }
        }
    }

    private var challengeSummarySection: some View {
        RedesignSectionCard(title: "카드 확인") {
            VStack(spacing: .jsSM) {
                summaryRow(
                    title: "제목",
                    value: model.trimmedTitle.isEmpty ? "미입력" : model.trimmedTitle
                )
                summaryRow(
                    title: "기간",
                    value: "\(model.stageType.durationDays)일"
                )
                summaryRow(
                    title: "대표사진",
                    value: model.image == nil ? "미선택" : "선택됨"
                )
            }
        }
    }

    private func summaryRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: .jsSM) {
            Text(title)
                .font(.jsLabelMedium)
                .foregroundColor(.labelAlternative)
                .frame(width: 68.jsScaled(), alignment: .leading)

            Text(value)
                .font(.jsBodyMedium)
                .foregroundColor(.labelStrong)
                .multilineTextAlignment(.leading)

            Spacer(minLength: .jsXS)
        }
    }

    private var alarmSection: some View {
        RedesignSectionCard(title: "알림") {
            Toggle("작심 알림", isOn: $model.isAlarmEnabled)
                .font(.jsBodyMedium)

            if model.isAlarmEnabled {
                DatePicker(
                    "시간 선택",
                    selection: $model.alarmDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .id(ScrollTarget.alarmPicker)
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.24), value: model.isAlarmEnabled)
    }

    private var buttonSection: some View {
        VStack(spacing: FooterLayout.buttonActionSpacing) {
            ZStack {
                JSButton(
                    title: primaryButtonTitle,
                    systemImage: primaryButtonIcon,
                    style: .primary,
                    size: .medium,
                    isEnabled: isPrimaryButtonEnabled
                ) {
                    primaryButtonTapped()
                }

                if model.isSaving && model.currentStep == .alarmConfirm {
                    JSProgressIndicator(size: .small, tintColor: .white)
                }
            }

            if !isFooterCompacted {
                secondaryFooterActions
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, FooterLayout.horizontalPadding)
        .padding(.top, isFooterCompacted ? FooterLayout.compactTopPadding : FooterLayout.topPadding)
        .padding(.bottom, isFooterCompacted ? FooterLayout.compactBottomPadding : FooterLayout.bottomPadding)
        .background(Color.v2Background)
        .background(alignment: .top) {
            LinearGradient(
                colors: [
                    Color.v2Background.opacity(0),
                    Color.v2Background.opacity(0.9),
                    Color.v2Background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: isFooterCompacted ? FooterLayout.compactTopFadeHeight : FooterLayout.topFadeHeight)
            .offset(y: -(isFooterCompacted ? FooterLayout.compactTopFadeHeight : FooterLayout.topFadeHeight))
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.labelAssistive.opacity(0.2))
                .frame(height: 1)
        }
    }

    private var isFooterCompacted: Bool {
        isKeyboardVisible
    }

    private var contentBottomInset: CGFloat {
        let baseInset = isFooterCompacted ? FooterLayout.compactContentBottomInset : FooterLayout.contentBottomInset
        guard model.currentStep == .alarmConfirm, model.isAlarmEnabled else { return baseInset }
        // Extra inset so DatePicker can settle fully above sticky footer.
        return baseInset + 96.jsScaled()
    }

    private var toastBottomPadding: CGFloat {
        isFooterCompacted ? FooterLayout.compactToastBottomPadding : FooterLayout.toastBottomPadding
    }

    private var primaryButtonTitle: String {
        switch model.currentStep {
        case .basicInfo, .photo:
            return "다음"
        case .alarmConfirm:
            return "시작하기"
        }
    }

    private var primaryButtonIcon: String {
        switch model.currentStep {
        case .basicInfo, .photo:
            return "arrow.right"
        case .alarmConfirm:
            return "sparkles"
        }
    }

    private var isPrimaryButtonEnabled: Bool {
        guard !model.isSaving else { return false }

        switch model.currentStep {
        case .basicInfo, .photo:
            return model.canProceedCurrentStep
        case .alarmConfirm:
            return model.canSubmit
        }
    }

    private func primaryButtonTapped() {
        switch model.currentStep {
        case .basicInfo, .photo:
            model.nextStepTapped()
        case .alarmConfirm:
            model.saveButtonTapped()
        }
    }

    private var saveFailedBanner: some View {
        RedesignInlineErrorView(
            model: InlineErrorModel(
                message: "저장에 실패했어요. 네트워크 상태를 확인해 주세요."
            )
        )
    }

    private var stageDayBinding: Binding<Int> {
        Binding(
            get: { model.stageType.durationDays },
            set: { day in
                model.stageType = stageType(for: day)
            }
        )
    }

    private func stageType(for day: Int) -> StageType {
        switch day {
        case 3:
            return .three
        case 7:
            return .seven
        case 15:
            return .fifteen
        case 30:
            return .thirty
        default:
            return .three
        }
    }

    private func updateKeyboardVisibility(_ visible: Bool) {
        guard isKeyboardVisible != visible else { return }

        if reduceMotion {
            isKeyboardVisible = visible
        } else {
            withAnimation(.easeInOut(duration: 0.22)) {
                isKeyboardVisible = visible
            }
        }
    }

    private var secondaryFooterActions: some View {
        HStack(spacing: FooterLayout.secondaryActionSpacing) {
            if model.currentStep.previous != nil {
                Button("이전") {
                    model.previousStepTapped()
                }
                .disabled(model.isSaving)
            }

            Button("취소") {
                model.cancelButtonTapped()
            }
            .disabled(model.isSaving)
        }
        .font(.jsButtonSmall)
        .foregroundColor(.labelAlternative)
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .padding(.vertical, .jsMicro)
    }

    private func requestAlarmPickerScroll(delayNanoseconds: UInt64) {
        scrollTargetID = nil
        _Concurrency.Task { @MainActor in
            try? await _Concurrency.Task.sleep(nanoseconds: delayNanoseconds)
            scrollTargetID = ScrollTarget.alarmPicker
            try? await _Concurrency.Task.sleep(nanoseconds: AlarmScrollPolicy.settleDelayNanoseconds)
            // Nudge once more after layout settles to guarantee full DatePicker visibility.
            scrollTargetID = nil
            scrollTargetID = ScrollTarget.alarmPicker
        }
    }
}
