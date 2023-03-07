//
//  TaskDetailViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/14.
//

import UIKit

final class TaskDetailViewModel {
    
    private let repository = JacsimRepository()
    
    var task: Observable<UserJacsim> = Observable(UserJacsim())
    
    private let documentManager = DocumentManager.shared
    
    // collectionView cell개수
    func configCellTitle() -> [Date] {
        
        var dayArray: [Date] = []
        
        for date in stride(from: task.value.startDate, to: (task.value.endDate) + 86400, by: 86400 ){
            dayArray.append(date)
        }
        
        return dayArray
    }
    
}

extension TaskDetailViewModel {
    
    var showStartDate: String {
        return DateFormatType.toString(task.value.startDate, to: .full)
    }
    
    var showEndDate: String {
        return DateFormatType.toString(task.value.endDate, to: .full)
    }
    
    var showAlarm: String {
        if let alarm = task.value.alarm {
            return DateFormatType.toString(alarm, to: .time)
        } else {
             return "설정된 알람이 없습니다."
        }
    }
    
    var loadMainImage: UIImage {
        return documentManager.loadImageFromDocument(fileName: "\(String(describing: task.value.id)).jpg") ?? UIImage.jacsimImage
    }
    
    var showCertified: String {
        
        if task.value.success - repository.checkCertified(item: task.value) > 0 {
            return "작심 성공까지 \(task.value.success - repository.checkCertified(item: task.value))회 남았습니다!"
        } else {
            return "목표를 달성했습니다! 끝까지 힘내세요!!"
        }
    }
    
    func checkIsToday(indexPath: IndexPath) -> Bool {
        
        let dayArray = configCellTitle()
        
        let dateText = DateFormatType.toString(dayArray[indexPath.item], to: .fullWithoutYear)
        
        return DateFormatType.toString(Date(), to: .fullWithoutYear) == dateText
    }
    
    var scrollToCurrentDate: Int {
        // 시작일이 오늘과 같거나, 다음 날이면 그대로 이후면 이후 날짜(순서 2번)를 왼쪽으로
        let now = Date()
        let dateArray = configCellTitle()
        var count = 0
        
        for index in 0...dateArray.count - 1 {
            if dateArray[index].year == now.year,
               dateArray[index].month == now.month,
               dateArray[index].day == now.day {
                count = index
            }
        }
        return count
    }
    
    func fetchTodayImage(index: Int) -> UIImage {
        let dayArray = configCellTitle()
        let dateText = DateFormatType.toString(dayArray[index], to: .fullWithoutYear)
        return documentManager.loadImageFromDocument(fileName: "\(task.value.id)_\(dateText).jpg") ?? UIImage.jacsimImage
    }
    
    func checkIsSuccess() {
        repository.checkIsSuccess(item: task.value)
    }
    
    func deleteAlarm() {
        repository.deleteAlarm(item: task.value)
    }
    
    func deleteJacsim() {
        
        if self.repository.checkCertified(item: task.value) == 0 {
            
            self.repository.deleteJacsim(item: task.value)
            
        } else {
            // 인증이 있을 때
            let dayArray = configCellTitle()
            
            for index in 0...self.repository.checkCertified(item: task.value) - 1 {
        
                let dateText = DateFormatType.toString(dayArray[index], to: .fullWithoutYear)
                self.repository.removeImageFromDocument(fileName: "\(task.value.id)_\(dateText).jpg")
            }
            
            self.repository.deleteJacsim(item: task.value)
        }
    }
}

//MARK: CollectionView
extension TaskDetailViewModel {
    
    func cellForItemAt(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskDetailCollectionViewCell.reuseIdentifier, for: indexPath) as? TaskDetailCollectionViewCell
        else { return UICollectionViewCell() }
        
        let dayArray = configCellTitle()
        
        let dateText = DateFormatType.toString(dayArray[indexPath.item], to: .fullWithoutYear)
        
        cell.dateLabel.text = dateText
        cell.certifiedMemo.text = task.value.memoList[indexPath.row].memo
        
        guard let image = self.documentManager.loadImageFromDocument(fileName: "\(task.value.id)_\(dateText).jpg") else { return UICollectionViewCell()}
        cell.certifiedImageView.image = image
        
        return cell
        
    }
    
}
