import SwiftUI

public enum JSCalendarScope {
    case month
    case week
}

public enum JSCalendarDateColor {
    case none
    case low
    case medium
    case high
}

public struct JSCalendar: View {
    @Binding var selectedDate: Date
    @State private var viewDate: Date
    @Binding var scope: JSCalendarScope
    private let eventDates: [Date]
    private let dateColors: [Date: JSCalendarDateColor]
    private let calendar = Calendar.current
    private let locale = Locale(identifier: "ko_KR")

    public init(
        selectedDate: Binding<Date>,
        scope: Binding<JSCalendarScope>,
        eventDates: [Date] = [],
        dateColors: [Date: JSCalendarDateColor] = [:]
    ) {
        self._selectedDate = selectedDate
        self._viewDate = State(initialValue: selectedDate.wrappedValue)
        self._scope = scope
        self.eventDates = eventDates
        self.dateColors = dateColors
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerView

            weekdayHeaderView

            calendarGridView
                .animation(JSAnimation.navigationSpring, value: viewDate)
                .animation(JSAnimation.navigationSpring, value: scope)
        }
        .background(Color.backgroundNormal)
        .clipped()
        .onChange(of: selectedDate) { _, newDate in
            alignViewDate(for: scope, selectedDate: newDate)
        }
        .onChange(of: scope) { _, newScope in
            alignViewDate(for: newScope, selectedDate: selectedDate)
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            HStack(spacing: .jsSM) {
                VStack(alignment: .leading, spacing: .jsMicro) {
                    Button(action: { withAnimation(JSAnimation.navigation) { moveToToday() } }) {
                        Text(headerTitle)
                            .font(.jsDisplay22Bold)
                            .foregroundColor(Color.labelNormal)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(headerTitle), 오늘로 이동")

                    Text(scopeText)
                        .font(.jsLabel12Medium)
                        .foregroundColor(Color.labelNeutral)
                }
                Spacer()

                if !calendar.isDateInToday(viewDate) || !calendar.isDate(viewDate, inSameDayAs: selectedDate) {
                    Button(action: { withAnimation(JSAnimation.navigationSpring) { moveToToday() } }) {
                        Text("오늘")
                            .font(.jsLabel13Bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, .jsSM)
                            .padding(.vertical, .jsXS)
                            .background(
                                Capsule()
                                    .fill(Color.primaryNormal)
                                    .jsShadow(.medium)
                            )
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: .jsXS) {
                    calendarPagingButton(
                        systemName: "chevron.left",
                        accessibilityLabel: scope == .month ? "이전 달" : "이전 주",
                        action: { movePage(by: -1) }
                    )
                    calendarPagingButton(
                        systemName: "chevron.right",
                        accessibilityLabel: scope == .month ? "다음 달" : "다음 주",
                        action: { movePage(by: 1) }
                    )
                }
            }

            Picker("캘린더 보기", selection: $scope) {
                Text("월간").tag(JSCalendarScope.month)
                Text("주간").tag(JSCalendarScope.week)
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal, .jsLG)
        .padding(.vertical, .jsSM)
        .background(Color.backgroundNormal)
    }

    private var weekdayHeaderView: some View {
        HStack(spacing: 0) {
            ForEach(0..<7) { index in
                Text(weekdayTitle(for: index))
                    .font(.jsLabel13Bold)
                    .foregroundColor(index == 0 ? Color.destructive.opacity(0.8) : (index == 6 ? Color.primaryNormal.opacity(0.8) : .labelNeutral))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .jsMicro)
            }
        }
        .padding(.horizontal, .jsMD)
        .padding(.vertical, .jsXS)
        .background(Color.clear)
        .zIndex(1)
    }

    private var calendarGridView: some View {
        let days = scope == .month ? daysInMonth : daysInWeek
        let rows = scope == .month ? 6 : 1
        
        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
            spacing: .jsXS
        ) {
            ForEach(days, id: \.self) { date in
                dayView(for: date)
            }
        }
        .padding(.horizontal, .jsXS)
        .frame(height: CGFloat(rows) * 56.jsScaled())
    }

    private func dayView(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isCurrentMonth = scope == .week || calendar.isDate(date, equalTo: viewDate, toGranularity: .month)
        let hasEvent = eventDates.contains { calendar.isDate($0, inSameDayAs: date) }
        let dateColor = dateColors[date] ?? .none

        return Button {
            withAnimation(JSAnimation.emphasisSpring) {
                selectedDate = date
                viewDate = date
            }
        }
        label: {
            VStack(spacing: .jsXS) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: .jsRadiusMD)
                            .fill(Color.primaryNormal)
                            .jsShadow(.medium)
                    } else if isToday {
                        RoundedRectangle(cornerRadius: .jsRadiusMD)
                            .stroke(Color.primaryNormal.opacity(0.4), lineWidth: 1.5)
                            .background(
                                RoundedRectangle(cornerRadius: .jsRadiusMD)
                                    .fill(Color.primaryNormal.opacity(0.08))
                            )
                    } else if hasEvent && !isSelected {
                        RoundedRectangle(cornerRadius: .jsRadiusMD)
                            .fill(dateColorBackground(dateColor))
                    } else {
                        RoundedRectangle(cornerRadius: .jsRadiusMD)
                            .fill(Color.clear)
                    }

