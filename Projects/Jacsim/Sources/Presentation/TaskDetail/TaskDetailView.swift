import SwiftUI
import ComposableArchitecture
import DesignSystem
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
                    if reduceMotion {
                        proxy.scrollTo("recordListSection", anchor: .top)
                    } else {
                        withAnimation(JSAnimation.navigation) {
                            proxy.scrollTo("recordListSection", anchor: .top)
                        }
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
        .allowsHitTesting(!store.isStagePopupPresented)
        .accessibilityHidden(store.isStagePopupPresented)
        .onAppear { store.send(.onAppear) }
        .toolbar {
            if !store.isStagePopupPresented {
                ToolbarItem(placement: .principal) {
                    TaskDetailToolbarTitle(
                        title: store.task.title,
                        subtitle: navigationStageSubtitle,
                        isVisible: isHeaderMinimized
                    )
                }

                ToolbarItem(placement: .topBarTrailing) {
                    TaskDetailToolbarMenu(
                        onChangePhoto: { store.send(.changePhotoButtonTapped) },
                        onNotificationSettings: { store.send(.notificationSettingsButtonTapped) },
                        onDelete: { store.send(.deleteButtonTapped) }
                    )
                }
            }
        }
        .sheet(item: $store.scope(state: \.editTask, action: \.editTask)) { store in
            NavigationStack {
                TaskEditView(store: store)
            }
            .presentationDragIndicator(.visible)
        }
        .alert($store.scope(state: \.deleteFailureAlert, action: \.deleteFailureAlert))
        .confirmationDialog(
            "작심을 삭제할까요?",
            isPresented: Binding(
                get: { store.isDeleteConfirmationPresented },
                set: { isPresented in
                    if !isPresented {
                        store.send(.deleteCancelled)
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button("삭제", role: .destructive) {
                store.send(.deleteConfirmed)
            }
            Button("취소", role: .cancel) {
                store.send(.deleteCancelled)
            }
        } message: {
            Text("모든 인증 기록과 사진이 함께 삭제되며 되돌릴 수 없어요.")
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
        }
    }

    private var coverImageBackground: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = store.coverImage {
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

    private var stageInfoSection: some View {
        TaskDetailStageInfoSection(
            currentStage: store.currentStage,
            challengeState: store.challengeState,
            stageProgress: store.stageProgress,
            stageProgressText: store.stageProgressText
        )
    }

    private var navigationStageSubtitle: String {
        "\(store.currentStage?.stageType.durationDays ?? 7)일 스테이지"
    }

    private var todayStatusSection: some View {
        TaskDetailTodayStatusSection(todayStatus: store.todayStatus)
    }

    private var recordListSection: some View {
        TaskDetailRecordListSection(
            dayViewData: store.dayViewData,
            onTapDay: { store.send(.dayTapped($0)) }
        )
    }

    private var bottomCTASection: some View {
        TaskDetailBottomCTASection(
            challengeState: store.challengeState,
            isTodayInChallengeRange: isTodayInChallengeRange,
            todayStatus: store.todayStatus,
            onCertifyToday: { store.send(.certifyTodayTapped) },
            onNextStage: { store.send(.nextStageButtonTapped) },
            onViewSuccessRecord: { store.send(.viewSuccessRecordTapped) },
            onRetryStage: { store.send(.retryStageButtonTapped) },
            onKeepAsIs: { store.send(.keepAsIsButtonTapped) },
            onViewHistory: { store.send(.viewHistoryButtonTapped) }
        )
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
}

private struct TaskDetailToolbarTitle: View {
    let title: String
    let subtitle: String
    let isVisible: Bool

    var body: some View {
        VStack(spacing: .jsMicro) {
            Text(title)
                .font(.jsHeadlineSmall)
                .foregroundColor(.labelStrong)
                .lineLimit(1)

            Text(subtitle)
                .font(.jsLabelMedium)
                .foregroundColor(.labelNeutral)
                .lineLimit(1)
        }
        .opacity(isVisible ? 1 : 0)
        .animation(JSAnimation.toast, value: isVisible)
    }
}

private struct TaskDetailToolbarMenu: View {
    let onChangePhoto: () -> Void
    let onNotificationSettings: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Menu {
            Button(action: onChangePhoto) {
                Label("대표 사진 변경", systemImage: "photo")
            }

            Button(action: onNotificationSettings) {
                Label("알림 설정", systemImage: "bell")
            }

            Divider()

            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.jsHeadlineMedium)
                .foregroundColor(.labelStrong)
                .frame(width: 44.jsScaled(.touchTarget), height: 44.jsScaled(.touchTarget))
        }
        .accessibilityLabel("작심 옵션")
        .accessibilityHint("대표 사진 변경, 알림 설정, 삭제 메뉴를 엽니다")
    }
}

private struct TaskDetailStageInfoSection: View {
    let currentStage: StageSnapshot?
    let challengeState: ChallengeDetailState
    let stageProgress: Double
    let stageProgressText: String

    private static let stageDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()

    var body: some View {
        JSCard(style: .elevated) {
            VStack(alignment: .leading, spacing: .jsMD) {
                HStack {
                    VStack(alignment: .leading, spacing: .jsMicro) {
                        Text("\(currentStage?.stageType.durationDays ?? 7)일 스테이지")
                            .font(.jsHeadlineSmall)
                            .foregroundColor(.labelStrong)

                        Text(stageDateRange)
                            .font(.jsBodySmall)
                            .foregroundColor(.labelNeutral)
                    }

                    Spacer()

                    TaskStatusChip(state: statusChipState)
                }

                VStack(alignment: .leading, spacing: .jsXS) {
                    JSProgress(
                        progress: stageProgress,
                        style: .linear,
                        size: .medium,
                        tintColor: progressColor
                    )

                    HStack {
                        Spacer()
                        Text(stageProgressText)
                            .font(.jsLabelMedium)
                            .foregroundColor(.labelNeutral)
                    }
                }
            }
        }
    }

    private var stageDateRange: String {
        guard let currentStage else { return "" }
        return "\(Self.stageDateFormatter.string(from: currentStage.startDate)) ~ \(Self.stageDateFormatter.string(from: currentStage.endDate))"
    }

    private var statusChipState: TaskStatusChipState {
        switch challengeState {
        case .stagePending:
            return .pending
        case .stageSuccess, .habitCompleted:
            return .completed
        case .stageFail:
            return .failed
        }
    }

    private var progressColor: Color {
        switch challengeState {
        case .stagePending:
            return .primaryNormal
        case .stageSuccess, .habitCompleted:
            return .positive
        case .stageFail:
            return .destructive
        }
    }
}

private struct TaskDetailTodayStatusSection: View {
    let todayStatus: TodayStatus

    var body: some View {
        RedesignSectionCard(
            title: sectionTitle,
            subtitle: sectionSubtitle
        ) {
            VStack(alignment: .leading, spacing: .jsSM) {
                HStack(alignment: .top, spacing: .jsSM) {
                    VStack(alignment: .leading, spacing: .jsMicro) {
                        Text("현재 상태")
                            .font(.jsLabelMedium)
                            .foregroundColor(.labelNeutral)

                        Text(headline)
                            .font(.jsBodyMedium)
                            .foregroundColor(.labelStrong)
                    }

                    Spacer()

                    TaskStatusChip(state: chipState)
                }

                if let followUp {
                    Text(followUp)
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelNeutral)
                }
            }
        }
    }

    private var chipState: TaskStatusChipState {
        switch todayStatus {
        case .notCertified:
            return .pending
        case .certified:
            return .completed
        }
    }

    private var sectionTitle: String {
        todayStatus == .certified ? "오늘 상태" : "오늘의 다음 행동"
    }

    private var sectionSubtitle: String {
        switch todayStatus {
        case .notCertified:
            return "지금 인증하면 연속 기록이 이어져요"
        case .certified:
            return "오늘 인증을 마쳤어요"
        }
    }

    private var headline: String {
        switch todayStatus {
        case .notCertified:
            return "오늘 인증을 남길 차례예요"
        case .certified:
            return "오늘 기록이 이미 저장됐어요"
        }
    }

    private var followUp: String? {
        switch todayStatus {
        case .notCertified:
            return "하단 버튼에서 바로 오늘 인증을 진행할 수 있어요."
        case .certified:
            return "아래 인증 기록에서 오늘 사진과 메모를 다시 볼 수 있어요."
        }
    }
}

private struct TaskDetailRecordListSection: View {
    let dayViewData: [TaskDetailFeature.State.DayViewData]
    let onTapDay: (Date) -> Void

    private static let accessibilityFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter
    }()

    var body: some View {
        RedesignSectionCard(
            title: "인증 기록",
            subtitle: recordListSubtitle
        ) {
            if dayViewData.isEmpty {
                RedesignStateBanner(
                    text: "아직 인증 기록이 없어요",
                    icon: "tray",
                    tintColor: .labelNeutral
                )
            } else {
                LazyVStack(spacing: .jsSM) {
                    ForEach(dayViewData) { data in
                        Button(action: { onTapDay(data.date) }) {
                            DailyRecordRow(data: data)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(Self.accessibilityFormatter.string(from: data.date)), \(data.isChecked ? "인증 완료" : "미인증")")
                        .accessibilityHint("해당 날짜 인증 화면으로 이동합니다")
                    }
                }
            }
        }
    }

    private var recordListSubtitle: String {
        dayViewData.isEmpty
        ? "기록이 쌓이면 날짜별로 바로 확인할 수 있어요"
        : "날짜를 누르면 그날 인증 화면으로 이동해요"
    }
}

private struct TaskDetailBottomCTASection: View {
    let challengeState: ChallengeDetailState
    let isTodayInChallengeRange: Bool
    let todayStatus: TodayStatus
    let onCertifyToday: () -> Void
    let onNextStage: () -> Void
    let onViewSuccessRecord: () -> Void
    let onRetryStage: () -> Void
    let onKeepAsIs: () -> Void
    let onViewHistory: () -> Void

    var body: some View {
        switch challengeState {
        case .stagePending:
            if isTodayInChallengeRange && todayStatus == .notCertified {
                JSButton(
                    title: "오늘 작심 인증하러 가기",
                    style: .primary,
                    size: .large
                ) {
                    onCertifyToday()
                }
            }
        case .stageSuccess:
            VStack(spacing: .jsSM) {
                JSButton(
                    title: "다음 스테이지로 넘어가기",
                    style: .primary,
                    size: .large
                ) {
                    onNextStage()
                }

                JSButton(
                    title: "인증 기록 보기",
                    style: .secondary,
                    size: .large
                ) {
                    onViewSuccessRecord()
                }
            }
        case .stageFail:
            VStack(spacing: .jsSM) {
                VStack(spacing: .jsMicro) {
                    Text("이번 스테이지는 여기서 멈췄어요")
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelStrong)

                    Text("재도전하면 같은 목표로 다시 이어갈 수 있어요")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelNeutral)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                JSButton(
                    title: "스테이지 재도전",
                    style: .primary,
                    size: .large
                ) {
                    onRetryStage()
                }

                JSButton(
                    title: "그대로 두기",
                    style: .secondary,
                    size: .large
                ) {
                    onKeepAsIs()
                }
            }
        case .habitCompleted:
            VStack(spacing: .jsSM) {
                VStack(spacing: .jsMicro) {
                    Text("30일 완주를 끝냈어요")
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelStrong)

                    Text("전체 기록을 돌아보며 다음 목표를 준비해 보세요")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelNeutral)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                JSButton(
                    title: "기록 돌아보기",
                    style: .secondary,
                    size: .large
                ) {
                    onViewHistory()
                }
            }
        }
    }
}

