//
//  EQMainScrollableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/13.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import MediaPlayer
class EQMainScrollableViewController: EQScrollableViewController {
  var topItemSize = CGSize(width: 50, height: 50)
  let topIcon = [UIImage(named: "user")]
  var blurView: UIVisualEffectView!
  @IBOutlet var topScrollableViewBase: UIView!
  @IBOutlet var playerView: EQPlayerView!
  @IBOutlet weak var addEQProjectButton: UIButton!
  var info = [String: Any]()

  @IBAction func addEQAction(_: Any) {
    if let eqProjectViewController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(withIdentifier: String(describing: EQProjectViewController.self)) as? EQProjectViewController {
      eqProjectViewController.modalPresentationStyle = .overCurrentContext
      eqProjectViewController.modalTransitionStyle = .crossDissolve
      present(eqProjectViewController, animated: true, completion: nil)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    becomeFirstResponder()
    UIApplication.shared.beginReceivingRemoteControlEvents()
    setupPlayerView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let userController = UIStoryboard.mainStoryBoard().instantiateViewController(withIdentifier: "EQUserTableViewController") as? EQUserTableViewController else {
      return
    }
    userController.delegate = self
    controllers.append(userController)
    cells.append("EQIconCollectionViewCell")
   
    registerCollectionCell()
    subscribeNotification()
    setupDelegate()
    setupTopScrollableMainView()
    setupBlurEffect()
    setupAddEQProjectButton()
    subControllerInit()
    playingBackground()
  }
  
  
  func setupAddEQProjectButton(){
    if EQUserManager.shard.userStatus == .guest {
      addEQProjectButton.isHidden = true
    }
  }
  
  func playingBackground() {
    let session = AVAudioSession.sharedInstance()
    try? session.setCategory(AVAudioSessionCategoryPlayback)
    try? session.setActive(true)
  }
 
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    resignFirstResponder()
    UIApplication.shared.endReceivingRemoteControlEvents()
    removeNotification()
  }
  
  override func remoteControlReceived(with event: UIEvent?) {
    let type = event?.subtype
    switch type! {
    case .remoteControlPlay:
      // 播放
      EQSpotifyManager.shard.playOrPause(isPlay: true) {
        
      }
    case .remoteControlPause:
      EQSpotifyManager.shard.playOrPause(isPlay: false) {
        
      }
    // 暂停
    case .remoteControlStop: break
    // 停止
    case .remoteControlTogglePlayPause: break
    // 切换播放暂停（耳机线控）
    case .remoteControlNextTrack:
      EQSpotifyManager.shard.skip()
    // 下一首
    case .remoteControlPreviousTrack:
      EQSpotifyManager.shard.previous()
    // 上一首
    case .remoteControlBeginSeekingBackward: break
    // 开始快退
    case .remoteControlEndSeekingBackward: break
    // 结束快退
    case .remoteControlBeginSeekingForward: break
    // 开始快进
    case .remoteControlEndSeekingForward: break
    // 结束快进
    default:
      break
    }
  }
  
  func setupPlayerView() {
    playerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height * 0.9, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
  }
  
  func setupTopScrollableMainView() {
    topScrollableViewBase.layer.cornerRadius = 10
    topScrollableViewBase.clipsToBounds = true
  }
  
  func setupBlurEffect() {
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    blurEffectView.isUserInteractionEnabled = false
    blurEffectView.alpha = 0
    blurEffectView.frame = topScrollableViewBase.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    topScrollableViewBase.addSubview(blurEffectView)
    blurView = blurEffectView
  }
  
  func setupDelegate() {
    playerView.delegate = self
    EQSpotifyManager.shard.delegate = self
  }
  
  override func setupCell(cell: UICollectionViewCell, atIndex: Int) {
    if let iconCell = cell as? EQIconCollectionViewCell {
      iconCell.iconImageView.image = topIcon[atIndex]
    }
  }
  
