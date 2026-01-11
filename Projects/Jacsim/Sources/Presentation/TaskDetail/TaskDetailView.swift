import SwiftUI
import ComposableArchitecture
import DSKit
import Darwin

public struct TaskDetailView: View {
    @Bindable var store: StoreOf<TaskDetailFeature>

    public init(store: StoreOf<TaskDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                
                successLabel
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(store.dayViewData) { data in
                        dayCell(data: data)
                            .onTapGesture {
                                store.send(.dayTapped(data.date))
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 24)
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
                    if store.task.alarm != nil {
                        Button(action: { store.send(.deleteAlarmButtonTapped) }) {
                            Label("알람 끄기", systemImage: "bell.slash")
                        }
                    }
                    Button(role: .destructive, action: { store.send(.deleteJacsimButtonTapped) }) {
                        Label("작심 그만두기", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.labelStrong)
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
                    hasNextStage: store.task.currentStageType.next != nil,
                    onNextStage: { store.send(.nextStageButtonTapped) },
                    onDismiss: { store.send(.stagePopupDismissed) }
                )
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("\(store.task.startDate.convertToString(withFormat: .full)) ~ \(store.task.endDate.convertToString(withFormat: .full))")
                .font(.pretendardMedium(size: 14))
                .foregroundColor(.labelNeutral)
            
            if let alarm = store.task.alarm {
                Text("알림: \(alarm.convertToString(withFormat: .ahhmm))")
                    .font(.pretendardMedium(size: 14))
                    .foregroundColor(.primaryNormal)
            }
        }
    }

    private var successLabel: some View {
        Group {
            if store.remainingSuccessCount > 0 {
                HStack(spacing: 4) {
                    Text("작심 성공까지")
                        .foregroundColor(.labelNormal)
                    Text("\(store.remainingSuccessCount) 회")
                        .foregroundColor(.primaryNormal)
                    Text("남았습니다!")
                        .foregroundColor(.labelNormal)
                }
                .font(.pretendardSemiBold(size: 18))
            } else {
                Text("🎉 목표를 달성했습니다! 🎉")
                    .font(.pretendardSemiBold(size: 18))
                    .foregroundColor(.positive)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.backgroundNormal)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    private func dayCell(data: TaskDetailFeature.State.DayViewData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let image = data.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.labelDisable)
                    .frame(height: 120)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.labelNeutral)
                    )
            }
            
            Text(DateFormatType.toString(data.date, to: .fullWithoutYear))
                .font(.pretendardSemiBold(size: 14))
                .foregroundColor(.labelStrong)
            
            Text(data.memo)
                .font(.pretendardMedium(size: 12))
                .foregroundColor(.labelNormal)
                .lineLimit(1)
        }
        .padding(12)
        .background(Color.backgroundNormal)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(data.isChecked ? Color.primaryNormal : Color.clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
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

            VStack(spacing: 20) {
                SparkleAnimationView(animate: $animate)
                    .frame(height: 120)

                Text(result == .success ? "스테이지를 완료했어요" : "이번 스테이지는 아쉬웠어요")
                    .font(.pretendardSemiBold(size: 18))
                    .foregroundColor(.labelStrong)

                Text(result == .success ? "다음 단계로 넘어가 볼까요?" : "다음 스테이지에서 다시 도전해요")
                    .font(.pretendardMedium(size: 14))
                    .foregroundColor(.labelNeutral)

                Button(action: {
                    if result == .success && hasNextStage {
                        onNextStage()
                    } else {
                        onDismiss()
                    }
                }) {
                    Text(result == .success && hasNextStage ? "다음 단계 시작" : "확인")
                        .font(.pretendardMedium(size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.primaryNormal)
                        .cornerRadius(12)
                }
            }
            .padding(24)
            .background(Color.backgroundNormal)
            .cornerRadius(16)
            .padding(.horizontal, 24)
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
