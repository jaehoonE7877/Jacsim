//
//  AlarmViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/27.
//

import UIKit

final class AlarmViewController: UIViewController {
    
    let mainView = AlarmView()
    
    var completion: ((Date?) -> ())?
    
    var alarmDate: Date?
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    func configure() {
        mainView.xButton.addTarget(self, action: #selector(xButtonTapped), for: .touchUpInside)
        mainView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc private func xButtonTapped() {
        guard let completion = completion else { return }
        completion(nil)
        self.dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {

        alarmDate = self.mainView.datePicker.date
        
        guard let alarmDate = alarmDate else { return }
        guard let completion = completion else { return }
        completion(alarmDate)
        
        self.dismiss(animated: true)
    }
    
}
