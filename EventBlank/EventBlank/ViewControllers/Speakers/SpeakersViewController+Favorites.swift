//
//  SpeakersViewController+Favorites.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

//MARK: - favorites
extension SpeakersViewController {
    
    func didFavoritesChange(n: NSNotification) {
        
        if let sender = n.userInfo?.values.first as? SpeakersModel where sender === speakers {
            //model already up to date, just reload table
            self.tableView.reloadData()
            return
        }
        
        backgroundQueue({
            self.speakers.refreshFavorites()
            self.speakers.filterItemsWithTerm(self.searchController.searchBar.text, favorites: self.btnFavorites.selected)
            },
            completion: self.tableView.reloadData)
    }
    
    func actionToggleFavorites(sender: AnyObject) {
        btnFavorites.selected = !btnFavorites.selected
        
        self.notification(kFavoritesToggledNotification, object: nil)
        
        let message = alert(btnFavorites.selected ? "Showing favorite speakers only" : "Showing all speakers", buttons: [], completion: nil)
        delay(seconds: 1.0, {
            message.dismissViewControllerAnimated(true, completion: nil)
        })
        
        btnFavorites.animateSelect(scale: 0.8, completion: nil)
        
        backgroundQueue({
            self.speakers.filterItemsWithTerm(self.searchController.searchBar.text, favorites: self.btnFavorites.selected)
            },
            completion: {
                //show no sessions message
                if self.speakers.currentNumberOfItems == 0 {
                    self.tableView.addSubview(MessageView(text: "You didn't favorite any speakers yet"))
                } else {
                    MessageView.removeViewFrom(self.tableView)
                }
                self.tableView.reloadData()
        })
    }
}