import SwiftUI

public enum StreakState: Sendable {
    case active
    case completed
    case frozen
    case empty
}

public struct JSStreakHeatmap: View {
    private let states: [Date: StreakState]
    private let calendar: Calendar
    private let endDate: Date
    private let accessibilityLabel: String

    public init(
        states: [Date: StreakState],
        calendar: Calendar = .current,
        endDate: Date = Date(),
        accessibilityLabel: String = "Streak heatmap"
    ) {
        self.calendar = calendar
        self.endDate = endDate
        self.accessibilityLabel = accessibilityLabel
        self.states = Dictionary(uniqueKeysWithValues: states.map {
            (calendar.startOfDay(for: $0.key), $0.value)
        })
    }

    public var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(14), spacing: .jsMicro), count: 12),
            spacing: .jsMicro
        ) {
            ForEach(heatmapDates, id: \.self) { date in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(color(for: state(for: date)))
                    .frame(width: 14, height: 14)
                    .accessibilityLabel(label(for: date))
            }
        }
        .padding(.jsSM)
        .background(Color.surfaceElevated.opacity(0.42))
        .clipShape(RoundedRectangle(cornerRadius: .jsCornerMedium, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var heatmapDates: [Date] {
        let end = calendar.startOfDay(for: endDate)
        return (0..<84).compactMap { offset in
            calendar.date(byAdding: .day, value: offset - 83, to: end)
        }
    }

    private func state(for date: Date) -> StreakState {
        states[calendar.startOfDay(for: date)] ?? .empty
    }

    private func color(for state: StreakState) -> Color {
        switch state {
        case .active:
            return Color.streakActive
        case .completed:
            return Color.streakCompleted
        case .frozen:
            return Color.streakFrozen
        case .empty:
            return Color.labelDisable.opacity(0.22)
        }
    }

    private func label(for date: Date) -> String {
        "\(date.formatted(date: .abbreviated, time: .omitted)) \(state(for: date))"
    }
}

private struct JSStreakHeatmapPreview: View {
    private let states: [Date: StreakState] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return Dictionary(uniqueKeysWithValues: (0..<84).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let state: StreakState = offset % 11 == 0 ? .frozen : (offset % 3 == 0 ? .active : .completed)
            return (date, state)
        })
    }()

    var body: some View {
        JSStreakHeatmap(states: states)
            .padding(.jsXL)
            .background(Color.backgroundNormal)
    }
}

#Preview("JSStreakHeatmap - Light") {
    JSStreakHeatmapPreview()
        .preferredColorScheme(.light)
}

#Preview("JSStreakHeatmap - Dark") {
    JSStreakHeatmapPreview()
        .preferredColorScheme(.dark)
}

#Preview("JSStreakHeatmap - Accessibility") {
    JSStreakHeatmapPreview()
        .dynamicTypeSize(.accessibility3)
}
