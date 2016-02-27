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

//
// MARK: negate()
//

extension ObservableType {
    func reaplaceWithDate<R>(value: R) -> Observable<NSDate> {
        return Observable.create {observer in
            let subscription = self.subscribe { e in
                switch e {
                case .Next(_):
                    observer.on(.Next(NSDate()))
                default: break
                }
            }
            return subscription
        }
    }
    
    func replaceWith<R>(value: R) -> Observable<R> {
        return Observable.create { observer in
            let subscription = self.subscribe { e in
                switch e {
                case .Next(_):
                    observer.on(.Next(value))
                case .Error(let error):
                    observer.on(.Error(error))
                case .Completed:
                    observer.on(.Completed)
                }
            }
            return subscription
        }
    }
}

extension UIResponder {
    public var rx_firstResponder: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) {[unowned self] view, shouldRespond in
            shouldRespond ? self.becomeFirstResponder() : self.resignFirstResponder()
        }.asObserver()
    }
}

extension Observable where Element : SignedIntegerType {
    public func negate() -> Observable<E> {
        return self.map({value in -value})
    }
}

extension Observable where Element: BooleanType {
    public func negate() -> Observable<Bool> {
        return self.map({value in !value})
    }
    
    public func filterNegatives() -> Observable<Bool> {
        return self.map({value in value.boolValue})
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



