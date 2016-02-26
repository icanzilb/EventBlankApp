//
//  SpeakerDetailsswift
//  EventBlank
//
//  Created by Marin Todorov on 6/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class SpeakerDetailsCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var btnToggleIsFavorite: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var btnIsFollowing: FollowTwitterButton!
    
    var indexPath: NSIndexPath?
    var didSetIsFavoriteTo: ((Bool, NSIndexPath)->Void)?
    
    var speakerUrl: NSURL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        
        twitterLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("actionTapTwitter")))
        websiteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("actionTapURL")))
        
        bioTextView.delegate = self
        
        btnIsFollowing.addTarget(self, action: "actionFollowSpeaker:", forControlEvents: .TouchUpInside)
        
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
    
    var didTapFollow: (()->Void)?
    
    @IBAction func actionFollowSpeaker(sender: AnyObject) {
//        if btnIsFollowing.followState == .Follow {
//            didTapFollow?()
//        }
    }
    
    var didTapPhoto: (()->Void)?
    
    func didTapPhotoWithRecognizer(tap: UITapGestureRecognizer) {
        didTapPhoto?()
    }
    
    var isFavoriteSpeaker = false

    func populateFromSpeaker(speaker: Speaker) -> Self {
        nameLabel.text = speaker.name
        if let twitterHandle = speaker.twitter where twitterHandle.utf8.count > 0 {
            twitterLabel.text = twitterHandle.hasPrefix("@") ? twitterHandle : "@"+twitterHandle
        }
        
        websiteLabel.text = speaker.url
        bioTextView.text = speaker.bio
        let userImage = speaker.photo?.imageValue ?? UIImage(named: "empty")!
        userImage.asyncToSize(.FillSize(self.userImage.bounds.size), cornerRadius: 5, completion: {result in
            self.userImage.image = result
        })
        
        return self
    }
    
    /*
    func populateFromSpeaker(speaker: Speaker, twitter: TwitterController) {
        nameLabel.text = speaker.name

        if let twitterHandle = speaker.twitter where twitterHandle.utf8.count > 0 {
            twitterLabel.text = twitterHandle.hasPrefix("@") ? twitterHandle : "@"+twitterHandle
            
            btnIsFollowing.hidden = false
            btnIsFollowing.username = twitterLabel.text
            
            
            //check if already following speaker
            twitter.authorize({success in
                if success {
                    twitter.isFollowingUser(twitterHandle, completion: {following in
                        if let following = following {
                            self.btnIsFollowing.followState = following ? .Following : .Follow
                        } else {
                            self.btnIsFollowing.hidden = true
                        }
                    })
                } else {
                    self.btnIsFollowing.hidden = true
                }
            })
        } else {
            mainQueue {
                self.btnIsFollowing.hidden = true
                self.twitterLabel.text = ""
                self.didTapTwitter = nil
            }
        }

        websiteLabel.text = speaker[Speaker.url]
        btnToggleIsFavorite.selected = isFavoriteSpeaker
        bioTextView.text = speaker[Speaker.bio]
        let userImage = speaker[Speaker.photo]?.imageValue ?? UIImage(named: "empty")!
        userImage.asyncToSize(.FillSize(self.userImage.bounds.size), cornerRadius: 5, completion: {result in
            self.userImage.image = result
        })

        if let urlString = speaker[Speaker.url], let url = NSURL(string: urlString) {
            speakerUrl = url
        } else {
            speakerUrl = nil
        }
    } */
}

extension SpeakerDetailsCell: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        didTapURL?(URL)
        return false
    }
}
