//
//  UITableView+Extensions.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 3/31/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: ClassIdentifier>(type: T.Type) -> T {
        print("\(type): \(T.classIdentifier)")
        return dequeueReusableCellWithIdentifier(T.classIdentifier) as! T
    }
}