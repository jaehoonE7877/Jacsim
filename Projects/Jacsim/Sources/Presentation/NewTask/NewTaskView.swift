import SwiftUI
import ComposableArchitecture
import DSKit
import Domain
import PhotosUI
import _Concurrency
import Combine
import UIKit

public struct NewTaskView: View {
    @Bindable var store: StoreOf<NewTaskFeature>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isKeyboardVisible = false
    @State private var scrollTargetID: AnyHashable?

    private enum FooterLayout {
        static let expandedContentBottomInset: CGFloat = 132.jsScaled()
        static let compactContentBottomInset: CGFloat = 84.jsScaled()
        static let expandedToastBottomPadding: CGFloat = 120.jsScaled()
        static let compactToastBottomPadding: CGFloat = 84.jsScaled()
        static let primarySecondarySpacing: CGFloat = 8.jsScaled()
        static let secondarySpacing: CGFloat = 8.jsScaled()
        static let horizontalPadding: CGFloat = .jsMD
        static let expandedTopPadding: CGFloat = .jsXS
        static let compactTopPadding: CGFloat = .jsMicro
        static let expandedBottomPadding: CGFloat = .jsSM
        static let compactBottomPadding: CGFloat = .jsXS
        static let expandedTopFadeHeight: CGFloat = 20.jsScaled()
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

    public init(store: StoreOf<NewTaskFeature>) {
        self.store = store
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "새 작심 만들기",
            subtitle: store.currentStep.description,
            contentBottomInset: contentBottomInset,
            scrollToID: scrollTargetID,
            scrollAnchor: .center,
            stickyFooter: {
                buttonSection
            }
        ) {
            stepProgressSection

            if store.saveFailed && store.currentStep == .alarmConfirm {
                saveFailedBanner
            }

            if let validationError = store.stepValidationError {
                RedesignInlineErrorView(
                    model: InlineErrorModel(message: validationError.message)
                )
            }

            switch store.currentStep {
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
            if let message = store.toastMessage {
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
                        store.send(.toastDismissed)
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("취소") {
                    store.send(.cancelButtonTapped)
                }
                .font(.jsButtonMedium)
                .foregroundColor(.labelAlternative)
                .disabled(store.isSaving)
            }

            if isFooterCompacted, store.currentStep.previous != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("이전") {
                        store.send(.previousStepTapped)
                    }
                    .font(.jsButtonMedium)
                    .foregroundColor(.labelAlternative)
                    .disabled(store.isSaving)
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
        .onChange(of: store.isAlarmEnabled) { _, isEnabled in
            guard isEnabled, store.currentStep == .alarmConfirm else { return }
            let delay = reduceMotion
                ? AlarmScrollPolicy.reducedMotionDelayNanoseconds
                : AlarmScrollPolicy.expandedDelayNanoseconds
            requestAlarmPickerScroll(delayNanoseconds: delay)
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: store.toastMessage)
    }

    private var stepProgressSection: some View {
        let steps = NewTaskFeature.CreateChallengeStep.allCases
        let currentIndex = store.currentStep.rawValue + 1

        return RedesignSectionCard(
            title: "단계 \(currentIndex)/\(steps.count)",
            subtitle: store.currentStep.title
        ) {
            VStack(alignment: .leading, spacing: .jsSM) {
                HStack(spacing: .jsXS) {
                    ForEach(steps, id: \.rawValue) { step in
                        Capsule()
                            .fill(step.rawValue <= store.currentStep.rawValue ? Color.primaryNormal : Color.backgroundStrong)
                            .frame(maxWidth: .infinity)
                            .frame(height: 6.jsScaled())
                    }
                }

                Text(store.currentStep.description)
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
                    text: $store.title
                )

                Text("\(store.title.count)/\(TextInputFieldPolicy.title.maxLength)")
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
                        store.stageType = stageType(for: selected)
                    }
                } else {
                    store.stageType = stageType(for: selected)
                }
            }

