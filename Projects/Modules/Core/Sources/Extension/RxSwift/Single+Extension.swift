//
//  Single+Extension.swift
//  Core
//
//  Created by Seo Jae Hoon on 4/5/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public extension ObservableConvertibleType {
    
    func asDriverOnErrorWithNever() -> Driver<Element> {
        let source = self
            .asObservable()
            .observe(on: DriverSharingStrategy.scheduler)
            .asDriver(onErrorDriveWith: .never())
        return source
    }
}
