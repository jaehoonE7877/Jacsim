import SwiftUI
import ComposableArchitecture
import DesignSystem
import Domain

public struct CalendarView: View {
    @Bindable var store: StoreOf<CalendarFeature>

    public init(store: StoreOf<CalendarFeature>) {
        self.store = store
    }

    public var body: some View {
        let context = selectedDateContext

        RedesignScreenScaffold(
            title: "캘린더",
            subtitle: "날짜를 고르면 그날의 작심 흐름을 바로 살펴볼 수 있어요",
            state: screenState
        ) {
            RedesignSectionCard(
                title: context.formattedSelectedDate,
                subtitle: context.selectionSubtitle
            ) {
                VStack(spacing: .jsSM) {
                    JSCalendar(
                        selectedDate: $store.selectedDate,
                        scope: $store.calendarScope,
                        eventDates: store.eventDates,
                        dateColors: convertDateColors(store.dateColors)
                    )
                    .onChange(of: store.selectedDate) { _, newValue in
                        handleDateSelection(newValue)
                    }

                    selectedDateSummary(context: context)
                }
            }

            RedesignSectionCard(
                title: "선택한 날짜 리뷰",
                subtitle: context.reviewSubtitle
            ) {
                if context.tasks.isEmpty {
                    emptyStateView
                } else {
                    VStack(alignment: .leading, spacing: .jsSM) {
                        Text(context.reviewNarrative)
                            .font(.jsLabelLarge)
                            .foregroundColor(.labelStrong)

                        ForEach(context.tasks) { task in
                            taskRow(task: task, selectedDate: context.selectedDate)
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
    
    private func selectedDateSummary(context: SelectedDateContext) -> some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            summaryChip(
                icon: "calendar",
                text: context.formattedSelectedDate,
                tint: .primaryNormal
            )

            HStack(spacing: .jsXS) {
                summaryChip(
                    icon: "checkmark.circle.fill",
                    text: "\(context.completedTasksCount) 완료",
                    tint: .positive
                )

                if context.pendingTasksCount > 0 {
                    summaryChip(
                        icon: "clock.fill",
                        text: "\(context.pendingTasksCount) 남음",
                        tint: .cautionary
                    )
                }
            }

            Text(context.tasks.isEmpty ? "날짜를 바꾸면 해당 날짜의 작심과 인증 상태를 이어서 볼 수 있어요." : context.reviewNarrative)
                .font(.jsBodySmall)
                .foregroundColor(.labelNeutral)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .jsSM)
        .padding(.vertical, .jsSM)
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                .fill(Color.backgroundAlternative)
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: .jsMD) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.jsDisplayScaledSemiBold(size: 48))
                .foregroundColor(.labelAlternative)
            Text("선택한 날짜에는 진행 중인 작심이 없어요")
                .font(.jsBodyMedium)
                .foregroundColor(.labelStrong)
            Text("다른 날짜를 고르거나 새 작심을 시작하면 여기에서 바로 기록을 살펴볼 수 있어요.")
                .font(.jsBodySmall)
                .foregroundColor(.labelNeutral)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .jsXL)
    }
    
    private func taskRow(task: Domain.Task, selectedDate: Date) -> some View {
        let isCompleted = isTaskCompleted(task, on: selectedDate)
        
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

    private func summaryChip(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: .jsMicro) {
            Image(systemName: icon)
                .font(.jsLabelMedium)
            Text(text)
                .font(.jsLabelMedium)
                .lineLimit(1)
        }
        .foregroundColor(tint)
        .padding(.horizontal, .jsXS)
        .padding(.vertical, .jsMicro)
        .background(
            Capsule()
                .fill(tint.opacity(0.12))
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

    private func handleDateSelection(_ date: Date) {
        store.send(.dateSelected(date))
    }

    private var selectedDateContext: SelectedDateContext {
        SelectedDateContext(
            selectedDate: store.selectedDate,
            tasks: tasksForSelectedDate,
            formattedSelectedDate: DateFormatType.toString(store.selectedDate, to: .fullWithoutYear)
        )
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

private struct SelectedDateContext {
    let selectedDate: Date
    let tasks: [Domain.Task]
    let formattedSelectedDate: String
    let completedTasksCount: Int

    init(selectedDate: Date, tasks: [Domain.Task], formattedSelectedDate: String) {
        self.selectedDate = selectedDate
        self.tasks = tasks
        self.formattedSelectedDate = formattedSelectedDate
        self.completedTasksCount = tasks.filter { Self.isTaskCompleted($0, on: selectedDate) }.count
    }

    var pendingTasksCount: Int {
        max(tasks.count - completedTasksCount, 0)
    }

    var selectionSubtitle: String {
        if tasks.isEmpty {
            return "진행 중인 작심이 없어요"
        }
        return "\(completedTasksCount)개 완료 · \(pendingTasksCount)개 남음"
    }

    var reviewSubtitle: String {
        if tasks.isEmpty {
            return "다른 날짜를 선택해 기록을 확인해 보세요"
        }
        return "\(tasks.count)개의 작심을 한 번에 확인해요"
    }

    var reviewNarrative: String {
        if pendingTasksCount == 0 {
            return "선택한 날짜의 작심을 모두 마쳤어요."
        }
        if completedTasksCount == 0 {
            return "아직 남아 있는 작심이 있어요. 한 항목씩 상태를 확인해 보세요."
        }
        return "\(completedTasksCount)개를 완료했고 \(pendingTasksCount)개가 남아 있어요."
    }

    private static func isTaskCompleted(_ task: Domain.Task, on date: Date) -> Bool {
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
