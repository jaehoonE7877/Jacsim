//
//  Observable.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/11.
//

import Foundation

class Observable<T> {
    
    private var listener: ((T) -> Void)?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ closure: @escaping (T) -> Void ){
        print(#function)
        closure(value)
        listener = closure
    }
}
