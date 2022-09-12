//
//  HomeViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit
import FSCalendar

class HomeViewController: BaseViewController {
    
    // MARK: Label, FSCalendar, TableView
    let nicknameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        
    }
    
    lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
        $0.rowHeight = 56
        $0.backgroundColor = .darkGray
    }
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func configure() {
        
    }
    
    override func setConstraint() {
        
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
