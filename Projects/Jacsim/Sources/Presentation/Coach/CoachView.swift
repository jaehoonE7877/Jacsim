import DSKit
import ExternalInterface
import SwiftUI

public struct CoachView: View {
    @Bindable var model: CoachModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var toastPresented = false

    public init(model: CoachModel) {
        self.model = model
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient.wallpaperForest
                .ignoresSafeArea()
            Color.backgroundNormal.opacity(0.18)
                .ignoresSafeArea()

            conversation
            composer
        }
        .navigationTitle("AI 코치")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("닫기") {
                    dismiss()
                }
                .font(.jsButtonMedium)
                .foregroundStyle(Color.labelAlternative)
                .accessibilityLabel("AI 코치 닫기")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("주간 회고 받기") {
                    model.weeklyReflectionTapped()
                }
                .font(.jsButtonMedium)
                .foregroundStyle(Color.forestAccent)
                .disabled(model.isSending)
                .accessibilityLabel("주간 회고 받기")
            }
        }
        .jsGlassNavBar()
        .onChange(of: model.toastMessage) { _, message in
            toastPresented = message != nil
        }
        .jsGlassToast(text: $model.toastMessage, isPresented: $toastPresented)
    }

    private var conversation: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: .jsMD) {
                    if model.messages.isEmpty {
                        emptyState
                    } else {
                        ForEach(model.messages) { message in
                            JSAICoachBubble(
                                message.text,
                                role: bubbleRole(message.role),
                                accessibilityLabel: accessibilityLabel(for: message)
                            )
                            .id(message.id)
                        }
                    }

                    if model.isSending {
                        JSAICoachBubble(role: .typing, accessibilityLabel: "AI 코치가 답변을 작성 중입니다")
                    }
                }
                .padding(.horizontal, .jsMD)
                .padding(.top, .jsLG)
                .padding(.bottom, 128.jsScaled())
            }
            .onChange(of: model.messages.count) { _, _ in
                guard let last = model.messages.last else { return }
                if reduceMotion {
                    proxy.scrollTo(last.id, anchor: .bottom)
                } else {
                    withAnimation(JSAnimation.easeInOut) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: .jsMD) {
            Image(systemName: "sparkles")
                .font(.jsDisplayScaledSemiBold(size: 36))
                .foregroundStyle(Color.forestAccent)

            Text("오늘은 무엇을 작심하셨나요?")
                .font(.jsSerifTitle)
                .foregroundStyle(Color.labelStrong)
                .multilineTextAlignment(.center)

            Text("목표가 막힐 때 한 문장으로 물어보세요")
                .font(.jsBodySmall)
                .foregroundStyle(Color.labelAlternative)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 88.jsScaled())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("AI 코치 빈 화면")
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: .jsSM) {
            JSInputField(
                title: "",
                placeholder: "코치에게 메시지 보내기",
                text: $model.draft,
                axis: .vertical,
                lineLimit: 3
            )

            Button {
                model.sendTapped()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.jsDisplaySmall)
                    .foregroundStyle(model.canSend ? Color.forestAccent : Color.labelDisable)
            }
            .disabled(!model.canSend)
            .jsTouchTarget()
            .accessibilityLabel("AI 코치에게 보내기")
        }
        .padding(.horizontal, .jsMD)
        .padding(.top, .jsSM)
        .padding(.bottom, .jsMD)
        .background(.thinMaterial)
    }

    private func bubbleRole(_ role: CoachMessageRole) -> JSAICoachBubble.Role {
        switch role {
        case .coach:
            return .coach
        case .user:
            return .user
        }
    }

    private func accessibilityLabel(for message: CoachMessage) -> String {
        switch message.role {
        case .coach:
            return "AI 코치 답변, \(message.text)"
        case .user:
            return "사용자 메시지, \(message.text)"
        }
    }
}

#Preview {
    NavigationStack {
        CoachView(model: CoachModel(dependencies: .test))
    }
}
