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
    let viewModel = MainViewModel()
    let bag = DisposeBag()
    
    // MARK: methods
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.active = true
        tabBarController!.selectedIndex = 1
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
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
    }
    
}