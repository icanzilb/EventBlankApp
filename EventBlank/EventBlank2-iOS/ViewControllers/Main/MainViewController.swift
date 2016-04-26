//
//  MainViewController.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/19/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewModel
import RealmSwift
import DynamicColor

class MainViewController: UIViewController {
    // MARK: outlets
    @IBOutlet weak var imgConfLogo: UIImageView!
    @IBOutlet weak var lblConfName: UILabel!
    @IBOutlet weak var lblConfSubtitle: UILabel!
    @IBOutlet weak var lblRightNow: UILabel!
    @IBOutlet weak var lblOrganizer: UILabel!
    
    // MARK: variables
    private let viewModel = MainViewModel()
    private let bag = DisposeBag()
    
    // MARK: methods
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }

    func bindUI() {
        // bind texts
        viewModel.title.bindTo(lblConfName.rx_text)
            .addDisposableTo(bag)
        viewModel.subtitle.bindTo(lblConfSubtitle.rx_text)
            .addDisposableTo(bag)
        viewModel.organizer.bindTo(lblOrganizer.rx_text)
            .addDisposableTo(bag)
        viewModel.logo.bindTo(imgConfLogo.rx_image)
            .addDisposableTo(bag)
        
        // bind color
        viewModel.mainColor.bindTo(lblConfName.rx_textColor)
            .addDisposableTo(bag)
        viewModel.mainColor.bindTo(lblConfSubtitle.rx_textColor)
            .addDisposableTo(bag)
        
        //next event
        viewModel.nextEvent.bindNext(showNextEvent)
            .addDisposableTo(bag)
    }
    
    func showNextEvent(next: Schedule.NextEventResult?) {
        guard let next = next else {
            lblRightNow.text = nil
            return
        }
        
        switch next {
        case .Next(let session):
            lblRightNow.text = "Next: \(session.beginTime!.toString(format: .Custom("hh:mm"))) \(session.title) (\(session.speaker.name))"
        case .EventFinished:
            lblRightNow.text = "This event has finished"
        case .EventStartsIn(let seconds):
            switch seconds {
            case 0..<60*60:
                lblRightNow.text = "The event starts any moment"
            case 60*60..<23*60*60:
                let hours = 1 + Int(seconds / 60 / 60)
                lblRightNow.text = "The event starts in \(hours) hours"
            default:
                let days = 1 + Int(seconds / 60 / 60 / 24)
                lblRightNow.text = "The event starts in \(days) days"
            }
        }
    }
}