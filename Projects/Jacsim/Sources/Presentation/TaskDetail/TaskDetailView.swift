import SwiftUI
import DSKit
import Domain
import Darwin
import UIKit

public struct TaskDetailView: View {
    @Bindable var model: TaskDetailModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(model: TaskDetailModel) {
        self.model = model
    }

    @State private var scrollOffset: CGFloat = 0
    @State private var isHeaderMinimized = false
    private let minHeaderHeight: CGFloat = 100.jsScaled()

    public var body: some View {
        GeometryReader { geometry in
            let topSafeArea = geometry.safeAreaInsets.top
            let coverImageWidth = geometry.size.width
            let coverImageHeight = coverImageWidth
            let minimizedHeaderHeight = minHeaderHeight + topSafeArea
            let revealRange = reduceMotion ? 1 : max(1, 32.jsScaled())
            let coverRevealDistance = coverImageHeight - minimizedHeaderHeight - scrollOffset
            let revealProgress = min(max(coverRevealDistance / revealRange, 0), 1)
            let coverImageVisibleHeight = max(minimizedHeaderHeight, coverImageHeight - scrollOffset)
            let shouldMinimizeHeaderTitle = revealProgress < 0.15

            ZStack(alignment: .top) {
                ZStack(alignment: .top) {
                    coverImageBackground
                        .frame(width: coverImageWidth, height: coverImageVisibleHeight)
                        .clipped()
                        .opacity(revealProgress)

                    LinearGradient(
                        colors: [
                            Color.backgroundNormal.opacity(0.92),
                            Color.backgroundNormal.opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: coverImageWidth, height: coverImageVisibleHeight)
                    .opacity(1 - revealProgress)
                    .allowsHitTesting(false)

                    let minOffset = coverImageHeight - minimizedHeaderHeight
                    let offsetY = scrollOffset <= 0 ? -scrollOffset : scrollOffset <= minOffset ? -scrollOffset : -minOffset

                    coverImageContent
                        .frame(width: coverImageWidth, height: coverImageHeight)
                        .opacity(revealProgress)
                        .offset(y: offsetY + (1 - revealProgress) * 6.jsScaled())
                }
                .frame(width: coverImageWidth, height: coverImageVisibleHeight, alignment: .top)
                .clipped()

                ScrollViewReader { proxy in
                    ScrollView {
                        Color.clear
                            .frame(width: coverImageWidth, height: coverImageHeight)

                    VStack(spacing: .jsLG) {
                        stageInfoSection

                        if PresentationRedesignFlags.isSectionEnabled(.taskDetailTodayStatus) {
                            todayStatusSection
                        }

                        if PresentationRedesignFlags.isSectionEnabled(.taskDetailRecordList) {
                            recordListSection
                                .id("recordListSection")
                        }
                    }
                    .padding(.top, .jsLG)
                    .padding(.horizontal, .jsMD)

                    Spacer(minLength: bottomCTASpacerHeight)
                }
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y + geometry.contentInsets.top
                } action: { _, new in
                    scrollOffset = new
                }
                .onChange(of: model.shouldScrollToRecords) { _, shouldScroll in
                    guard shouldScroll else { return }
                    withAnimation(.easeInOut) {
                        proxy.scrollTo("recordListSection", anchor: .top)
                    }
                    model.scrollToRecordsCompleted()
                }
            }

            if shouldShowBottomCTA {
                bottomCTASection
                    .padding(.horizontal, .jsMD)
                    .padding(.bottom, .jsMD)
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
                        .frame(height: 140.jsScaled())
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    )
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
            }
            .onChange(of: shouldMinimizeHeaderTitle) { _, newValue in
                guard isHeaderMinimized != newValue else { return }
                isHeaderMinimized = newValue
            }
            .onAppear {
                isHeaderMinimized = shouldMinimizeHeaderTitle
            }
            .background(Color.v2Background)
            .ignoresSafeArea(edges: .top)
        }
        .onAppear { model.onAppear() }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { model.backButtonTapped() }) {
                    Image(systemName: "chevron.left")
                        .font(.jsHeadlineMedium)
                        .foregroundColor(.white)
                        .frame(width: 44.jsScaled(.touchTarget), height: 44.jsScaled(.touchTarget))
                }
            }

            ToolbarItem(placement: .principal) {
                VStack(spacing: .jsMicro) {
                    Text(model.task.title)
                        .font(.jsHeadlineSmall)
                        .foregroundColor(.labelStrong)
                        .lineLimit(1)

                    Text(navigationStageSubtitle)
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelAlternative)
                        .lineLimit(1)
                }
                .opacity(isHeaderMinimized ? 1 : 0)
                .animation(.easeOut(duration: 0.12), value: isHeaderMinimized)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { model.changePhotoButtonTapped() }) {
                        Label("대표 사진 변경", systemImage: "photo")
                    }

                    Button(action: { model.notificationSettingsButtonTapped() }) {
                        Label("알림 설정", systemImage: "bell")
                    }

                    Button(action: { model.editMemoButtonTapped() }) {
                        Label("작심 메모 편집", systemImage: "note.text")
                    }

                    Divider()

                    Button(role: .destructive, action: { model.deleteButtonTapped() }) {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.jsHeadlineMedium)
                        .foregroundColor(.white)
                        .frame(width: 44.jsScaled(.touchTarget), height: 44.jsScaled(.touchTarget))
                }
            }
        }
        .background(InteractivePopGestureEnabler())
        .sheet(item: $model.editTask) { editModel in
            NavigationStack {
                TaskEditView(model: editModel)
            }
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(true)
        }
        .overlay {
            if model.isStagePopupPresented {
                StageCompletionPopupView(
                    result: model.stagePopupResult,
                    completedDays: stagePopupCompletedDays,
                    totalDays: stagePopupTotalDays,
                    recordImages: stagePopupRecordImages,
                    hasNextStage: model.task.stages.last?.stageType.next != nil,
                    onNextStage: { model.nextStageButtonTapped() },
                    onRetry: { model.retryStageButtonTapped() },
                    onDismiss: { model.stagePopupDismissed() }
                )
            }
            if model.isDeleteFlowPresented {
                TaskDropoffGuardPopupView(
                    step: model.deleteFlowStep,
                    progressRate: model.stageProgress,
                    completedDays: model.task.completedDays,
                    countdown: model.deleteConfirmCountdown,
                    isDeleteEnabled: model.isDeleteConfirmEnabled,
                    onKeepGoing: { model.deleteFlowKeepGoing() },
                    onProceed: { model.deleteFlowProceedToFinal() },
                    onDelete: { model.deleteFlowDeleteConfirmed() },
                    onDismiss: { model.deleteFlowDismissed() }
                )
            }
        }
    }

    private var coverImageBackground: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = loadCoverImage() {
                Image(uiImage: image)
                    .interpolation(.high)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.v2BrandBlue, Color.v2BrandBlueStrong],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
    }

    private var coverImageContent: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color.surfaceOverlay.opacity(0),
                    Color.surfaceOverlay.opacity(0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: .jsXS) {
                Text(model.task.title)
                    .font(.jsDisplaySmall)
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .padding(.jsMD)
            .padding(.bottom, .jsSM)
        }
    }

    private var coverImageSection: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = loadCoverImage() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280.jsScaled())
                    .clipped()
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.v2BrandBlue, Color.v2BrandBlueStrong],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 280.jsScaled())
            }

            LinearGradient(
                colors: [
                    Color.surfaceOverlay.opacity(0),
                    Color.surfaceOverlay.opacity(0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280.jsScaled())

            VStack(alignment: .leading, spacing: .jsXS) {
                Text(model.task.title)
                    .font(.jsDisplaySmall)
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .padding(.jsMD)
            .padding(.bottom, .jsSM)
        }
        .frame(height: 280.jsScaled())
    }
    
    private var stageInfoSection: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            HStack(alignment: .center) {
                JSV2SectionHeader("작심 프로필")
                stageStatusChip
            }

            HStack(spacing: .jsSM) {
                JSV2MetricPill(
                    title: "진행",
                    value: "\(Int(model.stageProgress * 100))%",
                    systemImage: "chart.line.uptrend.xyaxis",
                    style: statusStyle
                )
                JSV2MetricPill(
                    title: "인증",
                    value: model.stageProgressText,
                    systemImage: "checkmark.circle.fill",
                    style: .success
                )
                JSV2MetricPill(
                    title: "기간",
                    value: stageDateRange,
                    systemImage: "calendar",
                    style: .neutral
                )
            }

            JSProgress(
                progress: model.stageProgress,
                style: .linear,
                size: .medium,
                tintColor: progressColor
            )
            .accessibilityLabel("스테이지 진행률 \(Int(model.stageProgress * 100))퍼센트")
        }
        .padding(.jsMD)
        .jsv2CardSurface()
    }

    private var stageDateRange: String {
        guard let stage = model.currentStage else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return "\(formatter.string(from: stage.startDate)) ~ \(formatter.string(from: stage.endDate))"
    }

    private var navigationStageSubtitle: String {
        "\(model.currentStage?.stageType.durationDays ?? 7)일 스테이지"
    }
    
    private var stageStatusChip: some View {
        let state: JSStatusChipState
        
        switch model.challengeState {
        case .stagePending:
            state = .pending
        case .stageSuccess:
            state = .completed
        case .stageFail:
            state = .failed
        case .habitCompleted:
            state = .completed
        }
        
        switch state {
        case .completed:
            return JSV2StatusChip("완료", systemImage: "checkmark.circle.fill", style: .success)
        case .pending:
            return JSV2StatusChip("진행 중", systemImage: "clock.fill", style: .accent)
        case .failed:
            return JSV2StatusChip("재도전", systemImage: "arrow.counterclockwise", style: .danger)
        case .notStarted:
            return JSV2StatusChip("시작 전", systemImage: "circle", style: .neutral)
        }
    }

    private var statusStyle: JSV2StatusStyle {
        switch model.challengeState {
        case .stagePending:
            return .accent
        case .stageSuccess, .habitCompleted:
            return .success
        case .stageFail:
            return .danger
        }
    }
    
    private var progressColor: Color {
        switch model.challengeState {
        case .stagePending:
            return .v2BrandBlue
        case .stageSuccess, .habitCompleted:
            return .positive
        case .stageFail:
            return .destructive
        }
    }
    
    private var todayStatusSection: some View {
        HStack(spacing: .jsSM) {
            VStack(alignment: .leading, spacing: .jsMicro) {
                Text("오늘")
                    .font(.jsHeadlineSmall)
                    .foregroundColor(.labelStrong)

                Text(model.todayStatus == .certified ? "인증 완료" : "바로 인증 가능")
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelAlternative)
            }

            Spacer()

            JSV2StatusChip(
                model.todayStatus == .certified ? "완료" : "인증 전",
                systemImage: model.todayStatus == .certified ? "checkmark.circle.fill" : "camera.fill",
                style: model.todayStatus == .certified ? .success : .accent,
                isProminent: model.todayStatus != .certified
            )
        }
        .padding(.jsMD)
        .jsv2CardSurface()
        .accessibilityElement(children: .combine)
    }
    
    private var recordListSection: some View {
        VStack(alignment: .leading, spacing: .jsMD) {
            JSV2SectionHeader("기록 피드")

            if model.dayViewData.isEmpty {
                RedesignStateBanner(
                    text: "아직 기록이 없어요",
                    icon: "tray",
                    tintColor: .labelAlternative
                )
            } else {
                LazyVStack(spacing: .jsSM) {
                    ForEach(model.dayViewData) { data in
                        DailyRecordRow(data: data)
                            .onTapGesture {
                                model.dayTapped(data.date)
                            }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var bottomCTASection: some View {
        switch model.challengeState {
        case .stagePending:
            stagePendingCTA
        case .stageSuccess:
            stageSuccessCTA
        case .stageFail:
            stageFailCTA
        case .habitCompleted:
            habitCompletedCTA
        }
    }

    private var shouldShowBottomCTA: Bool {
        switch model.challengeState {
        case .stagePending:
            return isTodayInChallengeRange && model.todayStatus == .notCertified
        case .stageSuccess, .stageFail, .habitCompleted:
            return true
        }
    }

    private var bottomCTASpacerHeight: CGFloat {
        shouldShowBottomCTA ? 140.jsScaled() : .jsXL
    }

    private var stagePopupCompletedDays: Int {
        model.dayViewData
            .filter { isDateInCurrentStage($0.date) }
            .filter(\.isChecked)
            .count
    }

    private var stagePopupTotalDays: Int {
        model.currentStage?.durationDays ?? max(model.dayViewData.count, 1)
    }

    private var stagePopupRecordImages: [UIImage] {
        Array(
            model.dayViewData.lazy
                .filter { isDateInCurrentStage($0.date) }
                .filter(\.isChecked)
                .compactMap(\.image)
                .prefix(3)
        )
    }

    private func isDateInCurrentStage(_ date: Date) -> Bool {
        guard let stage = model.currentStage else { return true }
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        return day >= calendar.startOfDay(for: stage.startDate)
            && day <= calendar.startOfDay(for: stage.endDate)
    }

    private var isTodayInChallengeRange: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return today >= Calendar.current.startOfDay(for: model.task.startDate)
            && today <= Calendar.current.startOfDay(for: model.task.endDate)
    }
    
    @ViewBuilder
    private var stagePendingCTA: some View {
        if isTodayInChallengeRange && model.todayStatus == .notCertified {
            JSButton(
                title: "인증하기",
                systemImage: "camera.fill",
                style: .primary,
                size: .large
            ) {
                model.certifyTodayTapped()
            }
        } else {
            EmptyView()
        }
    }
    
    private var stageSuccessCTA: some View {
        VStack(spacing: .jsSM) {
            JSButton(
                title: "다음 단계",
                systemImage: "arrow.forward.circle.fill",
                style: .primary,
                size: .large
            ) {
                model.nextStageButtonTapped()
            }

            JSButton(
                title: "기록 보기",
                systemImage: "list.bullet.rectangle",
                style: .ghost,
                size: .large
            ) {
                model.viewSuccessRecordTapped()
            }
        }
    }
    
    private var stageFailCTA: some View {
        VStack(spacing: .jsSM) {
            Text("괜찮아요. 다시 시작할 수 있어요")
                .font(.jsBodySmall)
                .foregroundColor(.labelAlternative)
                .frame(maxWidth: .infinity, alignment: .center)
            
            JSButton(
                title: "재도전",
                systemImage: "arrow.counterclockwise.circle.fill",
                style: .primary,
                size: .large
            ) {
                model.retryStageButtonTapped()
            }
            
            JSButton(
                title: "그대로 두기",
                style: .ghost,
                size: .large
            ) {
                model.keepAsIsButtonTapped()
            }
        }
    }
    
    private var habitCompletedCTA: some View {
        VStack(spacing: .jsSM) {
            Text("30일을 완주했어요. 이제 습관이 되었어요")
                .font(.jsBodySmall)
                .foregroundColor(.labelAlternative)
                .frame(maxWidth: .infinity, alignment: .center)
            
            JSButton(
                title: "기록 보기",
                systemImage: "list.bullet.rectangle",
                style: .ghost,
                size: .large
            ) {
                model.viewHistoryButtonTapped()
            }
        }
    }
    
    private func loadCoverImage() -> UIImage? {
        return model.coverImage
    }
}

private struct InteractivePopGestureEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        Controller()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        (uiViewController as? Controller)?.enableSwipeBack()
    }

    private final class Controller: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            enableSwipeBack()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            enableSwipeBack()
        }

        func enableSwipeBack() {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
    }
}

