//
//  WeaponViewController.swift
//  livegun
//
//  Created by Marek Mako on 26/01/2017.
//  Copyright © 2017 Marek Mako. All rights reserved.
//

import UIKit
import GoogleMobileAds


class WeaponViewController: BaseViewController {
    
    /// from segue
    weak var mainVC: MainViewController!
    
    /// from segue
    var weaponType: BaseWeaponType!
    
    fileprivate let killed = Kills()
    
    @IBOutlet weak var weaponImage: UIImageView!
    
    @IBOutlet weak var weaponNameLabel: UILabel!
    
    @IBOutlet weak var weaponDemageLabel: UILabel!
    
    @IBAction func onSelectWeapon() {
        onClickSound()
        if killed.cnt >= weaponType.requiredKillsForFree {
            mainVC.selectedWeaponType = weaponType
            mainVC.dismiss(animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "\(weaponType.name)\n\nYou need only\n\(weaponType.requiredKillsForFree - killed.cnt)\nmore points to unlock", message: nil, preferredStyle: .alert)
            if RewardAd.shared.isReady() {
                alert.addAction(UIAlertAction(title: "Only watch video to unlock", style: .destructive, handler: { [unowned self] _ in
                    RewardAd.shared.present(from: self)
                }))
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
}



// MARK: - LICECYCLE
extension WeaponViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        #if DEBUG
            guard mainVC != nil else {
                fatalError()
            }
            guard weaponType != nil else {
                fatalError()
            }
        #endif
        
        weaponImage.image = weaponType.image
        weaponNameLabel.text = weaponNameLabel.text?.replacingOccurrences(of: "%@", with: weaponType.name)
        weaponDemageLabel.text  = weaponDemageLabel.text?.replacingOccurrences(of: "%@", with: "\(weaponType.demage!)")
    }
}
