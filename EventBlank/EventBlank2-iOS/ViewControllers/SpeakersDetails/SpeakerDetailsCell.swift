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
    
    private let bag = DisposeBag()

    @IBOutlet weak var userImage: TappableImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var btnWebsite: UIButton!
    @IBOutlet weak var btnToggleIsFavorite: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var btnIsFollowing: FollowTwitterButton!
    
    private var speaker: Speaker!

    // input/output
    let isFavorite = PublishSubject<Bool>()

    // methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        bioTextView.delegate = self
    }
    
    var didTapFollow: (()->Void)?
    
    @IBAction func actionFollowSpeaker(sender: AnyObject) {
//        if btnIsFollowing.followState == .Follow {
//            didTapFollow?()
//        }
    }
    
    static func cellOfTable(tv: UITableView, speaker: Speaker) -> SpeakerDetailsCell {
        return (tv.dequeueReusableCellWithIdentifier("SpeakerDetailsCell") as! SpeakerDetailsCell).populateFromSpeaker(speaker)
    }
    
    func populateFromSpeaker(speaker: Speaker) -> Self {
        
        //
        // setup UI
        //
        nameLabel.text = speaker.name
        
        if let twitterHandle = speaker.twitter where twitterHandle.utf8.count > 0 {
            let twitterString = twitterHandle.hasPrefix("@") ? twitterHandle : "@"+twitterHandle
            btnTwitter.setTitle(twitterString, forState: .Normal)
        }
        
        btnWebsite.setTitle(speaker.url, forState: .Normal)
        bioTextView.text = speaker.bio

        let image = speaker.photo ?? UIImage(named: "empty")!
        image.asyncToSize(.FillSize(self.userImage.bounds.size), cornerRadius: 5, completion: {result in
            self.userImage.image = result
        })
        
        self.speaker = speaker
        
        //
        // bind UI
        //
        
        //photo
        userImage.rx_tap.subscribeNext {
            PhotoPopupView.showImage(speaker.photo!,
                inView: UIApplication.sharedApplication().windows.first!)
        }.addDisposableTo(bag)
        
        //favorite button
        isFavorite.bindTo(btnToggleIsFavorite.rx_selected).addDisposableTo(bag)
        
        btnToggleIsFavorite.rx_tap.subscribeNext {[unowned self] in
            self.isFavorite.onNext(!self.btnToggleIsFavorite.selected)
            self.btnToggleIsFavorite.animateSelect(scale: 0.8, completion: nil)
        }.addDisposableTo(bag)
        
        //following button
        btnIsFollowing.rx_tap.subscribeNext {_ in
            
        }.addDisposableTo(bag)
        
        //website button
        btnWebsite.rx_tap.replaceWith(speaker.url)
            .map { NSURL(stringOptional: $0) }
            .unwrap()
            .bindNext(openUrl)
            .addDisposableTo(bag)
        
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
        openUrl(URL)
        return false
    }
}
