//
//  StatusBarDownloadProgressView.swift
//  EventBlank
//
//  Created by Marin Todorov on 7/17/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class StatusBarDownloadProgressView: UIView {

    init() {
        let barFrame = UIApplication.sharedApplication().statusBarFrame
        super.init(frame: barFrame)
        
        setupUI()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var textLabel = UILabel()
    private var bgBar = UIView()
    
    func setupUI() {
        //add progress bar
        addSubview(bgBar)
        
        //add text label
        textLabel.frame = bounds
        textLabel.textColor = UIColor.whiteColor()
        textLabel.backgroundColor = UIColor.clearColor()
        textLabel.textAlignment = .Center
        textLabel.font = UIFont.systemFontOfSize(12.0)
        addSubview(textLabel)
    }
    
    func setProgress(p: Double, text t: String) {
        textLabel.text = t
        bgBar.backgroundColor = backgroundColor?.lightenColor(0.1)
        bgBar.frame = CGRect(x: 0, y: 0, width: CGFloat(p) * bounds.size.width, height: bounds.size.height)
    }
}
