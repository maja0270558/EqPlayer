//
//  EQPlayerView.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/22.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import Lerp
import GPUImage
import CoreImage

public protocol EQPlayerViewDelegate: class {
  func didClapPlayer()
  func didOpenPlayer()
}
class EQPlayerView: EQPlayerPannableView {
  weak var delegate: EQPlayerViewDelegate?
  
  var maxCoverWidth: CGFloat {
    return UIScreen.main.bounds.width * 0.6
  }
  let minCoverWidth: CGFloat = 40
  let maxVerticleMultiplier: CGFloat = 1
  let minVerticleMultiplier: CGFloat = 0.2
  let maxHorizontalMultiplier: CGFloat = 0.6
  let minHorizontalMultiplier: CGFloat = 0.1
  
  @IBOutlet weak var miniPlayerCoverImagePosition: UIView!
  @IBOutlet weak var largePlayerCoverImage: UIImageView!
  @IBOutlet weak var playerControllView: UIView!
  @IBOutlet weak var coverWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var coverHorizontalConstraint: NSLayoutConstraint!
  @IBOutlet weak var coverVerticleConstraint: NSLayoutConstraint!
  
  var minPlayerViewSize: CGFloat = 60
  var currentOrigin: CGPoint = CGPoint.zero
  var currentSize: CGFloat = 60
  
