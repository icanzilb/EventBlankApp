//
//  Interactor.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 3/2/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

enum Segue {
    case SessionDetails(session: Session)
    case SpeakerDetails(speaker: Speaker)
    case WebPage(url: NSURL)
}

class Interactor {

    func show(segue: Segue, sender: UIViewController) throws {
        
        switch segue {
        
        //speaker details
        case .SessionDetails(let session):
            showViewController(SessionDetailsViewController.createWith(sender.storyboard!, session: session), sender: sender)
        case .SpeakerDetails(let speaker):
            showViewController(SpeakerDetailsViewController.createWith(sender.storyboard!, speaker: speaker), sender: sender)
        case .WebPage(let url):
            showViewController(WebViewController.createWith(sender.storyboard!, url: url), sender: sender)
        }
    }
    
    func showWebPage(url: NSURL) {
        if let topViewController = UIApplication.topViewController() {
            showViewController(WebViewController.createWith(defaultStoryboard, url: url), sender: topViewController)
        } else {
            openUrl(url)
        }
    }
    
    lazy private var defaultStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    private func showViewController(target: UIViewController, sender: UIViewController) {
        if let nav = sender.navigationController {
            nav.pushViewController(target, animated: true)
        } else {
            sender.presentViewController(target, animated: true, completion: nil)
        }
    }
    
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}