import SwiftUI
import DSKit
import Domain

public struct CalendarView: View {
    @Bindable var model: CalendarModel

    public init(model: CalendarModel) {
        self.model = model
    }

    public var body: some View {
        ZStack {
            LinearGradient.wallpaperForest
                .ignoresSafeArea()
            Color.backgroundNormal.opacity(0.22)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: .jsLG) {
                    header
                    modePicker
                    calendarSurface
                    selectedDateSummary
                }
                .padding(.horizontal, .jsMD)
                .padding(.top, .jsLG)
                .padding(.bottom, 112.jsScaled())
            }
        }
        .onAppear { model.loadTasks() }
        .overlay {
            dayRecordSheet
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: .jsXS) {
            Text("달력")
                .font(.jsSerifDisplay)
                .foregroundColor(.labelStrong)

            Text("월간 기록과 84일 흐름을 함께 봅니다")
                .font(.jsBodySmall)
                .foregroundColor(.labelAlternative)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("달력, 월간 기록과 84일 흐름")
    }

    private var modePicker: some View {
        Picker("달력 보기", selection: $model.displayMode) {
            ForEach(CalendarDisplayMode.allCases, id: \.self) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("달력 보기 방식")
    }

    @ViewBuilder
    private var calendarSurface: some View {
        if model.isLoading {
            JSGlassCard(accessibilityLabel: "캘린더 로딩") {
                HStack(spacing: .jsSM) {
                    ProgressView()
                        .tint(.primaryNormal)
                    Text("캘린더 기록을 준비하는 중이에요")
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelAlternative)
                }
            }
        } else if model.loadFailed {
            JSGlassCard(accessibilityLabel: "캘린더 오류") {
                VStack(alignment: .leading, spacing: .jsSM) {
                    Text("캘린더를 불러오지 못했어요")
                        .font(.jsSerifTitle)
                        .foregroundColor(.labelStrong)
                    JSButton(title: "다시 시도", style: .secondary, size: .medium) {
                        model.loadTasks()
                    }
                }
            }
        } else if model.displayMode == .month {
            JSCalendarV2(selectedDate: $model.selectedDate, eventStates: eventStates)
                .onChange(of: model.selectedDate) { _, newDate in
                    model.dateSelected(newDate)
                }
        } else {
            JSGlassCard(accessibilityLabel: "84일 히트맵") {
                VStack(alignment: .leading, spacing: .jsMD) {
                    Text("84일 히트맵")
                        .font(.jsSerifTitle)
                        .foregroundColor(.labelStrong)
                    JSStreakHeatmap(states: eventStates, endDate: model.selectedDate)
                }
            }
        }
    }

    private var selectedDateSummary: some View {
        JSGlassCard(accessibilityLabel: "\(formattedSelectedDate) 기록") {
            VStack(alignment: .leading, spacing: .jsMD) {
                HStack {
                    VStack(alignment: .leading, spacing: .jsMicro) {
                        Text(formattedSelectedDate)
                            .font(.jsSerifTitle)
                            .foregroundColor(.labelStrong)
                        Text("\(tasksForSelectedDate.count)개의 작심")
                            .font(.jsMonoSmall)
                            .foregroundColor(.labelAlternative)
                    }
                    Spacer()
                    Button {
                        model.isDaySheetPresented = true
                    } label: {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.jsHeadlineMedium)
                            .foregroundColor(.forestAccent)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("선택 날짜 기록 보기")
                }

                if tasksForSelectedDate.isEmpty {
                    Text("이 날은 작심이 없어요")
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelAlternative)
                } else {
                    VStack(spacing: .jsXS) {
                        ForEach(tasksForSelectedDate.prefix(3)) { task in
                            taskRow(task)
                        }
                    }
                }
            }
        }
    }

    private var dayRecordSheet: some View {
        JSBottomSheet(
            isPresented: $model.isDaySheetPresented,
            style: .contentHeight,
            allowsInteractiveDismiss: true,
            glass: true,
            onDismiss: { model.daySheetDismissed() }
        ) {
            VStack(alignment: .leading, spacing: .jsMD) {
                Text(formattedSelectedDate)
                    .font(.jsSerifTitle)
                    .foregroundColor(.labelStrong)
                    .padding(.horizontal, .jsLG)
                    .padding(.top, .jsSM)

                if tasksForSelectedDate.isEmpty {
                    Text("선택한 날짜에 기록이 없습니다")
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelAlternative)
                        .padding(.horizontal, .jsLG)
                        .padding(.bottom, .jsLG)
                } else {
                    VStack(spacing: .jsXS) {
                        ForEach(tasksForSelectedDate) { task in
                            taskRow(task)
                        }
                    }
                    .padding(.horizontal, .jsLG)
                    .padding(.bottom, .jsLG)
                }
            }
        }
    }

    private func taskRow(_ task: Domain.Task) -> some View {
        let completed = isTaskCompleted(task, on: model.selectedDate)
        return JSListItem(
            title: task.title,
            subtitle: completed ? "인증 완료" : "인증 대기",
            icon: completed ? "checkmark.circle.fill" : "circle",
            iconColor: completed ? .streakCompleted : .labelAlternative,
            accessory: .none
        )
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                .fill(Color.surfaceElevated.opacity(0.24))
        )
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

    private var eventStates: [Date: StreakState] {
        var states: [Date: StreakState] = [:]
        let calendar = Calendar.current
        for task in model.tasks {
            for record in task.records {
                let day = calendar.startOfDay(for: record.date)
                if record.check {
                    states[day] = .completed
                } else if states[day] == nil {
                    states[day] = .active
                }
            }
        }
        return states
    }

    private var formattedSelectedDate: String {
        DateFormatType.toString(model.selectedDate, to: .fullWithoutYear)
    }

    private func isTaskCompleted(_ task: Domain.Task, on date: Date) -> Bool {
        let calendar = Calendar.current
        return task.records.first {
            calendar.isDate($0.date, inSameDayAs: date)
        }?.check ?? false
    }
}
