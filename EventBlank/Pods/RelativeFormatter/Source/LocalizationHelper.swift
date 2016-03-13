//
//  String+Local.swift
//  RelativeFormatter
//
//  Created by David Collado Sela on 12/5/15.
//  Copyright (c) 2015 David Collado Sela. All rights reserved.
//

import Foundation

class LocalizationHelper{
    class func localize(key:String,count:Int?=nil)->String{
        let bundlePath = (NSBundle(forClass: LocalizationHelper.self).resourcePath! as NSString).stringByAppendingPathComponent("RelativeFormatter.bundle")
        
        var localizedString = NSLocalizedString(key, tableName: "RelativeFormatter", bundle: NSBundle(path: bundlePath)!, value: "", comment: "")
        
        if let count = count{
            localizedString = String.localizedStringWithFormat(localizedString, count)
        }
        return localizedString
    }
}
