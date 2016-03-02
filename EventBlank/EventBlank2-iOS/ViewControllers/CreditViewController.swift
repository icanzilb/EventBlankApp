//
//  CreditViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/28/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

import RealmSwift
import MMMarkdown

class CreditViewController: UIViewController, UIWebViewDelegate {

    var webView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Credits"
        
        webView.frame = view.bounds
        webView.delegate = self
        view.addSubview(webView)
        
        let textPath = NSBundle.mainBundle().pathForResource("credits", ofType: "markdown")!
        let text = try! NSString(contentsOfFile: textPath, encoding: NSUTF8StringEncoding) as String
        
        //convert markdown to html
        let markdownHtml = try! MMMarkdown.HTMLStringWithMarkdown(text, extensions: MMMarkdownExtensions.GitHubFlavored)
        
        //load event data
        let event = EventData.defaultEvent

        //build template
        let template = try! NSString(
            contentsOfFile: NSBundle.mainBundle().pathForResource("markdown", ofType: "html")!,
            encoding: NSUTF8StringEncoding)
        
        var fullPage = template.stringByReplacingOccurrencesOfString("%markdown%", withString: markdownHtml)
        fullPage = fullPage.stringByReplacingOccurrencesOfString("%headingColor%", withString: event.mainColor.toHexString())
        fullPage = fullPage.stringByReplacingOccurrencesOfString("%linkColor%", withString: event.mainColor.toHexString())
        
        //resources links
        fullPage = fullPage.stringByReplacingOccurrencesOfString("resources://", withString: NSBundle.mainBundle().resourceURL!.absoluteString)

        //footer
        fullPage += "<div style='height: 45px;'>&nbsp;</div>"
        
        //load html in webview
        let resourcesURL = NSBundle.mainBundle().resourceURL!
        webView.loadHTMLString(fullPage, baseURL: resourcesURL)
    }
    
    //MARK: - web view methods
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked && request.URL!.absoluteString.hasPrefix("http") {
            let webVC = self.navigationController!.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
            webVC.initialURL = request.URL
            self.navigationController!.pushViewController(webVC, animated: true)
            return false
        }
        
        return true
    }
}
