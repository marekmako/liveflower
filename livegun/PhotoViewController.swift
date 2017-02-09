//
//  PhotoViewController.swift
//  livegun
//
//  Created by Marek Mako on 26/01/2017.
//  Copyright © 2017 Marek Mako. All rights reserved.
//

import UIKit


class PhotoViewController: BaseViewController {
    
    /// from segue
    var videoVC: VideoViewController!
    /// from segue
    var photoImage: UIImage!
    /// from segue
    var hitEffects: HitEffects!
    
    let shareScore = Shares()
    
    let kills = Kills()
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBAction func onCancel() {
        onClickSound()
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onShare() {
        onClickSound()
        let text = "My victim list contains \(kills.cnt) people. Are you ready try this new game and beat me?"
        let image = photoImageView.image!
        let url = URL(string: "https://itunes.apple.com/us/app/myapp/id1203653615?ls=1&mt=8")!

        
        let activityVC = UIActivityViewController(activityItems: [text, image, url],
                                                  applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.airDrop, UIActivityType.copyToPasteboard, UIActivityType.openInIBooks]
        
        if let popoverVC = activityVC.popoverPresentationController {
            popoverVC.sourceView = view
        }
        
        present(activityVC, animated: true, completion: {
            self.shareScore.addScore()
        })
    }
}


// MARK: - LICECYCLE
extension PhotoViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            guard videoVC != nil else {
                fatalError()
            }
            guard photoImage != nil else {
                fatalError()
            }
            guard hitEffects != nil else {
                fatalError()
            }
        #endif

        // priprava na screen shot
        photoImageView.image = photoImage
        photoImageView.layer.addSublayer(hitEffects.effectsLayer)
        cancelButton.isHidden = true
        shareButton.isHidden = true
        
        // screen shot
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
//        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // upratujem po screenshote
        photoImageView.image = image
        videoVC.videoLayer.addSublayer(hitEffects.effectsLayer)
        cancelButton.isHidden = false
        shareButton.isHidden = false
    }
}
