//
//  HomeViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit
import FSCalendar
import Floaty

class HomeViewController: BaseViewController {
    
    // MARK: Label, FSCalendar, TableView
    let nicknameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.backgroundColor = .red
        $0.text = "Nickname의 챌린지"
    }
    
    lazy var calendar = FSCalendar().then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .systemYellow
    }
    
    lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
        $0.rowHeight = 56
        $0.backgroundColor = .darkGray
    }
    
    let formatter = DateFormatter().then{
        $0.dateFormat = "yyyyMMdd"
    }
    
    let floatButton = Floaty()
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func configure() {
        
        [nicknameLabel, calendar, tableView].forEach { view.addSubview($0) }
        
    }
    
    override func setConstraint() {
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.snp.leading).offset(16)
        }
        
        calendar.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(12)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(UIScreen.main.bounds.height / 2.5)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(12)
            make.height.equalTo(UIScreen.main.bounds.height)
        }
    }
    
    private func layoutFAB(){
        
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier) as? HomeTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .tintColor
        
        return cell
    }
    
    
}

extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 1
    }
    
    
}
