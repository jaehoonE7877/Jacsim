//
//  AllTaskViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/11.
//

import UIKit

import DSKit

final class AllTaskViewModel {

    private let repository: JacsimRepositoryProtocol
    let fetchTasks: [UserJacsim]
    let fetchSuccess: [UserJacsim]
    let fetchFail: [UserJacsim]

    init(repository: JacsimRepositoryProtocol = JacsimRepository.shared) {
        self.repository = repository
        self.fetchTasks = repository.fetchActiveTasks()
        self.fetchSuccess = repository.fetchIsSuccess()
        self.fetchFail = repository.fetchIsFail()
    }
}
