//
//  Weapons.swift
//  livegun
//
//  Created by Marek Mako on 24/01/2017.
//  Copyright © 2017 Marek Mako. All rights reserved.
//

import UIKit
import AVFoundation


//MARK: - CACTUS
class CactusType: BaseWeaponType {

    required init() {
        super.init()
        name = "Cactus"
        classType = Cactus.self
        demage = 70
        image = #imageLiteral(resourceName: "cactus")
        requiredKillsForFree = 100
    }
}
class Cactus: BaseWeapon {
    
    required init(gunLayer: CALayer, shootLayer: CALayer) {
        super.init(gunLayer: gunLayer, shootLayer: shootLayer)
        
        gunImage = #imageLiteral(resourceName: "cactus-anime1").cgImage
        soundName = "sound-cactus"
        gunAnimation.values = [
            #imageLiteral(resourceName: "cactus-anime2").cgImage!,
            #imageLiteral(resourceName: "cactus-anime3").cgImage!,
        ]
        lifeDemage = 0.7
        hitEffectsIndex = 9
        setupGun()
    }
}

//MARK: - CANDY
class CandyType: BaseWeaponType {
    
    required init() {
        super.init()
        name = "Sweet Box"
        classType = Candy.self
        demage = 35
        image = #imageLiteral(resourceName: "chocolate")
        requiredKillsForFree = 75
    }
}
class Candy: BaseWeapon {
    
    required init(gunLayer: CALayer, shootLayer: CALayer) {
        super.init(gunLayer: gunLayer, shootLayer: shootLayer)
        
        gunImage = #imageLiteral(resourceName: "candy-anime1").cgImage
        soundName = "sound-candy"
        gunAnimation.values = [
            #imageLiteral(resourceName: "candy-anime2").cgImage!,
            #imageLiteral(resourceName: "candy-anime3").cgImage!,
        ]
        lifeDemage = 0.35
        hitEffectsIndex = 7
        setupGun()
    }
}


//MARK: - SUNFLOWER
class SunflowerType: BaseWeaponType {
    
    required init() {
        super.init()
        name = "Sunflower"
        classType = Sunflower.self
        demage = 80
        image = #imageLiteral(resourceName: "sunflower")
        requiredKillsForFree = 150
    }
}
class Sunflower: BaseWeapon {
    
    required init(gunLayer: CALayer, shootLayer: CALayer) {
        super.init(gunLayer: gunLayer, shootLayer: shootLayer)
        
        gunImage = #imageLiteral(resourceName: "sunflower-anime1").cgImage
        soundName = "sound-flower"
        gunAnimation.values = [
            #imageLiteral(resourceName: "sunflower-anime2").cgImage!,
            #imageLiteral(resourceName: "sunflower-anime3").cgImage!,
        ]
        lifeDemage = 0.8
        hitEffectsIndex = 9
        setupGun()
    }
}

//MARK: - BLUE ROSE
class BlueRoseType: BaseWeaponType {
    
    required init() {
        super.init()
        name = "Blue Rose"
        classType = BlueRose.self
        demage = 55
        image = #imageLiteral(resourceName: "bluerose")
        requiredKillsForFree = 25
    }
}
class BlueRose: BaseWeapon {
    
    required init(gunLayer: CALayer, shootLayer: CALayer) {
        super.init(gunLayer: gunLayer, shootLayer: shootLayer)
        
        gunImage = #imageLiteral(resourceName: "bluerose-anime1").cgImage
        soundName = "sound-flower"
        gunAnimation.values = [
            #imageLiteral(resourceName: "bluerose-anime2").cgImage!,
            #imageLiteral(resourceName: "bluerose-anime3").cgImage!,
        ]
        lifeDemage = 0.5
        hitEffectsIndex = 6
        setupGun()
    }
}

//MARK: - ORCHID
class OrchidType: BaseWeaponType {
    
    required init() {
        super.init()
        
        name = "Orchid"
        classType = Orchid.self
        demage = 10
        image = #imageLiteral(resourceName: "orchid")
        requiredKillsForFree = 10
    }
}

class Orchid: BaseWeapon {
    
    required init(gunLayer: CALayer, shootLayer: CALayer) {
        super.init(gunLayer: gunLayer, shootLayer: shootLayer)
        
        gunImage = #imageLiteral(resourceName: "orchid-anime1").cgImage
        soundName = "sound-flower"
        gunAnimation.values = [
            #imageLiteral(resourceName: "orchid-anime2").cgImage!,
            #imageLiteral(resourceName: "orchid-anime3").cgImage!,
        ]
        lifeDemage = 0.1
        setupGun()
    }
}


