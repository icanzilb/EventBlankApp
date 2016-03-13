//
//  Services.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/27/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

func openUrl(string: String) {
    if let url = NSURL(string: string) {
        openUrl(url)
    }
}

func openUrl(url: NSURL) {
    UIApplication.sharedApplication().openURL(url)
}

extension NSURL {
    convenience init?(stringOptional: String?) {
        guard let string = stringOptional else {
            return nil
        }
        self.init(string: string)
    }
}


