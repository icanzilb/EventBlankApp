//
//  MDViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/24/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

import RealmSwift
import MMMarkdown
import DynamicColor

class MDViewController: UIViewController, UIWebViewDelegate, ClassIdentifier {
    
    var text: Text!
    
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        title = text.title
        
        //convert markdown to html
        let markdownHtml = try! MMMarkdown.HTMLStringWithMarkdown(text.content, extensions: MMMarkdownExtensions.GitHubFlavored)
        
        //load event data
        let event = EventData.defaultEvent
        
        //build template
        let template = try! NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("markdown", ofType: "html")!,
            encoding: NSUTF8StringEncoding)
        
        var fullPage = template.stringByReplacingOccurrencesOfString("%markdown%", withString: markdownHtml)
        fullPage = fullPage.stringByReplacingOccurrencesOfString("%headingColor%", withString: event.mainColor.toHexString())

        fullPage = fullPage.stringByReplacingOccurrencesOfString("%linkColor%", withString: event.mainColor.toHexString())
        
        fullPage += "<div style='height: 45px;'>&nbsp;</div>" //who came up with this stupidity to extend content under bars???
        
        //load html in webview
        let resourcesURL = NSBundle.mainBundle().resourceURL!
        webView.loadHTMLString(fullPage, baseURL: resourcesURL)
    }
    
    //MARK: - web view methods
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked && request.URL!.absoluteString.hasPrefix("http") {
            //TODO: implement new web vc here
            //            let webVC = self.navigationController!.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
//            webVC.initialURL = request.URL
//            self.navigationController!.pushViewController(webVC, animated: true)
            return false
        }
        
        return true
    }

}