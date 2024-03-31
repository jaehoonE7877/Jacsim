//
//  WalkThroughViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/25.
//

import UIKit

import DSKit

import SnapKit
import Then

final class WalkThroughViewController: BaseViewController {
    
    private let pageControl = UIPageControl().then {
        $0.pageIndicatorTintColor = .lightGray
        $0.currentPageIndicatorTintColor = DSKitAsset.Colors.button.color
    }
    
    private let continueButton = UIButton().then {
        $0.backgroundColor = DSKitAsset.Colors.button.color
        $0.setTitle("계속하기", for: .normal)
        $0.setTitleColor(DSKitAsset.Colors.text.color, for: .normal)
        $0.layer.cornerRadius = Constant.Design.cornerRadius
    }
    
    private lazy var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal).then {
        $0.delegate = self
        $0.dataSource = self
    }
    
    private var pageViewControllerList: [UIViewController] = []
    
    init(fromSetting: Bool) {
        self.continueButton.isHidden = fromSetting
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        createPageViewController()
        configurePageViewController()
        
        pageControl.numberOfPages = pageViewControllerList.count
        
        continueButton.addTarget(self, action: #selector(continueButtonClicked), for: .touchUpInside)
    }
    
    
    //배열에 뷰컨트롤러를 추가
    private func createPageViewController(){
        let controllers = [DSKitAsset.Assets.onboardingImg1.image,
                           DSKitAsset.Assets.onboardingImg2.image,
                           DSKitAsset.Assets.onboardingImg3.image,
                           DSKitAsset.Assets.onboardingImg4.image]
                        .map { OnboardingVC(image: $0) }
        pageViewControllerList = controllers
    }
    
    private func configurePageViewController() {
        //display
        guard let first = pageViewControllerList.first else { return }
        pageViewController.setViewControllers([first], direction: .forward, animated: true)
    }
    
    @objc private func continueButtonClicked() {
        
        if pageControl.currentPage < pageViewControllerList.count - 1 {
            let nextPage = pageViewControllerList[pageControl.currentPage + 1]
            pageControl.currentPage += 1
            pageViewController.setViewControllers([nextPage], direction: .forward, animated: true)
        } else {
            
            UserDefaults.standard.set(true, forKey: "onboarding")
            let viewModel = HomeViewModel()
            transitionViewController(viewController: HomeViewController(viewModel: viewModel), transitionStyle: .presentFullNavigation)
        }
        
        if pageControl.currentPage == 3{
            continueButton.setTitle("시작하기", for: .normal)
        }
    }
    
    override func configure() {
        [pageViewController.view, pageControl, continueButton].forEach { view.addSubview($0) }
    }
    
    override func setConstraint() {
        pageViewController.view.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
            
        }
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(continueButton.snp.top).offset(-20)
            make.centerX.equalTo(view)
        }
        
        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
            make.centerX.equalTo(view)
            make.width.equalTo(UIScreen.main.bounds.width / 1.2)
            make.height.equalTo(50)
        }
        
    }
    
}

extension WalkThroughViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
   
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pageViewControllerList.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        return previousIndex < 0 ? nil : pageViewControllerList[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pageViewControllerList.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        return nextIndex >= pageViewControllerList.count ? nil : pageViewControllerList[nextIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let firstView = pageViewController.viewControllers?.first, let index = pageViewControllerList.firstIndex(of: firstView) else { return }
        
        pageControl.currentPage = index
        
        if pageControl.currentPage == 3 {
            continueButton.setTitle("시작하기", for: .normal)
        } else {
            continueButton.setTitle("계속하기", for: .normal)
        }
        
    }
    
    
}