  @IBOutlet weak var miniPlayerBar: UIView!
  @IBOutlet weak var largePlayerView: UIView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    fromNib()
    setupLayer()
    setupCover()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    fromNib()
    setupLayer()
    setupCover()
  }
  
  func photoshopBlur(image: UIImage) -> UIImage {
   
//    let exposureFilter = ExposureAdjustment()
//    let blurFilter = GaussianBlur()
//    blurFilter.blurRadiusInPixels = 15
//    exposureFilter.exposure = 2
//
//
//    let filteredImage = image.filterWithPipeline { (input, output) in
//      input --> exposureFilter --> blurFilter --> output
//    }
//    return filteredImage
    
    /*
     UIImage sourceImage = ...
     GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:sourceImage];
     GPUImageTransformFilter *transformFilter = [GPUImageTransformFilter new];
     GPUImageFastBlurFilter *blurFilter = [GPUImageFastBlurFilter new];
     
     //Force processing at scale factor 1.4 and affine scale with scale factor 1 / 1.4 = 0.7
     [transformFilter forceProcessingAtSize:CGSizeMake(SOURCE_WIDTH * 1.4, SOURCE_WIDTH * 1.4)];
     [transformFilter setAffineTransform:CGAffineTransformMakeScale(0.7, 0.7)];
     
     //Setup desired blur filter
     [blurFilter setBlurSize:3.0f];
     [blurFilter setBlurPasses:20];
     
     //Chain Image->Transform->Blur->Output
     [imageSource addTarget:transformFilter];
     [transformFilter addTarget:blurFilter];
     [imageSource processImage];
     
     UIImage *blurredImage = [blurFilter imageFromCurrentlyProcessedOutputWithOrientation:UIImageOrientationUp];
     */
    let imageSource = GPUImagePicture(cgImage: image.cgImage!)!
    
    let filter = GPUImageTransformFilter()
    
    filter.forceProcessing(at: CGSize(width:200 * 1.4, height: 200 * 1.4))
    
    filter.affineTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    let blurFilter = GPUImageGaussianBlurFilter()
    
    blurFilter.blurRadiusInPixels = 3
    
    blurFilter.blurPasses = 3
    
    imageSource.addTarget(filter)
    
    filter.addTarget(blurFilter)
    
    blurFilter.useNextFrameForImageCapture()
    
    imageSource.processImage()
    
    let result = blurFilter.imageFromCurrentFramebuffer(with: .up)
    
    return result!
  }
  
  func setupCover(){
    self.coverWidthConstraint.constant = self.minCoverWidth
    self.coverVerticleConstraint = self.coverVerticleConstraint.setMultiplier(multiplier: self.minVerticleMultiplier)
    self.coverHorizontalConstraint = self.coverHorizontalConstraint.setMultiplier(multiplier: self.minHorizontalMultiplier)
    self.largePlayerCoverImage.image =  blur(image: self.largePlayerCoverImage.image!)
  
    
    
    let maskLayer = CAGradientLayer()
    maskLayer.frame = largePlayerCoverImage.bounds
    maskLayer.shadowRadius = 20
    maskLayer.shadowPath = CGPath(roundedRect: largePlayerCoverImage.bounds.insetBy(dx: 20, dy: 20), cornerWidth: 20, cornerHeight: 20, transform: nil)
    maskLayer.shadowOpacity = 0.8
    maskLayer.shadowOffset = CGSize.zero
    maskLayer.shadowColor = UIColor.white.cgColor
    largePlayerCoverImage.layer.mask = maskLayer
    largePlayerCoverImage.clipsToBounds = false
    
  }
  
  func setupLayer() {
    self.backgroundColor = UIColor.clear
    miniPlayerBar.layer.cornerRadius = 10
    miniPlayerBar.clipsToBounds = true
    miniPlayerBar.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    
  }
  
  func resetCurrentRect(){
    currentSize = self.frame.size.height
    currentOrigin = self.frame.origin
  }
  override func onBegan() {
    resetCurrentRect()
  }
  override func onChanged(translation: CGFloat) {
    var newOrigin = currentOrigin
    var newSize = currentSize
    newOrigin.y += translation
    var factorScale = max(0, newOrigin.y/(UIScreen.main.bounds.height * 0.9))
    
    coverWidthConstraint.constant = lerp(factorScale, min: maxCoverWidth , max: minCoverWidth )
    coverVerticleConstraint = coverVerticleConstraint.setMultiplier(multiplier: lerp(factorScale, min: maxVerticleMultiplier, max: minVerticleMultiplier))
    coverHorizontalConstraint = coverHorizontalConstraint.setMultiplier(multiplier: lerp(factorScale, min: maxHorizontalMultiplier, max: minHorizontalMultiplier))
    miniPlayerBar.alpha = factorScale * 3
    largePlayerView.layer.cornerRadius = 1 - 10 * factorScale * 3
    playerControllView.alpha = 1 - factorScale
    
    newSize -= translation
    self.frame.origin = newOrigin
  }
  override func onEnded(isClap: Bool) {
    if isClap {
      UIView.animate(withDuration: animationDuration, animations: {
        self.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height * 0.9)
        self.largePlayerView.layer.cornerRadius = 0
        self.miniPlayerBar.alpha = 1
        
        self.coverWidthConstraint.constant = self.minCoverWidth
        self.coverVerticleConstraint = self.coverVerticleConstraint.setMultiplier(multiplier: self.minVerticleMultiplier)
        self.coverHorizontalConstraint = self.coverHorizontalConstraint.setMultiplier(multiplier: self.minHorizontalMultiplier)
        self.layoutIfNeeded()
        self.delegate?.didClapPlayer()
      }, completion: { isCompleted in
        if isCompleted {
          self.resetCurrentRect()
        }
      })
    } else {
      UIView.animate(withDuration: animationDuration, animations: {
        self.frame.origin = CGPoint(x: 0, y: 0 )
        self.largePlayerView.layer.cornerRadius = 10
        self.miniPlayerBar.alpha = 0
        self.coverWidthConstraint.constant = self.maxCoverWidth
        self.coverVerticleConstraint = self.coverVerticleConstraint.setMultiplier(multiplier: self.maxVerticleMultiplier)
        self.coverHorizontalConstraint = self.coverHorizontalConstraint.setMultiplier(multiplier: self.maxHorizontalMultiplier)
        self.playerControllView.alpha = 1
        self.layoutIfNeeded()
        self.delegate?.didOpenPlayer()
      }, completion: { isCompleted in
        if isCompleted {
          self.resetCurrentRect()
        }
      })
    }
  }
  func transformFromRect(from source: CGRect, toRect destination: CGRect) -> CGAffineTransform {
    return CGAffineTransform.identity
      .translatedBy(x: destination.midX - source.midX, y: destination.midY - source.midY)
      .scaledBy(x: destination.width / source.width, y: destination.height / source.height)
  }
  
  func blur(image image: UIImage) -> UIImage {
 
    let imageToBlur = CIImage(image: image)
    let blurfilter = CIFilter(name: "CIGaussianBlur")
    blurfilter!.setValue(imageToBlur, forKey: "inputImage")
    blurfilter!.setValue(70, forKey:kCIInputRadiusKey);
    let resultBlurImage = blurfilter!.value(forKey: "outputImage") as? CIImage
    let context = CIContext(options: nil)
//    let blurredImage = UIImage(cgImage: context.createCGImage(resultBlurImage!, from: (imageToBlur?.extent)!)!)
    let exposureFilter = CIFilter(name: "CIExposureAdjust")
    exposureFilter?.setValue(resultBlurImage, forKey: kCIInputImageKey)
    exposureFilter?.setValue(10, forKey: kCIInputEVKey)
    let resultBlurAndExposureImage = blurfilter!.value(forKey: "outputImage") as? CIImage
    let blurredAndExposuredImage = UIImage(cgImage: context.createCGImage(resultBlurAndExposureImage!, from: (imageToBlur?.extent)!)!)


    
//
//    let radius: CGFloat = 200
//    let context = CIContext(options: nil)
//
//    let inputImage = CIImage(cgImage: image.cgImage!)
//    let filter = CIFilter(name: "CIGaussianBlur")
//      filter?.setValue(inputImage, forKey: kCIInputImageKey)
//      filter?.setValue(radius, forKey:kCIInputRadiusKey)
//    let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage

    return blurredAndExposuredImage
  }
}
