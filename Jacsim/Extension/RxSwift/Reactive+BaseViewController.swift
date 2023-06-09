//
//  Reactive+BaseViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2023/06/09.
//

import UIKit

import RxCocoa
import RxSwift

extension Reactive where Base: BaseViewController {
    
    var viewDidLoad: Observable<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return source
    }
    
    var viewWillAppear: Observable<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { _ in }
        return source
    }
    
    var viewDidAppear: Observable<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear)).map { _ in }
        return source
    }
    
    var viewWillDisappear: Observable<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { _ in }
        return source
    }
    
    var viewDidDisappear: Observable<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear)).map { _ in}
        return source
    }
}

// MARK: - UIView
extension Reactive where Base: UIView {
    public var layoutSubviews: Observable<[Any]> {
        return sentMessage(#selector(UIView.layoutSubviews))
    }
}
