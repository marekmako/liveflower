//
//  RewardAd.swift
//  livegun
//
//  Created by Marek Mako on 01/02/2017.
//  Copyright © 2017 Marek Mako. All rights reserved.
//

import Foundation
import GoogleMobileAds


protocol RewardAdDelegate: class {
    func rewardAdd(didRewardUserWith with: GADAdReward)
}


class RewardAd: NSObject, GADRewardBasedVideoAdDelegate {
    
    let rewardUserNotificationName = Notification.Name("RewardAd.rewardUserNotificationName")
    
    static let shared = RewardAd()
    
    private var ad: GADRewardBasedVideoAd
    
    weak var delegate: RewardAdDelegate?
    
    private override init() {
        ad = GADRewardBasedVideoAd.sharedInstance()
        
        super.init()
        
        ad.delegate = self
    }
    
    func load() {
        if !ad.isReady {
            #if DEBUG
                print("RewardAd.load")
            #endif
            ad.load(GADRequest(), withAdUnitID: "ca-app-pub-3278005872817682/4989693076")
        }
    }
    
    func isReady() -> Bool {
        return ad.isReady
    }
    
    func present(from VC: UIViewController) {
        ad.present(fromRootViewController: VC)
    }
    
    // MARK: GADRewardBasedVideoAdDelegate
    
    /// Tells the delegate that the reward based video ad has rewarded the user.
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        #if DEBUG
            print("rewardBasedVideoAd:didRewardUserWith")
        #endif
//        delegate?.rewardAd(didRewardUser: reward)
        delegate?.rewardAdd(didRewardUserWith: reward)
        NotificationCenter.default.post(name: rewardUserNotificationName, object: nil)
        load()
    }
    
    /// Tells the delegate that the reward based video ad failed to load.
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        #if DEBUG
            print("rewardBasedVideoAd:didFailToLoadWithError", error.localizedDescription)
        #endif
    }
    
    /// Tells the delegate that a reward based video ad was received.
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        #if DEBUG
            print("rewardBasedVideoAdDidReceive")
            print("rewardBasedVideoAd is ready", rewardBasedVideoAd.isReady)
        #endif
//        delegate?.rewardAd?(isReady: rewardBasedVideoAd)
    }
    
    /// Tells the delegate that the reward based video ad opened.
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        #if DEBUG
            print("rewardBasedVideoAdDidOpen")
        #endif
    }
    
    /// Tells the delegate that the reward based video ad started playing.
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        #if DEBUG
            print("rewardBasedVideoAdDidStartPlaying")
        #endif
    }
    
    /// Tells the delegate that the reward based video ad closed.
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        #if DEBUG
            print("rewardBasedVideoAdDidClose")
        #endif
        load()
    }
    
    /// Tells the delegate that the reward based video ad will leave the application.
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        #if DEBUG
            print("rewardBasedVideoAdWillLeaveApplication")
        #endif
    }
}
