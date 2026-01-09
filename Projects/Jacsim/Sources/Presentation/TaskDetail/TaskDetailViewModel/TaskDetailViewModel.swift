//
//  TaskDetailViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/14.
//

import Combine
import UIKit

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
    private let documentManager: DocumentManager
    private var task: UserJacsim

    init(task: UserJacsim,
         repository: JacsimRepositoryProtocol = JacsimRepository.shared,
         documentManager: DocumentManager = .shared) {
        self.task = task
        self.repository = repository
        self.documentManager = documentManager
    }

    var currentTask: UserJacsim {
        task
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
        }
        return "설정된 알람이 없습니다."
    }

    var mainImageIdentifier: String {
        task.mainImageURL
    }

    var remainingSuccessCount: Int {
        max(task.success - repository.checkCertified(item: task), 0)
    }

    var dayViewData: [DayViewData] {
        let dates = task.jacsimDayArray
        return dates.enumerated().map { index, date in
            let memo: String
            let isChecked: Bool
            if task.memoList.indices.contains(index) {
                memo = task.memoList[index].memo
                isChecked = task.memoList[index].check
            } else {
                memo = "인증해주세요"
                isChecked = false
            }
            let dateText = DateFormatType.toString(date, to: .fullWithoutYear)
            let imageIdentifier = "\(task.id)_\(dateText).jpg"
            return DayViewData(date: date, memo: memo, imageIdentifier: imageIdentifier, isChecked: isChecked)
        }
    }

    func refreshTaskStatus() {
        repository.checkIsDone(items: [task])
        repository.checkIsSuccess(item: task)
    }

    func deleteAlarm() {
        repository.deleteAlarm(item: task)
    }

    func deleteJacsim() {
        if repository.checkCertified(item: task) == 0 {
            repository.deleteJacsim(item: task)
            return
        }

        for date in task.jacsimDayArray {
            let dateText = DateFormatType.toString(date, to: .fullWithoutYear)
            repository.removeImageFromDocument(fileName: "\(task.id)_\(dateText).jpg")
        }
        repository.deleteJacsim(item: task)
    }
}
