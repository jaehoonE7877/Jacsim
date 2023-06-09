//
//  RxSwift+Optional.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2023/06/09.
//

import Foundation

import RxSwift
import RxCocoa

protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    /// Cast `Optional<Wrapped>` to `Wrapped?`
    public var value: Wrapped? {
        return self
    }
}

enum RxOptionalError: Error, CustomStringConvertible {
    case foundNilWhileUnwrappingOptional(Any.Type)
    case emptyOccupiable(Any.Type)

    public var description: String {
        switch self {
        case .foundNilWhileUnwrappingOptional(let type):
           return "Found nil while trying to unwrap type <\(String(describing: type))>"
        case .emptyOccupiable(let type):
            return "Empty occupiable of type <\(String(describing: type))>"
        }
    }
}


extension ObservableType where Element: OptionalType {
    /**
     Unwraps and filters out `nil` elements.

     - returns: `Observable` of source `Observable`'s elements, with `nil` elements filtered out.
     */
    
    func filterNil() -> Observable<Element.Wrapped> {
        return self.flatMap { element -> Observable<Element.Wrapped> in
            guard let value = element.value else {
                return Observable<Element.Wrapped>.empty()
            }
            return Observable<Element.Wrapped>.just(value)
        }
    }

    /**
    
    Filters out `nil` elements. Similar to `filterNil`, but keeps the elements of the observable
    wrapped in Optionals. This is often useful for binding to a UIBindingObserver with an optional type.

    - returns: `Observable` of source `Observable`'s elements, with `nil` elements filtered out.
    */

    func filterNilKeepOptional() -> Observable<Element> {
        return self.filter { element -> Bool in
            return element.value != nil
        }
    }

    /**
     Throws an error if the source `Observable` contains an empty element; otherwise returns original source `Observable` of non-empty elements.

     - parameter error: error to throw when an empty element is encountered. Defaults to `RxOptionalError.FoundNilWhileUnwrappingOptional`.

     - throws: `error` if an empty element is encountered.

     - returns: original source `Observable` of non-empty elements if it contains no empty elements.
     */
    
    func errorOnNil(_ error: Error = RxOptionalError.foundNilWhileUnwrappingOptional(Element.self)) -> Observable<Element.Wrapped> {
        return self.map { element -> Element.Wrapped in
            guard let value = element.value else {
                throw error
            }
            return value
        }
    }

    /**
     Unwraps optional elements and replaces `nil` elements with `valueOnNil`.

     - parameter valueOnNil: value to use when `nil` is encountered.

     - returns: `Observable` of the source `Observable`'s unwrapped elements, with `nil` elements replaced by `valueOnNil`.
     */
    
    func replaceNilWith(_ valueOnNil: Element.Wrapped) -> Observable<Element.Wrapped> {
        return self.map { element -> Element.Wrapped in
            guard let value = element.value else {
                return valueOnNil
            }
            return value
        }
    }

    /**
     Unwraps optional elements and replaces `nil` elements with result returned by `handler`.

     - parameter handler: `nil` handler throwing function that returns `Observable` of non-`nil` elements.

     - returns: `Observable` of the source `Observable`'s unwrapped elements, with `nil` elements replaced by the handler's returned non-`nil` elements.
     */
    
    func catchOnNil(_ handler: @escaping () throws -> Observable<Element.Wrapped>) -> Observable<Element.Wrapped> {
        return self.flatMap { element -> Observable<Element.Wrapped> in
            guard let value = element.value else {
                return try handler()
            }
            return Observable<Element.Wrapped>.just(value)
        }
    }
}

extension ObservableType {
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            assertionFailure("Error \(error)")
            return Driver.empty()
        }
    }

    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
    func withPrevious() -> Observable<(Element?, Element)> {
        scan((Element?.none, Element?.none)) { ($0.1, $1) }
            .map { ($0.0, $0.1!) }
    }
}

#if !swift(>=3.3) || (swift(>=4.0) && !swift(>=4.1))
public extension ObservableType where Element: OptionalType, Element.Wrapped: Equatable {
    /**
     Returns an observable sequence that contains only distinct contiguous elements according to equality operator.
     
     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)
     
     - returns: An observable sequence only containing the distinct contiguous elements, based on equality operator, from the source sequence.
     */
    
    func distinctUntilChanged() -> Observable<Self.E> {
        return self.distinctUntilChanged { (lhs, rhs) -> Bool in
            return lhs.value == rhs.value
        }
    }
}
#endif
