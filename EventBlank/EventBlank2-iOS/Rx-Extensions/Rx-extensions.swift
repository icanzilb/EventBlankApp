//
//  Rx-extensions.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/22/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension ObservableType {
    func replaceWithDate<R>(value: R) -> Observable<NSDate> {
        return map { _ in NSDate() }
    }
    
    func replaceWith<R>(value: R) -> Observable<R> {
        return map { _ in value }
    }
    
    public func bindNextIgnoreResult(onNext: (E -> Any)) -> Disposable {
        return bindNext { onNext($0) }
    }
}

extension UIResponder {
    public var rx_firstResponder: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) {[unowned self] view, shouldRespond in
            shouldRespond ? self.becomeFirstResponder() : self.resignFirstResponder()
        }.asObserver()
    }
}

extension Observable {
    func replaceNilWith(value: Element) -> Observable<Element> {
        return map {element in element == nil ? value : element}
    }
}

extension Observable where Element : SignedIntegerType {
    public func negate() -> Observable<E> {
        return map {value in -value}
    }
}

extension Observable where Element: BooleanType {
    public func negate() -> Observable<Bool> {
        return map(!)
    }
    
    public func filterNegatives() -> Observable<Bool> {
        return map {value in value.boolValue}
    }
}

extension Observable where Element: Equatable {
    public func filterOut(targetValue: Element) -> Observable<Element> {
        return self.filter {value in targetValue != value}
    }
}

protocol Optionable
{
    typealias WrappedType
    func unwrap() -> WrappedType
    func isEmpty() -> Bool
}

extension Optional : Optionable
{
    typealias WrappedType = Wrapped
    func unwrap() -> WrappedType {
        return self!
    }
    
    func isEmpty() -> Bool {
        return !(flatMap({_ in true})?.boolValue == true)
    }
}

extension Observable where Element : Optionable {
    func unwrap() -> Observable<Element.WrappedType> {
        return self
            .filter {value in
                return !value.isEmpty()
            }
            .map {value -> Element.WrappedType in
                value.unwrap()
            }
    }
}

extension UIView {
    public var rx_visible: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) { view, visible in
            view.hidden = !visible
        }.asObserver()
    }
}

public struct RxGestureTypeOptions : OptionSetType, Hashable {
    
    private let raw: UInt
    
    public init(rawValue: UInt) {
        raw = rawValue
    }
    public var rawValue: UInt {
        return raw
    }
    
    public var hashValue: Int { return Int(rawValue) }
    
    public static var None = RxGestureTypeOptions(rawValue: 0)
    public static var Tap = RxGestureTypeOptions(rawValue: 1 << 0)
    
    public static var SwipeLeft = RxGestureTypeOptions(rawValue: 1 << 1)
    public static var SwipeRight = RxGestureTypeOptions(rawValue: 1 << 2)
    public static var SwipeUp = RxGestureTypeOptions(rawValue: 1 << 3)
    public static var SwipeDown = RxGestureTypeOptions(rawValue: 1 << 4)
    
    public static var LongPress = RxGestureTypeOptions(rawValue: 1 << 5)
}

extension UIView {
    public func rx_gesture(type: RxGestureTypeOptions) -> Observable<RxGestureTypeOptions> {
        let source: Observable<RxGestureTypeOptions> = Observable.create { [weak self] observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            guard let control = self else {
                observer.on(.Completed)
                return NopDisposable.instance
            }
            
            control.userInteractionEnabled = true
            
            var gestures = [Disposable]()

            //taps
            if type.contains(.Tap) {
                let tap = UITapGestureRecognizer()
                control.addGestureRecognizer(tap)
                gestures.append(
                    tap.rx_event.replaceWith(RxGestureTypeOptions.Tap)
                        .bindNext(observer.onNext)
                )
            }
            
            //swipes
            for direction in Array<RxGestureTypeOptions>([.SwipeLeft, .SwipeRight, .SwipeUp, .SwipeDown]) {
                if type.contains(direction) {
                    if let swipeDirection = control.directionForGestureType(direction) {
                        let swipe = UISwipeGestureRecognizer()
                        swipe.direction = swipeDirection
                        control.addGestureRecognizer(swipe)
                        gestures.append(
                            swipe.rx_event.replaceWith(direction)
                            .bindNext(observer.onNext)
                        )
                    }
                }
            }
            
            //long press
            if type.contains(.LongPress) {
                let press = UILongPressGestureRecognizer()
                control.addGestureRecognizer(press)
                gestures.append(
                    press.rx_event.replaceWith(RxGestureTypeOptions.LongPress)
                        .bindNext(observer.onNext)
                )
            }
            
            //dispose gestures properly
            return AnonymousDisposable {
                for gesture in gestures {
                    gesture.dispose()
                }
            }
        }.takeUntil(rx_deallocated)
        
        return source
    }
    
    private func directionForGestureType(type: RxGestureTypeOptions) -> UISwipeGestureRecognizerDirection? {
        if type == .SwipeLeft  { return .Left  }
        if type == .SwipeRight { return .Right }
        if type == .SwipeUp    { return .Up    }
        if type == .SwipeDown  { return .Down  }
        return nil
    }
}

