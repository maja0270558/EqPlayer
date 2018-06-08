//
//  EQUserTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

class EQUserViewController: UIViewController {
  @IBOutlet weak var userInfoTopView: UIView!
  @IBOutlet weak var userInfoView: EQUserInfoView!
  @IBOutlet weak var toolBarView: EQCustomToolBarView!
  var toolBarData = [String]()
  var childContainerViewDictionary = [Int: UIView]()
  var childControllerDictionary = [Int: EQProjectTableViewController]()
  var childTableViews = [UITableView]()
  var currentToolItemIndex: Int = 1

  @IBOutlet weak var savedContainerView: UIView!
  private var savedController: EQUserSavedTableViewController!
  
  @IBOutlet weak var postedContainerView: UIView!
  private var postedController: EQUserPostedTableViewController!
  
  @IBOutlet weak var tempContainerView: UIView!
  private var tempController: EQUserTempTableViewController!

  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let savedVC = segue.destination as? EQUserSavedTableViewController,
      segue.identifier == "savedVC" {
      self.savedController = savedVC
      savedController.topInset = userInfoTopView.bounds.height
    }
    if let postedVC = segue.destination as? EQUserPostedTableViewController,
      segue.identifier == "postedVC" {
      self.postedController = postedVC
      postedController.topInset = userInfoTopView.bounds.height
    }
    if let tempVC = segue.destination as? EQUserTempTableViewController,
      segue.identifier == "tempVC" {
      self.tempController = tempVC
      tempController.topInset = userInfoTopView.bounds.height
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    setupToolBar()
    setupUserInfoView()
    setupChildBranchViewController()
  }

  func setupToolBar() {
    toolBarData = EQUserManager.shard.userStatus == .guest ? ["已儲存的專案"] : ["已儲存", "施工中", "已發布"]
    toolBarView.delegate = self
    toolBarView.datasource = self
  }
  
  func setupChildBranchViewController() {
    childContainerViewDictionary = [
      1: savedContainerView,
      2: tempContainerView,
      3: postedContainerView
    ]
    childControllerDictionary = [
      1: savedController,
      2: tempController,
      3: postedController
    ]
    childTableViews = [
    savedController.tableView,
    tempController.tableView,
    postedController.tableView
    ]
    savedController.delegate = self
    postedController.delegate = self
    tempController.delegate = self
    showCurrentIndexChildController()
  }
  func showCurrentIndexChildController() {
    hideAllChildController()
    UIView.animate(withDuration: 0.5) {
      [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.childContainerViewDictionary[strongSelf.currentToolItemIndex]?.alpha = 1
    }
  }
  
  func reloadCurrentIndexChildController() {
    childControllerDictionary[currentToolItemIndex]?.reloadTableView()
  }
  
  func hideAllChildController() {
    childContainerViewDictionary.forEach { (_ , view) in
      view.alpha = 0
    }
  }
  
  func setupUserInfoView() {
    let userData = EQUserManager.shard.getUser()
    userInfoView.cameraButton.addTarget(self, action: #selector(self.changeProfilePhoto), for: .touchUpInside)
    userInfoView.userName.text = userData.name
    userInfoView.userImage.sd_setImage(with: userData.photoURL, placeholderImage: #imageLiteral(resourceName: "dark-1920956_1280"), options: [], completed: nil)
  }
  
  @objc func changeProfilePhoto() {
    EQCameraHandler.shared.showActionSheet(vc: self)
    EQCameraHandler.shared.imagePickedBlock = { image in
      EQFirebaseManager.uploadImage(userUID: EQUserManager.shard.userUID, image: image) { [weak self]
        _ in
        self?.userInfoView.userImage.image = image
      }
    }
  }
}

extension EQUserViewController: EQSaveProjectCellDelegate {
  
  func didClickMoreOptionButton(indexPath: IndexPath) {
    guard let mainVC = self.parent as? EQMainScrollableViewController else {
        return
    }
    let data = self.getTargetModelCopy(at: indexPath)
    
    moreOptionAlert(
      delete: {_ in
        if EQRealmManager.shard.checkModelExist(filter: "uuid == %@", value: data.uuid) {
          let result: [EQProjectModel] = EQRealmManager.shard.findWithFilter(filter: "uuid == %@", value: data.uuid)
          let object = result.first!
          EQRealmManager.shard.remove(object: object)
        }
        EQFirebaseManager.remove(path: "post/\(data.uuid)")
        EQFirebaseManager.remove(path: "userPosts/\(EQUserManager.shard.userUID)/\(data.uuid)")
        EQNotifycationCenterManager.post(name: Notification.Name.eqProjectDelete)

    }, edit: {_ in
        if let eqProjectViewController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(withIdentifier: String(describing: EQProjectViewController.self)) as? EQProjectViewController {
          eqProjectViewController.modalPresentationStyle = .overCurrentContext
          eqProjectViewController.modalTransitionStyle = .crossDissolve
          eqProjectViewController.eqSettingManager.tempModel = EQProjectModel(value: data)
          mainVC.present(eqProjectViewController, animated: true, completion: nil)
        }
    })
  }
  
  func getTargetModelCopy(at: IndexPath) -> EQProjectModel {
    guard let data = childControllerDictionary[currentToolItemIndex]?.projectData![at.row] else{
      return EQProjectModel()
    }
    return EQProjectModel(value: data)
  }
  
}
extension EQUserViewController: EQProjectTableViewControllerDelegate {
  func didScrollTableView(scrollView: UIScrollView, offset: CGFloat) {
    
    let finalOffset = -offset - userInfoTopView.bounds.height
    userInfoTopView.frame.origin.y = finalOffset
    if offset > -toolBarView.bounds.height {
      userInfoTopView.frame.origin.y =  -userInfoTopView.bounds.height+toolBarView.bounds.height
    }
    if -offset > -userInfoTopView.bounds.height {
      let factor = -offset / userInfoTopView.bounds.height
      userInfoView.userImage.transform = CGAffineTransform(scaleX: 1*factor, y: 1*factor)
    }
    syncChidTableViewContentOffset(sender: scrollView, offset: offset, range: -1000...(-toolBarView.bounds.height))
  }
  
  func syncChidTableViewContentOffset(sender: UIScrollView, offset: CGFloat, range: ClosedRange<CGFloat>) {
    switch offset {
    case range:
      childTableViews.forEach { (tableView) in
        if tableView !== sender {
          tableView.contentOffset.y = offset
        }
      }
      break
    default:
      break
    }
  }
  
  func didSelectProjectCell(at: IndexPath, data: EQProjectModelProtocol) {
    guard let projectData = data as? EQProjectModel,
          let mainController = parent as? EQMainScrollableViewController else {
      return
    }
    let dataCopy = EQProjectModel(value: projectData)
    switch projectData.status {
    case .saved, .post:
      mainController.openPlayerAndPlayback(data: dataCopy)
    case .temp:
      mainController.openEditProjectPage(data: dataCopy)
    default:
      break
    }
  }
}
extension EQUserViewController: EQCustomToolBarDataSource, EQCustomToolBarDelegate {
  func eqToolBarNumberOfItem() -> Int {
    return toolBarData.count
  }
  
  func eqToolBar(titleOfItemAt: Int) -> String {
    return toolBarData[titleOfItemAt]
  }
  
  func eqToolBar(didSelectAt: Int) {
    currentToolItemIndex = didSelectAt + 1
    if EQUserManager.shard.userStatus != .guest {
      showCurrentIndexChildController()
    }
  }
}

