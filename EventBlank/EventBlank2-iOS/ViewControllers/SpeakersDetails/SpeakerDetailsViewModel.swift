//
//  SpeakerDetailsViewModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/25/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources
import RxViewModel

class SpeakerDetailsViewModel: RxViewModel {
    
    private let bag = DisposeBag()
    private let model: SpeakerDetailsModel
    
    //output
    typealias AnySection = SectionModel<String, AnyObject>
    let tableItems = BehaviorSubject<[AnySection]>(value: [])
    
    let dataSource = RxTableViewSectionedReloadDataSource<AnySection>()

    init(speaker: Speaker) {
        self.model = SpeakerDetailsModel(speaker: speaker)
        
        super.init()
        
        //table items
        tableItems.onNext([
            AnySection(model: "details", items: [speaker])
            ])
        
        //the data source
        dataSource.configureCell = {[unowned self] (tv, indexPath, _) in
            switch indexPath.section {
            case 0:
                let cell = SpeakerDetailsCell.cellOfTable(tv, speaker: speaker)
                
                self.model.favorites
                    .map {favorites in favorites.contains(speaker.uuid)}
                    .bindTo(cell.isFavorite)
                    .addDisposableTo(self.bag)
                
                cell.isFavorite
                    .bindNext(self.model.updateSpeakerFavoriteTo)
                    .addDisposableTo(self.bag)
                
                return cell
            default: return UITableViewCell()
            }
        }
        dataSource.titleForHeaderInSection = {section in
            return "Speaker Details"
        }

    }
}