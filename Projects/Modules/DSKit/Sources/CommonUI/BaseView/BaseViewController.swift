//
//  BaseViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/10.
//

import UIKit
import UserNotifications

import RxSwift
import SnapKit
import Toast
import Then

open class BaseViewController: UIViewController {
    
    public enum BackButtonType {
        case dismiss
        case pop
        case none
        
        var image: UIImage? {
            switch self {
            case .dismiss:
                return DSKitAsset.Assets.close.image.withRenderingMode(.alwaysTemplate)
            case .pop:
                return DSKitAsset.Assets.chevronLeft.image.withRenderingMode(.alwaysTemplate)
            case .none:
                return nil
            }
        }
    }
    
    public let calendar = Calendar.current
    public let notificationCenter = UNUserNotificationCenter.current()
    
    public let disposeBag = DisposeBag()
    
    //MARK: - initializers
    deinit {
//        Log("deinit - \(theClassName)")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .backgroundNormal
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setConstraint()
        setNavigationController()
    }
    
    
    open func configure() {}
    
    open func setConstraint() {}
    
    open func setNavigationController() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .backgroundNormal
        appearance.configureWithOpaqueBackground()
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.labelStrong]
        self.navigationController?.navigationBar.backItem?.title = nil
    }
    
    public func setBackButton(type: BackButtonType) {
        switch type {
        case .dismiss:
            let backButton = UIBarButtonItem(image: type.image,
                                             style: .plain,
                                             target: self,
                                             action: #selector(closeButtonTapped))
            backButton.imageInsets = .init(top: 0, left: -4, bottom: 0, right: 0)
            backButton.tintColor = .labelStrong
            navigationItem.leftBarButtonItem = backButton
        case .pop:
            let backButton = UIBarButtonItem(image: type.image,
                                             style: .plain,
                                             target: self,
                                             action: #selector(popViewController))
            backButton.imageInsets = .init(top: 0, left: -4, bottom: 0, right: 0)
            backButton.tintColor = .labelStrong
            navigationItem.leftBarButtonItem = backButton
        case .none: break
        }
    }
    
    @objc func closeButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    public func showAlertMessage(title: String, message: String? ,button: String, cancel: String, completion: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: button, style: .destructive, handler: completion)
        let cancel = UIAlertAction(title: cancel, style: .cancel)
        alert.addAction(cancel)
        alert.addAction(ok)
        
        present(alert, animated: true)
    }
    
    public func showAlertMessage(title: String, message: String ,button: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: button, style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    public func showAlertMessage(title: String, button: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: button, style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    public func calculateDays(startDate: Date, endDate: Date) -> Int {
        return (calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 1) + 1
    }
    
    public func showAlertSetting(message: String) {
        
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

public extension BaseViewController {

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
