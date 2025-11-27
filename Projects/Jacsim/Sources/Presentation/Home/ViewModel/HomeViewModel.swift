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
        let results = repository.fetchRealm()
        tasks = Array(results)
    }

    func fetchDate(date: Date) {
        let results = repository.fetchDate(date: date)
        tasks = Array(results)
    }

    func checkIsDone() {
        repository.checkIsDone(items: tasks)
    }

    func fetchIsNotDone() -> Int {
        return repository.fetchIsNotDone()
    }

}