                    Text("\(calendar.component(.day, from: date))")
                        .font(.jsHeadline16Bold)
                        .foregroundColor(isSelected ? .white : (isCurrentMonth ? (isToday ? Color.primaryNormal : Color.labelNormal) : Color.labelAlternative))
                }
                .frame(height: 44.jsScaled(.touchTarget))

                if hasEvent {
                    Circle()
                        .fill(isSelected ? Color.backgroundAlternative.opacity(0.9) : dateColorIndicator(dateColor))
                        .frame(width: 5.jsScaled(), height: 5.jsScaled())
                        .jsShadow(.small)
                } else if isToday && !isSelected {
                    Circle()
                        .fill(Color.primaryNormal.opacity(0.5))
                        .frame(width: 4.jsScaled(), height: 4.jsScaled())
                } else {
                    Spacer().frame(height: 5.jsScaled())
                }
            }
            .padding(.horizontal, .jsXS)
            .frame(height: 60.jsScaled())
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel(for: date, hasEvent: hasEvent))
        .accessibilityValue(isSelected ? "선택됨" : (isToday ? "오늘" : ""))
        .accessibilityHint("이 날짜의 작심 기록을 확인합니다")
    }

    private func dateColorBackground(_ color: JSCalendarDateColor) -> Color {
        switch color {
        case .none:
            return Color.clear
        case .low:
            return Color.destructive.opacity(0.1)
        case .medium:
            return Color.cautionary.opacity(0.1)
        case .high:
            return Color.positive.opacity(0.1)
        }
    }

    private func dateColorIndicator(_ color: JSCalendarDateColor) -> Color {
        switch color {
        case .none:
            return Color.primaryNormal
        case .low:
            return Color.destructive
        case .medium:
            return Color.cautionary
        case .high:
            return Color.positive
        }
    }

    private var scopeText: String {
        scope == .month ? "월간 보기" : "주간 보기"
    }

    private var headerTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = locale
        return formatter.string(from: viewDate)
    }

    private func weekdayTitle(for index: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        return formatter.shortWeekdaySymbols[index]
    }

    private func movePage(by value: Int) {
        if scope == .month {
            if let nextMonth = calendar.date(byAdding: .month, value: value, to: viewDate) {
                viewDate = nextMonth
            }
        } else {
            if let nextWeek = calendar.date(byAdding: .weekOfYear, value: value, to: viewDate) {
                viewDate = nextWeek
                selectedDate = nextWeek
            }
        }
    }

    private func moveToToday() {
        let today = Date()
        selectedDate = today
        viewDate = startOfMonth(for: today)
        if scope == .week {
            viewDate = today
        }
    }

    private func alignViewDate(for scope: JSCalendarScope, selectedDate: Date) {
        switch scope {
        case .month:
            viewDate = startOfMonth(for: selectedDate)
        case .week:
            viewDate = selectedDate
        }
    }

    private func calendarPagingButton(
        systemName: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: { withAnimation(JSAnimation.navigation) { action() } }) {
            Image(systemName: systemName)
                .font(.jsBody14Semibold)
                .foregroundColor(Color.labelNormal)
                .frame(width: 44.jsScaled(.touchTarget), height: 44.jsScaled(.touchTarget))
                .background(
                    RoundedRectangle(cornerRadius: .jsRadiusMD)
                        .fill(Color.backgroundAlternative)
                        .jsShadow(.small)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private func accessibilityLabel(for date: Date, hasEvent: Bool) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "M월 d일 EEEE"

        var parts = [formatter.string(from: date)]
        if calendar.isDateInToday(date) {
            parts.append("오늘")
        }
        if hasEvent {
            parts.append("기록 있음")
        } else {
            parts.append("기록 없음")
        }
        return parts.joined(separator: ", ")
    }

    private func startOfMonth(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    private var daysInMonth: [Date] {
        guard calendar.range(of: .day, in: .month, for: viewDate) != nil,
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: viewDate))
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offset = firstWeekday - 1
        
        guard let startGridDate = calendar.date(byAdding: .day, value: -offset, to: firstDayOfMonth) else { return [] }
        
        return (0..<42).compactMap { calendar.date(byAdding: .day, value: $0, to: startGridDate) }
    }

    private var daysInWeek: [Date] {
        let weekday = calendar.component(.weekday, from: viewDate)
        let offset = weekday - 1
        
        guard let startOfWeek = calendar.date(byAdding: .day, value: -offset, to: viewDate) else { return [] }
        
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}
