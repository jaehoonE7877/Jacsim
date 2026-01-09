//
//  HomeViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/12.
//

import Combine
import Foundation

@MainActor
final class HomeViewModel {

    private let repository = JacsimRepository.shared

    @Published private(set) var tasks: [UserJacsim] = []
}

extension HomeViewModel {

    func fetch() {
        tasks = repository.fetchActiveTasks()
    }

    func fetchDate(date: Date) {
        tasks = repository.fetchDate(date: date)
    }

    func checkIsDone() {
        repository.checkIsDone(items: tasks)
    }

    func fetchIsNotDone() -> Int {
        return repository.fetchIsNotDone()
    }

}
