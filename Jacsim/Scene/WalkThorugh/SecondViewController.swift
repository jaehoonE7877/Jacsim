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
        mainView.topLabel.text = "도전하고 싶은 챌린지를 기록해보세요"
        mainView.bottomLabel.text = ""
    }
    
}
