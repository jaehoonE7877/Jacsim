//
//  BaseViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/10.
//

import UIKit
import UserNotifications

import RealmSwift
import SnapKit
import Toast
import Then

class BaseViewController: UIViewController {
    
    let formatter = DateFormatter()
    let calendar = Calendar.current
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setFormatterTimezone()
        setFormatterLocale()
        setFormatter()
        configure()
        setConstraint()
        setNavigationController()
    }
    
    
    func configure() {}
    
    func setConstraint() {}
    
    func setNavigationController() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = Constant.BaseColor.backgroundColor
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func showAlertMessage(title: String, message: String ,button: String, cancel: String, completion: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: button, style: .destructive, handler: completion)
        let cancel = UIAlertAction(title: cancel, style: .cancel)
        alert.addAction(cancel)
        alert.addAction(ok)
        
        present(alert, animated: true)
    }
    
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
        formatter.locale = Locale(identifier: "ko_KR")
    }
    
    func setFormatter(){
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
    }
    
    func setFormatterTimezone() {
        formatter.timeZone = TimeZone(identifier: "ko_KR")
    }
    
    func calculateDays(startDate: Date, endDate: Date) -> Int {
        return (calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 1) + 1
    }
    
    func showAlertSetting(message: String) {
        
        let alert = UIAlertController(title: "설정", message: message, preferredStyle: .alert)
            
        let cancel = UIAlertAction(title: "취소", style: .default)

        let confirm = UIAlertAction(title: "설정", style: .default) { action in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        
        self.present(alert, animated: true)
    }
    
}

extension BaseViewController {

       func showLoading() {
          
           DispatchQueue.main.async {
               
               let scenes = UIApplication.shared.connectedScenes
               let windowScenes = scenes.first as? UIWindowScene
               guard let window = windowScenes?.windows.last else { return }
               
               let loadingView: UIActivityIndicatorView
               
               if let existView = window.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
                   loadingView = existView
               } else {
                   loadingView = UIActivityIndicatorView(style: .large)
                   
                   loadingView.frame = window.frame
                   loadingView.color = UIColor.systemPink
                   window.addSubview(loadingView)
               }
               loadingView.startAnimating()
           }
       }
       
       func hideLoading() {
           DispatchQueue.main.async {
               let scenes = UIApplication.shared.connectedScenes
               let windowScenes = scenes.first as? UIWindowScene
               guard let window = windowScenes?.windows.last else { return }
               
               window.subviews.filter { $0 is UIActivityIndicatorView }.forEach { $0.removeFromSuperview() }
           }
       }
   

}
