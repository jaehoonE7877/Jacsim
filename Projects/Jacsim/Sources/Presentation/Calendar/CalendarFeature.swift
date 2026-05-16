import Domain
import DSKit
import Foundation
import Observation

@MainActor
@Observable
public final class CalendarModel {
    public var selectedDate: Date = Date()
    public var datePickerDate: Date = Date()
    public var isDatePickerPresented: Bool = false
    public var calendarScope: JSCalendarScope = .month
    public var tasks: [Domain.Task] = []
    public var eventDates: [Date] = []
    public var dateColors: [Date: TaskSuccessRate] = [:]
    public var isLoading: Bool = false
    public var loadFailed: Bool = false

    @ObservationIgnored private let dependencies: JacsimDependencies
    @ObservationIgnored private var loadTask: _Concurrency.Task<Void, Never>?

    public init(dependencies: JacsimDependencies) {
        self.dependencies = dependencies
    }

    deinit {
        loadTask?.cancel()
    }

    public func loadTasks() {
        isLoading = true
        loadFailed = false
        loadTask?.cancel()
        loadTask = _Concurrency.Task { [dependencies] in
            do {
                let tasks = try await dependencies.taskQueryClient.fetchActiveTasks()
                tasksResponse(tasks)
            } catch {
                tasksLoadFailed()
            }
        }
    }

    public func dateSelected(_ date: Date) {
        selectedDate = date
    }

    public func datePickerButtonTapped() {
        datePickerDate = selectedDate
        isDatePickerPresented = true
    }

    public func datePickerConfirmed() {
        selectedDate = datePickerDate
        isDatePickerPresented = false
    }

    public func datePickerDismissed() {
        datePickerDate = selectedDate
        isDatePickerPresented = false
    }

    private func tasksResponse(_ tasks: [Domain.Task]) {
        self.tasks = tasks
        eventDates = dependencies.calendarEventService.calculateEventDates(from: tasks)
        dateColors = dependencies.calendarEventService.calculateDateColors(from: tasks)
        isLoading = false
        loadFailed = false
    }

    private func tasksLoadFailed() {
        isLoading = false
        loadFailed = true
    }
}
