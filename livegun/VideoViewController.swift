//
//  VideoViewController.swift
//  livegun
//
//  Created by Marek Mako on 25/01/2017.
//  Copyright © 2017 Marek Mako. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: BaseViewController {
    
    /// tu testujem otocenie videa
    @IBOutlet weak var testVideoImageView: UIImageView!
    
    // from segue
    var captureDevicePosition: AVCaptureDevicePosition = .back
    
    /// from segue
    var mainVC: MainViewController!
    
    /// from segue
    var weaponType: BaseWeapon.Type!
    
    fileprivate var isInitialized = false
    
    fileprivate var currImage: CIImage?
    
    fileprivate var weapon: BaseWeapon!
    
    fileprivate let killScore = Kills()
    
    fileprivate let extraSound = ExtraSound()
    
    fileprivate var audioPlayer: AVAudioPlayer?
    
    // video
    fileprivate let avSession = AVCaptureSession()
    fileprivate var videoOutputConnection: AVCaptureConnection?
    fileprivate var videoLayerConnection: AVCaptureConnection?
    
    // layers
    var videoLayer: AVCaptureVideoPreviewLayer!
    
    fileprivate let faceLayer = CALayer()
    fileprivate let leftEyeLayer = CALayer()
    fileprivate let rightEyeLayer = CALayer()
    fileprivate let mouthLayer = CALayer()
    
    fileprivate let aimLayer = CALayer()
    fileprivate let shootLayer = CALayer()
    fileprivate let bloodLayer = CALayer()
    fileprivate let gunLayer = CALayer()
    
    fileprivate let stieracLayer = CALayer()
    
    // effects
    fileprivate var hitEffects: HitEffects!
    
    fileprivate let faceDetector = CIDetector(ofType: CIDetectorTypeFace,
                                              context: nil,
                                              options: [CIDetectorAccuracy : CIDetectorAccuracyLow , /*CIDetectorTracking : true*/])!
    
    // actions
    @IBAction func onCancel() {
        onClickSound()
        mainVC.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onStieracClick() {
        onClickSound()
        runStierac()
    }
    
    @IBAction func onPhoto() {
        onClickSound()
        guard currImage != nil else {
            return
        }
        performSegue(withIdentifier: "PhotoViewControllerSegue", sender: nil)
    }
    
    // outlets && support outlets
    fileprivate var isAlive = true
    
    fileprivate var life: Float = 1 {
        didSet {
            if life <= 0 && isAlive {
                isAlive = false
                killScore.addScore()
                extraSound.addKill()
                updateKillLabel()
                extraSound.playKill()
                
                let killCntLabelanimation = CABasicAnimation(keyPath: "transform.scale")
                killCntLabelanimation.toValue = 5
                killCntLabelanimation.duration = 0.2
                killCntLabelanimation.repeatCount = 4
                killCntLabelanimation.autoreverses = true
                killCntLabel.layer.add(killCntLabelanimation, forKey: nil)
            }
            lifeProgressView.progress = life
        }
    }
    @IBOutlet weak var lifeProgressView: UIProgressView!
    
    @IBOutlet weak var searchingTargetLabel: UILabel!
    
    @IBOutlet weak var killCntLabel: UILabel!
}


// MARK: HELPERS 
fileprivate extension VideoViewController {
    
    func updateKillLabel() {
        killCntLabel.text = "Points: \(killScore.cnt)"
    }
}


// MARK: ACTIONS
fileprivate extension VideoViewController {
    
    func runStierac() {
        let stieracAnimation = CAKeyframeAnimation(keyPath: "contents")
        stieracAnimation.calculationMode = kCAAnimationDiscrete
        stieracAnimation.duration = 0.5
        stieracAnimation.keyTimes = [0, 0.1, 0.2, 0.3, 0.5, 0.6, 0.7, 0.8, 0.9, 1]
        stieracAnimation.isAdditive = true
        stieracAnimation.values = [
            #imageLiteral(resourceName: "stierac1").cgImage!,
            #imageLiteral(resourceName: "stierac2").cgImage!,
            #imageLiteral(resourceName: "stierac3").cgImage!,
            #imageLiteral(resourceName: "stierac4").cgImage!,
            #imageLiteral(resourceName: "stierac5").cgImage!,
            #imageLiteral(resourceName: "stierac7").cgImage!,
            #imageLiteral(resourceName: "stierac8").cgImage!,
            #imageLiteral(resourceName: "stierac9").cgImage!,
            #imageLiteral(resourceName: "stierac10").cgImage!,
            #imageLiteral(resourceName: "stierac11").cgImage!,
        ]
        stieracLayer.add(stieracAnimation, forKey: nil)
        
        let audioName = "stierac-sound" + "\(Int(arc4random_uniform(2)))"
        audioPlayer = try? AVAudioPlayer(data: NSDataAsset(name: audioName)!.data, fileTypeHint: AVFileTypeCoreAudioFormat)
        audioPlayer?.play()
        
        hitEffects.hideRandKrvaveFrkance()
    }
}



