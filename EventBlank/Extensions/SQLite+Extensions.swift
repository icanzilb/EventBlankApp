//
//  SQLite+Extensions.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

extension Query {
    func map<T>(block: (Row)->T) -> [T] {
        var result = [T]()
        for row in self {
            result.append(block(row))
        }
        return result
    }
}

extension Blob {
    var imageValue: UIImage? {
        let photoData = NSData(bytes: self.bytes, length: self.length)
        if let image = UIImage(data: photoData) {
            return image
        } else {
            return nil
        }
    }
}

extension UIImage {
    var blobValue: Blob? {
        let photoData = UIImagePNGRepresentation(self)
        return Blob(bytes: photoData.bytes, length: photoData.length)
    }
}

