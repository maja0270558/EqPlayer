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
                        playlistViewController.eqSettingManager = (self?.eqSettingManager)!
                        self?.present(playlistViewController, animated: true, completion: nil)
                    }
                }
            }
        }
        section.cellDatas = Array(eqSettingManager.tempModel.tracks)
        section.cellHeight = UITableViewAutomaticDimension
        editTableView.registeCell(cellIdentifier: EQSPTTrackTableViewCell.typeName)
        section.cellIdentifier = EQSPTTrackTableViewCell.typeName
        section.cellOperator = {
            data, cell in
            if let trackCell = cell as? EQSPTTrackTableViewCell,let track = data as? EQTrack {
                trackCell.setupCell(coverURLString: track.coverURL, title: track.name, artist: track.artist)
            }
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
