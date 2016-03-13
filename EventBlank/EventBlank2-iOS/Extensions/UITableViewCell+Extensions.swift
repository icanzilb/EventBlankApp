//
//  UITableViewCell+Extensions.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 3/13/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

extension UITableViewCell: UITextViewDelegate {
    /// Search up the view hierarchy of the table view cell to find the containing table view
    private var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            
            return table as? UITableView
        }
    }
    
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
