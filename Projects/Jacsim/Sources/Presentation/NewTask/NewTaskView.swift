import SwiftUI
import ComposableArchitecture
import DesignSystem
import Domain
import PhotosUI
import _Concurrency

@MainActor
public struct NewTaskView: View {
    private enum ScrollTarget: Hashable {
        case titleSection
    }

    @Bindable var store: StoreOf<NewTaskFeature>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var keyboardObserver = KeyboardObserver()
    @FocusState private var isTitleFieldFocused: Bool
    @State private var scrollTargetID: ScrollTarget?
    @State private var scrollRequestToken = 0
    @State private var scrollAnimation: Animation? = JSAnimation.navigation

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

    public init(store: StoreOf<NewTaskFeature>) {
        self.store = store
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "새 작심 만들기",
            subtitle: screenSubtitle,
            contentBottomInset: contentBottomInset,
            scrollToID: scrollTargetID,
            scrollAnchor: .center,
            scrollRequestToken: scrollRequestToken,
            scrollAnimation: scrollAnimation,
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
                photoSection
            case .alarmConfirm:
                challengeSummarySection
                alarmSection
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(store.hasUnsavedChanges || store.isSaving)
        .alert($store.scope(state: \.alert, action: \.alert))
        .overlay(alignment: .bottom) {
            if let message = store.toastMessage {
                RedesignToastView(
                    message: message,
                    style: .error,
                    bottomPadding: toastBottomPadding,
                    dismissAction: { store.send(.toastDismissed) }
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
                .foregroundColor(.labelNeutral)
                .disabled(store.isSaving)
            }

            if isFooterCompacted, store.currentStep.previous != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("이전") {
                        store.send(.previousStepTapped)
                    }
                    .font(.jsButtonMedium)
                    .foregroundColor(.labelNeutral)
                    .disabled(store.isSaving)
                }
            }
        }
        .onChange(of: isTitleFieldFocused) { _, isFocused in
            guard store.currentStep == .basicInfo else { return }

            if isFocused {
                requestScroll(to: .titleSection, duration: keyboardObserver.context.animationDuration)
            } else {
                clearInputScrollRequest()
            }
        }
        .onChange(of: keyboardObserver.context) { _, context in
            guard store.currentStep == .basicInfo else { return }
            guard isTitleFieldFocused, context.isVisible else { return }

            requestScroll(to: .titleSection, duration: context.animationDuration)
        }
        .onChange(of: store.currentStep) { _, step in
            guard step != .basicInfo else { return }
            isTitleFieldFocused = false
            clearInputScrollRequest()
        }
        .animation(reduceMotion ? .none : JSAnimation.toast, value: store.toastMessage)
        .animation(
            reduceMotion ? .none : .easeInOut(duration: keyboardObserver.context.animationDuration),
            value: keyboardObserver.context.isVisible
        )
    }

    private var stepProgressSection: some View {
        let steps = NewTaskFeature.CreateChallengeStep.allCases
        let currentIndex = store.currentStep.rawValue + 1

        return RedesignSectionCard(
            title: "진행 \(currentIndex)/\(steps.count)",
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

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .jsXS) {
                        ForEach(steps, id: \.rawValue) { step in
                            stepBadge(step)
                        }
                    }
                }

                HStack(spacing: .jsMicro) {
                    Image(systemName: store.currentStep.next == nil ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                        .font(.jsLabelMedium)
                        .foregroundColor(store.currentStep.next == nil ? .positive : .primaryNormal)

                    Text(stepProgressCaption)
                        .font(.jsLabelLarge)
                        .foregroundColor(.labelNeutral)
                }
            }
        }
    }

    private var titleSection: some View {
        RedesignSectionCard(
            title: "제목",
            subtitle: "짧고 분명하게 적어 주세요"
        ) {
            VStack(alignment: .trailing, spacing: .jsXS) {
                JSInputField(
                    title: "작심 제목",
                    placeholder: "예: 매일 10분 독서",
                    text: $store.title,
                    accessibilityLabel: "작심 제목",
                    focus: $isTitleFieldFocused
                )

                Text("\(store.title.count)/\(TextInputFieldPolicy.title.maxLength)")
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelNeutral)

                Text(titleHelperText)
                    .font(.jsLabelSmall)
                    .foregroundColor(.labelNeutral)
            }
        }
        .id(ScrollTarget.titleSection)
    }

    private var stageSection: some View {
        RedesignSectionCard(
            title: "스테이지",
            subtitle: "이어갈 기간을 고르세요"
        ) {
            JSStageSelector(
                selectedStage: stageDayBinding,
                stages: [3, 7, 15, 30]
            ) { selected in
                if !reduceMotion {
                    withAnimation(JSAnimation.navigation) {
                        store.stageType = stageType(for: selected)
                    }
                } else {
                    store.stageType = stageType(for: selected)
                }
            }

            Text("총 \(store.stageType.durationDays)일 동안 진행")
                .font(.jsBodySmall)
                .foregroundColor(.labelNeutral)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var photoSection: some View {
        let photoHeight: CGFloat = 232.jsScaled()
        let cardShape = RoundedRectangle(cornerRadius: .jsRadiusLG, style: .continuous)

        return RedesignSectionCard(
            title: "대표 사진",
            subtitle: "카드에 보일 사진 한 장"
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

                            Text("비율은 자동으로 조정돼요")
                                .font(.jsLabelMedium)
                                .foregroundColor(.labelNeutral)
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

                            Text("선택 완료")
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
                            .foregroundColor(.labelNeutral)
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
                .accessibilityLabel(hasImage ? "대표 사진 변경" : "대표 사진 선택")
                .accessibilityHint("사진 보관함에서 작심 대표 사진을 고릅니다")
                .onChange(of: store.photoPickerItem) { _, newItem in
                    store.send(.photoPickerItemChanged(newItem))
                }
            }
        }
    }

    private var challengeSummarySection: some View {
        RedesignSectionCard(
            title: "시작 전 확인",
            subtitle: "입력한 내용만 빠르게 확인해요"
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
                    value: store.image == nil ? "미선택" : "선택 완료"
                )
            }
        }
    }

    private func summaryRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: .jsSM) {
            Text(title)
                .font(.jsLabelMedium)
                .foregroundColor(.labelNeutral)
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
            subtitle: "선택한 시간에 오늘 포커스 작심 한 개를 리마인드해요"
        ) {
            Toggle("리마인드 받기", isOn: $store.isAlarmEnabled)
                .font(.jsBodyMedium)
                .accessibilityHint("매일 같은 시간에 인증 알림을 받도록 설정합니다")

            if store.isAlarmEnabled {
                DatePicker(
                    "리마인드 시간",
                    selection: $store.alarmDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .accessibilityHint("받고 싶은 알림 시간을 고릅니다")

                Text("권한이 허용되면 가장 먼저 챙길 작심 기준으로 하루 1건만 보내드려요")
                    .font(.jsLabelSmall)
                    .foregroundColor(.labelAlternative)
            }
        }
        .animation(reduceMotion ? .none : JSAnimation.navigation, value: store.isAlarmEnabled)
    }

    private var buttonSection: some View {
        VStack(spacing: FooterLayout.primarySecondarySpacing) {
            if let disabledReason = primaryButtonDisabledReason {
                disabledReasonBanner(text: disabledReason)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

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
        keyboardObserver.context.isVisible
    }

    private var contentBottomInset: CGFloat {
        isFooterCompacted ? FooterLayout.compactContentBottomInset : FooterLayout.expandedContentBottomInset
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

    private var primaryButtonDisabledReason: String? {
        guard !store.isSaving, !isPrimaryButtonEnabled else { return nil }

        switch store.currentStep {
        case .basicInfo:
            return "제목을 입력해 주세요."
        case .photo:
            return "대표 사진을 선택해 주세요."
        case .alarmConfirm:
            return "제목과 대표 사진을 확인해 주세요."
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

    private func disabledReasonBanner(text: String) -> some View {
        RedesignStateBanner(
            text: text,
            icon: "info.circle.fill",
            tintColor: .primaryNormal
        )
        .accessibilityLabel(text)
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

    private func requestScroll(to target: ScrollTarget, duration: Double) {
        scrollTargetID = target
        scrollAnimation = reduceMotion ? nil : .easeInOut(duration: max(duration, 0.18))
        scrollRequestToken += 1
    }

    private func clearInputScrollRequest() {
        scrollTargetID = nil
    }

    private var screenSubtitle: String {
        switch store.currentStep {
        case .basicInfo:
            return "핵심 정보만 정하면 바로 다음 단계로 넘어가요"
        case .photo:
            return "대표 사진 한 장만 고르면 준비가 거의 끝나요"
        case .alarmConfirm:
            return "마지막 설정을 확인하고 바로 시작해요"
        }
    }

    private var stepProgressCaption: String {
        if let nextStep = store.currentStep.next {
            return "다음은 \(nextStep.title) 단계예요"
        }
        return "이제 시작만 남았어요"
    }

    private var titleHelperText: String {
        if store.trimmedTitle.isEmpty {
            return "저장 후에는 제목을 바꿀 수 없어요"
        }
        return "앞뒤 공백은 자동으로 정리돼요"
    }

    private func stepBadge(_ step: NewTaskFeature.CreateChallengeStep) -> some View {
        let isCurrent = step == store.currentStep
        let isComplete = step.rawValue < store.currentStep.rawValue

        return HStack(spacing: .jsMicro) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : (isCurrent ? "circle.fill" : "circle"))
                .font(.jsLabelMedium)

            Text(step.title)
                .font(.jsLabelMedium)
                .lineLimit(1)
        }
        .foregroundColor(isCurrent || isComplete ? .labelStrong : .labelAlternative)
        .padding(.horizontal, .jsXS)
        .padding(.vertical, .jsMicro)
        .background(
            Capsule()
                .fill(isCurrent ? Color.primaryNormal.opacity(0.14) : Color.backgroundStrong)
        )
    }
}
