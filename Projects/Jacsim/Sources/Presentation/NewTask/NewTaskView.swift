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
            title: "새 작심 만들기",
            subtitle: model.currentStep.description,
            contentBottomInset: contentBottomInset,
            scrollToID: scrollTargetID,
            scrollAnchor: .center,
            stickyFooter: {
                buttonSection
            }
        ) {
            stepProgressSection

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

        return RedesignSectionCard(
            title: "단계 \(currentIndex)/\(steps.count)",
            subtitle: model.currentStep.title
        ) {
            VStack(alignment: .leading, spacing: .jsSM) {
                HStack(spacing: .jsXS) {
                    ForEach(steps, id: \.rawValue) { step in
                        Capsule()
                            .fill(step.rawValue <= model.currentStep.rawValue ? Color.primaryNormal : Color.backgroundStrong)
                            .frame(maxWidth: .infinity)
                            .frame(height: 6.jsScaled())
                    }
                }

                Text(model.currentStep.description)
                    .font(.jsBodySmall)
                    .foregroundColor(.labelAlternative)
            }
        }
    }

    private var titleSection: some View {
        RedesignSectionCard(
            title: "제목",
            subtitle: "나중에 변경할 수 없어요"
        ) {
            VStack(alignment: .trailing, spacing: .jsXS) {
                JSInputField(
                    title: "",
                    placeholder: "예: 매일 10분 독서",
                    text: $model.title
                )

                Text("\(model.title.count)/\(TextInputFieldPolicy.title.maxLength)")
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelAssistive)

                Text("공백 포함 · 저장 시 앞뒤 공백은 자동 정리돼요")
                    .font(.jsLabelSmall)
                    .foregroundColor(.labelAssistive)
            }
        }
    }

    private var stageSection: some View {
        RedesignSectionCard(
            title: "스테이지",
            subtitle: "이번 목표를 며칠 동안 이어갈까요?"
        ) {
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

            Text("선택된 기간: \(model.stageType.durationDays)일")
                .font(.jsBodySmall)
                .foregroundColor(.labelAlternative)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var photoSection: some View {
        RedesignSectionCard(
            title: "대표 사진",
            subtitle: "카드에 노출될 대표 이미지를 설정해요"
        ) {
            ImageAttachmentPicker(
                image: model.image,
                emptyTitle: "대표 사진을 추가해 주세요",
                emptySubtitle: "가로·세로 비율은 자동으로 맞춰져요",
                height: 232.jsScaled()
            ) { image in
                model.imageSelected(image)
            }
        }
    }

    private var challengeSummarySection: some View {
        RedesignSectionCard(
            title: "작심 확인",
            subtitle: "아래 내용으로 챌린지를 시작해요"
        ) {
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
        RedesignSectionCard(
            title: "알림",
            subtitle: "매일 같은 시간에 인증 리마인드를 받을 수 있어요"
        ) {
            Toggle("알림 받기", isOn: $model.isAlarmEnabled)
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
        .background(Color.backgroundNormal)
        .background(alignment: .top) {
            LinearGradient(
                colors: [
                    Color.backgroundNormal.opacity(0),
                    Color.backgroundNormal.opacity(0.9),
                    Color.backgroundNormal
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
            return "챌린지 시작"
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
