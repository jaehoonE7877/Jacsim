//
//  BehaviorRelay+Extension.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2023/06/09.
//

import RxSwift
import RxCocoa

extension BehaviorRelay where Element: RangeReplaceableCollection {
    func add(element: Element.Element) {
        var array = self.value
        array.append(element)
        self.accept(array)
    }
}
