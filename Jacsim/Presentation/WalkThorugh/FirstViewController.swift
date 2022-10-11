//
//  FirstViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/26.
//

import UIKit

class FirstViewController: BaseViewController {
    
    private let mainView = PageView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configure() {
        
    }
    
}
