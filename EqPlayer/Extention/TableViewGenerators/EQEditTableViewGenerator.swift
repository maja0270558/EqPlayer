//
//  EQEditTableViewGenerator.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/15.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
enum EQEditTableViewGenerator {
    case addTrackHeader
}

extension EQEditViewController {
    //    func createEditEQView() -> EQSectionProvider {
    //        let section = EQSectionProvider()
    //        editTableView.registeCell(cellIdentifier: EQEditChartCell.typeName)
    //        section.cellIdentifier = EQEditChartCell.typeName
    //        section.cellDatas = ["Django Free"]
    //        section.cellHeight = UITableViewAutomaticDimension
    //        section.cellOperator = { _, cell  in
    //            guard let editCell = cell as? EQEditChartCell else {
    //                return
    //            }
    //            editCell.lineChart.delegate = self
    //        }
    //        return section
    //    }
    //
    func createAddTrackHeader() -> EQSectionProvider {
        let section = EQSectionProvider()
        section.headerHeight = UITableViewAutomaticDimension
        section.headerView = EQEditAddTrackHeader()
        //        section.headerData = barData
        section.headerOperator = {
            _, view in
            if let addTrackBar = view as? EQEditAddTrackHeader {
                addTrackBar.addTrack = { [weak self] in
                    if let playlistViewController = UIStoryboard.eqProjectStoryBoard().instantiateInitialViewController() as? EQSPTPlaylistViewController {
                        playlistViewController.modalPresentationStyle = .overCurrentContext
                        playlistViewController.modalTransitionStyle = .crossDissolve
                        self?.present(playlistViewController, animated: true, completion: nil)
                    }
                }
            }
        }
        section.cellDatas = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        section.cellHeight = 150
        editTableView.registeCell(cellIdentifier: EQSPTTrackTableViewCell.typeName)
        section.cellIdentifier = EQSPTTrackTableViewCell.typeName
        section.cellOperator = {
            _, cell in
        }
        return section
    }
    
    // Must call after get data
    func generateSectionAndCell(providerTypes: [EQEditTableViewGenerator]) -> [EQSectionProvider] {
        var providers = [EQSectionProvider]()
        for sectionType in providerTypes {
            switch sectionType {
            case .addTrackHeader:
                providers.append(createAddTrackHeader())
            }
        }
        return providers
    }
}
