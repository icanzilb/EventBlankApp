//
//  SessionDetailsCell.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/25/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class SessionDetailsCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var btnToggleIsFavorite: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var sessionTitleLabel: UITextView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    
    var indexPath: NSIndexPath?
    var didSetIsFavoriteTo: ((Bool, NSIndexPath)->Void)?
    
    var speakerUrl: NSURL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        
        twitterLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("actionTapTwitter")))
        websiteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("actionTapURL")))
        
        descriptionTextView.delegate = self
    }

    @IBAction func actionToggleIsFavorite(sender: AnyObject) {
        btnToggleIsFavorite.selected = !btnToggleIsFavorite.selected
        btnToggleIsFavorite.animateSelect(scale: 0.8, completion: {
            self.didSetIsFavoriteTo!(self.btnToggleIsFavorite.selected, self.indexPath!)
        })
        
        return
    }
    
    var didTapTwitter: (()->Void)?
    var didTapURL: ((NSURL)->Void)?
    
    func actionTapTwitter() {
        didTapTwitter?()
    }
    
    func actionTapURL() {
        if let speakerUrl = speakerUrl {
            didTapURL?(speakerUrl)
        }
    }
}

extension SessionDetailsCell: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        didTapURL?(URL)
        return false
    }
}
