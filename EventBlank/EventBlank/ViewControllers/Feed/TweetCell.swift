//
//  TweetCell.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

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
