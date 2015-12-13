//
//  SessionTableViewswift
//  EventBlank
//
//  Created by Marin Todorov on 6/20/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift

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
  
    var dateFormatter: NSDateFormatter!
    var isFavoriteSession = false
    var isFavoriteSpeaker = false
    
    var mainColor: UIColor!
    
    func populateFromSession(session: Row) {
        
        titleLabel.text = session[Session.title]
        speakerLabel.text = session[Speaker.name]
        trackLabel.text = session[Track.track]
        
        let sessionDate = NSDate(timeIntervalSince1970: Double(session[Session.beginTime]))
        timeLabel.text = dateFormatter.stringFromDate(sessionDate)
        
        let userImage = session[Speaker.photo]?.imageValue ?? UIImage(named: "empty")!
        userImage.asyncToSize(.FillSize(speakerImageView.bounds.size), cornerRadius: speakerImageView.bounds.size.width/2, completion: {result in
            self.speakerImageView.image = result
        })
        
        locationLabel.text = session[Location.name]
        
        btnToggleIsFavorite.selected = isFavoriteSession
        btnSpeakerIsFavorite.selected = isFavoriteSpeaker
        
        //theme
        titleLabel.textColor = mainColor
        trackLabel.textColor = mainColor.lightenColor(0.1).desaturatedColor()
        speakerLabel.textColor = UIColor.blackColor()
        locationLabel.textColor = UIColor.blackColor()
        
        //check if in the past
        if NSDate().isLaterThanDate(sessionDate) {
            titleLabel.textColor = titleLabel.textColor.desaturateColor(0.5).lighterColor()
            trackLabel.textColor = titleLabel.textColor
            speakerLabel.textColor = UIColor.grayColor()
            locationLabel.textColor = UIColor.grayColor()
        }
    }
  
}