//
//  SecondViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/26.
//

import UIKit

class SecondViewController: BaseViewController {
    
    private let mainView = PageView()
    
    override func loadView() {
        self.view = mainView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configure() {
        mainView.mainImageView.image = UIImage(named: "onboarding_img2")
    }
    
}
