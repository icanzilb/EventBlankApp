//
//  PhotoPopupView.swift
//  EventBlank
//
//  Created by Marin Todorov on 8/23/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import Haneke

import RxSwift
import RxCocoa

class PhotoPopupView: UIView {

    var bag = DisposeBag()
    
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
            precondition(backdrop == nil)
            setupUI()
            
            imgView.hnk_setImageFromURL(photoUrl, placeholder: nil, format: nil, failure: {error in
                UIViewController.alert("Couldn't fetch image.", buttons: ["Close"], completion: {_ in self.didTapPhoto()})
            }, success: {[weak self]image in
                self?.imgView.image = image
                if self?.spinner != nil {
                    self?.spinner.removeFromSuperview()
                }
            })
            displayPhoto()
        }
    }
    
    var photo: UIImage! {
        didSet {
            precondition(backdrop == nil)
            setupUI()
            imgView.image = photo
            displayPhoto()
        }
    }
    
    private var backdrop: UIView!
    private var imgView: TappableImageView!
    private var spinner: UIActivityIndicatorView!
    
    func setupUI() {
        guard superview != nil else {
            return
        }
        
        frame = superview!.bounds
        
        //add background
        backdrop = UIView(frame: bounds)
        backdrop.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        backdrop.alpha = 0.0
        addSubview(backdrop)
        
        spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        spinner.center = center
        spinner.startAnimating()
        spinner.backgroundColor = UIColor.clearColor()
        spinner.layer.masksToBounds = true
        spinner.layer.cornerRadius = 5

        imgView = TappableImageView()
        imgView.frame = CGRectInset(bounds, 20, 40)
        imgView.layer.cornerRadius = 10
        imgView.clipsToBounds = true
        imgView.contentMode = .ScaleAspectFit
        imgView.alpha = 0
    }
    
    func displayPhoto() {
        //add image view
        backdrop.addSubview(imgView)
        UIView.animateWithDuration(0.2, animations: {[unowned self] in
            self.backdrop.alpha = 1.0
        })

        //spinner
        if imgView.image == nil {
            backdrop.addSubview(spinner)
        }
        
        //imgView.rx_tap.bindNext(didTapPhoto).addDisposableTo(bag)
        imgView.rx_gesture([.Tap, .SwipeUp, .SwipeDown])
            .subscribeNext({[unowned self] _ in
            self.didTapPhoto()
        }).addDisposableTo(bag)
        
        UIView.animateWithDuration(0.67, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.imgView.alpha = 1.0
        }, completion: nil)

        UIView.animateWithDuration(0.67, delay: 0.0, usingSpringWithDamping: 0.33, initialSpringVelocity: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            let yDelta = ((UIApplication.sharedApplication().windows.first!).rootViewController as! UITabBarController).tabBar.frame.size.height/2
            self.imgView.center.y -= yDelta
            self.spinner.center.y -= yDelta
        }, completion: nil)
    }
    
    func didTapPhoto() {
        
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