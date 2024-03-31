//
//  DoneTaskViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

import RealmSwift

import DSKit

final class AllTaskViewController: BaseViewController {
    
    // MARK: 객체 선언 TableView
    
    private var viewModel = AllTaskViewModel()
    
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
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

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
        navigationController?.navigationBar.tintColor = DSKitAsset.Colors.text.color
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.xmark, style: .plain, target: self, action: #selector(xButtonTapped))
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
        return viewModel.numberOfRowsInSection(section: section)
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
            headerView.foldImage.image = UIImage.chevornUp
        } else {
            headerView.foldImage.image = UIImage.chevornDown
        }
        
        return headerView
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel.cellForRowAt(tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if foldValue[indexPath.section] {
            return 0
        } else {
            return 68
        }
        
    }
    
}
