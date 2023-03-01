//
//  HomeViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/12.
//

import Foundation

final class HomeViewModel {
    
    private let repository = JacsimRepository()
    
    var tasks: Observable<[UserJacsim]> = Observable([UserJacsim]())
}

extension HomeViewModel {
    
    func fetch() {
        
        let task = repository.fetchRealm()
        
        tasks.value.removeAll()
        
        task?.forEach{ item in
            tasks.value.append(item)
        }
    }
    
    func fetchDate(date: Date) {
        
        let task = repository.fetchDate(date: date)
        
        tasks.value.removeAll()
        
        task?.forEach{ item in
            tasks.value.append(item)
        }
        
    }
    
    func checkIsDone() {
        repository.checkIsDone(items: tasks.value)
    }
    
    func fetchIsNotDone() -> Int {
        return repository.fetchIsNotDone()
    }
    
}