            Text("선택된 기간: \(store.stageType.durationDays)일")
                .font(.jsBodySmall)
                .foregroundColor(.labelAlternative)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var photoSection: some View {
        let photoHeight: CGFloat = 232.jsScaled()
        let cardShape = RoundedRectangle(cornerRadius: .jsRadiusLG, style: .continuous)

        return RedesignSectionCard(
            title: "대표 사진",
            subtitle: "카드에 노출될 대표 이미지를 설정해요"
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

                            Text("대표 사진을 추가해 주세요")
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

                        Text(hasImage ? "대표 사진 변경" : "대표 사진 선택")
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

    private var challengeSummarySection: some View {
        RedesignSectionCard(
            title: "작심 확인",
            subtitle: "아래 내용으로 챌린지를 시작해요"
        ) {
            VStack(spacing: .jsSM) {
                summaryRow(
                    title: "제목",
                    value: store.trimmedTitle.isEmpty ? "미입력" : store.trimmedTitle
                )
                summaryRow(
                    title: "기간",
                    value: "\(store.stageType.durationDays)일"
                )
                summaryRow(
                    title: "대표사진",
                    value: store.image == nil ? "미선택" : "선택됨"
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
            Toggle("알림 받기", isOn: $store.isAlarmEnabled)
                .font(.jsBodyMedium)

            if store.isAlarmEnabled {
                DatePicker(
                    "시간 선택",
                    selection: $store.alarmDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .id(ScrollTarget.alarmPicker)
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.24), value: store.isAlarmEnabled)
    }

    private var buttonSection: some View {
        VStack(spacing: FooterLayout.primarySecondarySpacing) {
            ZStack {
                JSButton(
                    title: primaryButtonTitle,
                    style: .primary,
                    size: .large,
                    isEnabled: isPrimaryButtonEnabled
                ) {
                    primaryButtonTapped()
                }

                if store.isSaving && store.currentStep == .alarmConfirm {
                    JSProgressIndicator(size: .small, tintColor: .white)
                }
            }

            if !isFooterCompacted {
                HStack(spacing: FooterLayout.secondarySpacing) {
                    if store.currentStep.previous != nil {
                        JSButton(
                            title: "이전",
                            style: .secondary,
                            size: .medium,
                            isEnabled: !store.isSaving
                        ) {
                            store.send(.previousStepTapped)
                        }
                    }

                    JSButton(
                        title: "취소",
                        style: .secondary,
                        size: .medium,
                        isEnabled: !store.isSaving
                    ) {
                        store.send(.cancelButtonTapped)
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, FooterLayout.horizontalPadding)
        .padding(.top, isFooterCompacted ? FooterLayout.compactTopPadding : FooterLayout.expandedTopPadding)
        .padding(.bottom, isFooterCompacted ? FooterLayout.compactBottomPadding : FooterLayout.expandedBottomPadding)
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
            .frame(height: isFooterCompacted ? FooterLayout.compactTopFadeHeight : FooterLayout.expandedTopFadeHeight)
            .offset(y: -(isFooterCompacted ? FooterLayout.compactTopFadeHeight : FooterLayout.expandedTopFadeHeight))
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
        let baseInset = isFooterCompacted ? FooterLayout.compactContentBottomInset : FooterLayout.expandedContentBottomInset
        guard store.currentStep == .alarmConfirm, store.isAlarmEnabled else { return baseInset }
        // Extra inset so DatePicker can settle fully above sticky footer.
        return baseInset + 96.jsScaled()
    }

    private var toastBottomPadding: CGFloat {
        isFooterCompacted ? FooterLayout.compactToastBottomPadding : FooterLayout.expandedToastBottomPadding
    }

    private var primaryButtonTitle: String {
        switch store.currentStep {
        case .basicInfo, .photo:
            return "다음"
        case .alarmConfirm:
            return "챌린지 시작"
        }
    }

    private var isPrimaryButtonEnabled: Bool {
        guard !store.isSaving else { return false }

        switch store.currentStep {
        case .basicInfo, .photo:
            return store.canProceedCurrentStep
        case .alarmConfirm:
            return store.canSubmit
        }
    }

    private func primaryButtonTapped() {
        switch store.currentStep {
        case .basicInfo, .photo:
            store.send(.nextStepTapped)
        case .alarmConfirm:
            store.send(.saveButtonTapped)
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
            get: { store.stageType.durationDays },
            set: { day in
                store.stageType = stageType(for: day)
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
