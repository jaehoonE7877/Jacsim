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

@available(*, deprecated, message: "Use JSCalendarV2")
public struct JSCalendar: View {
    @Binding var selectedDate: Date
    @State private var viewDate: Date
    @State private var scope: JSCalendarScope
    private let eventDates: [Date]
    private let dateColors: [Date: JSCalendarDateColor]
    private let calendar = Calendar.current
    private let locale = Locale(identifier: "ko_KR")

    public init(
        selectedDate: Binding<Date>,
        scope: JSCalendarScope = .month,
        eventDates: [Date] = [],
        dateColors: [Date: JSCalendarDateColor] = [:]
    ) {
        self._selectedDate = selectedDate
        self._viewDate = State(initialValue: selectedDate.wrappedValue)
        self._scope = State(initialValue: scope)
        self.eventDates = eventDates
        self.dateColors = dateColors
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerView
            
            weekdayHeaderView
            
            calendarGridView
                .gesture(gridGesture)
                .animation(.spring(response: 0.35, dampingFraction: 0.82), value: viewDate)
                .animation(.spring(response: 0.35, dampingFraction: 0.82), value: scope)
            
            handleBar
        }
        .background(Color.backgroundNormal)
        .clipped()
    }

    private var headerView: some View {
        HStack(spacing: .jsSM) {
            VStack(alignment: .leading, spacing: 2.jsScaled()) {
                Button(action: { withAnimation { moveToToday() } }) {
                    Text(headerTitle)
                        .font(.jsDisplay22Bold)
                        .foregroundColor(Color.labelNormal)
                        .contentShape(Rectangle())
                }
                Text(scopeText)
                    .font(.jsLabel12Medium)
                    .foregroundColor(Color.labelNeutral)
            }
            Spacer()

            if !calendar.isDateInToday(viewDate) || !calendar.isDate(viewDate, inSameDayAs: selectedDate) {
                Button(action: { withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { moveToToday() } }) {
                    Text("오늘")
                        .font(.jsLabel13Bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12.jsScaled())
                        .padding(.vertical, 8.jsScaled())
                        .background(
                            Capsule()
                                .fill(Color.primaryNormal)
                                .jsShadow(.medium)
                        )
                }
            }

            HStack(spacing: 10.jsScaled()) {
                Button(action: { withAnimation { movePage(by: -1) } }) {
                    Image(systemName: "chevron.left")
                        .font(.jsBody14Semibold)
                        .foregroundColor(Color.labelNormal)
                        .frame(width: 36.jsScaled(), height: 36.jsScaled())
                        .background(
                            RoundedRectangle(cornerRadius: 12.jsScaled())
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                .jsShadow(.small)
                        )
                }
                Button(action: { withAnimation { movePage(by: 1) } }) {
                    Image(systemName: "chevron.right")
                        .font(.jsBody14Semibold)
                        .foregroundColor(Color.labelNormal)
                        .frame(width: 36.jsScaled(), height: 36.jsScaled())
                        .background(
                            RoundedRectangle(cornerRadius: 12.jsScaled())
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                .jsShadow(.small)
                        )
                }
            }
        }
        .padding(.horizontal, 20.jsScaled())
        .padding(.vertical, 10.jsScaled())
        .background(Color.backgroundNormal)
    }

    private var weekdayHeaderView: some View {
        HStack(spacing: 0) {
            ForEach(0..<7) { index in
                Text(weekdayTitle(for: index))
                    .font(.jsLabel13Bold)
                    .foregroundColor(index == 0 ? Color.destructive.opacity(0.8) : (index == 6 ? Color.primaryNormal.opacity(0.8) : .labelNeutral))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4.jsScaled())
            }
        }
        .padding(.horizontal, 16.jsScaled())
        .padding(.vertical, 6.jsScaled())
        .background(Color.clear)
        .zIndex(1)
    }

    private var calendarGridView: some View {
        let days = scope == .month ? daysInMonth : daysInWeek
        let rows = scope == .month ? 6 : 1
        
        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
            spacing: 8.jsScaled()
        ) {
            ForEach(days, id: \.self) { date in
                dayView(for: date)
            }
        }
        .padding(.horizontal, 8.jsScaled())
        .frame(height: CGFloat(rows) * 56.jsScaled())
    }

    private func dayView(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isCurrentMonth = scope == .week || calendar.isDate(date, equalTo: viewDate, toGranularity: .month)
        let hasEvent = eventDates.contains { calendar.isDate($0, inSameDayAs: date) }
        let dateColor = dateColors[date] ?? .none

        return VStack(spacing: 6.jsScaled()) {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12.jsScaled())
                        .fill(Color.primaryNormal)
                        .jsShadow(.medium)
                } else if isToday {
                    RoundedRectangle(cornerRadius: 12.jsScaled())
                        .stroke(Color.primaryNormal.opacity(0.4), lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 12.jsScaled())
                                .fill(Color.primaryNormal.opacity(0.08))
                        )
                } else if hasEvent && !isSelected {
                    RoundedRectangle(cornerRadius: 12.jsScaled())
                        .fill(dateColorBackground(dateColor))
                } else {
                    RoundedRectangle(cornerRadius: 12.jsScaled())
                        .fill(Color.clear)
                }

                Text("\(calendar.component(.day, from: date))")
                    .font(.jsHeadline16Bold)
                    .foregroundColor(isSelected ? .white : (isCurrentMonth ? (isToday ? Color.primaryNormal : Color.labelNormal) : Color.labelAlternative))
            }
            .frame(height: 42.jsScaled())

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
        .padding(.horizontal, 6.jsScaled())
        .frame(height: 58.jsScaled())
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                selectedDate = date
                viewDate = date
            }
        }
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

    private var gridGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                if abs(horizontal) > abs(vertical) && abs(horizontal) > 28.jsScaled() {
                    if horizontal < 0 {
                        movePage(by: 1)
                    } else {
                        movePage(by: -1)
                    }
                } else if abs(vertical) > 28.jsScaled() {
                    if vertical < 0 {
                        switchScope(to: .week)
                    } else {
                        switchScope(to: .month)
                    }
                }
            }
    }

    private var handleBar: some View {
        Capsule()
            .fill(Color.labelDisable.opacity(0.3))
            .frame(width: 44.jsScaled(), height: 4.jsScaled())
            .padding(.vertical, 10.jsScaled())
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

    private func switchScope(to newScope: JSCalendarScope) {
        guard scope != newScope else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            scope = newScope
            alignViewDate(for: newScope)
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

    private func alignViewDate(for scope: JSCalendarScope) {
        switch scope {
        case .month:
            viewDate = startOfMonth(for: selectedDate)
        case .week:
            viewDate = selectedDate
        }
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
