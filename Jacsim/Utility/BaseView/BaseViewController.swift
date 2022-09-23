//
//  BaseViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/10.
//

import UIKit

import RealmSwift
import SnapKit
import Toast
import Then

class BaseViewController: UIViewController {
    
    let formatter = DateFormatter()
    let calendar = Calendar.current
    
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
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Constant.BaseColor.backgroundColor
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
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
        formatter.locale = Locale(identifier: "ko-KR")
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
                   loadingView.color = Constant.BaseColor.buttonColor
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
