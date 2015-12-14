//
//  SpeakersViewController+Search.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

//MARK: search
extension SpeakersViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    //how can a single class be so broken @UISearchController?
    
    @IBAction func actionSearch(sender: AnyObject) {
        searchController.searchBar.hidden = false
        
        btnFavorites.hidden = true
        navigationItem.leftBarButtonItem = nil
        
        searchController.searchBar.becomeFirstResponder()
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        searchController.searchBar.hidden = true
        
        self.btnFavorites.hidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "actionSearch:")
    }
    
    func showSearchBar() {
        UIView.animateWithDuration(0.33, delay: 0, options: [], animations: {
            self.searchController.searchBar.alpha = 1
            }, completion: nil)
    }
    
    func hideSearchBar(completion: (()->Void)? = nil) {
        UIView.animateWithDuration(0.33, delay: 0, options: [], animations: {
            self.searchController.searchBar.alpha = 0
            }, completion: nil)
    }
    
    //search controller
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.speakers.filterItemsWithTerm(searchController.searchBar.text, favorites: self.btnFavorites.selected)
        self.tableView.reloadData()
    }
}

