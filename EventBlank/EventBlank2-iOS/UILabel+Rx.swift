//
//  UILabel+Rx.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/20/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private func bindingErrorToInterface(error: ErrorType) {
    let error = "Binding error to UI: \(error)"
    #if DEBUG
        rxFatalError(error)
    #else
        print(error)
    #endif
}

extension UILabel {
    
    /**
     Bindable sink for `textColor` property.
     */
    public var rx_textColor: AnyObserver<UIColor> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let value):
                self?.textColor = value
            case .Error(let error):
                bindingErrorToInterface(error)
                break
            case .Completed:
                break
            }
        }
    }
    
}
