//
//  MainViewController.swift
//  livegun
//
//  Created by Marek Mako on 25/01/2017.
//  Copyright © 2017 Marek Mako. All rights reserved.
//

import UIKit
import GameKit

class MainViewController: BaseViewController {
    
    fileprivate let kills = Kills()
    
    /// nastavene po unwinde z WeaponViewController, kde si hrac vybral zbran po pouziti vo videoVC je zbran vynulovana
    var selectedWeaponType: BaseWeaponType?
    
    @IBOutlet weak var killedLabel: UILabel!
    
    /// vrazda alebo samovrazda?
    fileprivate var isMurderType: Bool = true
    
    
    /* leader board support */
    
    var authentificatedNotification: NSObjectProtocol?
    
    @IBOutlet weak var leaderBoardButton: UIButton!
    
    @IBAction func onLeaderBoardClick(_ sender: Any) {
        onClickSound()
        let leaderBoardVC = LeaderBoard.createLeaderBoard(delegateView: self)
        present(leaderBoardVC, animated: true, completion: nil)
    }
    
    
    @IBAction func onNewMurder() {
        onClickSound()
    }
    
    @IBAction func onSuicide() {
        onClickSound()
    }
    
    
//    @IBOutlet weak var bloodModeSwitch: UISwitch!
//    @IBAction func bloodModeChange() {
//        BloodMode.shared.isBloodModeActive = bloodModeSwitch.isOn
//    }
}

// MARK: - LIFECYCLE
extension MainViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        leaderBoardButton.isEnabled = false
        
//        bloodModeSwitch.isOn = BloodMode.shared.isBloodModeActive
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        authentificatedNotification = NotificationCenter.default.addObserver(forName: Authentificator.authentificatedNotificationName, object: nil, queue: .main, using: {[unowned self] (_) in
            self.leaderBoardButton.isEnabled = true
        })
        
        if selectedWeaponType != nil {
            performSegue(withIdentifier: "VideoViewControllerSegue", sender: nil)
        }
        
        killedLabel.text = "\(kills.cnt)"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if authentificatedNotification != nil {
            NotificationCenter.default.removeObserver(authentificatedNotification!)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let weaponPageVC = segue.destination as? WeaponPageViewController {
            weaponPageVC.mainVC = self
            
            if segue.identifier == "suicide" {
                isMurderType = false
            } else if segue.identifier == "murder" {
                isMurderType = true
            }
            
        } else if let videoVC = segue.destination as? VideoViewController {
            videoVC.mainVC = self
            videoVC.weaponType = selectedWeaponType!.classType!
            selectedWeaponType = nil
            
            if isMurderType {
                videoVC.captureDevicePosition = .back
            } else {
                videoVC.captureDevicePosition = .front
            }
        }
    }
}


// MARK: - GKGameCenterControllerDelegate
extension MainViewController: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        dismiss(animated: true, completion: nil)
    }
}