private struct DailyRecordRow: View {
    let data: TaskDetailModel.DayViewData
    
    var body: some View {
        HStack(spacing: .jsSM) {
            ZStack {
                if let image = data.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: .jsRadiusLG, style: .continuous)
                        .fill(Color.v2Surface)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.jsHeadlineMedium)
                                .foregroundColor(.labelAlternative)
                        )
                }
            }
            .frame(width: 92.jsScaled(), height: 92.jsScaled())
            .clipShape(RoundedRectangle(cornerRadius: .jsRadiusLG, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: .jsRadiusLG, style: .continuous)
                    .stroke(data.isChecked ? Color.v2BrandBlue.opacity(0.35) : Color.labelAssistive.opacity(0.16), lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing: .jsXS) {
                JSV2StatusChip(
                    data.isChecked ? "인증" : "대기",
                    systemImage: data.isChecked ? "checkmark.circle.fill" : "circle",
                    style: data.isChecked ? .success : .neutral
                )

                Text(formattedDate(data.date))
                    .font(.jsBodyMedium)
                    .foregroundColor(.labelStrong)
                    .lineLimit(1)

                if !data.memo.isEmpty {
                    Text(data.memo)
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelAlternative)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(.jsSM)
        .jsv2CardSurface(cornerRadius: .jsRadiusLG, shadowOpacity: 0.04)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(formattedDate(data.date)), \(data.isChecked ? "인증 완료" : "인증 전")")
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: date)
    }
}

