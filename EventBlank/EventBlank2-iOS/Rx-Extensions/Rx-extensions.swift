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
        return UIBindingObserver(UIElement: self) {control, shouldRespond in
            shouldRespond ? control.becomeFirstResponder() : control.resignFirstResponder()
        }.asObserver()
    }
}

extension Observable {
    func replaceNilWith(value: Element) -> Observable<Element> {
        return map {element in element == nil ? value : element}
    }
}

extension Observable where Element: SignedIntegerType {
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
    public func filterOut(targetValues: [Element]) -> Observable<Element> {
        return self.filter {value in !targetValues.contains(value)}
    }
}

protocol Optionable
{
    associatedtype WrappedType
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

extension Observable where Element: Optionable {
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

extension CollectionType where Self.Generator.Element: Optionable {
    func unwrap() -> [Self.Generator.Element.WrappedType] {
        return self
            .filter {value in
                return !value.isEmpty()
            }
            .map {value in
                return value.unwrap()
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