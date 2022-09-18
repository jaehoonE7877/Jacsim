//
//  Tabbar.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/10.
//

import UIKit

final class TabbarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureTab()
        setupTabbarAppearance()
    }
    // MARK: SettingVC 추가하기 
    private func configureTab(){
        let firstTabVC = HomeViewController()
        let firstTabbarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        firstTabVC.tabBarItem = firstTabbarItem
        let firstNav = UINavigationController(rootViewController: firstTabVC)
        let secondTabVC = DoneTaskViewController()
        let secondTabbarItem = UITabBarItem(title: "이전 작심", image: UIImage(systemName: "checkmark.square"), selectedImage: UIImage(systemName: "checkmark.square.fill"))
        secondTabVC.tabBarItem = secondTabbarItem
        let secondNav = UINavigationController(rootViewController: secondTabVC)
        
        self.viewControllers = [firstNav, secondNav]
    }
    
    private func setupTabbarAppearance(){
        let appearance = UITabBarAppearance()
        tabBar.tintColor = .white
        tabBar.backgroundColor = UIColor(red: 14/255, green: 30/255, blue: 80/255, alpha: 1)
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    
}
