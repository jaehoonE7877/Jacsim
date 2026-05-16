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
            title: "탐색",
            state: screenState
        ) {
            RedesignSectionCard(title: "날짜") {
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

            RedesignSectionCard(title: "인증 피드") {
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
            return .loading(message: "기록을 불러오는 중")
        }

        if model.loadFailed {
            return .error(
                RedesignErrorStateModel(
                    title: "기록을 불러오지 못했어요",
                    message: "다시 시도해 주세요",
                    retry: RetryActionModel {
                        model.loadTasks()
                    }
                )
            )
        }

        if model.tasks.isEmpty {
            return .empty(
                RedesignEmptyStateModel(
                    title: "아직 작심이 없어요",
                    message: "첫 작심을 시작해 보세요",
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
            Text("이 날은 비어 있어요")
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
                    .foregroundColor(.v2BrandBlue)
                    .frame(width: 36.jsScaled(), height: 36.jsScaled())
                    .background(
                        Circle()
                            .fill(Color.v2BrandBlueSoft)
                    )

                VStack(alignment: .leading, spacing: .jsMicro) {
                    Text(formattedSelectedDate)
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelStrong)

                    Text("\(tasksForSelectedDate.count)개 작심")
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
                    .fill(Color.v2Surface)
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint("날짜 선택 화면을 엽니다")
    }
    
    private func taskRow(task: Domain.Task) -> some View {
        let isCompleted = isTaskCompleted(task, on: model.selectedDate)
        
        return HStack(spacing: .jsSM) {
            ZStack {
                RoundedRectangle(cornerRadius: 18.jsScaled(), style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isCompleted
                                ? [Color.v2BrandBlue.opacity(0.86), Color.positive.opacity(0.82)]
                                : [Color.v2Surface, Color.v2BrandBlueSoft],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: isCompleted ? "checkmark.circle.fill" : "camera.fill")
                    .font(.jsHeadlineLarge)
                    .foregroundColor(isCompleted ? .white : .v2BrandBlue)
            }
            .frame(width: 74.jsScaled(), height: 74.jsScaled())
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: .jsXS) {
                Text(task.title)
                    .font(.jsHeadlineSmall)
                    .foregroundColor(.labelStrong)
                    .lineLimit(2)

                Text(taskDateRange(task))
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelAlternative)
                    .lineLimit(1)

                JSV2StatusChip(
                    isCompleted ? "인증 완료" : "인증 전",
                    systemImage: isCompleted ? "checkmark.circle.fill" : "circle",
                    style: isCompleted ? .success : .neutral
                )
            }

            Spacer(minLength: .jsXS)
        }
        .padding(.jsSM)
        .jsv2CardSurface(cornerRadius: 20.jsScaled(), shadowOpacity: 0.05)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(task.title), \(formattedSelectedDate), \(isCompleted ? "인증 완료" : "인증 전")")
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

    private func taskDateRange(_ task: Domain.Task) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M.d"
        return "\(formatter.string(from: task.startDate)) - \(formatter.string(from: task.endDate))"
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
