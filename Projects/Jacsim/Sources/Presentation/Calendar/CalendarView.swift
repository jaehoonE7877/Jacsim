import SwiftUI
import ComposableArchitecture
import DSKit
import Domain

public struct CalendarView: View {
    @Bindable var store: StoreOf<CalendarFeature>

    public init(store: StoreOf<CalendarFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("캘린더")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.labelStrong)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 16)

            JSCalendar(
                selectedDate: $store.selectedDate,
                scope: store.calendarScope,
                eventDates: store.eventDates
            )
            .onChange(of: store.selectedDate) {
                store.send(.dateSelected(store.selectedDate))
            }
            .padding(.horizontal, 16)
            
            ScrollView {
                VStack(spacing: 16) {
                    let tasksForDate = tasksForSelectedDate
                    
                    if tasksForDate.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(tasksForDate) { task in
                            taskRow(task: task)
                        }
                    }
                }
                .padding(.jsXL)
            }
        }
        .background(Color.backgroundNormal)
        .onAppear { store.send(.onAppear) }
    }
    
    private var tasksForSelectedDate: [Domain.Task] {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: store.selectedDate)
        
        return store.tasks.filter { task in
            let start = calendar.startOfDay(for: task.startDate)
            let end = calendar.startOfDay(for: task.endDate)
            return targetDate >= start && targetDate <= end
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.3))
            Text("이 날은 작심이 없어요")
                .font(.system(size: 16))
                .foregroundColor(.labelAlternative)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
    
    private func taskRow(task: Domain.Task) -> some View {
        let isCompleted = isTaskCompleted(task, on: store.selectedDate)
        
        return JSListItem(
            title: task.title,
            icon: isCompleted ? "checkmark.circle.fill" : "circle",
            iconColor: isCompleted ? .primaryNormal : .labelDisable,
            accessory: isCompleted ? .checkmark(isSelected: true) : .disclosure
        )
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private func isTaskCompleted(_ task: Domain.Task, on date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        
        if let dailyRecord = task.records.first(where: {
            calendar.isDate($0.date, inSameDayAs: targetDate)
        }) {
            return dailyRecord.check
        }
        return false
    }
}
