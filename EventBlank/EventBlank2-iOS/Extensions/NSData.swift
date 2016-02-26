//
//  NSData.swift
//  EventBlank
//
//  Created by Marin Todorov on 12/13/15.
//  Copyright © 2015 Underplot ltd. All rights reserved.
//

import UIKit

extension NSData {
    var imageValue: UIImage? {
        if let image = UIImage(data: self) {
            return image
        } else {
            return nil
        }
    }
}