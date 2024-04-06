//
//  BottomSheetViewController.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

import Core

import RxCocoa
import RxGesture
import RxSwift
import SnapKit

open class BottomSheetViewController: BaseViewController {
    
    public enum BottomSheetDetent: Equatable {
        
        case large
        case medium
        case zero
        case custom(CGFloat)
        
        func calculateHeight(baseView: UIView) -> CGFloat {
            switch self {
            case .large:
                return baseView.frame.size.height * 0.88
            case .medium:
                return baseView.frame.size.height * 0.5
            case .zero:
                return .zero
            case .custom(let height):
                return height
            }
        }
    }
    
    // MARK: - SubViews
    
    public lazy var body: UIView = .init().then {
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        $0.layer.cornerRadius = 16
        $0.backgroundColor = .backgroundNormal
    }
    
    private lazy var dimmedView:UIView = .init().then {
        $0.backgroundColor = .black
        $0.alpha = 0.24
    }
    

    // MARK: - Public Properties
    public var detent: BehaviorRelay = BehaviorRelay<BottomSheetDetent>(value: .zero)
    // 반투명 백그라운드 터치시 이벤트
    public let dimmedViewTapRelay: PublishRelay<Void> = .init()
    // MARK: - Private Properties
    
    private let bottomSheetMinHeight: CGFloat = 150.0
    private let bottomSheetPanMinMoveConstant: CGFloat = 30.0
    private let bottomSheetPanMinCloseConstant: CGFloat = 150.0
    
    private var initialBodyY: CGFloat = 0.0
    private var initialPanY: CGFloat = 0.0
    
    //백그라운드 탭 동작 제한
    private var isBackGroundTapEnable: Bool
    
    //모달 드래그 제한
    private var isDragEnable: Bool

    // MARK: - Initializers
    
    public init(isBackGroundTapEnable: Bool = true, isDragEnable: Bool = true ) {
        self.isBackGroundTapEnable = isBackGroundTapEnable
        self.isDragEnable = isDragEnable
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .clear
        configureCommon()
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Life Cycle
    
    open override func loadView() {
        super.loadView()
        bindUI()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindGesture()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetUIAttribute()
    }
    
    // MARK: - Override Methods
    open override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        let duration = animated ? 0.25 : 0.0
        
        if self.presentedViewController == nil {
            hideBottomSheet(duration: duration) {
                super.dismiss(animated: false, completion: completion)
            }
        } else {
            super.dismiss(animated: animated, completion: completion)
        }
    }
}

extension BottomSheetViewController {
    // MARK: - Helpers
    
    private func configureCommon() {
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    private func configureUI() {
        self.view.addSubview(dimmedView)
        self.dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(body)
        self.body.frame.origin = CGPoint(x: 0, y: self.view.frame.height)

        self.body.frame.size = CGSize(width: self.view.frame.width, height: self.detent.value.calculateHeight(baseView: self.view))
    }
    
    private func bindGesture() {
        if isDragEnable {
            self.view.rx
                .panGesture()
                .when(.began, .changed, .ended)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] sender in
                    guard let self = self else { return }
                    self.viewDidPan(sender)
                })
                .disposed(by: disposeBag)
        }
        
        if isBackGroundTapEnable {
            self.dimmedView.rx
                .tapGesture()
                .when(.recognized)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] sender in
                    guard let self = self else { return }
                    self.dimmedViewTap(sender)
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func bindUI() {
        self.detent
            .subscribe(on: MainScheduler.instance)
            .withUnretained(self)
            .bind(onNext: { weakSelf, detent in
                weakSelf.body.frame.size = CGSize(width: weakSelf.view.frame.width, height: weakSelf.detent.value.calculateHeight(baseView: weakSelf.view))
            })
            .disposed(by: disposeBag)
        
        self.detent
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { weakSelf, _ in
                weakSelf.showBottomSheet()
            })
            .disposed(by: disposeBag)
    }
}
// MARK: - Private Method
extension BottomSheetViewController {
    
    private func showBottomSheet(duration: CGFloat = 0.25, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration) {
            self.body.frame.origin = CGPoint(x: 0, y: self.view.frame.height - self.detent.value.calculateHeight(baseView: self.view))
        } completion: { _ in
            completion?()
        }
    }
    
    private func hideBottomSheet(duration: CGFloat = 0.25, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration) {
            self.body.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            self.dimmedView.alpha = 0.0
        } completion: { _ in
            self.body.subviews.forEach {
                $0.alpha = 0.0
            }
            completion?()
        }
    }
    
    private func dimmedViewTap(_ sender: UITapGestureRecognizer) {
        self.dimmedViewTapRelay.accept(())
        self.dismiss(animated: true, completion: nil)
    }
    
    private func viewDidPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        let dimmedViewHeight = self.view.frame.height - self.detent.value.calculateHeight(baseView: self.view)
        
        switch sender.state {
        case .began: break
        case .changed:
            if translation.y > 0 &&
                self.body.frame.height > self.bottomSheetMinHeight &&
                dimmedViewHeight + translation.y > self.bottomSheetPanMinMoveConstant {
                self.body.frame.origin = CGPoint(x: self.body.frame.origin.x, y: dimmedViewHeight + translation.y)
            }
        case .ended, .possible:
            if translation.y > self.bottomSheetPanMinCloseConstant {
                self.dismiss(animated: true, completion: nil)
            } else {
                fallthrough
            }
        default:
            showBottomSheet()
        }
    }
    
    private func resetUIAttribute() {
        self.body.subviews.forEach {
            $0.alpha = 1
        }
        dimmedView.alpha = 0.24
        self.body.transform = .identity
        self.body.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
        self.body.frame.size = CGSize(width: self.view.frame.width, height: self.detent.value.calculateHeight(baseView: self.view))
    }
}
