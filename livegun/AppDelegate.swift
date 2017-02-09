//
//  AppDelegate.swift
//  livegun
//
//  Created by Marek Mako on 14/01/2017.
//  Copyright © 2017 Marek Mako. All rights reserved.
//

import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var isAlreadyRun: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "kIsAlreadyRun")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "kIsAlreadyRun")
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if !isAlreadyRun {
            BloodMode.shared.isBloodModeActive = false
            isAlreadyRun = true
        }
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3278005872817682~5192365879")
        RewardAd.shared.load()
        Authentificator.shared.authentificate()
        
        return true
    }
}

