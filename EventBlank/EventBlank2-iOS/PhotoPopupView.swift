//
//  PhotoPopupView.swift
//  EventBlank
//
//  Created by Marin Todorov on 8/23/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import Haneke

class PhotoPopupView: UIView {

    static func showImage(image: UIImage, inView: UIView) {
        let popup = PhotoPopupView()
        inView.addSubview(popup)
        
        popup.photo = image
    }
    
    static func showImageWithUrl(url: NSURL, inView: UIView) {
        let popup = PhotoPopupView()
        inView.addSubview(popup)
        
        popup.photoUrl = url
    }
    
    func hideImage() {
        didTapPhoto(UITapGestureRecognizer()) //hack
    }
    
    var photoUrl: NSURL! {
        didSet {
            imgView.hnk_setImageFromURL(photoUrl, placeholder: nil, format: nil, failure: {error in
                
                UIViewController.alert("Couldn't fetch image.", buttons: ["Close"], completion: {_ in
                    self.hideImage()
                })
                
            }, success: {[weak self]image in
                self?.imgView.image = image
                if self?.spinner != nil {
                    self?.spinner.removeFromSuperview()
                }
            })
        }
    }
    
    var photo: UIImage! {
        didSet {
            imgView.image = photo
        }
    }
    
    private var imgView: UIImageView!
    private var spinner: UIActivityIndicatorView!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview == nil {
            return
        }
        
        frame = superview!.bounds
        
        //add background
        let backdrop = UIView(frame: bounds)
        backdrop.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        addSubview(backdrop)
        
        //spinner
        spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        spinner.center = center
        spinner.startAnimating()
        spinner.backgroundColor = UIColor.whiteColor()
        spinner.layer.masksToBounds = true
        spinner.layer.cornerRadius = 5
        backdrop.addSubview(spinner)
        
        //add image view
        imgView = UIImageView()
        imgView.frame = CGRectInset(bounds, 20, 40)
        imgView.layer.cornerRadius = 10
        imgView.clipsToBounds = true
        imgView.contentMode = .ScaleAspectFit
        imgView.alpha = 0
        backdrop.addSubview(imgView)
        
        imgView.userInteractionEnabled = true
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapPhoto:"))
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "didSwipePhoto:")
        swipeDown.direction = .Down
        imgView.addGestureRecognizer(swipeDown)
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "didSwipePhoto:")
        swipeUp.direction = .Up
        imgView.addGestureRecognizer(swipeUp)
        
        UIView.animateWithDuration(0.67, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.imgView.alpha = 1.0
        }, completion: nil)

        UIView.animateWithDuration(0.67, delay: 0.0, usingSpringWithDamping: 0.33, initialSpringVelocity: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            let yDelta = ((UIApplication.sharedApplication().windows.first!).rootViewController as! UITabBarController).tabBar.frame.size.height/2
            self.imgView.center.y -= yDelta
            self.spinner.center.y -= yDelta
        }, completion: nil)
    }
    
    func didTapPhoto(tap: UIGestureRecognizer) {
        
        imgView.userInteractionEnabled = false
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.alpha = 0
        }, completion: {_ in
            self.removeFromSuperview()
        })
    }
    
    func didSwipePhoto(swipe: UISwipeGestureRecognizer) {
        
        imgView.userInteractionEnabled = false
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.imgView.center.y += (swipe.direction == .Down ? 1 : -1) * ((UIApplication.sharedApplication().windows.first!).rootViewController as! UITabBarController).tabBar.frame.size.height/2
            self.alpha = 0
            }, completion: {_ in
                self.removeFromSuperview()
        })
    }
}