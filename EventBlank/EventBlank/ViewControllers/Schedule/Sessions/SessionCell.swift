//
//  SessionTableViewCell.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/20/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class SessionTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var speakerLabel: UILabel!
    @IBOutlet weak var speakerImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var btnToggleIsFavorite: UIButton!
    @IBOutlet weak var btnSpeakerIsFavorite: UIButton!
    
    var indexPath: NSIndexPath?
    var didSetIsFavoriteTo: ((Bool, NSIndexPath)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        
        btnSpeakerIsFavorite.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        btnSpeakerIsFavorite.setImage(nil, forState: .Normal)
    }

    @IBAction func actionToggleIsFavorite(sender: AnyObject) {
        btnToggleIsFavorite.selected = !btnToggleIsFavorite.selected
        
        btnToggleIsFavorite.animateSelect(scale: 0.8, completion: {
            self.didSetIsFavoriteTo!(self.btnToggleIsFavorite.selected, self.indexPath!)
        })
        
        return
    }
    
}