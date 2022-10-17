//
//  TaskDetailViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/14.
//

import UIKit

final class TaskDetailViewModel {
    
    private let repository = JacsimRepository()
    
    var task: UserJacsim?
    
    var jacsimDays: Int = 0
    var dayArray: [Date] = []
    
    var showStartDate: String {
        return DateFormatType.toString(task?.startDate ?? Date(), to: .full)
    }
    
    var showEndDate: String {
        return DateFormatType.toString(task?.endDate ?? Date(), to: .full)
    }
    
    var showAlarm: String {
        if let alarm = task?.alarm {
            return DateFormatType.toString(alarm, to: .time)
        } else {
             return "설정된 알람이 없습니다."
        }
    }
    
    var loadMainImage: String {
        return "\(String(describing: task?.id)).jpg"
    }
    
    var showCertified: String {
        guard let task = task else { return ""}
        if task.success - repository.checkCertified(item: task) > 0 {
            return "작심 성공까지 \(task.success - repository.checkCertified(item: task))회 남았습니다!"
        } else {
            return "목표를 달성했습니다! 끝까지 힘내세요!!"
        }
    }
    
}

extension TaskDetailViewModel {
    
    func checkIsSuccess() {
        guard let task = task else { return }
        repository.checkIsSuccess(item: task)
    }
    
}
