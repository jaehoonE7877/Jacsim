//
//  Observable+Extension.swift
//  Core
//
//  Created by Seo Jae Hoon on 4/5/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

public extension Observable where Element: Equatable {
    func ignore(value: Element) -> Observable<Element> {
        return filter { (selfE) -> Bool in
            return value != selfE
        }
    }
}

public extension ObservableType {

    /**
     Takes a sequence of optional elements and returns a sequence of non-optional elements, filtering out any nil values.

     - returns: An observable sequence of non-optional elements
     */

    func unwrap<Result>() -> Observable<Result> where Element == Result? {
        return self.compactMap { $0 }
    }
    
    func catchAndReturnNever() -> Observable<Element> {
        return self.catch { _ in return .never() }
    }
    
    func retry(maxAttempts: Int, delay: RxTimeInterval) -> Observable<Element> {
        return self.retry { errors in
            return errors.enumerated().flatMap { (index, error) -> Observable<Int64> in
                if index < maxAttempts - 1 {
                    return Observable<Int64>.timer(delay, scheduler: MainScheduler.instance)
                } else {
                    return Observable.error(error)
                }
            }
        }
    }
}

public extension Observable where Element == String {    
    func formatted(by patternString: String) -> Observable<String> {
        return flatMap { element -> Observable<String> in
            let formattedString = element.formated(by: patternString)
            return .just(formattedString)
        }
    }
}

public extension Observable where Element: OptionalType {
    func filterNil() -> Observable<Element.Wrapped> {
        return flatMap { (element) -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .empty()
            }
        }
    }

    func filterNilKeepOptional() -> Observable<Element> {
        return self.filter { (element) -> Bool in
            return element.value != nil
        }
    }

    func replaceNil(with nilValue: Element.Wrapped) -> Observable<Element.Wrapped> {
        return flatMap { (element) -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .just(nilValue)
            }
        }
    }
}

public extension SharedSequenceConvertibleType {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}
