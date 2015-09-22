//
//  SpeakerCell.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

class SpeakerCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var btnToggleIsFavorite: UIButton!
    
    var indexPath: NSIndexPath?
    var didSetIsFavoriteTo: ((Bool, NSIndexPath)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        btnToggleIsFavorite.setImage(nil, forState: .Normal)
    }

    @IBAction func actionToggleIsFavorite(sender: AnyObject) {
        btnToggleIsFavorite.selected = !btnToggleIsFavorite.selected
        didSetIsFavoriteTo!(btnToggleIsFavorite.selected, indexPath!)
        return
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImage.image = nil
    }
    
    var isFavoriteSpeaker = false
    
    func populateFromSpeaker(speaker: Row) {
        
        let userImage = speaker[Speaker.photo]?.imageValue ?? UIImage(named: "empty")!
        userImage.asyncToSize(.FillSize(self.userImage.bounds.size), cornerRadius: self.userImage.bounds.size.width/2, completion: {result in
            self.userImage.image = result
        })
        
        nameLabel.text = speaker[Speaker.name]
        if let twitter = speaker[Speaker.twitter] where count(twitter) > 0 {
            twitterLabel.text = twitter.hasPrefix("@") ? twitter : "@"+twitter
        } else {
            twitterLabel.text = ""
        }
        btnToggleIsFavorite.selected = isFavoriteSpeaker
        

    }
}
