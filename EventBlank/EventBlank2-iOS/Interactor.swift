//
//  Interactor.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 3/2/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

enum Segue {
    case SpeakerDetails(speaker: Speaker)
    case WebPage(url: NSURL)
}

class Interactor {

    func show(segue: Segue, sender: UIViewController) throws {
        
        switch segue {
        
        //speaker details
        case .SpeakerDetails(let speaker):
            showViewController(SpeakerDetailsViewController.createWith(sender.storyboard!, speaker: speaker), sender: sender)
        case .WebPage(let url):
            showViewController(WebViewController.createWith(sender.storyboard!, url: url), sender: sender)
        }
    }
    
    private func showViewController(target: UIViewController, sender: UIViewController) {
        if let nav = sender.navigationController {
            nav.pushViewController(target, animated: true)
        }
    }
    
}
