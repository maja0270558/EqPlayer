//
//  EQCameraProvider.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/6/1.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import Photos
import UIKit

class EQCameraHandler: NSObject {
    static let shared = EQCameraHandler()

    fileprivate var currentVC: UIViewController!

    var imagePickedBlock: ((UIImage) -> Void)?

    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            myPickerController.modalTransitionStyle = .crossDissolve
            myPickerController.modalPresentationStyle = .overCurrentContext
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
    }

    func photoAuth(vc: UIViewController) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            photoLibrary()
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                newStatus in
                if newStatus == PHAuthorizationStatus.authorized {
                    self.photoLibrary()
                }
            })
        case .restricted, .denied:
            let actionSheet = UIAlertController(title: "提示", message: "為了更換大頭貼您可以前往 設定 -> 搜尋 -> qtune 允許我們取用照片。", preferredStyle: .alert)
            actionSheet.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
            vc.present(actionSheet, animated: true, completion: nil)
            break
        }
    }

    func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
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

        actionSheet.addAction(UIAlertAction(title: "使用相機", style: .default, handler: { (_: UIAlertAction!) -> Void in
            self.camera()
        }))

        actionSheet.addAction(UIAlertAction(title: "使用圖庫", style: .default, handler: { (_: UIAlertAction!) -> Void in
            self.photoAuth(vc: vc)
        }))

        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        vc.present(actionSheet, animated: true, completion: nil)
    }
}

extension EQCameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickedBlock?(image)
        } else {
            print("Something went wrong")
        }
        currentVC.dismiss(animated: true, completion: nil)
    }
}
