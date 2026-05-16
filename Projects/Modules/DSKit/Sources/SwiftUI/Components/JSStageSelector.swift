import SwiftUI

public struct JSStageSelector: View {
    @Binding var selectedStage: Int
    let stages: [Int]
    let onStageSelected: ((Int) -> Void)?

    public init(
        selectedStage: Binding<Int>,
        stages: [Int] = [3, 7, 15, 30],
        onStageSelected: ((Int) -> Void)? = nil
    ) {
        self._selectedStage = selectedStage
        self.stages = stages
        self.onStageSelected = onStageSelected
    }

    public var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 72.jsScaled()), spacing: .jsSM)],
            spacing: .jsSM
        ) {
            ForEach(stages, id: \.self) { stage in
                StageButton(
                    stage: stage,
                    isSelected: selectedStage == stage,
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedStage = stage
                        }
                        onStageSelected?(stage)
                    }
                )
            }
        }
    }
}

private struct StageButton: View {
    let stage: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: .jsMicro) {
                Text("\(stage)")
                    .font(.jsMonoMedium)

                Text("일")
                    .font(.jsLabel12Medium)
            }
            .foregroundColor(isSelected ? .backgroundNormal : Color.labelNormal)
            .frame(maxWidth: .infinity)
            .frame(height: 72.jsScaled())
            .background(
                RoundedRectangle(cornerRadius: .jsRadiusSM)
                    .fill(isSelected ? Color.primaryNormal : Color.backgroundAlternative.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: .jsRadiusSM)
                    .stroke(isSelected ? Color.primaryNormal : Color.backgroundAlternative.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(minWidth: 44.jsScaled(.touchTarget), minHeight: 44.jsScaled(.touchTarget))
        .contentShape(Rectangle())
    }
}

public struct JSStageInputView: View {
    @Binding var selectedStage: Int
    let title: String
    let subtitle: String?
    let onConfirm: (() -> Void)?

    public init(
        selectedStage: Binding<Int>,
        title: String = "기간 선택",
        subtitle: String? = "작심을 얼마나 유지할까요?",
        onConfirm: (() -> Void)? = nil
    ) {
        self._selectedStage = selectedStage
        self.title = title
        self.subtitle = subtitle
        self.onConfirm = onConfirm
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .jsLG) {
            VStack(alignment: .leading, spacing: .jsXS) {
                Text(title)
                    .font(.jsHeadline20Bold)
                    .foregroundColor(Color.labelNormal)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.jsBody16Regular)
                        .foregroundColor(Color.labelNeutral)
                }
            }

            JSStageSelector(
                selectedStage: $selectedStage,
                onStageSelected: { _ in }
            )

            HStack {
                Spacer()

                Text("총 \(selectedStage)일")
                    .font(.jsHeadline18Bold)
                    .foregroundColor(Color.primaryNormal)
                    .padding(.jsXS)
                    .background(
                        RoundedRectangle(cornerRadius: 6.jsScaled())
                            .fill(Color.primaryNormal.opacity(0.1))
                    )

                Spacer()
            }
            .padding(.top, .jsXS)

            Spacer()

            Button(action: { onConfirm?() }) {
                Text("확인")
                    .font(.jsHeadline17Bold)
                    .foregroundColor(.backgroundNormal)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50.jsScaled())
                    .background(
                        RoundedRectangle(cornerRadius: 10.jsScaled())
                            .fill(Color.primaryNormal)
                    )
            }
            .frame(minWidth: 44.jsScaled(.touchTarget), minHeight: 44.jsScaled(.touchTarget))
            .contentShape(Rectangle())
        }
        .padding(.jsMD)
    }
}

struct JSStageSelector_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @State private var selectedStage = 7

        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stage Selector")
                            .font(.jsHeadline18Bold)

                        JSStageSelector(
                            selectedStage: $selectedStage,
                            onStageSelected: { _ in }
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stage Input View")
                            .font(.jsHeadline18Bold)

                        JSStageInputView(
                            selectedStage: $selectedStage,
                            onConfirm: {}
                        )
                    }
                    .frame(height: 300)
                }
                .padding()
            }
        }
    }

    static var previews: some View {
        PreviewContainer()
    }
}
