//
//  HomeViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/12.
//

import Foundation

final class HomeViewModel {
    
    private let repository = JacsimRepository.shared

    private(set) var tasks: [UserJacsim] = [] {
        didSet {
            tasksDidUpdate?(tasks)
        }
    }

    var tasksDidUpdate: (([UserJacsim]) -> Void)?
}

extension HomeViewModel {
    
    func fetch() {
        
        let task = repository.fetchRealm()

        var jacsims: [UserJacsim] = []

        task.forEach { item in
            jacsims.append(item)
        }

        self.tasks = jacsims
    }

    func fetchDate(date: Date) {

        let task = repository.fetchDate(date: date)

        var jacsims: [UserJacsim] = []

        task.forEach{ item in
            jacsims.append(item)
        }

        self.tasks = jacsims
    }

    func checkIsDone() {
        repository.checkIsDone(items: tasks)
    }

    func fetchIsNotDone() -> Int {
        return repository.fetchIsNotDone()
    }
    
}
