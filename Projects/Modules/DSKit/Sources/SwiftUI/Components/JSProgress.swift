import SwiftUI

public enum JSProgressSize {
    case small
    case medium
    case large
}

public enum JSProgressStyle {
    case linear
    case circular
}

public struct JSProgress: View {
    let progress: Double
    let style: JSProgressStyle
    let size: JSProgressSize
    let showPercentage: Bool
    let tintColor: Color

    public init(
        progress: Double,
        style: JSProgressStyle = .linear,
        size: JSProgressSize = .medium,
        showPercentage: Bool = false,
        tintColor: Color = .blue
    ) {
        self.progress = max(0, min(1, progress))
        self.style = style
        self.size = size
        self.showPercentage = showPercentage
        self.tintColor = tintColor
    }

    public var body: some View {
        switch style {
        case .linear:
            linearProgressView
        case .circular:
            circularProgressView
        }
    }

    private var linearProgressView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: trackHeight / 2)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: trackHeight)

                RoundedRectangle(cornerRadius: trackHeight / 2)
                    .fill(tintColor)
                    .frame(width: geometry.size.width * progress, height: trackHeight)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: trackHeight)
    }

    private var circularProgressView: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: strokeWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(tintColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)

            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(percentageFont)
                    .foregroundColor(.primary)
            }
        }
        .frame(width: circleSize, height: circleSize)
    }

    private var trackHeight: CGFloat {
        switch size {
        case .small:
            return 4
        case .medium:
            return 8
        case .large:
            return 12
        }
    }

    private var strokeWidth: CGFloat {
        switch size {
        case .small:
            return 3
        case .medium:
            return 5
        case .large:
            return 8
        }
    }

    private var circleSize: CGFloat {
        switch size {
        case .small:
            return 24
        case .medium:
            return 44
        case .large:
            return 64
        }
    }

    private var percentageFont: Font {
        switch size {
        case .small:
            return .system(size: 12, weight: .medium)
        case .medium:
            return .system(size: 14, weight: .medium)
        case .large:
            return .system(size: 16, weight: .medium)
        }
    }
}

public struct JSProgressIndicator: View {
    let size: JSProgressSize
    let tintColor: Color

    @State private var isAnimating = false

    public init(
        size: JSProgressSize = .medium,
        tintColor: Color = .blue
    ) {
        self.size = size
        self.tintColor = tintColor
    }

    public var body: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(tintColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
            .frame(width: indicatorSize, height: indicatorSize)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(
                Animation.linear(duration: 1)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }

    private var strokeWidth: CGFloat {
        switch size {
        case .small:
            return 2
        case .medium:
            return 3
        case .large:
            return 4
        }
    }

    private var indicatorSize: CGFloat {
        switch size {
        case .small:
            return 16
        case .medium:
            return 24
        case .large:
            return 32
        }
    }
}

struct JSProgress_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @State private var progress: Double = 0.65

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("Linear Progress")
                            .font(.system(size: 16, weight: .semibold))

                        VStack(spacing: 8) {
                            JSProgress(progress: progress, style: .linear, size: .small)
                            JSProgress(progress: progress, style: .linear, size: .medium)
                            JSProgress(progress: progress, style: .linear, size: .large)
                        }
                    }

                    VStack(spacing: 12) {
                        Text("Circular Progress")
                            .font(.system(size: 16, weight: .semibold))

                        HStack(spacing: 20) {
                            JSProgress(progress: progress, style: .circular, size: .small)
                            JSProgress(progress: progress, style: .circular, size: .medium, showPercentage: true)
                            JSProgress(progress: progress, style: .circular, size: .large, showPercentage: true)
                        }
                    }

                    VStack(spacing: 12) {
                        Text("Loading Indicators")
                            .font(.system(size: 16, weight: .semibold))

                        HStack(spacing: 20) {
                            JSProgressIndicator(size: .small)
                            JSProgressIndicator(size: .medium)
                            JSProgressIndicator(size: .large)
                        }
                    }

                    VStack(spacing: 12) {
                        Text("Custom Colors")
                            .font(.system(size: 16, weight: .semibold))

                        HStack(spacing: 20) {
                            JSProgress(progress: 0.7, style: .circular, size: .medium, tintColor: .green)
                            JSProgress(progress: 0.5, style: .circular, size: .medium, tintColor: .orange)
                            JSProgress(progress: 0.3, style: .circular, size: .medium, tintColor: .red)
                        }
                    }

                    Slider(value: $progress, in: 0...1)
                        .padding(.top, 20)
                }
                .padding()
            }
        }
    }

    static var previews: some View {
        PreviewContainer()
    }
}
