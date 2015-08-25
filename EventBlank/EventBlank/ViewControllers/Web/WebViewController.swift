//
//  WebViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import WebKit

//TODO: check the safari vc in iOS9 if iOS9 adoption rate is real high

class WebViewController: UIViewController, WKNavigationDelegate {

    var initialURL: NSURL! //set from previous controller
    private var webView = WKWebView()
    
    var loadingIndicator = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = initialURL.absoluteString
        
        webView.frame = view.bounds
        webView.frame.size.height -= ((UIApplication.sharedApplication().windows.first! as! UIWindow).rootViewController! as! UITabBarController).tabBar.frame.size.height
        webView.navigationDelegate = self
        view.insertSubview(webView, belowSubview: loadingIndicator)
        
        //setup loading indicator
        loadingIndicator.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.15)
        loadingIndicator.userInteractionEnabled = false
        loadingIndicator.hidden = true
        navigationController?.navigationBar.addSubview(loadingIndicator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let request = NSURLRequest(URL: initialURL!)
        webView.loadRequest(request)
        setLoadingIndicatorAnimating(true)
        
        //observe the progress
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //remove observer
        webView.stopLoading()
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        
        loadingIndicator.removeFromSuperview()
    }
    
    func setLoadingIndicatorAnimating(animating: Bool) {
        loadingIndicator.hidden = !animating
        if animating {
            loadingIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: navigationController!.navigationBar.bounds.size.height)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            
            if loadingIndicator.hidden {
                loadingIndicator.hidden = false
            }
            
            self.title = webView.title ?? webView.URL?.absoluteString
            
            UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseOut, animations: {
                self.loadingIndicator.frame = CGRect(
                    x: 0, y: 0,
                    width: self.navigationController!.navigationBar.bounds.size.width * CGFloat(self.webView.estimatedProgress),
                    height: self.navigationController!.navigationBar.bounds.size.height)

                }, completion: {_ in
                    if self.webView.estimatedProgress > 0.95 {
                        mainQueue {
                            //hide the loading indicator
                            UIView.animateWithDuration(0.2, animations: {
                                self.loadingIndicator.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.15)
                            }, completion: {_ in
                                self.setLoadingIndicatorAnimating(false)
                                self.loadingIndicator.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.15)
                            })
                            
                        }
                    }
            })
            
        }
    }
    
}
