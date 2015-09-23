//
//  Tweetswift
//  EventBlank
//
//  Created by Marin Todorov on 6/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

class TweetCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var attachmentImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var didTapAttachment: (()->Void)? {
        willSet {
            if let _ = newValue where attachmentImage.gestureRecognizers == nil {
                attachmentImage.userInteractionEnabled = true
                attachmentImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "actionTapAttachment"))
            }
        }
    }
    
    var didTapURL: ((NSURL)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        message.delegate = self
    }
    
    func actionTapAttachment() {
        didTapAttachment?()
    }
    
    var attachmentHeight: NSLayoutConstraint {
        let constraints = attachmentImage.constraints() as! [NSLayoutConstraint]
        let attachmentHeight = filter(constraints, { $0.firstAttribute == NSLayoutAttribute.Height && $0.relation == NSLayoutRelation.Equal}).first!
        return attachmentHeight
    }
    
    override func prepareForReuse() {
        if attachmentImage != nil {
            attachmentImage.image = nil
        }
        userImage.image = nil
        
        didTapAttachment = nil
        attachmentHeight.constant = 0.0
    }
    
    
    var database: Database!
    
    func populateFromNewsTweet(tweet: Row) {
        
        let usersTable = database[UserConfig.tableName]
        let user = usersTable.filter(User.idColumn == tweet[Chat.idUser]).first
        
        message.text = tweet[News.news]
        timeLabel.text = NSDate(timeIntervalSince1970: Double(tweet[News.created])).relativeTimeToString()
        message.selectedRange = NSRange(location: 0, length: 0)
        
        if let attachmentUrlString = tweet[News.imageUrl], let attachmentUrl = NSURL(string: attachmentUrlString) {
            attachmentImage.hnk_setImageFromURL(attachmentUrl, placeholder: nil, format: nil, failure: nil, success: {image in
                image.asyncToSize(.Fill(self.attachmentImage.bounds.width, 150), cornerRadius: 5.0, completion: {result in
                    self.attachmentImage.image = result
                })
            })
            attachmentHeight.constant = 148.0
        }
        
        if let user = user {
            nameLabel.text = user[User.name]
            if let imageUrlString = user[User.photoUrl], let imageUrl = NSURL(string: imageUrlString) {
                userImage.hnk_setImageFromURL(imageUrl, placeholder: UIImage(named: "feed-item"), format: nil, failure: nil, success: {image in
                    image.asyncToSize(.FillSize(self.userImage.bounds.size), cornerRadius: 5.0, completion: {result in
                        self.userImage.image = result
                    })
                })
            }
        }
    }
    
    func populateFromChatTweet(tweet: Row) {
        
        let usersTable = database[UserConfig.tableName]
        let user = usersTable.filter(User.idColumn == tweet[Chat.idUser]).first
        
        message.text = tweet[Chat.message]
        timeLabel.text = NSDate(timeIntervalSince1970: Double(tweet[Chat.created])).relativeTimeToString()
        message.selectedRange = NSRange(location: 0, length: 0)
        
        if let attachmentUrlString = tweet[Chat.imageUrl], let attachmentUrl = NSURL(string: attachmentUrlString) {
            attachmentImage.hnk_setImageFromURL(attachmentUrl, placeholder: nil, format: nil, failure: nil, success: {image in
                image.asyncToSize(.Fill(self.attachmentImage.bounds.width, 150), cornerRadius: 0.0, completion: {result in
                    self.attachmentImage.image = result
                })
            })
            attachmentHeight.constant = 148.0
        }
        
        if let user = user {
            nameLabel.text = user[User.name]
            if let imageUrlString = user[User.photoUrl], let imageUrl = NSURL(string: imageUrlString) {
                self.userImage.hnk_setImageFromURL(imageUrl, placeholder: UIImage(named: "feed-item"), format: nil, failure: nil, success: {image in
                    image.asyncToSize(.FillSize(self.userImage.bounds.size), cornerRadius: 5.0, completion: {result in
                        self.userImage.image = result
                    })
                })
            }
        }
    }
}

// https://pontifex.azurewebsites.net/self-sizing-uitableviewcell-with-uitextview-in-ios-8/

extension UITableViewCell: UITextViewDelegate {

    public func textViewDidChange(textView: UITextView) {
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.max))
        
        // Resize the cell only when cell's size is changed
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            if let thisIndexPath = tableView?.indexPathForCell(self) {
                tableView?.scrollToRowAtIndexPath(thisIndexPath, atScrollPosition: .Bottom, animated: false)
            }
        }
    }
}

extension UITableViewCell {
    /// Search up the view hierarchy of the table view cell to find the containing table view
    var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            
            return table as? UITableView
        }
    }
}

extension TweetCell: UITextViewDelegate {    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        didTapURL?(URL)
        return false
    }
}
