//
//  AddAlertViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/23.
//

import UIKit

class AddAlarmViewController: BaseViewController {
    
    var delegate: ((_ date: Date) -> Void)?
    
    lazy var datePicker = UIDatePicker().then {
        $0.locale = Locale(identifier: "ko_KR")
    }
    
    let timeLabel = UILabel().then {
        $0.text = "시간"
        $0.font = .systemFont(ofSize: 20)
        $0.textColor = .label
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
    override func configure() {
        [timeLabel, datePicker].forEach { view.addSubview($0) }
    }
    
    override func setConstraint() {
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.leading.equalTo(view).offset(20)
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.top)
            make.centerY.equalTo(timeLabel.snp.centerY)
            make.trailing.equalTo(view).offset(-20)
        }
    }
    
    override func setNavigationController() {
        self.title = "알람설정"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = Constant.BaseColor.buttonColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveButtonTapped))
    }
    
    @objc func backButtonTapped(){
        self.dismiss(animated: true)
    }
    
    @objc func saveButtonTapped(){
        
        delegate?(datePicker.date)
        self.dismiss(animated: true)
    }
    
}
