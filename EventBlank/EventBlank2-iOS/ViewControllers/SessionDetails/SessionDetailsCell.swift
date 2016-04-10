//
//  SessionDetailsCell.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Then

class SessionDetailsCell: UITableViewCell, ClassIdentifier {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var btnToggleIsFavorite: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var sessionTitleLabel: UITextView!
    @IBOutlet weak var trackTitleLabel: UILabel!

    private var reuseBag = DisposeBag()
    private let lifeBag  = DisposeBag()
    
    // input/output
    let isFavorite = PublishSubject<Bool>()

    static func cellOfTable(tv: UITableView, session: Session, event: EventData) -> SessionDetailsCell {
        return tv.dequeueReusableCell(SessionDetailsCell).then {cell in
            cell.populateFromSession(session, event: event)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        descriptionTextView.delegate = self
    }
    
    func populateFromSession(session: Session, event: EventData) {
        nameLabel.text = session.speakers.first!.name
        
        let time = shortStyleDateFormatter.stringFromDate(session.beginTime!)
        
        var textAttributes = [String: AnyObject]()
        textAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(22)
        sessionTitleLabel.attributedText = NSAttributedString(
            string: "\(time) \(session.title)\n",
            attributes: textAttributes)
        
        trackTitleLabel.text = (session.track?.track ?? "") + "\n"
        
        if let twitter = session.speakers.first!.twitter where twitter.utf8.count > 0 {
            twitterLabel.text = twitter.hasPrefix("@") ? twitter : "@"+twitter
        } else {
            twitterLabel.text = nil
        }
        
        websiteLabel.text = session.speakers.first!.url
        //btnToggleIsFavorite.selected = isFavoriteSession //TODO: add binding
        
        //only way to force textview autosizing I found
        descriptionTextView.text = (session.sessionDescription ?? "") + "\n\n"
        
        let userImage = session.speaker.photo?.data?.imageValue ?? UIImage(named: "empty")!
        userImage.asyncToSize(.FillSize(self.userImage.bounds.size), cornerRadius: 5, completion: {result in
            self.userImage.image = result
        })
        
        if let urlString = session.speakers.first!.url, let url = NSURL(string: urlString) {
            //speaker url TODO: need binding?
        }
        
        //theme
        sessionTitleLabel.textColor = event.mainColor
        trackTitleLabel.textColor = event.mainColor.lightenColor(0.1).desaturatedColor()
        
        //check if in the past
        if NSDate().isLaterThanDate(session.beginTime!) {
            sessionTitleLabel.textColor = sessionTitleLabel.textColor?.desaturateColor(0.5).lighterColor()
            trackTitleLabel.textColor = sessionTitleLabel.textColor
        }
    }
}

extension SessionDetailsCell {
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        openUrl(URL)
        return false
    }
}
