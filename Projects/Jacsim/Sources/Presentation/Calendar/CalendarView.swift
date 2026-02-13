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
        RedesignScreenScaffold(
            title: "캘린더",
            subtitle: "날짜별 작심 인증 상태를 확인해요",
            state: screenState
        ) {
            RedesignSectionCard(
                title: formattedSelectedDate,
                subtitle: "\(tasksForSelectedDate.count)개의 작심"
            ) {
                JSCalendar(
                    selectedDate: $store.selectedDate,
                    scope: store.calendarScope,
                    eventDates: store.eventDates,
                    dateColors: convertDateColors(store.dateColors)
                )
                .onChange(of: store.selectedDate) {
                    store.send(.dateSelected(store.selectedDate))
                }
            }

            RedesignSectionCard(title: "오늘의 기록") {
                let tasksForDate = tasksForSelectedDate

                if tasksForDate.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: .jsSM) {
                        ForEach(tasksForDate) { task in
                            taskRow(task: task)
                        }
                    }
                }
            }
        }
        .onAppear { store.send(.onAppear) }
    }

    private var screenState: RedesignScreenState {
        if store.isLoading {
            return .loading(message: "캘린더 기록을 준비하는 중이에요")
        }

        if store.loadFailed {
            return .error(
                RedesignErrorStateModel(
                    title: "캘린더를 불러오지 못했어요",
                    message: "잠시 후 다시 시도해 주세요",
                    retry: RetryActionModel {
                        store.send(.onAppear)
                    }
                )
            )
        }

        if store.tasks.isEmpty {
            return .empty(
                RedesignEmptyStateModel(
                    title: "표시할 작심이 없어요",
                    message: "작심을 시작하면 날짜별 인증 상태를 볼 수 있어요",
                    icon: "calendar.badge.plus"
                )
            )
        }

        return .content
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
        VStack(spacing: .jsMD) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.jsDisplayScaledSemiBold(size: 48))
                .foregroundColor(.labelAssistive)
            Text("이 날은 작심이 없어요")
                .font(.jsBodyMedium)
                .foregroundColor(.labelAlternative)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .jsXL)
    }
    
    private func taskRow(task: Domain.Task) -> some View {
        let isCompleted = isTaskCompleted(task, on: store.selectedDate)
        
        return JSListItem(
            title: task.title,
            icon: isCompleted ? "checkmark.circle.fill" : "circle",
            iconColor: isCompleted ? .primaryNormal : .labelDisable,
            accessory: isCompleted ? .checkmark(isSelected: true) : .none
        )
        .padding(.vertical, .jsXS)
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(Color.backgroundAlternative)
                .jsShadow(JSShadow.small)
        )
    }

    private var formattedSelectedDate: String {
        DateFormatType.toString(store.selectedDate, to: .fullWithoutYear)
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

    private func convertDateColors(_ colors: [Date: Domain.TaskSuccessRate]) -> [Date: JSCalendarDateColor] {
        var result: [Date: JSCalendarDateColor] = [:]
        for (date, rate) in colors {
            switch rate {
            case .low:
                result[date] = .low
            case .medium:
                result[date] = .medium
            case .high:
                result[date] = .high
            default:
                break
            }
        }
        return result
    }
}
