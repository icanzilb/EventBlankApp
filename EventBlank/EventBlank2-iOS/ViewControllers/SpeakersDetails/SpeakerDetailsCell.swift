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

import Then

class SpeakerDetailsCell: UITableViewCell, ClassIdentifier {
    
    var reuseBag = DisposeBag()
    private let lifeBag  = DisposeBag()

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var btnWebsite: UIButton!
    @IBOutlet weak var btnToggleIsFavorite: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var btnIsFollowing: FollowTwitterButton!
    
    // input/output
    let isFavorite = PublishSubject<Bool>()
    let isFollowing = PublishSubject<FollowingOnTwitter>()
    
    // methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        bioTextView.delegate = self
        
        //bind UI
        isFavorite.bindTo(btnToggleIsFavorite.rx_selected).addDisposableTo(lifeBag)
        
        btnToggleIsFavorite.rx_tap.subscribeNext {[unowned self] in
            self.isFavorite.onNext(!self.btnToggleIsFavorite.selected)
            self.btnToggleIsFavorite.animateSelect(scale: 0.8, completion: nil)
        }.addDisposableTo(lifeBag)
        
        //following
        isFollowing.asObservable()
            .bindTo(btnIsFollowing.rx_following)
            .addDisposableTo(lifeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseBag = DisposeBag()
    }
    
    static func cellOfTable(tv: UITableView, speaker: Speaker) -> SpeakerDetailsCell {
        return tv.dequeueReusableCell(SpeakerDetailsCell).then {cell in
            cell.populateFromSpeaker(speaker)
        }
    }
    
    func populateFromSpeaker(speaker: Speaker) {
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
        
        //
        // bind UI
        //
        
        //photo
        userImage.rx_gesture(.Tap)
            .subscribeNext {_ in
                PhotoPopupView.showImage(speaker.photo!,
                    inView: UIApplication.sharedApplication().windows.first!)
            }.addDisposableTo(reuseBag)
        
        //twitter button
        btnTwitter.rx_tap.replaceWith(speaker.twitter)
            .unwrap()
            .map(twitterUrl)
            .bindNext(openUrl)
            .addDisposableTo(reuseBag)
        
        //website button
        btnWebsite.rx_tap.replaceWith(speaker.url)
            .map { NSURL(stringOptional: $0) }
            .unwrap()
            .bindNext(UIApplication.interactor.showWebPage)
            .addDisposableTo(reuseBag)
    }
}

extension SpeakerDetailsCell {
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        openUrl(URL)
        return false
    }
}
