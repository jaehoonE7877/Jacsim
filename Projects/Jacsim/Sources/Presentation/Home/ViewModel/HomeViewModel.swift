//
//  HomeViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/12.
//

import Foundation
import RxCocoa
import RxSwift

final class HomeViewModel {
    
    private let repository = JacsimRepository.shared
    
    var tasks: BehaviorRelay<[UserJacsim]> = .init(value: [])
}

extension HomeViewModel {
    
    func fetch() {
        
        let task = repository.fetchRealm()
        
        var original = tasks.value
        original.removeAll()
        self.tasks.accept(original)
        
        var jacsims: [UserJacsim] = []
        
        task.forEach { item in
            jacsims.append(item)
        }
        
        self.tasks.accept(jacsims)
    }
    
    func fetchDate(date: Date) {
        
        let task = repository.fetchDate(date: date)
        
        var original = tasks.value
        original.removeAll()
        self.tasks.accept(original)
        
        var jacsims: [UserJacsim] = []
        
        task.forEach{ item in
            jacsims.append(item)
        }
        
        self.tasks.accept(jacsims)
    }
    
    func checkIsDone() {
        repository.checkIsDone(items: tasks.value)
    }
    
    func fetchIsNotDone() -> Int {
        return repository.fetchIsNotDone()
    }
    
}
