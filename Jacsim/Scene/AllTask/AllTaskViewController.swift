//
//  DoneTaskViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit


import RealmSwift

final class AllTaskViewController: BaseViewController {
    
    // MARK: 객체 선언 TableView
    let repository = JacsimRepository()
    
    var foldValue = [false, false, false]
    
    lazy var tableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(JacsimHeaderView.self, forHeaderFooterViewReuseIdentifier: JacsimHeaderView.reuseIdentifier)
        $0.register(JacsimTableViewCell.self, forCellReuseIdentifier: JacsimTableViewCell.reuseIdentifier)
        $0.rowHeight = 60
        $0.sectionFooterHeight = 0
        $0.sectionHeaderHeight = 56
        $0.separatorStyle = UITableViewCell.SeparatorStyle.none
        $0.backgroundColor = .clear
    }
    
    var tasks: Results<UserJacsim>!{
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var successTasks: Results<UserJacsim>!{
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var failTasks: Results<UserJacsim>!{
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tasks = repository.fetchRealm()
        
        successTasks = repository.fetchIsSuccess()
        failTasks = repository.fetchIsFail()
    }
    
    // MARK: Navigation title
    override func configure() {
        
        view.addSubview(tableView)
        
    }
    
    override func setConstraint() {
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.width.equalTo(view).multipliedBy(0.88)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setNavigationController() {
        self.title = "작심 모아보기"
        navigationController?.navigationBar.tintColor = Constant.BaseColor.textColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(xButtonTapped))
    }
    
    @objc func xButtonTapped(){
        self.dismiss(animated: true)
    }
    
    @objc func foldButtonTapped(sender: UIButton){
        foldValue[sender.tag].toggle()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

extension AllTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return tasks?.count ?? 0
        case 1:
            return successTasks?.count ?? 0
        case 2:
            return failTasks?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: JacsimHeaderView.reuseIdentifier) as? JacsimHeaderView else { return UIView() }
        
        headerView.foldButton.tag = section
        headerView.foldImage.tag = headerView.foldButton.tag
        headerView.foldButton.addTarget(self, action: #selector(foldButtonTapped(sender:)), for: .touchUpInside)
        
        switch section {
        case 0:
            headerView.headerLabel.text = "진행중인 작심"
        case 1:
            headerView.headerLabel.text = "성공한 작심"
        case 2:
            headerView.headerLabel.text = "실패한 작심"
        default:
            headerView.headerLabel.text = "작심"
        }
        
        if foldValue[section] {
            headerView.foldImage.image = UIImage(systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        } else {
            headerView.foldImage.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        }
        
        return headerView
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: JacsimTableViewCell.reuseIdentifier) as? JacsimTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .clear
        
        switch indexPath.section {
        case 0:
            cell.titleLabel.text = tasks[indexPath.item].title
        case 1:
            cell.titleLabel.text = successTasks[indexPath.item].title
        case 2:
            cell.titleLabel.text = failTasks[indexPath.item].title
        default:
            cell.titleLabel.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if foldValue[indexPath.section] {
            return 0
        } else {
            return 68
        }
        
    }
    
}
