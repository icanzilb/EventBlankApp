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
    
    var photoUrl: NSURL! {
        didSet {
            imgView.hnk_setImageFromURL(photoUrl)
        }
    }
    
    var photo: UIImage! {
        didSet {
            imgView.image = photo
        }
    }
    
    var imgView: UIImageView!
    
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
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
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

        UIView.animateWithDuration(0.67, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.imgView.alpha = 1.0
            spinner.alpha = 0.0
        }, completion: nil)

        UIView.animateWithDuration(0.67, delay: 0.0, usingSpringWithDamping: 0.33, initialSpringVelocity: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            let yDelta = ((UIApplication.sharedApplication().windows.first! as! UIWindow).rootViewController as! UITabBarController).tabBar.frame.size.height/2
            self.imgView.center.y -= yDelta
            spinner.center.y -= yDelta
        }, completion: nil)
    }
    
    func didTapPhoto(tap: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.imgView.center.y += ((UIApplication.sharedApplication().windows.first! as! UIWindow).rootViewController as! UITabBarController).tabBar.frame.size.height/2
            self.alpha = 0
        }, completion: {_ in
            self.removeFromSuperview()
        })
    }
}