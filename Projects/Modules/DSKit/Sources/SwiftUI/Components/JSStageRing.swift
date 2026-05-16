import SwiftUI

public struct JSStageRing: View {
    public enum StageType: Int, CaseIterable, Sendable {
        case three = 3, seven = 7, fourteen = 14, twentyOne = 21, thirty = 30
        case fortyFive = 45, sixty = 60, ninety = 90, oneEighty = 180

        public var days: Int { rawValue }
    }

    private let currentDays: Int
    private let targetDays: Int
    private let stageType: StageType
    private let accessibilityLabel: String

    public init(
        currentDays: Int,
        targetDays: Int,
        stageType: StageType,
        accessibilityLabel: String? = nil
    ) {
        self.currentDays = max(0, currentDays)
        self.targetDays = max(1, targetDays)
        self.stageType = stageType
        self.accessibilityLabel = accessibilityLabel
            ?? "Stage ring, \(currentDays) of \(targetDays) days complete"
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(Color.labelAssistive.opacity(0.24), lineWidth: 12)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.forestAccent,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: .jsMicro) {
                Text("D-\(remainingDays)")
                    .font(.jsMonoLarge)
                    .foregroundStyle(Color.labelStrong)
                Text("\(stageType.days)일 작심")
                    .font(.jsLabelMedium)
                    .foregroundStyle(Color.labelNeutral)
            }
        }
        .frame(width: 156, height: 156)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var progress: CGFloat {
        CGFloat(min(Double(currentDays) / Double(targetDays), 1))
    }

    private var remainingDays: Int {
        max(targetDays - currentDays, 0)
    }
}

private struct JSStageRingPreview: View {
    var body: some View {
        VStack(spacing: .jsLG) {
            JSStageRing(currentDays: 4, targetDays: 7, stageType: .seven)
            JSStageRing(currentDays: 38, targetDays: 90, stageType: .ninety)
        }
        .padding(.jsXL)
        .background(Color.backgroundNormal)
    }
}

#Preview("JSStageRing - Light") {
    JSStageRingPreview()
        .preferredColorScheme(.light)
}

#Preview("JSStageRing - Dark") {
    JSStageRingPreview()
        .preferredColorScheme(.dark)
}

#Preview("JSStageRing - Accessibility") {
    JSStageRingPreview()
        .dynamicTypeSize(.accessibility3)
}
