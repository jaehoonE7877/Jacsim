//
//  TaskUpdateViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/12.
//

import UIKit

final class TaskUpdateViewModel {
    
    private let repository = JacsimRepository()
    
    // 필요한 거 : UserJacsim 1개
    // Jacsim.memoList[indexPath.row]
    var task = Observable([UserJacsim]())
    var memoList = Observable(Certified())
    var memo = Observable("")
    var check = Observable(false)
    
}

extension TaskUpdateViewModel {
    
    func updateMemo(task: UserJacsim, index: Int, memo: String) {
        
        repository.updateMemo(item: task, index: index, memo: memo)
        
    }
    
    func saveImageToDocument(fileName: String, image: UIImage?) {
        
        
    }
}