// MARK: LIFECYCLE
extension VideoViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            testVideoImageView.isHidden = true
        #else
            testVideoImageView.isHidden = true
        #endif

        #if DEBUG
            guard mainVC != nil else {
                fatalError()
            }
            guard weaponType != nil else {
                fatalError()
            }
        #endif
        
        lifeProgressView.isHidden = true
        
        weapon = weaponType.init(gunLayer: gunLayer, shootLayer: shootLayer)
        
        updateKillLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isInitialized {
            isInitialized = true
            setup()
            extraSound.playStart()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    
        let currentOrientation = self.currentOrientation
        videoOutputConnection?.videoOrientation = currentOrientation
        videoLayerConnection?.videoOrientation = currentOrientation
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let photoVC = segue.destination as? PhotoViewController {
            photoVC.photoImage = UIImage(ciImage: currImage!)
            photoVC.hitEffects = hitEffects
            photoVC.videoVC = self
        }
    }
}



// MARK: SETUP
extension VideoViewController {
    
    fileprivate var currentOrientation: AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
//        case .portrait:
//            return .portrait
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
//        case .portraitUpsideDown:
//            return .portraitUpsideDown
        default:
            return .landscapeRight
        }
    }
    
    fileprivate func setup() {
        setupGunTriggerRecognizer()
        avSessionSetup()
        setupAndRunCameraLivePreview()
        setupLayers()
        hitEffectsSetup()
    }
    
    private func avSessionSetup() {
        let camera = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera,
                                                   mediaType: AVMediaTypeVideo,
                                                   position: captureDevicePosition)
        
        avSession.beginConfiguration()
        
        // MARK: INPUT VIDEO
        let input = try! AVCaptureDeviceInput(device: camera)
        avSession.addInput(input)
        // najrychlejsi format videa
        if captureDevicePosition == .back {
            var bestFormat: AVCaptureDeviceFormat?
            var bestFrameRange: AVFrameRateRange?
            for format in input.device.formats as! [AVCaptureDeviceFormat] {
                for range in format.videoSupportedFrameRateRanges as! [AVFrameRateRange] {
                    if bestFrameRange == nil {
                        bestFrameRange = range
                        bestFormat = format
                        
                    } else if bestFrameRange!.maxFrameRate < range.maxFrameRate {
                        bestFrameRange = range
                        bestFormat = format
                    }
                }
            }
            if bestFormat != nil {
                try! input.device.lockForConfiguration()
                
                input.device.activeFormat = bestFormat!
                input.device.activeVideoMinFrameDuration = bestFrameRange!.minFrameDuration
                input.device.activeVideoMaxFrameDuration = bestFrameRange!.minFrameDuration
                input.device.unlockForConfiguration()
            }
        }
        
        
        // MARK: OUTPUT VIDEO
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : kCMPixelFormat_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        
        let queue = DispatchQueue(label: "com.marekmako.livegun.videooutput_queue")
        output.setSampleBufferDelegate(self, queue: queue)
        avSession.addOutput(output)
        
        avSession.commitConfiguration()
        
        // MARK: VIDEO ORIENTATION
        videoOutputConnection = output.connections.first as? AVCaptureConnection
        videoOutputConnection?.videoOrientation = currentOrientation
        if captureDevicePosition == .front, videoOutputConnection!.isVideoMirroringSupported {
            videoOutputConnection?.isVideoMirrored = true
        }
    }
    
    private func setupAndRunCameraLivePreview() {
        // MARK: VIDEO LAYER
        videoLayer = AVCaptureVideoPreviewLayer(session: avSession)!
        videoLayerConnection = videoLayer.connection
        
        videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoLayerConnection?.videoOrientation = currentOrientation
        
        videoLayer.frame = view.bounds
        videoLayer.zPosition = -1
        view.layer.addSublayer(videoLayer)
        avSession.startRunning()
    }
    
    private func setupLayers() {
        // MARK: AIM LAYER
        let aimImage = #imageLiteral(resourceName: "aim").cgImage
        let aimSize = CGSize(width: view.bounds.height * 0.3, height: view.bounds.height * 0.3)
        aimLayer.frame = CGRect(x: view.frame.midX - aimSize.width / 2,
                                y: view.layer.frame.midY - aimSize.height,
                                width: aimSize.width,
                                height: aimSize.height)
        aimLayer.contents = aimImage
        view.layer.addSublayer(aimLayer)
        
        // MARK: SHOOT LAYER
        shootLayer.frame = aimLayer.frame
        view.layer.addSublayer(shootLayer)
        

        
        
        // MARK: BLOOD LAYER
        bloodLayer.frame = aimLayer.frame
        view.layer.addSublayer(bloodLayer)
        
        
        // MARK: GUN LAYER
        let gunSize = CGSize(width: view.bounds.height * 0.7, height: view.bounds.height * 0.7)
        gunLayer.frame = CGRect(x: view.frame.maxX - gunSize.width,
                                y: view.frame.maxY - gunSize.height,
                                width: gunSize.width,
                                height: gunSize.height)
        gunLayer.contentsGravity = kCAGravityResizeAspect
        view.layer.addSublayer(gunLayer)
        
        // MARK: FACE LAYER
        #if DEBUG
            faceLayer.borderWidth = 1
            faceLayer.borderColor = UIColor.red.cgColor
        #endif
        view.layer.addSublayer(faceLayer)
        
        
        // MARK: LEFT EYE LAYER
        #if DEBUG
            leftEyeLayer.borderWidth = 1
            leftEyeLayer.borderColor = UIColor.green.cgColor
        #endif
        view.layer.addSublayer(leftEyeLayer)
        
        
        // MARK: RIGHT EYE LAYER
        #if DEBUG
            rightEyeLayer.borderWidth = 1
            rightEyeLayer.borderColor = UIColor.blue.cgColor
        #endif
        view.layer.addSublayer(rightEyeLayer)
        
        
        // MARK: MOUTH LAYER
        #if DEBUG
            mouthLayer.borderWidth = 1
            mouthLayer.borderColor = UIColor.yellow.cgColor
        #endif
        view.layer.addSublayer(mouthLayer)
        
        // MARK: STIERAC LAYER
        stieracLayer.frame = videoLayer.bounds
        view.layer.addSublayer(stieracLayer)
    }

    private func hitEffectsSetup() {
        hitEffects = HitEffects(weapon: weapon,
                                videoLayer: videoLayer,
                                faceLayer: faceLayer,
                                laveOkoLayer: leftEyeLayer,
                                praveOkoLayer: rightEyeLayer,
                                ustaLayer: mouthLayer)
    }
    
    private func setupGunTriggerRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onShot(sender:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func onShot(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: view)
        if touchPoint.x >= view.bounds.width - gunLayer.bounds.width && touchPoint.y >= view.bounds.height - gunLayer.bounds.height { // klika na zbran
            
            weapon.onShoot()
            
            // MARK: HIT RECOGNIZER
            let aimLayerCenter = CGPoint(x: aimLayer.bounds.width / 2 + aimLayer.frame.origin.x, y: aimLayer.bounds.height / 2 + aimLayer.frame.origin.y)
            
            if faceLayer.frame.origin.x <= aimLayerCenter.x && (faceLayer.frame.origin.x + faceLayer.bounds.width) >= aimLayerCenter.x &&
                faceLayer.frame.origin.y <= aimLayerCenter.y && faceLayer.frame.origin.y + faceLayer.bounds.height >= aimLayerCenter.y  {
                
                hitEffects.onHit()
                life -= weapon.lifeDemage
            }
        }
    }
}



