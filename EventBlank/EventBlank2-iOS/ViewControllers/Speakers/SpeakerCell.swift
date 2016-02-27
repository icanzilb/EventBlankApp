//
//  SpeakerCell.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift

import RxSwift
import RxCocoa

class SpeakerCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var btnToggleIsFavorite: UIButton!
    
    let bag = DisposeBag()
    let isFavorite = PublishSubject<Bool>()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        btnToggleIsFavorite.setImage(nil, forState: .Normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImage.image = UIImage(named: "empty")!
        twitterLabel.text = nil
    }
    
    func populateFromSpeaker(speaker: Speaker) {
        
        if let userImage = speaker.photo?.imageValue {
            userImage.asyncToSize(.FillSize(self.userImage.bounds.size), cornerRadius: self.userImage.bounds.size.width/2, completion: {result in
                self.userImage.image = result
            })
        }
        
        nameLabel.text = speaker.name
        if let twitter = speaker.twitter where twitter.utf8.count > 0 {
            twitterLabel.text = twitter.hasPrefix("@") ? twitter : "@"+twitter
        }
        
        isFavorite.bindTo(btnToggleIsFavorite.rx_selected).addDisposableTo(bag)
    }
}
