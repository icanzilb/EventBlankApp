//
//  SpeakersViewController+Search.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift

//MARK: search
extension SpeakersViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    func setupSearchBar() {
        //search bar
        searchController.searchBar.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.center = CGPoint(
            x: CGRectGetMidX(navigationController!.navigationBar.frame) + 4,
            y: 20)
        
        //search controller is the worst
        let iOSVersion = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
        if iOSVersion < 9.0 {
            //position the bar on iOS8
            searchController.searchBar.center = CGPoint(
                x: CGRectGetMinX(navigationController!.navigationBar.frame) + 4,
                y: 20)
        }
        
        toggleSearchBarVisibility(true)
    }
    
    func toggleSearchBarVisibility(visible: Bool) {
        if visible {
            navigationController!.navigationBar.addSubview(
                searchController.searchBar
            )
        } else {
            searchController.searchBar.removeFromSuperview()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBarBtnCancel.onNext()
    }
    
    func fadeInSearchBar(visible: Bool) {
        let (from, to) = visible ? (0.0, 1.0) : (1.0, 0.0)
        
        searchController.searchBar.alpha = CGFloat(from)
        searchController.searchBar.setNeedsDisplay()
        
        UIView.animateWithDuration(0.33, delay: 0, options: [], animations: {
            self.searchController.searchBar.alpha = CGFloat(to)
            }, completion: nil)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //placeholder
    }
}
