//
//  HomeViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/12.
//

import UIKit

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

extension HomeViewModel {
    
    func numberOfRowsInSection(_ tableView: UITableView, section: Int) -> Int {
        return tasks.value.count
    }
    
    func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: JacsimTableViewCell.reuseIdentifier) as? JacsimTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.titleLabel.text = tasks.value[indexPath.row].title
        if tasks.value[indexPath.row].alarm != nil {
            cell.alarmImageView.isHidden = false
        } else {
            cell.alarmImageView.isHidden = true
        }
        
        return cell
    }
    
}



