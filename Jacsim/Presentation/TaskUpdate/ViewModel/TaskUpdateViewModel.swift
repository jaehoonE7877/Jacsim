//
//  TaskUpdateViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/12.
//

import UIKit

final class TaskUpdateViewModel {
    
    private let repository = JacsimRepository()
    

    var task: Observable<UserJacsim> = Observable(UserJacsim())
    
    private let documentManager = DocumentManager.shared
    
    var dateText: String? //image 저장시에 objectId_dateText로 넣어주기
    var index: Int?
}

extension TaskUpdateViewModel {
    
    private func updateMemo(task: UserJacsim, index: Int, memo: String) {
        
        repository.updateMemo(item: task, index: index, memo: memo)
        
    }
    
//    func saveImageToDocument(fileName: String, image: UIImage?) {
//
//
//    }

}
