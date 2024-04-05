//
//  AllTaskViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/11.
//

import UIKit

import DSKit

import RealmSwift

final class AllTaskViewModel {

    private let repository: JacsimRepositoryProtocol
    let fetchTasks: Results<UserJacsim>
    let fetchSuccess: Results<UserJacsim>
    let fetchFail: Results<UserJacsim>

    init(repository: JacsimRepositoryProtocol = JacsimRepository.shared) {
        self.repository = repository
        self.fetchTasks = repository.fetchRealm()
        self.fetchSuccess = repository.fetchIsSuccess()
        self.fetchFail = repository.fetchIsFail()
    }
}
