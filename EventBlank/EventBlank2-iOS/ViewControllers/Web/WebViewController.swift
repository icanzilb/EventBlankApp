//
//  WebViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import WebKit
import Reachability

import RxSwift
import Then

class WebViewController: UIViewController, ClassIdentifier {

    private let bag = DisposeBag()
    private let webView = WKWebView()
    private let loadingIndicator = UIView()
    
    private var viewModel: WebViewModel!
    
    // MARK: create
    
    static func createWith(storyboard: UIStoryboard,
        url: NSURL) -> WebViewController {
            
        return storyboard.instantiateViewController(WebViewController).then {vc in
            vc.viewModel = WebViewModel(url: url)
        }
    }
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        webView.frame = view.bounds
        viewModel.active = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.active = true
        loadingIndicator.removeFromSuperview()
    }
    
    // MARK: setup UI
    
    func setupUI() {
        webView.frame.size.height -= ((UIApplication.sharedApplication().windows.first!).rootViewController! as! UITabBarController).tabBar.frame.size.height
        webView.backgroundColor = UIColor.redColor()
        view.addSubview(webView)
        
        //setup loading indicator
        loadingIndicator.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.15)
        navigationController?.navigationBar.addSubview(loadingIndicator)
    }

    // MARK: bind UI
    func bindUI() {
        
        //load the web page
        viewModel.urlRequest
            .bindNextIgnoreResult(webView.loadRequest)
            .addDisposableTo(bag)
        
        let progress = webView.rx_observe(Double.self, "estimatedProgress").shareReplay(1)

        //show/hide progress
        progress
            .map {$0 > 0.99}
            .debug()
            .bindTo(loadingIndicator.rx_hidden)
            .addDisposableTo(bag)
        
        //update progress bar
        progress
            .debug()
            .bindNext(displayProgress)
            .addDisposableTo(bag)
    }
    
    // MARK: private
    
    func displayProgress(progress: Double?) {

        self.title = webView.title ?? webView.URL?.absoluteString
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseOut, animations: {
            self.loadingIndicator.frame = CGRect(
                x: 0, y: 0,
                width: self.navigationController!.navigationBar.bounds.size.width * CGFloat(self.webView.estimatedProgress),
                height: self.navigationController!.navigationBar.bounds.size.height)
            
            }, completion: {_ in
                if progress > 0.95 {
                    mainQueue {
                        //hide the loading indicator
                        UIView.animateWithDuration(0.2, animations: {
                            self.loadingIndicator.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.15)
                            }, completion: {_ in
                                self.loadingIndicator.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.15)
                        })
                        
                    }
                }
        })
    }
    
    //TODO: add reachability to the view controller
    
    func __loadInitialURL() {
//        //not connected message
//        let reach = Reachability(hostName: initialURL!.host)
//        if !reach.isReachable() {
//            //show the message
//            view.addSubview(MessageView(text: "It certainly looks like you are not connected to the Internet right now..."))
//            
//            //show a reload button
//            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "loadInitialURL")
//            
//            return
//        }

        MessageView.removeViewFrom(view)
        navigationItem.rightBarButtonItem = nil
    }
}