private struct DailyRecordRow: View {
    let data: TaskDetailFeature.State.DayViewData

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter
    }()
    
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
                                .foregroundColor(.labelNeutral)
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
                
                Text(recordMemoText)
                    .font(.jsLabelMedium)
                    .foregroundColor(recordMemoColor)
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
        Self.dateFormatter.string(from: date)
    }

    private var recordMemoText: String {
        data.memo.isEmpty ? "메모 없음" : data.memo
    }

    private var recordMemoColor: Color {
        data.memo.isEmpty ? .labelAlternative : .labelNeutral
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
                    HStack {
                        Spacer()

                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.jsHeadlineMedium)
                                .foregroundColor(.labelNeutral)
                                .frame(width: 44.jsScaled(.touchTarget), height: 44.jsScaled(.touchTarget))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("팝업 닫기")
                    }

                    SparkleAnimationView(animate: $animate)
                        .frame(height: 120.jsScaled())

                    Text(result == .success ? "스테이지를 완료했어요" : "이번 스테이지는 아쉬웠어요")
                        .font(.jsHeadlineSmall)
                        .foregroundColor(.labelStrong)

                    Text(result == .success ? "다음 단계로 넘어가 볼까요?" : "다음 스테이지에서 다시 도전해요")
                        .font(.jsBodySmall)
                        .foregroundColor(.labelNeutral)

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
            .accessibilityElement(children: .contain)
            .accessibilityHint("닫기 버튼 또는 확인 버튼으로 팝업을 닫을 수 있어요")
        }
        .onAppear {
            if reduceMotion {
                animate = false
            } else {
                withAnimation(
                    Animation.easeOut(duration: JSAnimation.durationSlow * 4)
                        .repeatForever(autoreverses: false)
                ) {
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
