//
//  +EQUIViewControllerExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/25.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

extension UIViewController {
  func moreOptionAlert(delete: @escaping (UIAlertAction) -> Void, edit: @escaping (UIAlertAction) -> Void) {
    let alertController = UIAlertController(
      title: nil,
      message: nil,
      preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(
      title: "取消",
      style: .cancel,
      handler: nil)
    alertController.addAction(cancelAction)
    
    let editAction = UIAlertAction(
      title: "編輯",
      style: .destructive,
      handler: edit)
    alertController.addAction(editAction)
    
    let deleteAction = UIAlertAction(
      title: "刪除",
      style: .destructive,
      handler: delete)
    alertController.addAction(deleteAction)
    
    alertController.view.tintColor = UIColor.black
    
    present(
      alertController,
      animated: true,
      completion: nil)
  }
  
  func moreOptionAlert() {
    let alertController = UIAlertController(
      title: nil,
      message: nil,
      preferredStyle: .actionSheet)
    
    
    
    let cancelAction = UIAlertAction(
      title: "取消",
      style: .cancel,
      handler: nil)
    alertController.addAction(cancelAction)
    
    let editAction = UIAlertAction(
      title: "檢舉",
      style: .destructive,
      handler: {[weak self] _ in
        
        let alertController = UIAlertController(
          title: nil,
          message: "已收到您的檢舉，我們會盡快處理",
          preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(
          title: "確認",
          style: .cancel,
          handler: nil)
        alertController.addAction(cancelAction)
        
        self?.present(
          alertController,
          animated: true,
          completion: nil)
        
    })
    alertController.addAction(editAction)
    
    alertController.view.tintColor = UIColor.black
    
    present(
      alertController,
      animated: true,
      completion: nil)
  }
}
