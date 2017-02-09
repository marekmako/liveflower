//
//  Player.swift
//  livegun
//
//  Created by Marek Mako on 31/01/2017.
//  Copyright © 2017 Marek Mako. All rights reserved.
//

import Foundation
import GameKit


// MARK: - Blood Mode
class BloodMode {
    
    static let shared = BloodMode()
    
    private let userDefaults = UserDefaults.standard
    
    private let kBloodMode = "is_blood_mode"
    
    var isBloodModeActive: Bool {
        get {
            return userDefaults.bool(forKey: kBloodMode)
        }
        set {
            userDefaults.set(newValue, forKey: kBloodMode)
        }
    }
}


// MARK: - GAME CENTER LEADERBORD
class LeaderBoard {
    
    private static let identifier = "com.marekmako.liveflower.top_players"
    
    func report(score: Int) {
        guard Authentificator.shared.isAuthenticated() else {
            return
        }
        
        let gkscore = GKScore(leaderboardIdentifier: LeaderBoard.identifier)
        gkscore.value = Int64(score)
        
        GKScore.report([gkscore], withCompletionHandler: { (error: Error?) in
            #if DEBUG
                if nil != error {
                    print(error!.localizedDescription)
                    
                } else {
                    print("score reported: \(gkscore.value) for \(LeaderBoard.identifier)" )
                }
            #endif
        })
    }
    
    class func createLeaderBoard(delegateView delegate: GKGameCenterControllerDelegate) -> GKGameCenterViewController {
        let gkVC = GKGameCenterViewController()
        gkVC.gameCenterDelegate = delegate
        gkVC.viewState = .leaderboards
        gkVC.leaderboardIdentifier = LeaderBoard.identifier
        
        return gkVC
    }
}


// MARK: - Authentificator
class Authentificator {
    
    static let shared = Authentificator()
    
    static let errorNotificationName = Notification.Name("PlayerAuthentificator.errorNotificationName")
    var error: Error?
    
    static let presentVCNotificationName = Notification.Name("PlayerAuthentificator.presentAuthetificationVCNotificationName")
    var authentificationViewController: UIViewController?
    
    static let authentificatedNotificationName = Notification.Name("PlayerAuthentificator.authentificatedLocalPlayerNotificationName")
    var authentificatedLocalPlayer: GKLocalPlayer?
    
    private init() {}
    
    func isAuthenticated() -> Bool {
        return GKLocalPlayer.localPlayer().isAuthenticated
    }
    
    func authentificate() {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        if localPlayer.isAuthenticated {
            NotificationCenter.default.post(name: Authentificator.authentificatedNotificationName, object: self)
            
        } else {
            localPlayer.authenticateHandler = { (viewController: UIViewController?, error: Error?) in
                guard error == nil else {
                    self.error = error
                    #if DEBUG
                        print("Authentificator.authentificate", error!.localizedDescription)
                    #endif
                    NotificationCenter.default.post(name: Authentificator.errorNotificationName, object: self)
                    return
                }
                
                if viewController != nil {
                    self.authentificationViewController = viewController
                    NotificationCenter.default.post(name: Authentificator.presentVCNotificationName, object: self)
                    
                    
                } else if localPlayer.isAuthenticated {
                    self.authentificatedLocalPlayer = localPlayer
                    NotificationCenter.default.post(name: Authentificator.authentificatedNotificationName, object: self)
                    
                } else {
                    #if DEBUG
                        fatalError()
                    #endif
                }
            }
        }
    }
}


// MARK: - SCORE
class Kills: AbstractScore {
    
    private let leaderBoard = LeaderBoard()
    
    init() {
        super.init(userDefaultScoreKey: "k_kills_cnt")
    }
    
    override func addScore(_ score: Int = 1) {
        super.addScore(score)
        leaderBoard.report(score: cnt)
    }
}

class Shares: AbstractScore {
    
    init() {
        super.init(userDefaultScoreKey: "k_shares_cnt")
    }
}

class AbstractScore {
    
    let userDefaults = UserDefaults.standard
    
    let kScore: String
    
    init(userDefaultScoreKey kScore: String) {
        self.kScore = kScore
    }
    
    private(set) var cnt: Int  {
        get {
            return userDefaults.integer(forKey: kScore)
        }
        set {
            userDefaults.set(newValue, forKey: kScore)
        }
    }
    
    func addScore(_ score: Int = 1) {
        cnt += score
    }
}