//MARK: - BEAR
class BearType: BaseWeaponType {
    
    required init() {
        super.init()
        
        name = "Teddy Bear"
        classType = Bear.self
        demage = 30
        image = #imageLiteral(resourceName: "bear")
    }
}
class Bear: BaseWeapon {
    
    required init(gunLayer: CALayer, shootLayer: CALayer) {
        super.init(gunLayer: gunLayer, shootLayer: shootLayer)
        
        gunImage = #imageLiteral(resourceName: "macik-anime1").cgImage
        soundName = "sound-bear"
        gunAnimation.values = [
            #imageLiteral(resourceName: "macik-anime2").cgImage!,
            #imageLiteral(resourceName: "macik-anime3").cgImage!,
        ]
        lifeDemage = 0.3
        hitEffectsIndex = 5
        setupGun()
    }
}

// MARK: - RED ROSE
class RedRoseType: BaseWeaponType {
    
    required init() {
        super.init()
        
        name = "Red Rose"
        classType = RedRose.self
        demage = 5
        image = #imageLiteral(resourceName: "redrose")
    }
}
class RedRose: BaseWeapon {
    
    required init(gunLayer: CALayer, shootLayer: CALayer) {
        super.init(gunLayer: gunLayer, shootLayer: shootLayer)
        
        gunImage = #imageLiteral(resourceName: "redrose-anime1").cgImage
        soundName = "sound-flower"
        
        gunAnimation.values = [
            #imageLiteral(resourceName: "redrose-anime2").cgImage!,
            #imageLiteral(resourceName: "redrose-anime3").cgImage!
        ]
        
        lifeDemage = 0.05
        hitEffectsIndex = 2
        setupGun()
    }
}



// MARK: - BaseWeapon
class BaseWeaponType {
    
    var name = "Some Weapon"
    
    var classType: BaseWeapon.Type?
    
    var demage: Int?
    
    var image: UIImage?
    
    var requiredKillsForFree = 0
    
    required init() {}
}
class BaseWeapon {
    
    var lifeDemage: Float = 0.05
    
    /// overide z child class
    var gunImage: CGImage?
    
    var audioPlayer: AVAudioPlayer?
    
    var soundName: String?
    
    /// pripraveny na 5 obrazkov
    var shootAnimation = CAKeyframeAnimation(keyPath: "contents")
    
    /// pripraveny na 2 obrazky
    var gunAnimation = CAKeyframeAnimation(keyPath: "contents")
    
    let gunLayer: CALayer
    
    let shootLayer: CALayer
    
    /// cim vacsie cislo tym vacsia pravdepodobnost efektu po zasahu
    var hitEffectsIndex = 3
    
    required init(gunLayer: CALayer, shootLayer: CALayer) {
        self.gunLayer = gunLayer
        self.shootLayer = shootLayer
        
        setupShootAnimation()
        setupGunAnimation()
        
    }
    
    func setupGun() {
        gunLayer.contents = gunImage
    }
    
    private func setupShootAnimation() {
        shootAnimation.calculationMode = kCAAnimationDiscrete
        shootAnimation.duration = 0.3
        shootAnimation.keyTimes = [0, 0.22, 0.58, 0.84, 1]
        shootAnimation.isAdditive = true
        shootAnimation.values = [
            #imageLiteral(resourceName: "shot1").cgImage!,
            #imageLiteral(resourceName: "shot2").cgImage!,
            #imageLiteral(resourceName: "shot3").cgImage!,
            #imageLiteral(resourceName: "shot4").cgImage!,
            #imageLiteral(resourceName: "shot5").cgImage!
        ]
    }
    
    private func setupGunAnimation() {
        gunAnimation.calculationMode = kCAAnimationDiscrete
        gunAnimation.isAdditive = true
        gunAnimation.duration = 0.3
        gunAnimation.keyTimes = [0, 0.5, 1]
    }
    
    func onShoot() {
        playAudio()
        gunLayer.add(gunAnimation, forKey: nil)
//        shootLayer.add(shootAnimation, forKey: nil)
    }
    
    private func playAudio() {
        guard soundName != nil else {
            return
        }
        audioPlayer = try? AVAudioPlayer(data: NSDataAsset(name: soundName!)!.data, fileTypeHint: AVFileTypeCoreAudioFormat)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
}


