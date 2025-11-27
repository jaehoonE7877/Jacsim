//
//  TaskDetailViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/14.
//

import Foundation

import Core

@MainActor
final class TaskDetailViewModel {

    struct DayViewData {
        let date: Date
        let memo: String
        let imageIdentifier: String
        let isChecked: Bool
    }

    private let repository: JacsimRepositoryProtocol
    private let task: UserJacsim

    init(task: UserJacsim,
         repository: JacsimRepositoryProtocol = JacsimRepository.shared) {
        self.task = task
        self.repository = repository
    }

    var currentTask: UserJacsim {
        task
    }

    var taskTitle: String {
        task.title
    }

    var startDateText: String {
        DateFormatType.toString(task.startDate, to: .full)
    }

    var endDateText: String {
        DateFormatType.toString(task.endDate, to: .full)
    }

    var alarmText: String {
        if let alarm = task.alarm {
            return DateFormatType.toString(alarm, to: .time)
        } else {
            return "설정된 알람이 없습니다."
        }
    }

    var mainImageIdentifier: String {
        "\(task.id).jpg"
    }

    var dayViewData: [DayViewData] {
        var dayArray: [DayViewData] = []

        for (index, date) in stride(from: task.startDate, to: (task.endDate) + 86400, by: 86400).enumerated() {
            let memo = index < task.memoList.count ? task.memoList[index].memo : ""
            let isChecked = index < task.memoList.count ? task.memoList[index].check : false
            let dateText = DateFormatType.toString(date, to: .fullWithoutYear)
            let identifier = "\(task.id)_\(dateText).jpg"
            dayArray.append(DayViewData(date: date, memo: memo, imageIdentifier: identifier, isChecked: isChecked))
        }

        return dayArray
    }

    var remainingSuccessCount: Int {
        max(task.success - repository.checkCertified(item: task), 0)
    }

    var isSuccessAchieved: Bool {
        remainingSuccessCount == 0
    }

    var scrollToCurrentDate: Int {
        let now = Date()
        var count = 0

        for (index, data) in dayViewData.enumerated() {
            if data.date.year == now.year,
               data.date.month == now.month,
               data.date.day == now.day {
                count = index
            }
        }
        return count
    }

    func dayViewData(at index: Int) -> DayViewData? {
        guard dayViewData.indices.contains(index) else { return nil }
        return dayViewData[index]
    }

    func refreshTaskStatus() {
        repository.checkIsDone(item: task, count: dayViewData.count)
        repository.checkIsSuccess(item: task)
    }

    func deleteAlarm() {
        repository.deleteAlarm(item: task)
    }

    func deleteJacsim() {
        if repository.checkCertified(item: task) != 0 {
            dayViewData
                .filter { $0.isChecked }
                .forEach { repository.removeImageFromDocument(fileName: $0.imageIdentifier) }
        }

        repository.deleteJacsim(item: task)
    }
}