  func registerCollectionCell() {
    let iconNib = UINib(nibName: "EQIconCollectionViewCell", bundle: nil)
    topCollectionView.register(iconNib, forCellWithReuseIdentifier: "EQIconCollectionViewCell")
  }
  
  override func customizeTopItemWhenScrolling(_ currentIndex: CGFloat = 0) {
    let cells = topCollectionView.visibleCells
    for cell in cells {
      if let iconCell = cell as? EQIconCollectionViewCell {
        let row = CGFloat((topCollectionView.indexPath(for: iconCell)?.row)!)
        iconCell.setupImageSize(size: topItemSize, currentIndex: currentIndex, cellRow: row)
      }
    }
  }
  
  override func setupCollectionLayout() {
    if let iconLayout = topCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      let spaceCount = visiableItemCount - 1
      iconLayout.itemSize = topItemSize
      // Center the first icon
      let insetEdge = UIScreen.main.bounds.width / 2 - (iconLayout.itemSize.width / 2)
      let spacing = (UIScreen.main.bounds.width - iconLayout.itemSize.width * visiableItemCount) / spaceCount
      iconLayout.minimumInteritemSpacing = 0
      iconLayout.minimumLineSpacing = spacing
      iconLayout.sectionInset = UIEdgeInsets(
        top: 0.0,
        left: insetEdge,
        bottom: 0.0,
        right: insetEdge
      )
      topPageWidth = UIScreen.main.bounds.width / spaceCount - topItemSize.width / 2
    }
  }
}

extension EQMainScrollableViewController: EQUserTableViewControllerDelegate {
  func didPressMoreOptionEditButton(at _: IndexPath, data: EQProjectModel) {
    if let eqProjectViewController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(withIdentifier: String(describing: EQProjectViewController.self)) as? EQProjectViewController {
      eqProjectViewController.modalPresentationStyle = .overCurrentContext
      eqProjectViewController.modalTransitionStyle = .crossDissolve
      eqProjectViewController.eqSettingManager.tempModel = EQProjectModel(value: data)
      present(eqProjectViewController, animated: true, completion: nil)
    }
  }
  
  func didPressMoreOptionDeleteButton(at _: IndexPath, data: EQProjectModel) {
    if EQRealmManager.shard.checkModelExist(filter: "uuid == %@", value: data.uuid) {
      let result: [EQProjectModel] = EQRealmManager.shard.findWithFilter(filter: "uuid == %@", value: data.uuid)
      let object = result.first!
      EQRealmManager.shard.remove(object: object)
      EQNotifycationCenterManager.post(name: Notification.Name.eqProjectDelete)
    }
  }
  
  func didSelectTempEQCellRow(at _: IndexPath, data: EQProjectModel) {
    if let eqProjectViewController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(withIdentifier: String(describing: EQProjectViewController.self)) as? EQProjectViewController {
      eqProjectViewController.modalPresentationStyle = .overCurrentContext
      eqProjectViewController.modalTransitionStyle = .crossDissolve
      eqProjectViewController.eqSettingManager.tempModel = EQProjectModel(value: data)
      present(eqProjectViewController, animated: true, completion: nil)
    }
  }
  
  func didSelectSavedEQCellRow(at _: IndexPath, data: EQProjectModel) {
    let uris = Array(data.tracks.map { $0.uri })
    EQSpotifyManager.shard.queuePlaylist(playlistURI: uris)
    EQSpotifyManager.shard.setGain(withModel: data)
    EQSpotifyManager.shard.playFirstTrack()
    playerView.openPlayer()
  }
  
  func didSelectPostedEQCellRow(at _: IndexPath, data _: EQProjectModel) {
  }
}

extension EQMainScrollableViewController: EQPlayerViewDelegate {
  
  func didDragPlayer(factor: CGFloat) {
    var finalScale = 0.1 * (1-factor)
    topScrollableViewBase.transform = CGAffineTransform(scaleX: 1 - finalScale, y: 1 - finalScale)
    blurView.alpha = (1-factor)
    print(finalScale)
  }
  
