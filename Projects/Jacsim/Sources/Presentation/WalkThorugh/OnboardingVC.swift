//
//  OnboardingVC.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/26.
//

import UIKit

import DSKit

import SnapKit
import Then

final class OnboardingVC: BaseViewController {
    
    private let onboardingImageView: UIImageView = .init().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 5
    }
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        onboardingImageView.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
}

extension OnboardingVC {
    private func setView() {
        self.view.addSubview(onboardingImageView)
        
        onboardingImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.92)
            make.height.equalToSuperview().multipliedBy(0.72)
        }
    }
}
