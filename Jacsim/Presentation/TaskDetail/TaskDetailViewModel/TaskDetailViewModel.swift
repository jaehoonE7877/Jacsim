//
//  TaskDetailViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/14.
//

import Foundation

import RxCocoa
import RxSwift

final class TaskDetailViewModel {
    
    private(set) var jacsimTask: UserJacsim
    //MARK: - Dependecy
    private let documentManager: DocumentManager
    private let repository: JacsimRepository
    
    init(jacsimTask: UserJacsim, repository: JacsimRepository = JacsimRepository.shared, doucumentManager: DocumentManager = DocumentManager.shared) {
        self.jacsimTask = jacsimTask
        self.repository = repository
        self.documentManager = doucumentManager
    }
    
    // collectionView cell개수
    func configCellTitle() -> [Date] {
        
        var dayArray: [Date] = []
        
        for date in stride(from: jacsimTask.startDate, to: (jacsimTask.endDate) + 86400, by: 86400 ){
            dayArray.append(date)
        }
        
        return dayArray
    }
    
}

extension TaskDetailViewModel {
    
    var showStartDate: String {
        return DateFormatType.toString(jacsimTask.startDate, to: .full)
    }
    
    var showEndDate: String {
        return DateFormatType.toString(jacsimTask.endDate, to: .full)
    }
    
    var showAlarm: String {
        if let alarm = jacsimTask.alarm {
            return DateFormatType.toString(alarm, to: .time)
        } else {
             return "설정된 알람이 없습니다."
        }
    }
    
    var loadMainImage: UIImage {
        return documentManager.loadImageFromDocument(fileName: "\(String(describing: jacsimTask.id)).jpg") ?? UIImage.jacsimImage
    }
    
    var showCertified: String {
        
        if jacsimTask.success - repository.checkCertified(item: jacsimTask) > 0 {
            return "작심 성공까지 \(jacsimTask.success - repository.checkCertified(item: jacsimTask))회 남았습니다!"
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
        return documentManager.loadImageFromDocument(fileName: "\(jacsimTask.id)_\(dateText).jpg") ?? UIImage.jacsimImage
    }
    
    func checkIsSuccess() {
        repository.checkIsSuccess(item: jacsimTask)
    }
    
    func deleteAlarm() {
        repository.deleteAlarm(item: jacsimTask)
    }
    
    func deleteJacsim() {
        
        if self.repository.checkCertified(item: jacsimTask) == 0 {
            
            self.repository.deleteJacsim(item: jacsimTask)
            
        } else {
            // 인증이 있을 때
            let dayArray = configCellTitle()
            
            for index in 0...self.repository.checkCertified(item: jacsimTask) - 1 {
        
                let dateText = DateFormatType.toString(dayArray[index], to: .fullWithoutYear)
                self.repository.removeImageFromDocument(fileName: "\(jacsimTask.id)_\(dateText).jpg")
            }
            
            self.repository.deleteJacsim(item: jacsimTask)
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
        cell.certifiedMemo.text = jacsimTask.memoList[indexPath.row].memo
        
        guard let image = self.documentManager.loadImageFromDocument(fileName: "\(jacsimTask.id)_\(dateText).jpg") else { return UICollectionViewCell()}
        cell.certifiedImageView.image = image
        
        return cell
        
    }
    
}
