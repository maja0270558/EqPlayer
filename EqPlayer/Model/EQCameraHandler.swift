//
//  EQCameraProvider.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/6/1.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import UIKit


class EQCameraHandler: NSObject{
  static let shared = EQCameraHandler()
  
  fileprivate var currentVC: UIViewController!
  
  var imagePickedBlock: ((UIImage) -> Void)?
  
  func camera()
  {
    if UIImagePickerController.isSourceTypeAvailable(.camera){
      let myPickerController = UIImagePickerController()
      myPickerController.delegate = self
      myPickerController.sourceType = .camera
      myPickerController.modalTransitionStyle = .crossDissolve
      myPickerController.modalPresentationStyle = .overCurrentContext
      currentVC.present(myPickerController, animated: true, completion: nil)
    }
    
  }
  
  func photoLibrary()
  {
    
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
      let myPickerController = UIImagePickerController()
      myPickerController.delegate = self
      myPickerController.sourceType = .photoLibrary
      myPickerController.modalTransitionStyle = .crossDissolve
      myPickerController.modalPresentationStyle = .overCurrentContext
      currentVC.present(myPickerController, animated: true, completion: nil)
    }
    
  }
  
  func showActionSheet(vc: UIViewController) {
    currentVC = vc
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "使用相機", style: .default, handler: { (alert:UIAlertAction!) -> Void in
      self.camera()
    }))
    
    actionSheet.addAction(UIAlertAction(title: "使用圖庫", style: .default, handler: { (alert:UIAlertAction!) -> Void in
      self.photoLibrary()
    }))
    
    actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
    vc.present(actionSheet, animated: true, completion: nil)
  }
  
}


extension EQCameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    currentVC.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      self.imagePickedBlock?(image)
    }else{
      print("Something went wrong")
    }
    currentVC.dismiss(animated: true, completion: nil)
  }
  
}