private struct TaskDropoffGuardPopupView: View {
    let step: TaskDetailModel.DeleteFlowStep
    let progressRate: Double
    let completedDays: Int
    let countdown: Int
    let isDeleteEnabled: Bool
    let onKeepGoing: () -> Void
    let onProceed: () -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showPopup = false

    var body: some View {
        ZStack {
            PopupBackdrop(opacity: 0.5)

            JSCard(style: .elevated, padding: .jsLG) {
                VStack(spacing: .jsMD) {
                    Image(systemName: step == .firstGuard ? "flame.fill" : "exclamationmark.triangle.fill")
                        .font(.jsDisplayMedium)
                        .foregroundColor(step == .firstGuard ? .cautionary : .destructive)
                        .frame(width: 56.jsScaled(), height: 56.jsScaled())
                        .background(
                            Circle()
                                .fill((step == .firstGuard ? Color.cautionary : Color.destructive).opacity(0.16))
                        )

                    Text(step == .firstGuard ? "여기서 멈추기엔 아까워요" : "정말 끝낼까요?")
                        .font(.jsHeadlineSmall)
                        .foregroundColor(.labelStrong)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.jsBodySmall)
                        .foregroundColor(.labelAlternative)
                        .multilineTextAlignment(.center)

                    if step == .firstGuard {
                        HStack(spacing: .jsSM) {
                            metricPill(title: "진행률", value: "\(Int(progressRate * 100))%")
                            metricPill(title: "완료 일수", value: "\(completedDays)일")
                        }
                    }

                    VStack(spacing: .jsSM) {
                        JSButton(
                            title: "계속 도전하기",
                            style: .primary,
                            size: .large
                        ) {
                            onKeepGoing()
                        }

                        if step == .firstGuard {
                            JSButton(
                                title: "그래도 그만둘래요",
                                style: .secondary,
                                size: .large
                            ) {
                                onProceed()
                            }
                        } else {
                            JSButton(
                                title: isDeleteEnabled ? "삭제" : "삭제 (\(max(0, countdown)))",
                                style: .destructive,
                                size: .large,
                                isEnabled: isDeleteEnabled
                            ) {
                                onDelete()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, .jsLG)
            .scaleEffect(reduceMotion ? 1 : (showPopup ? 1 : 0.96))
            .opacity(showPopup ? 1 : 0)
        }
        .onAppear {
            if reduceMotion {
                showPopup = true
            } else {
                withAnimation(.easeOut(duration: 0.24)) {
                    showPopup = true
                }
            }
        }
    }

    private var subtitle: String {
        switch step {
        case .firstGuard:
            return "지금까지 만든 기록이 사라져요.\n한 번만 더 고민해봐요."
        case .finalConfirmation:
            if isDeleteEnabled {
                return "모든 인증 기록과 사진이 삭제되며,\n이 작업은 되돌릴 수 없어요."
            }
            return "삭제 버튼은 \(max(0, countdown))초 후에 활성화돼요.\n정말 삭제할지 마지막으로 확인해 주세요."
        }
    }

    private func metricPill(title: String, value: String) -> some View {
        VStack(spacing: .jsMicro) {
            Text(title)
                .font(.jsLabelSmall)
                .foregroundColor(.labelAlternative)
            Text(value)
                .font(.jsHeadlineSmall)
                .foregroundColor(.labelStrong)
        }
        .frame(maxWidth: .infinity, minHeight: 68.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(Color.backgroundStrong)
        )
    }
}

private struct StageCompletionPopupView: View {
    let result: StageResult
    let completedDays: Int
    let totalDays: Int
    let recordImages: [UIImage]
    let hasNextStage: Bool
    let onNextStage: () -> Void
    let onRetry: () -> Void
    let onDismiss: () -> Void

    @State private var animate = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            PopupBackdrop(opacity: 0.45)

            JSCard(style: .elevated, padding: .jsLG) {
                VStack(spacing: .jsMD) {
                    SparkleAnimationView(animate: $animate)
                        .frame(height: 120.jsScaled())

                    Text(result == .success ? "스테이지를 완료했어요" : "이번 스테이지는 아쉬웠어요")
                        .font(.jsHeadlineSmall)
                        .foregroundColor(.labelStrong)
                        .multilineTextAlignment(.center)

                    Text(result == .success ? "다음 단계로 넘어가 볼까요?" : "다음 스테이지에서 다시 도전해요")
                        .font(.jsBodySmall)
                        .foregroundColor(.labelAlternative)
                        .multilineTextAlignment(.center)

                    stageSummary

                    if result == .fail {
                        JSButton(
                            title: "다시 시도",
                            style: .secondary,
                            size: .large
                        ) {
                            onRetry()
                        }
                    }

                    JSButton(
                        title: result == .success && hasNextStage ? "다음 단계 시작" : "확인",
                        style: .primary,
                        size: .large
                    ) {
                        if result == .success && hasNextStage {
                            onNextStage()
                        } else {
                            onDismiss()
                        }
                    }
                }
            }
            .padding(.horizontal, .jsLG)
        }
        .onAppear {
            if reduceMotion {
                animate = false
            } else {
                withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
        }
    }

    private var stageSummary: some View {
        VStack(spacing: .jsSM) {
            HStack(spacing: .jsSM) {
                stageMetric(title: "인증", value: "\(completedDays)/\(totalDays)일")
                stageMetric(title: "결과", value: result == .success ? "성공" : "재도전")
            }

            if !recordImages.isEmpty {
                HStack(spacing: .jsXS) {
                    ForEach(Array(recordImages.enumerated()), id: \.offset) { _, image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 72.jsScaled())
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                                    .stroke(Color.labelDisable.opacity(0.18), lineWidth: 1)
                            )
                    }
                }
                .accessibilityLabel("최근 인증 사진")
            }
        }
        .padding(.jsSM)
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                .fill(Color.backgroundStrong)
        )
    }

    private func stageMetric(title: String, value: String) -> some View {
        VStack(spacing: .jsMicro) {
            Text(title)
                .font(.jsLabelSmall)
                .foregroundColor(.labelAlternative)
            Text(value)
                .font(.jsHeadlineSmall)
                .foregroundColor(result == .success ? .positive : .cautionary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct PopupBackdrop: View {
    let opacity: Double

    var body: some View {
        Color.surfaceOverlay.opacity(opacity)
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture { }
            .accessibilityHidden(true)
    }
}

private struct SparkleAnimationView: View {
    @Binding var animate: Bool

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.v2BrandBlue.opacity(0.8))
                    .frame(width: 10.jsScaled(), height: 10.jsScaled())
                    .offset(sparkleOffset(for: index))
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 1.6 : 0.3)
            }
        }
    }

    private func sparkleOffset(for index: Int) -> CGSize {
        let angle = Double(index) * (Double.pi / 4)
        let radius: CGFloat = animate ? 60.jsScaled() : 10.jsScaled()
        return CGSize(width: Darwin.cos(angle) * radius, height: Darwin.sin(angle) * radius)
    }
}
