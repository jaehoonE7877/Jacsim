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
    
    private let documentManager = DocumentManager.shared
    
    // collectionView cell개수
    func configCellTitle() -> [Date] {
        
        var dayArray: [Date] = []
        
        for date in stride(from: task?.startDate ?? Date(), to: (task?.endDate ?? Date()) + 86400, by: 86400 ){
            dayArray.append(date)
        }
        
        return dayArray
    }
    
    
    
}

extension TaskDetailViewModel {
    
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
    
    var loadMainImage: UIImage {
        return documentManager.loadImageFromDocument(fileName: "\(String(describing: task?.id)).jpg") ?? UIImage.jacsimImage
    }
    
    var showCertified: String {
        guard let task = task else { return ""}
        if task.success - repository.checkCertified(item: task) > 0 {
            return "작심 성공까지 \(task.success - repository.checkCertified(item: task))회 남았습니다!"
        } else {
            return "목표를 달성했습니다! 끝까지 힘내세요!!"
        }
    }
    
    func checkIsSuccess() {
        guard let task = task else { return }
        repository.checkIsSuccess(item: task)
    }
    
    func deleteAlarm() {
        guard let task = task else { return }
        repository.deleteAlarm(item: task)
    }
    
    func deleteJacsim() {
        
        guard let task = task else { return }
        
        // 인증유무 분기처리
        
        if self.repository.checkCertified(item: task) == 0 {
            
            self.repository.deleteJacsim(item: task)
            
        } else {
            // 인증이 있을 때
            
            for index in 0...self.repository.checkCertified(item: task) - 1 {
                let dayArray = configCellTitle()
                let dateText = DateFormatType.toString(dayArray[index], to: .fullWithoutYear)
                self.repository.removeImageFromDocument(fileName: "\(task.id)_\(dateText).jpg")
            }
            
            self.repository.deleteJacsim(item: task)
            
        }
    }
}

//MARK: CollectionView
extension TaskDetailViewModel {
    
    func numberOfItemsInSection() -> Int {
        guard let task = task else { return 0 }
        return (Calendar.current.dateComponents([.day], from: task.startDate, to: task.endDate).day ?? 1) + 1
    }
    
    func cellForItemAt(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskDetailCollectionViewCell.reuseIdentifier, for: indexPath) as? TaskDetailCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.layer.borderWidth = Constant.Design.borderWidth
        cell.layer.cornerRadius = Constant.Design.cornerRadius
        cell.layer.borderColor = Constant.BaseColor.textColor?.cgColor
        
        let dayArray = configCellTitle()
        
        let dateText = DateFormatType.toString(dayArray[indexPath.item], to: .fullWithoutYear)
        guard let objectId = task?.id else { return UICollectionViewCell() }
        cell.dateLabel.text = dateText
        cell.certifiedMemo.text = task?.memoList[indexPath.row].memo
        
        guard let image = self.documentManager.loadImageFromDocument(fileName: "\(objectId)_\(dateText).jpg") else { return UICollectionViewCell()}
        cell.certifiedImageView.image = image
        
        return cell
        
    }
}
