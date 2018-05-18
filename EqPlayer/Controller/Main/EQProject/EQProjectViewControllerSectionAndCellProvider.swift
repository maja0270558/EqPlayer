import Foundation
enum EQProjectSectionCell: Int, EnumCollection {
    case trackHeaderWithCell
}

extension EQProjectViewController {
    func createAddTrackHeader() -> EQSectionProvider {
        let section = EQSectionProvider()
        section.headerHeight = UITableViewAutomaticDimension
        section.headerView = EQSaveProjectPageAddTrackHeader()
        section.headerOperator = {
            _, view in
            if let addTrackBar = view as? EQSaveProjectPageAddTrackHeader {
                addTrackBar.addTrack = { [weak self] in
                    if let playlistViewController = UIStoryboard.eqProjectStoryBoard().instantiateInitialViewController() as? EQSelectTrackViewController {
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
        editTableView.registeCell(cellIdentifier: EQSonglistTableViewCell.typeName)
        section.cellIdentifier = EQSonglistTableViewCell.typeName
        section.cellOperator = {
            data, cell in
            if let trackCell = cell as? EQSonglistTableViewCell, let track = data as? EQTrack {
                trackCell.setupCell(coverURLString: track.coverURL, title: track.name, artist: track.artist)
            }
        }
        return section
    }

    func generateSectionAndCell() {
        var providers = [EQSectionProvider]()
        for sectionType in Array(EQProjectSectionCell.cases()) {
            switch sectionType {
            case .trackHeaderWithCell:
                providers.append(createAddTrackHeader())
            }
        }
        sectionProviders = providers
    }
}
