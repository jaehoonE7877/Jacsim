import SwiftUI

public struct JSCalendarV2: View {
    public enum Mode: String, CaseIterable, Sendable {
        case month = "월"
        case year = "연"
    }

    @Binding private var selectedDate: Date
    @State private var viewDate: Date
    @State private var mode: Mode = .month
    private let eventStates: [Date: StreakState]
    private let calendar: Calendar

    public init(
        selectedDate: Binding<Date>,
        eventStates: [Date: StreakState] = [:],
        calendar: Calendar = .current
    ) {
        self._selectedDate = selectedDate
        self._viewDate = State(initialValue: selectedDate.wrappedValue)
        self.eventStates = eventStates
        self.calendar = calendar
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .jsMD) {
            header
            Picker("Calendar mode", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Calendar view mode")

            if mode == .month {
                weekdayHeader
                monthGrid
            } else {
                JSStreakHeatmap(states: eventStates, endDate: viewDate)
            }
        }
        .padding(.jsLG)
        .background(Color.surfaceElevated.opacity(0.46))
        .jsGlassCard(cornerRadius: 24)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Calendar")
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: .jsMicro) {
                Text(title)
                    .font(.jsSerifTitle)
                    .foregroundStyle(Color.labelStrong)
                Text(mode == .month ? "월간 기록" : "84일 히트맵")
                    .font(.jsLabelMedium)
                    .foregroundStyle(Color.labelNeutral)
            }
            Spacer()
            Button { moveMonth(-1) } label: {
                Image(systemName: "chevron.left")
            }
            .accessibilityLabel("이전 달")
            Button { moveMonth(1) } label: {
                Image(systemName: "chevron.right")
            }
            .accessibilityLabel("다음 달")
        }
        .buttonStyle(.glass)
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .font(.jsLabelSmall)
                    .foregroundStyle(Color.labelAlternative)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: .jsXS) {
            ForEach(monthDates, id: \.self) { date in
                dayCell(date)
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let selected = calendar.isDate(date, inSameDayAs: selectedDate)
        let currentMonth = calendar.isDate(date, equalTo: viewDate, toGranularity: .month)
        return Button {
            selectedDate = date
        } label: {
            Text("\(calendar.component(.day, from: date))")
                .font(.jsMonoSmall)
                .foregroundStyle(selected ? Color.backgroundNormal : dayForeground(currentMonth))
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(dayBackground(date, selected: selected))
                .clipShape(RoundedRectangle(cornerRadius: .jsCornerSmall, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(date.formatted(date: .abbreviated, time: .omitted))")
    }

    private func dayForeground(_ currentMonth: Bool) -> Color {
        currentMonth ? Color.labelNormal : Color.labelDisable
    }

    private func dayBackground(_ date: Date, selected: Bool) -> Color {
        if selected { return Color.forestAccent }
        switch eventStates[calendar.startOfDay(for: date)] ?? .empty {
        case .active: return Color.streakActive.opacity(0.22)
        case .completed: return Color.streakCompleted.opacity(0.22)
        case .frozen: return Color.streakFrozen.opacity(0.24)
        case .empty: return Color.surfaceSelected.opacity(0.22)
        }
    }

    private var title: String {
        viewDate.formatted(.dateTime.year().month(.wide))
    }

    private var monthDates: [Date] {
        guard let first = calendar.date(from: calendar.dateComponents([.year, .month], from: viewDate)) else {
            return []
        }
        let offset = calendar.component(.weekday, from: first) - 1
        guard let start = calendar.date(byAdding: .day, value: -offset, to: first) else { return [] }
        return (0..<42).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private func moveMonth(_ value: Int) {
        if let next = calendar.date(byAdding: .month, value: value, to: viewDate) {
            withAnimation(JSAnimation.spring) {
                viewDate = next
            }
        }
    }
}

private struct JSCalendarV2Preview: View {
    @State private var selectedDate = Date()

    var body: some View {
        JSCalendarV2(selectedDate: $selectedDate, eventStates: JSCalendarV2Preview.states)
            .padding(.jsLG)
            .background(LinearGradient.wallpaperMorning)
    }

    static var states: [Date: StreakState] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return Dictionary(uniqueKeysWithValues: (0..<36).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return (date, offset % 5 == 0 ? StreakState.active : StreakState.completed)
        })
    }
}

#Preview("JSCalendarV2 - Light") {
    JSCalendarV2Preview()
        .preferredColorScheme(.light)
}

#Preview("JSCalendarV2 - Dark") {
    JSCalendarV2Preview()
        .preferredColorScheme(.dark)
}

#Preview("JSCalendarV2 - Accessibility") {
    JSCalendarV2Preview()
        .dynamicTypeSize(.accessibility3)
}
