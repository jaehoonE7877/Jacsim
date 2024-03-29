//
//  RxUIControl+Extension.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2023/06/09.
//

import UIKit

import RxSwift
import RxCocoa

struct TargetedControlEvent<T> {
    var event: UIControl.Event
    var sender: T
}

extension Reactive where Base: UIControl {
    func controlEvent(event: UIControl.Event) -> Observable<TargetedControlEvent<Base>> {
        let targetedControlEvent = TargetedControlEvent(event: event, sender: base)
        return base.rx.controlEvent(event).map({ _ in targetedControlEvent })
    }

    func controlEvent(events: [UIControl.Event]) -> Observable<TargetedControlEvent<Base>> {
        return Observable.merge(events.map({ controlEvent(event: $0) }))
    }

    var allTouchEvents: Observable<TargetedControlEvent<Base>> {
        let touchEvents: [UIControl.Event] = [
                .touchDownRepeat,
                .touchDragInside,
                .touchDragOutside,
                .touchDragEnter,
                .touchDragExit,
                .touchUpInside,
                .touchUpOutside,
                .touchCancel
        ]
        return controlEvent(events: touchEvents)
    }

    var editingAction: Observable<TargetedControlEvent<Base>> {
        let events: [UIControl.Event] = [
            .editingDidBegin,
            .editingDidEnd,
            .editingDidEndOnExit
        ]
        
        let eventObservables = events.map({ controlEvent(event: $0) })
        return Observable.merge(eventObservables)
    }
    
    var allEditingEvents: Observable<TargetedControlEvent<Base>> {
        let editingEvents: [UIControl.Event] = [
                .editingDidBegin,
                .editingChanged,
                .editingDidEnd,
                .editingDidEndOnExit
        ]
        return controlEvent(events: editingEvents)
    }

    var allEvents: Observable<TargetedControlEvent<Base>> {
        let events: [UIControl.Event] = [
                .valueChanged,
                .applicationReserved,
                .systemReserved
        ]

        var eventObservables = events.map({ controlEvent(event: $0) })
        eventObservables.append(contentsOf: [allTouchEvents, allEditingEvents])
        
        return Observable.merge(eventObservables)
    }

}
