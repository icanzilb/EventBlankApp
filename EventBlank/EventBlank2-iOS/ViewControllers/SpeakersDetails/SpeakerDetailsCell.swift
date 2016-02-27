//
//  SpeakerDetailsswift
//  EventBlank
//
//  Created by Marin Todorov on 6/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class SpeakerDetailsCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var btnWebsite: UIButton!
    @IBOutlet weak var btnToggleIsFavorite: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var btnIsFollowing: FollowTwitterButton!
    
    private var speaker: Speaker!
    private let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        bioTextView.delegate = self
        btnIsFollowing.addTarget(self, action: "actionFollowSpeaker:", forControlEvents: .TouchUpInside)
        userImage.userInteractionEnabled = true
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapPhotoWithRecognizer:"))
    }
    
    @IBAction func actionToggleIsFavorite(sender: AnyObject) {
        btnToggleIsFavorite.selected = !btnToggleIsFavorite.selected
        btnToggleIsFavorite.animateSelect(scale: 0.8, completion: {
            
        })
        return
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
    
    func populateFromSpeaker(speaker: Speaker) -> Self {
        nameLabel.text = speaker.name
        if let twitterHandle = speaker.twitter where twitterHandle.utf8.count > 0 {
            let twitterString = twitterHandle.hasPrefix("@") ? twitterHandle : "@"+twitterHandle
            btnTwitter.setTitle(twitterString, forState: .Normal)
        }
        
        btnWebsite.setTitle(speaker.url, forState: .Normal)
        bioTextView.text = speaker.bio
        let userImage = speaker.photo ?? UIImage(named: "empty")!
        userImage.asyncToSize(.FillSize(self.userImage.bounds.size), cornerRadius: 5, completion: {result in
            self.userImage.image = result
        })
        
        self.speaker = speaker
        
        return self
    }
    
    func bindUI() {
        
        btnWebsite.rx_tap.replaceWith(speaker.url)
            .map { NSURL(stringOptional: $0) }
            .filter { $0 != nil }
            .map { $0! }
            .bindNext(openUrl)
            .addDisposableTo(bag)
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
        
        return false
    }
}
