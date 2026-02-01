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

    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: .jsLG) {
                    headerSection

                    successLabel

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: .jsMD) {
                        ForEach(store.dayViewData) { data in
                            dayCell(data: data)
                                .onTapGesture {
                                    store.send(.dayTapped(data.date))
                                }
                        }
                    }
                    .padding(.horizontal, .jsMD)

                    Spacer(minLength: 100)
                }
                .padding(.vertical, .jsLG)
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
                    .frame(height: 120)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                )
        }
        .background(Color.backgroundNormal)
        .navigationTitle(store.task.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.send(.onAppear) }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { store.send(.editButtonTapped) }) {
                        Label("작심 수정", systemImage: "pencil")
                    }

                    Button(role: .destructive, action: { store.send(.deleteJacsimButtonTapped) }) {
                        Label("작심 그만두기", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.labelStrong)
                        .jsTouchTarget()
                }
            }
        }
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
                    onDismiss: { store.send(.stagePopupDismissed) }
                )
            }
        }
    }

    @ViewBuilder
    private var bottomCTASection: some View {
        let today = Calendar.current.startOfDay(for: Date())
        let isTodayInRange = today >= Calendar.current.startOfDay(for: store.task.startDate)
            && today <= Calendar.current.startOfDay(for: store.task.endDate)

        if isTodayInRange {
            let todayIndex = store.task.dayArray.firstIndex { Calendar.current.isDate($0, inSameDayAs: today) }
            let isTodayChecked = todayIndex.map { store.task.records.indices.contains($0) && store.task.records[$0].check } ?? false

            if isTodayChecked {
                completedCTA
            } else {
                certifyCTA(todayIndex: todayIndex)
            }
        }
    }

    private var completedCTA: some View {
        JSCard(style: .elevated, padding: 16) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text("오늘 인증 완료!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    Text("내일도 함께해요")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
    }

    private func certifyCTA(todayIndex: Int?) -> some View {
        JSButton(
            title: "오늘 인증하기",
            style: .primary,
            size: .large
        ) {
            if let index = todayIndex {
                store.send(.delegate(.navigateToUpdate(store.task, index)))
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: .jsXS) {
            Text("\(DateFormatType.toString(store.task.startDate, to: .full)) ~ \(DateFormatType.toString(store.task.endDate, to: .full))")
                .font(.jsBodySmall)
                .foregroundColor(.labelAlternative)
        }
    }

    private var successLabel: some View {
        JSCard(style: store.remainingSuccessCount > 0 ? .elevated : .flat, padding: .jsMD) {
            if store.remainingSuccessCount > 0 {
                HStack(spacing: .jsMicro) {
                    Text("작심 성공까지")
                        .foregroundColor(.labelNormal)
                    Text("\(store.remainingSuccessCount) 회")
                        .foregroundColor(.primaryNormal)
                    Text("남았습니다!")
                        .foregroundColor(.labelNormal)
                }
                .font(.jsHeadlineSmall)
            } else {
                Text("🎉 목표를 달성했습니다! 🎉")
                    .font(.jsHeadlineSmall)
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, .jsMD)
    }

    private func dayCell(data: TaskDetailFeature.State.DayViewData) -> some View {
        VStack(alignment: .leading, spacing: .jsXS) {
            if let image = data.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(.jsRadiusSM)
            } else {
                Rectangle()
                    .fill(Color.labelDisable.opacity(0.3))
                    .frame(height: 120)
                    .cornerRadius(.jsRadiusSM)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.labelAlternative)
                    )
            }
            
            Text(DateFormatType.toString(data.date, to: .fullWithoutYear))
                .font(.jsLabelMedium)
                .foregroundColor(.labelStrong)
            
            Text(data.memo)
                .font(.jsLabelSmall)
                .foregroundColor(.labelAlternative)
                .lineLimit(1)
        }
        .padding(.jsSM)
        .background(Color.backgroundStrong)
        .cornerRadius(.jsRadiusMD)
        .overlay(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .stroke(data.isChecked ? Color.primaryNormal : Color.clear, lineWidth: 2)
        )
    }
}

private struct StageCompletionPopupView: View {
    let result: StageResult
    let hasNextStage: Bool
    let onNextStage: () -> Void
    let onDismiss: () -> Void

    @State private var animate = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
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
            withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                animate = true
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
