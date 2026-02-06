import SwiftUI
import ComposableArchitecture
import DSKit
import Domain
import Darwin

public struct TaskDetailView: View {
    @Bindable var store: StoreOf<TaskDetailFeature>

    public init(store: StoreOf<TaskDetailFeature>) {
        self.store = store
    }

    @State private var scrollOffset: CGFloat = 0
    private let minHeaderHeight: CGFloat = 100

    public var body: some View {
        GeometryReader { geometry in
            let coverImageHeight = geometry.size.width
            let showMinimizedHeader = coverImageHeight - scrollOffset <= minHeaderHeight

            ZStack(alignment: .top) {
                if !showMinimizedHeader {
                    ZStack(alignment: .top) {
                        coverImageBackground
                            .frame(height: max(minHeaderHeight, coverImageHeight - scrollOffset))
                            .clipped()

                        let minOffset = coverImageHeight - minHeaderHeight
                        let offsetY = scrollOffset <= 0 ? -scrollOffset : scrollOffset <= minOffset ? -scrollOffset : -minOffset

                        coverImageContent
                            .frame(height: coverImageHeight)
                            .frame(maxWidth: .infinity)
                            .offset(y: offsetY)
                    }
                }

                ScrollViewReader { proxy in
                    ScrollView {
                        Color.clear
                            .frame(height: coverImageHeight)

                    VStack(spacing: .jsLG) {
                        stageInfoSection

                        todayStatusSection

                        recordListSection
                            .id("recordListSection")
                    }
                    .padding(.top, .jsLG)
                    .padding(.horizontal, .jsMD)

                    Spacer(minLength: 140)
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

            if showMinimizedHeader {
                minimizedHeader
                    .frame(height: minHeaderHeight)
                    .frame(maxWidth: .infinity)
                    .background(Color.backgroundNormal)
            }

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
                    .frame(height: 140)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                )
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .background(Color.backgroundNormal)
            .ignoresSafeArea(edges: .top)
        }
        .onAppear { store.send(.onAppear) }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: { store.send(.backButtonTapped) }) {
                Image(systemName: "chevron.left")
                    .font(.jsHeadlineMedium)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            },
            trailing: Menu {
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
                    .frame(width: 44, height: 44)
            }
        )
        .sheet(item: $store.scope(state: \.editTask, action: \.editTask)) { store in
            NavigationStack {
                TaskEditView(store: store)
            }
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
        .alert("작심을 삭제할까요?", isPresented: Binding(
            get: { store.isDeleteConfirmationPresented },
            set: { newValue in
                if !newValue {
                    store.send(.deleteCancelled)
                }
            }
        )) {
            Button("취소", role: .cancel) {
                store.send(.deleteCancelled)
            }
            Button("삭제", role: .destructive) {
                store.send(.deleteConfirmed)
            }
        } message: {
            Text("모든 기록과 사진이 삭제되며 되돌릴 수 없어요")
        }
    }

    private var coverImageBackground: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = loadCoverImage() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
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

    private var minimizedHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(store.task.title)
                    .font(.jsHeadlineSmall)
                    .foregroundColor(.labelStrong)
                    .lineLimit(1)

                Text("\(store.currentStage?.stageType.durationDays ?? 7)일 스테이지")
                    .font(.jsBodySmall)
                    .foregroundColor(.labelAlternative)
            }

            Spacer()
        }
        .padding(.horizontal, .jsMD)
        .padding(.top, 52)
        .padding(.bottom, .jsSM)
    }

    private var coverImageSection: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = loadCoverImage() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280)
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
                    .frame(height: 280)
            }

            LinearGradient(
                colors: [
                    Color.surfaceOverlay.opacity(0),
                    Color.surfaceOverlay.opacity(0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)

            VStack(alignment: .leading, spacing: .jsXS) {
                Text(store.task.title)
                    .font(.jsDisplaySmall)
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .padding(.jsMD)
            .padding(.bottom, .jsSM)
        }
        .frame(height: 280)
    }
    
    private var stageInfoSection: some View {
        JSCard(style: .elevated) {
            VStack(alignment: .leading, spacing: .jsMD) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
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
        HStack {
            Text("오늘 상태")
                .font(.jsHeadlineSmall)
                .foregroundColor(.labelStrong)

            Spacer()

            JSStatusChip(state: todayStatusChipState)
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
            
            LazyVStack(spacing: .jsSM) {
                ForEach(store.dayViewData) { data in
                    DailyRecordRow(data: data)
                        .onTapGesture {
                            store.send(.dayTapped(data.date))
                        }
                }
            }
        }
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
    
    @ViewBuilder
    private var stagePendingCTA: some View {
        let today = Calendar.current.startOfDay(for: Date())
        let isTodayInRange = today >= Calendar.current.startOfDay(for: store.task.startDate)
            && today <= Calendar.current.startOfDay(for: store.task.endDate)
        
        if isTodayInRange && store.todayStatus == .notCertified {
            JSButton(
                title: "오늘 작심 인증하러 가기",
                style: .primary,
                size: .large
            ) {
                store.send(.certifyTodayTapped)
            }
                } else if isTodayInRange && store.todayStatus == .certified {
            JSCard(style: .elevated, padding: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.positive)
                        .font(.jsDisplaySmall)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("오늘 인증 완료!")
                            .font(.jsBodyMedium)
                            .foregroundColor(.labelStrong)
                        Text("내일도 함께해요")
                            .font(.jsBodySmall)
                            .foregroundColor(.labelAlternative)
                    }
                    
                    Spacer()
                }
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
            .frame(width: 64, height: 64)
            .cornerRadius(.jsRadiusSM)
            .overlay(
                RoundedRectangle(cornerRadius: .jsRadiusSM)
                    .stroke(data.isChecked ? Color.primaryNormal : Color.clear, lineWidth: 2)
            )
            
            VStack(alignment: .leading, spacing: 4) {
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
                        .frame(height: 120)

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
                    .frame(width: 10, height: 10)
                    .offset(sparkleOffset(for: index))
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 1.6 : 0.3)
            }
        }
    }

    private func sparkleOffset(for index: Int) -> CGSize {
        let angle = Double(index) * (Double.pi / 4)
        let radius: CGFloat = animate ? 60 : 10
        return CGSize(width: Darwin.cos(angle) * radius, height: Darwin.sin(angle) * radius)
    }
}
