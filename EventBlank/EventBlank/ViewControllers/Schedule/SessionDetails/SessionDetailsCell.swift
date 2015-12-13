//
//  SessionDetailsswift
//  EventBlank
//
//  Created by Marin Todorov on 6/25/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift

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
        
        userImage.userInteractionEnabled = true
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapPhotoWithRecognizer:"))
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
    
    var didTapPhoto: (()->Void)?
    
    func didTapPhotoWithRecognizer(tap: UITapGestureRecognizer) {
        didTapPhoto?()
    }
    
    var dateFormatter: NSDateFormatter!
    var isFavoriteSession = false
    var mainColor: UIColor!
    
    func populateFromSession(session: Row) {
        nameLabel.text = session[Speaker.name]
        
        let sessionDate = NSDate(timeIntervalSince1970: Double(session[Session.beginTime]))
        let time = dateFormatter.stringFromDate(sessionDate)
        
        sessionTitleLabel.attributedText = NSAttributedString(
            string: "\(time) \(session[Session.title])\n",
            attributes: NSDictionary(object: UIFont.systemFontOfSize(22), forKey: NSFontAttributeName) as [NSObject : AnyObject])
        
        trackTitleLabel.text = (session[Track.track] ?? "") + "\n"
        
        if let twitter = session[Speaker.twitter] where count(twitter) > 0 {
            twitterLabel.text = twitter.hasPrefix("@") ? twitter : "@"+twitter
        } else {
            twitterLabel.text = nil
        }
        
        websiteLabel.text = session[Speaker.url]
        btnToggleIsFavorite.selected = isFavoriteSession
            
        //only way to force textview autosizing I found
        descriptionTextView.text = (session[Session.description] ?? "") + "\n\n"
        
        let userImage = session[Speaker.photo]?.imageValue ?? UIImage(named: "empty")!
        userImage.asyncToSize(.FillSize(self.userImage.bounds.size), cornerRadius: 5, completion: {result in
            self.userImage.image = result
        })

        if let urlString = session[Speaker.url], let url = NSURL(string: urlString) {
            speakerUrl = url
        } else {
            speakerUrl = nil
        }
        
        //theme
        sessionTitleLabel.textColor = mainColor
        trackTitleLabel.textColor = mainColor.lightenColor(0.1).desaturatedColor()
        
        //check if in the past
        if NSDate().isLaterThanDate(sessionDate) {
            sessionTitleLabel.textColor = sessionTitleLabel.textColor.desaturateColor(0.5).lighterColor()
            trackTitleLabel.textColor = sessionTitleLabel.textColor
        }
    }
}

extension SessionDetailsCell: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        didTapURL?(URL)
        return false
    }
}