  func didClapPlayer() {
    topScrollableViewBase.transform = CGAffineTransform(scaleX: 1, y: 1)
    blurView.alpha = 0
  }
  
  func didOpenPlayer() {
    topScrollableViewBase.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    blurView.alpha = 1
  }
}

extension EQMainScrollableViewController: EQSpotifyManagerDelegate {
  
  func setLockScreenDisplay(model: SPTPlaybackTrack, cover: UIImage) {
    info[MPMediaItemPropertyTitle] = model.name
    info[MPMediaItemPropertyArtist] = model.artistName
    info[MPMediaItemPropertyAlbumArtist] = model.artistName
    info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: cover)
    info[MPMediaItemPropertyPlaybackDuration] = model.duration
    info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
  }
  
  func updateMPMediaProperty (){
    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
  }
  
  func didChangePlaybackStatus(isPlaying: Bool) {
    switch EQSpotifyManager.shard.currentPlayingType {
    case .preview:
      info[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
      break
    case .project:
      playerView.playButton.isSelected = isPlaying
      playerView.miniBarPlayButton.isSelected = isPlaying
      info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
    default:
      break
    }
    updateMPMediaProperty()
  }
  
  func didChangeTrack(track: SPTPlaybackTrack) {
    
    switch EQSpotifyManager.shard.currentPlayingType {
    case .preview:
      EQSpotifyManager.shard.durationObseve.maxPreviewDuration = track.duration/2 > 30 ? 30 : track.duration/2
      EQSpotifyManager.shard.durationObseve.maxDuration = track.duration
     
    case .project:
      playerView.durationSlider.maximumValue = Float(track.duration)
      playerView.maxDurationLabel.text = "-" + track.duration.stringFromTimeInterval()
      playerView.coverImageView.sd_setImage(with: URL(string: track.albumCoverArtURL!), placeholderImage: #imageLiteral(resourceName: "vinyl"), options: []) { image, _, _, _ in
        self.playerView.blurCoverBackground(source: image!)
        self.info[MPNowPlayingInfoPropertyPlaybackRate] = 1
        self.setLockScreenDisplay(model: track, cover: image!)
      }
      playerView.artistNameLabel.text = track.artistName
      playerView.trackNameLabel.text = track.name
      playerView.miniBarTrackNameLabel.text = track.name
      EQSpotifyManager.shard.durationObseve.currentPlayingURI = track.uri
    default:
      break
    }
  }
  
  func didPositionChange(position: TimeInterval) {
    switch EQSpotifyManager.shard.currentPlayingType {
    case .preview:
      let previewCurrentDuration = EQSpotifyManager.shard.durationObseve.maxDuration/2 - position
    case .project:
      EQSpotifyManager.shard.durationObseve.currentDuration = position
      playerView.durationSlider.value = Float(position)
      playerView.currentPositionLabel.text = position.stringFromTimeInterval()
      info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Float(position)
      updateMPMediaProperty()
    default:
      break
    }
  }
}

extension EQMainScrollableViewController {
  
  func subscribeNotification() {
    EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(eqProjectDelete), notification: Notification.Name.eqProjectDelete)
    EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(eqProjectSave), notification: Notification.Name.eqProjectSave)
    EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(eqProjectPlayPreviewTrack), notification: Notification.Name.eqProjectPlayPreviewTrack)
  }
  
  func removeNotification() {
    EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectTrackModifyNotification)
    EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectAccidentallyClose)
    EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectPlayPreviewTrack)
  }
  
  @objc func eqProjectDelete() {
    EQSpotifyManager.shard.player?.setIsPlaying(false, callback: nil)
    playerView.resetPlayer()
  }
  
  @objc func eqProjectSave() {
  }
  
  @objc func eqProjectPlayPreviewTrack() {
    info[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
    updateMPMediaProperty()
    playerView.playButton.isSelected = false
    playerView.miniBarPlayButton.isSelected = false
  }
}
