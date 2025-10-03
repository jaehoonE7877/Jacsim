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
        let items = repository.fetchAllActive()
        self.tasks.accept(items)
    }
    
    func fetchDate(date: Date) {
        
        let items = repository.fetchDate(date: date)
        self.tasks.accept(items)
    }
    
    func checkIsDone() {
        repository.checkIsDone(items: tasks.value)
    }
    
    func fetchIsNotDone() -> Int {
        return repository.fetchIsNotDone()
    }
    
}
