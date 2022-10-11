//
//  AllTaskViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/11.
//

import UIKit

import RealmSwift

final class AllTaskViewModel {

    private let repository = JacsimRepository()
    
    var fetchTasks: Results<UserJacsim> {
        return repository.fetchRealm()
    }
    
    var fetchSuccess: Results<UserJacsim> {
        return repository.fetchIsSuccess()
    }
    
    var fetchFail: Results<UserJacsim> {
        return repository.fetchIsFail()
    }
    
}

extension AllTaskViewModel {
    
    func numberOfRowsInSection(section: Int) -> Int {
        switch section {
        case 0:
            return fetchTasks.count
        case 1:
            return fetchSuccess.count
        case 2:
            return fetchFail.count
        default:
            return 0
        }
    }
    
    func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: JacsimTableViewCell.reuseIdentifier) as? JacsimTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .clear
        
        switch indexPath.section {
        case 0:
            cell.titleLabel.text = fetchTasks[indexPath.item].title
        case 1:
            cell.titleLabel.text = fetchSuccess[indexPath.item].title
        case 2:
            cell.titleLabel.text = fetchFail[indexPath.item].title
        default:
            cell.titleLabel.text = ""
        }
        return cell
    }
}
