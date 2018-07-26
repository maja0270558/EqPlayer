//
//  EQPlayerView.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/22.
//  Copyright © 2018年 Django. All rights reserved.
//

import Lerp
import MediaPlayer
import UIKit
public protocol EQPlayerViewDelegate: class {
    func didClapPlayer()
    func didOpenPlayer()
    func didDragPlayer(factor: CGFloat)
}

class EQPlayerView: EQPlayerPannableView {
    weak var delegate: EQPlayerViewDelegate?
    let mpVolumeView = MPVolumeView(frame: CGRect.zero)

    var maxCoverWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.6
    }

    let minCoverWidth: CGFloat = 40
    let maxVerticleMultiplier: CGFloat = 1
    let minVerticleMultiplier: CGFloat = 0.2
    let maxHorizontalMultiplier: CGFloat = 0.6
    let minHorizontalMultiplier: CGFloat = 0.1

    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var largePlayerCoverImage: UIImageView!

    @IBOutlet var miniBarTrackNameLabel: UILabel!
    @IBOutlet var trackNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!

    @IBOutlet var maxDurationLabel: UILabel!
    @IBOutlet var currentPositionLabel: UILabel!

    @IBOutlet var playButton: UIButton!
    @IBOutlet var miniBarPlayButton: UIButton!

    @IBOutlet var volumeSlider: EQCustomSlider!
    @IBOutlet var durationSlider: EQCustomSlider!

    @IBOutlet var miniPlayerBar: UIView!
    @IBOutlet var largePlayerView: UIView!

    @IBOutlet var playerControllView: UIView!

    @IBOutlet var coverWidthConstraint: NSLayoutConstraint!
    @IBOutlet var coverHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet var coverVerticleConstraint: NSLayoutConstraint!

    @IBAction func miniBarSkipButton(_: UIButton) {
        EQSpotifyManager.shard.skip()
    }

    @IBAction func skipTrackAction(_: UIButton) {
        if EQSpotifyManager.shard.currentPlayingType == .preview {
            return
        }
        EQSpotifyManager.shard.skip()
    }

    @IBAction func miniBarPlayOrPauseAction(_ sender: UIButton) {
        let isPlay = !sender.isSelected

        playOrPause(isPlay: isPlay) {
            sender.isSelected = isPlay
        }
    }

    @IBAction func playOrPauseAction(_ sender: UIButton) {
        let isPlay = !sender.isSelected

        playOrPause(isPlay: isPlay) {
            sender.isSelected = isPlay
        }
    }

    @IBAction func previousTrackAction(_: UIButton) {
        if EQSpotifyManager.shard.currentPlayingType == .preview {
            return
        }
        EQSpotifyManager.shard.previous()
    }

    var minPlayerViewSize: CGFloat = 60
    var currentOrigin: CGPoint = CGPoint.zero
    var currentSize: CGFloat = 60
    var systemVolumeView: UISlider?

    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
        setupLayer()
        setupCover()
        setupVolumeView()
        setupDurationTarget()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
        setupLayer()
        setupCover()
        setupVolumeView()
        setupDurationTarget()
    }

    func playOrPause(isPlay: Bool, completion: @escaping () -> Void) {
        EQSpotifyManager.shard.playOrPause(isPlay: isPlay) {
            completion()
        }
    }

    func setupDurationTarget() {
        durationSlider.addTarget(self, action: #selector(touchUpEvent(sender:)), for: .touchUpInside)
        durationSlider.addTarget(self, action: #selector(touchUpEvent(sender:)), for: .touchUpOutside)
    }

    func resetPlayer() {
        playButton.isSelected = false
        miniBarPlayButton.isSelected = false
        durationSlider.maximumValue = 1
        maxDurationLabel.text = "-0:00"
        currentPositionLabel.text = "0:00"
        coverImageView.image = #imageLiteral(resourceName: "vinyl")
        blurCoverBackground(source: coverImageView.image!)
        artistNameLabel.text = "無"
        trackNameLabel.text = "尚未播放"
        miniBarTrackNameLabel.text = "尚未播放"
        durationSlider.value = 0
    }

    @objc func touchUpEvent(sender: UISlider) {
        if EQSpotifyManager.shard.currentPlayingType == .preview {
            sender.value = Float(EQSpotifyManager.shard.durationObseve.currentDuration)
            return
        }

        if EQSpotifyManager.shard.player?.getMetadata() == nil {
            sender.value = 0
            return
        }

        EQSpotifyManager.shard.player?.seekTo(TimeInterval(sender.value))
    }

    func setupVolumeView() {
        playerControllView.addSubview(mpVolumeView)
        mpVolumeView.showsRouteButton = false
        for subview in mpVolumeView.subviews {
            if NSStringFromClass(subview.classForCoder) != "MPVolumeSlider" {
                subview.isHidden = true
                subview.removeFromSuperview()
            } else {
                guard let volumeSlider = subview as? UISlider else {
                    return
                }
                systemVolumeView = volumeSlider
            }
        }
        systemVolumeView?.maximumValueImage = #imageLiteral(resourceName: "volumeOn")
        systemVolumeView?.minimumValueImage = #imageLiteral(resourceName: "volumeOff")
        volumeSlider.isHidden = true
    }

    func fitVolumeView() {
        mpVolumeView.frame = volumeSlider.frame
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        fitVolumeView()
    }

    func openPlayer() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.frame.origin = CGPoint(x: 0, y: 0)
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

    func folderPlayer() {
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
    }

    func setupCover() {
        coverWidthConstraint.constant = minCoverWidth
        coverVerticleConstraint = coverVerticleConstraint.setMultiplier(multiplier: minVerticleMultiplier)
        coverHorizontalConstraint = coverHorizontalConstraint.setMultiplier(multiplier: minHorizontalMultiplier)
        coverImageView.addShadow()
        coverImageView.layer.cornerRadius = 10
        largePlayerCoverImage.image = blur(image: largePlayerCoverImage.image!)
        largePlayerCoverImage.layer.masksToBounds = false
        let maskLayer = CAGradientLayer()
        maskLayer.frame = largePlayerCoverImage.bounds
        maskLayer.shadowRadius = 10
        maskLayer.shadowPath = CGPath(roundedRect: largePlayerCoverImage.bounds.insetBy(dx: 20, dy: 20), cornerWidth: 20, cornerHeight: 20, transform: nil)
        maskLayer.shadowOpacity = 0.8
        maskLayer.shadowOffset = CGSize.zero
        maskLayer.shadowColor = UIColor.white.cgColor
        largePlayerCoverImage.layer.mask = maskLayer
    }

    func blurCoverBackground(source: UIImage) {
        largePlayerCoverImage.image = blur(image: source)
    }

    func setupLayer() {
        backgroundColor = UIColor.clear
        miniPlayerBar.layer.cornerRadius = 10
        miniPlayerBar.clipsToBounds = true
        miniPlayerBar.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    func resetCurrentRect() {
        currentSize = frame.size.height
        currentOrigin = frame.origin
    }

    override func onBegan() {
        resetCurrentRect()
    }

    override func onChanged(translation: CGFloat) {
        var newOrigin = currentOrigin
        var newSize = currentSize
        newOrigin.y += translation
        newOrigin.y = max(0, newOrigin.y)
        let factorScale = max(0, newOrigin.y / (UIScreen.main.bounds.height * 0.9))
        delegate?.didDragPlayer(factor: factorScale)
        coverWidthConstraint.constant = lerp(factorScale, min: maxCoverWidth, max: minCoverWidth)
        coverVerticleConstraint = coverVerticleConstraint.setMultiplier(multiplier: lerp(factorScale, min: maxVerticleMultiplier, max: minVerticleMultiplier))
        coverHorizontalConstraint = coverHorizontalConstraint.setMultiplier(multiplier: lerp(factorScale, min: maxHorizontalMultiplier, max: minHorizontalMultiplier))
        miniPlayerBar.alpha = factorScale * 3
        largePlayerView.layer.cornerRadius = 1 - 10 * factorScale * 3
        playerControllView.alpha = 1 - factorScale
        newSize -= translation
        frame.origin = newOrigin
    }

    override func onEnded(isClap: Bool) {
        if isClap {
            folderPlayer()
        } else {
            openPlayer()
        }
    }

    func transformFromRect(from source: CGRect, toRect destination: CGRect) -> CGAffineTransform {
        return CGAffineTransform.identity
            .translatedBy(x: destination.midX - source.midX, y: destination.midY - source.midY)
            .scaledBy(x: destination.width / source.width, y: destination.height / source.height)
    }

    func blur(image: UIImage) -> UIImage {
        let imageToBlur = CIImage(image: image)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        blurfilter!.setValue(30, forKey: kCIInputRadiusKey)
        let resultBlurImage = blurfilter!.value(forKey: "outputImage") as? CIImage
        let context = CIContext(options: nil)
        let exposureFilter = CIFilter(name: "CIExposureAdjust")
        exposureFilter?.setValue(resultBlurImage, forKey: kCIInputImageKey)
        exposureFilter?.setValue(15, forKey: kCIInputEVKey)
        let resultBlurAndExposureImage = blurfilter!.value(forKey: "outputImage") as? CIImage
        let blurredAndExposuredImage = UIImage(cgImage: context.createCGImage(resultBlurAndExposureImage!, from: (imageToBlur?.extent)!)!)
        return blurredAndExposuredImage
    }
}
