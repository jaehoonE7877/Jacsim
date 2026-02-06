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
        HStack(spacing: 12) {
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
            VStack(spacing: 4) {
                Text("\(stage)")
                    .font(.jsHeadline20Bold)

                Text("일")
                    .font(.jsLabel12Medium)
            }
            .foregroundColor(isSelected ? .white : DSKitAsset.Colors.textPrimary.swiftUIColor)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? DSKitAsset.Colors.primaryNormal.swiftUIColor : DSKitAsset.Colors.gray100.swiftUIColor.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? DSKitAsset.Colors.primaryNormal.swiftUIColor : DSKitAsset.Colors.gray100.swiftUIColor.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(minWidth: 44, minHeight: 44)
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
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.jsHeadline20Bold)
                    .foregroundColor(DSKitAsset.Colors.textPrimary.swiftUIColor)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.jsBody16Regular)
                        .foregroundColor(DSKitAsset.Colors.textSecondary.swiftUIColor)
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
                    .foregroundColor(DSKitAsset.Colors.primaryNormal.swiftUIColor)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(DSKitAsset.Colors.primaryNormal.swiftUIColor.opacity(0.1))
                    )

                Spacer()
            }
            .padding(.top, 8)

            Spacer()

            Button(action: { onConfirm?() }) {
                Text("확인")
                    .font(.jsHeadline17Bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(DSKitAsset.Colors.primaryNormal.swiftUIColor)
                    )
            }
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
        }
        .padding(16)
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
                            onStageSelected: { stage in
                                print("Selected: \(stage)")
                            }
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stage Input View")
                            .font(.jsHeadline18Bold)

                        JSStageInputView(
                            selectedStage: $selectedStage,
                            onConfirm: {
                                print("Confirmed: \(selectedStage)")
                            }
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
