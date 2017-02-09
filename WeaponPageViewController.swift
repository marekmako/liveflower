//
//  WeaponPageViewController.swift
//  livegun
//
//  Created by Marek Mako on 26/01/2017.
//  Copyright © 2017 Marek Mako. All rights reserved.
//

import UIKit
import GoogleMobileAds


class WeaponPageViewController: UIPageViewController {
    
    /// nastaveny zo segue
    weak var mainVC: MainViewController!
    
    /// sluzi pre datasource
    fileprivate var currentVC: WeaponViewController!
    
    fileprivate lazy  var orderedVC: [WeaponViewController] = {
        func createWeaponController(weapon: BaseWeaponType) -> WeaponViewController {
            let weaponVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WeaponViewController.self)) as! WeaponViewController
            weaponVC.weaponType = weapon
            weaponVC.mainVC = self.mainVC
            return weaponVC
        }
        
        return [
            createWeaponController(weapon: RedRoseType()),
            createWeaponController(weapon: BearType()),
            createWeaponController(weapon: OrchidType()),
            createWeaponController(weapon: BlueRoseType()),
            createWeaponController(weapon: SunflowerType()),
            createWeaponController(weapon: CandyType()),
            createWeaponController(weapon: CactusType()),
        ]
    }()
    
    
    fileprivate var previousVC: WeaponViewController?
    fileprivate var pendingVC: WeaponViewController?
    /// zobrazeny VC
    fileprivate var visibleVC: WeaponViewController?
}



// MARK: - LIFECYCLE
extension WeaponPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            guard  mainVC != nil else {
                fatalError()
            }
        #endif

        dataSource = self
        
        currentVC = orderedVC.first!
        visibleVC = currentVC
        setViewControllers([currentVC], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        RewardAd.shared.delegate = self
        delegate = self
    }
}



// MARK: UIPageViewControllerDataSource
extension WeaponPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! WeaponViewController
        let index = orderedVC.index(of: vc)!
        
        let prewIndex = index - 1
        
        guard prewIndex >= 0 else {
            return nil
        }
        
        currentVC = orderedVC[prewIndex]
        return currentVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! WeaponViewController
        let index = orderedVC.index(of: vc)!
        
        let nextIndex = index + 1
        
        guard nextIndex < orderedVC.count else {
            return nil
        }
        
        currentVC = orderedVC[nextIndex]
        return currentVC
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedVC.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return orderedVC.index(of: currentVC)!
    }
}

// MARK: - UIPageViewControllerDelegate
extension WeaponPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingVC = pendingViewControllers.first as? WeaponViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        previousVC = previousViewControllers.first as? WeaponViewController
        
        if completed {
            visibleVC = pendingVC
            
        } else {
            visibleVC = previousVC
        }
    }
}


// MARK: - RewardAdDelegate
extension WeaponPageViewController: RewardAdDelegate {
    
    func rewardAdd(didRewardUserWith with: GADAdReward) {
        mainVC.selectedWeaponType = visibleVC?.weaponType
        mainVC.dismiss(animated: true, completion: nil)
    }
}
