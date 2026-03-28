import SwiftUI
import ComposableArchitecture
import DSKit
import Domain
import Darwin
import UIKit

@MainActor
public struct TaskDetailView: View {
    @Bindable var store: StoreOf<TaskDetailFeature>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(store: StoreOf<TaskDetailFeature>) {
        self.store = store
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

                        todayStatusSection

                        recordListSection
                            .id("recordListSection")
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
                .onChange(of: store.shouldScrollToRecords) { _, shouldScroll in
                    guard shouldScroll else { return }
                    withAnimation(.easeInOut) {
                        proxy.scrollTo("recordListSection", anchor: .top)
                    }
                    store.send(.scrollToRecordsCompleted)
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
            .background(Color.backgroundNormal)
            .ignoresSafeArea(edges: .top)
        }
        .onAppear { store.send(.onAppear) }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { store.send(.backButtonTapped) }) {
                    Image(systemName: "chevron.left")
                        .font(.jsHeadlineMedium)
                        .foregroundColor(.white)
                        .frame(width: 44.jsScaled(.touchTarget), height: 44.jsScaled(.touchTarget))
                }
            }

            ToolbarItem(placement: .principal) {
                VStack(spacing: .jsMicro) {
                    Text(store.task.title)
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
                    Button(action: { store.send(.changePhotoButtonTapped) }) {
                        Label("대표 사진 변경", systemImage: "photo")
                    }

                    Button(action: { store.send(.notificationSettingsButtonTapped) }) {
                        Label("알림 설정", systemImage: "bell")
                    }

                    Button(action: { store.send(.editMemoButtonTapped) }) {
                        Label("작심 메모 편집", systemImage: "note.text")
                    }

                    Divider()

                    Button(role: .destructive, action: { store.send(.deleteButtonTapped) }) {
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
        .sheet(item: $store.scope(state: \.editTask, action: \.editTask)) { store in
            NavigationStack {
                TaskEditView(store: store)
            }
            .presentationDragIndicator(.visible)
        }
        .overlay {
            if store.isStagePopupPresented {
                StageCompletionPopupView(
                    result: store.stagePopupResult,
                    hasNextStage: store.task.stages.last?.stageType.next != nil,
                    onNextStage: { store.send(.nextStageButtonTapped) },
                    onRetry: { store.send(.retryStageButtonTapped) },
                    onDismiss: { store.send(.stagePopupDismissed) }
                )
            }
            if store.isDeleteFlowPresented {
                TaskDropoffGuardPopupView(
                    step: store.deleteFlowStep,
                    progressRate: store.stageProgress,
                    completedDays: store.task.completedDays,
                    countdown: store.deleteConfirmCountdown,
                    isDeleteEnabled: store.isDeleteConfirmEnabled,
                    onKeepGoing: { store.send(.deleteFlowKeepGoing) },
                    onProceed: { store.send(.deleteFlowProceedToFinal) },
                    onDelete: { store.send(.deleteFlowDeleteConfirmed) },
                    onDismiss: { store.send(.deleteFlowDismissed) }
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
                            colors: [Color.primaryNormal, Color.primaryStrong],
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
                Text(store.task.title)
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
                            colors: [Color.primaryNormal, Color.primaryStrong],
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
                Text(store.task.title)
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
        JSCard(style: .elevated) {
            VStack(alignment: .leading, spacing: .jsMD) {
                HStack {
                    VStack(alignment: .leading, spacing: .jsMicro) {
                        Text("\(store.currentStage?.stageType.durationDays ?? 7)일 스테이지")
                            .font(.jsHeadlineSmall)
                            .foregroundColor(.labelStrong)
                        
                        Text(stageDateRange)
                            .font(.jsBodySmall)
                            .foregroundColor(.labelAlternative)
                    }
                    
                    Spacer()
                    
                    stageStatusChip
                }
                
                VStack(alignment: .leading, spacing: .jsXS) {
                    JSProgress(
                        progress: store.stageProgress,
                        style: .linear,
                        size: .medium,
                        tintColor: progressColor
                    )
                    
                    HStack {
                        Spacer()
                        Text(store.stageProgressText)
                            .font(.jsLabelMedium)
                            .foregroundColor(.labelAlternative)
                    }
                }
            }
        }
    }

    private var stageDateRange: String {
        guard let stage = store.currentStage else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return "\(formatter.string(from: stage.startDate)) ~ \(formatter.string(from: stage.endDate))"
    }

    private var navigationStageSubtitle: String {
        "\(store.currentStage?.stageType.durationDays ?? 7)일 스테이지"
    }
    
    private var stageStatusChip: some View {
        let state: JSStatusChipState
        
        switch store.challengeState {
        case .stagePending:
            state = .pending
        case .stageSuccess:
            state = .completed
        case .stageFail:
            state = .failed
        case .habitCompleted:
            state = .completed
        }
        
        return JSStatusChip(state: state)
    }
    
    private var progressColor: Color {
        switch store.challengeState {
        case .stagePending:
            return .primaryNormal
        case .stageSuccess, .habitCompleted:
            return .positive
        case .stageFail:
            return .destructive
        }
    }
    
    private var todayStatusSection: some View {
        RedesignSectionCard(title: "오늘 상태") {
            HStack {
                Text(store.todayStatus == .certified ? "오늘 인증을 마쳤어요" : "인증을 완료하면 연속 기록이 이어져요")
                    .font(.jsBodySmall)
                    .foregroundColor(.labelAlternative)

                Spacer()

                JSStatusChip(state: todayStatusChipState)
            }
        }
    }

    private var todayStatusChipState: JSStatusChipState {
        switch store.todayStatus {
        case .notCertified:
            return .pending
        case .certified:
            return .completed
        }
    }
    
    private var recordListSection: some View {
        VStack(alignment: .leading, spacing: .jsMD) {
            Text("인증 기록")
                .font(.jsHeadlineSmall)
                .foregroundColor(.labelStrong)

            if store.dayViewData.isEmpty {
                RedesignStateBanner(
                    text: "아직 인증 기록이 없어요",
                    icon: "tray",
                    tintColor: .labelAlternative
                )
            } else {
                LazyVStack(spacing: .jsSM) {
                    ForEach(store.dayViewData) { data in
                        Button(action: {
                            store.send(.dayTapped(data.date))
                        }) {
                            DailyRecordRow(data: data)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(formattedDateForAccessibility(data.date)), \(data.isChecked ? "인증 완료" : "미인증")")
                        .accessibilityHint("해당 날짜 인증 화면으로 이동합니다")
                    }
                }
            }
        }
    }

    private func formattedDateForAccessibility(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: date)
    }

    @ViewBuilder
    private var bottomCTASection: some View {
        switch store.challengeState {
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
        switch store.challengeState {
        case .stagePending:
            return isTodayInChallengeRange && store.todayStatus == .notCertified
        case .stageSuccess, .stageFail, .habitCompleted:
            return true
        }
    }

    private var bottomCTASpacerHeight: CGFloat {
        shouldShowBottomCTA ? 140.jsScaled() : .jsXL
    }

    private var isTodayInChallengeRange: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return today >= Calendar.current.startOfDay(for: store.task.startDate)
            && today <= Calendar.current.startOfDay(for: store.task.endDate)
    }
    
    @ViewBuilder
    private var stagePendingCTA: some View {
        if isTodayInChallengeRange && store.todayStatus == .notCertified {
            JSButton(
                title: "오늘 작심 인증하러 가기",
                style: .primary,
                size: .large
            ) {
                store.send(.certifyTodayTapped)
            }
        } else {
            EmptyView()
        }
    }
    
    private var stageSuccessCTA: some View {
        VStack(spacing: .jsSM) {
            JSButton(
                title: "다음 스테이지로 넘어가기",
                style: .primary,
                size: .large
            ) {
                store.send(.nextStageButtonTapped)
            }
            
            JSButton(
                title: "성공 기록 보기",
                style: .secondary,
                size: .large
            ) {
                store.send(.viewSuccessRecordTapped)
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
                title: "스테이지 재도전",
                style: .primary,
                size: .large
            ) {
                store.send(.retryStageButtonTapped)
            }
            
            JSButton(
                title: "그대로 두기",
                style: .secondary,
                size: .large
            ) {
                store.send(.keepAsIsButtonTapped)
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
                title: "기록 돌아보기",
                style: .secondary,
                size: .large
            ) {
                store.send(.viewHistoryButtonTapped)
            }
        }
    }
    
    private func loadCoverImage() -> UIImage? {
        return store.coverImage
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
    let data: TaskDetailFeature.State.DayViewData
    
    var body: some View {
        HStack(spacing: .jsSM) {
            ZStack {
                if let image = data.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.backgroundAlternative)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.labelAlternative)
                        )
                }
            }
            .frame(width: 64.jsScaled(), height: 64.jsScaled())
            .cornerRadius(.jsRadiusSM)
            .overlay(
                RoundedRectangle(cornerRadius: .jsRadiusSM)
                    .stroke(data.isChecked ? Color.primaryNormal : Color.clear, lineWidth: 2)
            )
            
            VStack(alignment: .leading, spacing: .jsMicro) {
                Text(formattedDate(data.date))
                    .font(.jsBodyMedium)
                    .foregroundColor(.labelStrong)
                
                Text(data.memo)
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelAlternative)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if data.isChecked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.positive)
                    .font(.jsDisplaySmall)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.labelDisable)
                    .font(.jsDisplaySmall)
            }
        }
        .padding(.jsSM)
        .background(Color.backgroundStrong)
        .cornerRadius(.jsRadiusMD)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: date)
    }
}

private struct TaskDropoffGuardPopupView: View {
    let step: TaskDetailFeature.DeleteFlowStep
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
            Color.surfaceOverlay.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

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
    let hasNextStage: Bool
    let onNextStage: () -> Void
    let onRetry: () -> Void
    let onDismiss: () -> Void

    @State private var animate = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.surfaceOverlay.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            JSCard(style: .elevated, padding: .jsLG) {
                VStack(spacing: .jsMD) {
                    SparkleAnimationView(animate: $animate)
                        .frame(height: 120.jsScaled())

                    Text(result == .success ? "스테이지를 완료했어요" : "이번 스테이지는 아쉬웠어요")
                        .font(.jsHeadlineSmall)
                        .foregroundColor(.labelStrong)

                    Text(result == .success ? "다음 단계로 넘어가 볼까요?" : "다음 스테이지에서 다시 도전해요")
                        .font(.jsBodySmall)
                        .foregroundColor(.labelAlternative)

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
}

private struct SparkleAnimationView: View {
    @Binding var animate: Bool

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.primaryNormal.opacity(0.8))
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