// MARK: AVCaptureVideoDataOutputSampleBufferDelegate & FACE RECOGNIZER
extension VideoViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
 
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let cvImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            #if DEBUG
                fatalError()
            #else
                return
            #endif
        }
        let ciImage = CIImage(cvImageBuffer: cvImageBuffer)
        currImage = ciImage
        faceDetection(from: ciImage)
        
        #if DEBUG
            DispatchQueue.main.async {
                self.testVideoImageView.image = UIImage(ciImage: ciImage)
            }
        #endif
    }
    
    private func faceDetection(from image: CIImage) {
        let faces = faceDetector.features(in: image) as! [CIFaceFeature]
        
        if faces.isEmpty {
            DispatchQueue.main.async {
                self.hideFaceLayers()
            }
            
        } else {
            for face in faces {
                
                DispatchQueue.main.async {
                    
                    // MARK: FRAME PRE TVAR
                    let faceFrame = self.createFrame(for: face, from: image, to: self.view)
                    /// + 30% navrchu
                    let headFrame = CGRect(x: faceFrame.minX,
                                           y: faceFrame.minY - faceFrame.height * 0.3,
                                           width: faceFrame.width,
                                           height: faceFrame.height * 1.3)
                    self.faceLayer.frame = headFrame
                    
                    if face.hasLeftEyePosition {
                        self.leftEyeLayer.frame = self.createFrame(for: face.leftEyePosition, from: image, to: self.view)
                        
                    } else {
                        self.leftEyeLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                    }
                    
                    
                    if face.hasRightEyePosition {
                        self.rightEyeLayer.frame = self.createFrame(for: face.rightEyePosition, from: image, to: self.view)
                        
                    } else {
                        self.rightEyeLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                    }
                    
                    
                    if face.hasMouthPosition {
                        self.mouthLayer.frame = self.createFrame(for: face.mouthPosition, from: image, to: self.view)
                        
                    } else {
                        self.mouthLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                    }
                    
                    self.hitEffects.updateFrames()
                    
                    self.lifeProgressView.isHidden = false
                    self.searchingTargetLabel.isHidden = true
                }
            }
        }
    }
    
    private func hideFaceLayers() {
        self.faceLayer.frame = CGRect(x: self.faceLayer.frame.origin.x,
                                      y: self.faceLayer.frame.origin.y,
                                      width: 0,
                                      height: 0)
        self.leftEyeLayer.frame = CGRect(x: self.leftEyeLayer.frame.origin.x,
                                         y: self.leftEyeLayer.frame.origin.y,
                                         width: 0,
                                         height: 0)
        self.rightEyeLayer.frame = CGRect(x: self.rightEyeLayer.frame.origin.x,
                                          y: self.rightEyeLayer.frame.origin.y,
                                          width: 0,
                                          height: 0)
        self.mouthLayer.frame = CGRect(x: self.mouthLayer.frame.origin.x,
                                       y: self.mouthLayer.frame.origin.y,
                                       width: 0,
                                       height: 0)
        self.hitEffects.hideFrames()
        
        self.lifeProgressView.isHidden = true
        self.searchingTargetLabel.isHidden = false
    }
    
    private func createFrame(for face: CIFaceFeature, from image: CIImage, to view: UIView) -> CGRect {
        // For converting the Core Image Coordinates to UIView Coordinates
        let ciImageSize = image.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        
        // Apply the transform to convert the coordinates
        var faceFrame = face.bounds.applying(transform)
        
        // Calculate the actual position and size of the rectangle in the image view
        let viewSize = view.bounds.size
        let scale = min(viewSize.width / ciImageSize.width,
                        viewSize.height / ciImageSize.height)
        let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
        let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
        
        faceFrame = faceFrame.applying(CGAffineTransform(scaleX: scale, y: scale))
        faceFrame.origin.x += offsetX
        faceFrame.origin.y += offsetY
        
        return faceFrame
    }
    
    private func createFrame(for part: CGPoint, from image: CIImage, to view: UIView) -> CGRect {
        // For converting the Core Image Coordinates to UIView Coordinates
        let ciImageSize = image.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        
        var partFrame = CGRect(x: part.x, y: part.y, width: 10, height: 10).applying(transform)
        
        // Calculate the actual position and size of the rectangle in the image view
        let viewSize = view.bounds.size
        let scale = min(viewSize.width / ciImageSize.width,
                        viewSize.height / ciImageSize.height)
        let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
        let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
        
        partFrame = partFrame.applying(CGAffineTransform(scaleX: scale, y: scale))
        partFrame.origin.x += offsetX
        partFrame.origin.y += offsetY
        
        return partFrame
    }
}

