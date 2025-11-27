//
//  HomeViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/12.
//

import Foundation

@MainActor
final class HomeViewModel {

    private let repository = JacsimRepository.shared

    private(set) var tasks: [UserJacsim] = []
}

extension HomeViewModel {

    func fetch() async -> [UserJacsim] {

        let task = repository.fetchRealm()
        let jacsims = Array(task)
        tasks = jacsims
        return jacsims
    }

    func fetchDate(date: Date) async -> [UserJacsim] {

        let task = repository.fetchDate(date: date)
        let jacsims = Array(task)
        tasks = jacsims
        return jacsims
    }

    func checkIsDone() {
        repository.checkIsDone(items: tasks)
    }

    func fetchIsNotDone() -> Int {
        return repository.fetchIsNotDone()
    }

}
