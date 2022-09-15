//
//  BaseViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/10.
//

import UIKit

import SnapKit
import Then

class BaseViewController: UIViewController {
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setConstraint()
        setNavigationController()
        
        setFormatterTimezone()
        setFormatter()
        setFormatterLocale()
    }
    
    
    func configure() {}
    
    func setConstraint() {}
    
    func setNavigationController() {}
    
    func showAlertMessage(title: String, message: String ,button: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: button, style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    func showAlertMessage(title: String, button: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: button, style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    // (다국어 대응에 따라서 국가별로)
    func setFormatterLocale(){
        formatter.locale = Locale(identifier: "ko-KR")
    }
    
    // 다국어 대응에 따라서 생각해보기
    private func setFormatter(){
        formatter.dateFormat = "yyyy년 M월 dd일 EEEE"
    }
    
    private func setFormatterTimezone() {
        formatter.timeZone = TimeZone.autoupdatingCurrent
    }
    
}