import SwiftUI
import DSKit
import Domain

public struct CalendarView: View {
    @Bindable var model: CalendarModel

    public init(model: CalendarModel) {
        self.model = model
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "캘린더",
            subtitle: "날짜별 작심 인증 상태를 확인해요",
            state: screenState
        ) {
            RedesignSectionCard(
                title: "날짜 선택",
                subtitle: "\(formattedSelectedDate) · \(tasksForSelectedDate.count)개의 작심"
            ) {
                selectedDateButton

                JSCalendar(
                    selectedDate: $model.selectedDate,
                    scope: model.calendarScope,
                    eventDates: model.eventDates,
                    dateColors: convertDateColors(model.dateColors)
                )
                .onChange(of: model.selectedDate) {
                    model.dateSelected(model.selectedDate)
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
        .onAppear { model.loadTasks() }
        .overlay {
            JSDatePickerBottomSheet(
                selectedDate: $model.datePickerDate,
                isPresented: $model.isDatePickerPresented,
                title: "날짜 선택",
                onConfirm: {
                    model.datePickerConfirmed()
                },
                onDismiss: {
                    model.datePickerDismissed()
                }
            )
        }
    }

    private var screenState: RedesignScreenState {
        if model.isLoading {
            return .loading(message: "캘린더 기록을 준비하는 중이에요")
        }

        if model.loadFailed {
            return .error(
                RedesignErrorStateModel(
                    title: "캘린더를 불러오지 못했어요",
                    message: "잠시 후 다시 시도해 주세요",
                    retry: RetryActionModel {
                        model.loadTasks()
                    }
                )
            )
        }

        if model.tasks.isEmpty {
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
        let targetDate = calendar.startOfDay(for: model.selectedDate)
        
        return model.tasks.filter { task in
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

    private var selectedDateButton: some View {
        Button {
            model.datePickerButtonTapped()
        } label: {
            HStack(spacing: .jsSM) {
                Image(systemName: "calendar")
                    .font(.jsHeadlineSmall)
                    .foregroundColor(.primaryNormal)
                    .frame(width: 36.jsScaled(), height: 36.jsScaled())
                    .background(
                        Circle()
                            .fill(Color.primaryNormal.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: .jsMicro) {
                    Text(formattedSelectedDate)
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelStrong)

                    Text("탭해서 날짜를 빠르게 이동")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelAlternative)
                }

                Spacer(minLength: .jsXS)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelAlternative)
            }
            .padding(.jsSM)
            .background(
                RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                    .fill(Color.backgroundStrong)
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint("날짜 선택 화면을 엽니다")
    }
    
    private func taskRow(task: Domain.Task) -> some View {
        let isCompleted = isTaskCompleted(task, on: model.selectedDate)
        
        return JSListItem(
            title: task.title,
            icon: isCompleted ? "checkmark.circle.fill" : "circle",
            iconColor: isCompleted ? .primaryNormal : .labelDisable,
            accessory: isCompleted ? .checkmark(isSelected: true) : .disclosure
        )
        .padding(.vertical, .jsXS)
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(Color.backgroundAlternative)
                .jsShadow(JSShadow.small)
        )
    }

    private var formattedSelectedDate: String {
        DateFormatType.toString(model.selectedDate, to: .fullWithoutYear)
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
