//
//  UIStoryboard+Extensions.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 3/31/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

extension UIStoryboard {
    func instantiateViewController<T: ClassIdentifier>(type: T.Type) -> T {
        return instantiateViewControllerWithIdentifier(type.classIdentifier) as! T
    }
}