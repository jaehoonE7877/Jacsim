import Domain
import DSKit
import SwiftUI

public struct StageGraduationView: View {
    let context: GraduationContext
    let onNextStage: () -> Void
    let onFinish: () -> Void
    let onBrag: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var didReveal = false

    public init(
        context: GraduationContext,
        onNextStage: @escaping () -> Void,
        onFinish: @escaping () -> Void,
        onBrag: @escaping () -> Void
    ) {
        self.context = context
        self.onNextStage = onNextStage
        self.onFinish = onFinish
        self.onBrag = onBrag
    }

    public var body: some View {
        ZStack {
            LinearGradient.wallpaperForest
                .ignoresSafeArea()

            VStack(spacing: .jsXL) {
                Spacer(minLength: .jsXL)

                VStack(spacing: .jsMD) {
                    Text("축하해요")
                        .font(.jsSerifHero)
                        .foregroundStyle(Color.labelStrong)
                        .multilineTextAlignment(.center)

                    Text("\(context.taskTitle) \(context.durationDays)일 스테이지를 완주했어요")
                        .font(.jsBodyMedium)
                        .foregroundStyle(Color.labelAlternative)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .jsLG)
                }

                JSStageRing(
                    currentDays: context.durationDays,
                    targetDays: context.durationDays,
                    stageType: ringStageType,
                    accessibilityLabel: "\(context.durationDays)일 스테이지 완주"
                )
                .scaleEffect(reduceMotion || didReveal ? 1 : 0.86)
                .opacity(reduceMotion || didReveal ? 1 : 0)

                nextStageChips

                Spacer(minLength: .jsLG)

                VStack(spacing: .jsSM) {
                    JSButton(title: "다음 스테이지로", style: .primary, size: .large) {
                        onNextStage()
                    }
                    .accessibilityLabel("다음 스테이지로")

                    JSButton(title: "여기서 종료", style: .secondary, size: .large) {
                        onFinish()
                    }
                    .accessibilityLabel("여기서 종료")

                    Button {
                        onBrag()
                    } label: {
                        Label("이 졸업을 자랑할까요?", systemImage: "megaphone.fill")
                            .font(.jsButtonMedium)
                            .foregroundStyle(Color.forestAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, .jsSM)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("이 졸업을 자랑할까요")
                }
                .padding(.horizontal, .jsMD)
                .padding(.bottom, .jsLG)
            }
        }
        .onAppear {
            guard !reduceMotion else {
                didReveal = true
                return
            }
            withAnimation(JSAnimation.spring) {
                didReveal = true
            }
        }
    }

    private var nextStageChips: some View {
        HStack(spacing: .jsXS) {
            Text("다음 추천")
                .font(.jsLabelMedium)
                .foregroundStyle(Color.labelAlternative)

            Text(nextStageTitle)
                .font(.jsMonoMedium)
                .foregroundStyle(Color.backgroundNormal)
                .padding(.horizontal, .jsMD)
                .padding(.vertical, .jsXS)
                .background(Color.forestAccent, in: Capsule())
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("다음 추천, \(nextStageTitle)")
    }

    private var nextStageTitle: String {
        guard let next = context.stageType.next else { return "완주 유지" }
        return "\(next.durationDays)일"
    }

    private var ringStageType: JSStageRing.StageType {
        JSStageRing.StageType(rawValue: context.durationDays) ?? .three
    }
}

#Preview {
    StageGraduationView(
        context: GraduationContext(
            taskId: TaskID(UUID()),
            taskTitle: "매일 10분 명상",
            stageTypeRaw: 7,
            durationDays: 7,
            successDays: 7
        ),
        onNextStage: {},
        onFinish: {},
        onBrag: {}
    )
}
