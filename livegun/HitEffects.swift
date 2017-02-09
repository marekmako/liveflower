//
//  FaceEffects.swift
//  livegun
//
//  Created by Marek Mako on 22/01/2017.
//  Copyright © 2017 Marek Mako. All rights reserved.
//

import UIKit
import AVFoundation


class HitEffects {
    
    private var weapon: BaseWeapon!
    
    /// hlavny layer pouziva sa na krvave frkance
    let videoLayer: CALayer!
    
    let effectsLayer = CALayer()
    
    /// vyuziva sa na efekty na tvari
    let faceLayer: CALayer!
    
    private let laveOkoLayer: CALayer!
    
    private let praveOkoLayer: CALayer!
    
    private let ustaLayer: CALayer!

    private var krvaveFrkanceCollection = [KrvaveFrkance]()
    
    private var availableEffects: [BaseHitEffect.Type] = [
        LaveOko.self,
        LaveOkoFlak.self,
        Soplik.self,
        Usta.self,
        PraveOkoSlzy.self,
        PraveUchoCeruzka.self,
        CeloPot.self,
        HlavaZmrzka.self,
        Macko.self,

    ]
    
    private var effectsInUse = [BaseHitEffect]()
    
    init(weapon: BaseWeapon ,videoLayer: CALayer, faceLayer: CALayer, laveOkoLayer: CALayer, praveOkoLayer: CALayer, ustaLayer: CALayer) {
        self.weapon = weapon
        self.videoLayer = videoLayer
        self.videoLayer.addSublayer(effectsLayer)
        
        effectsLayer.frame = videoLayer.bounds
        
        self.faceLayer = faceLayer
        self.laveOkoLayer = laveOkoLayer
        self.praveOkoLayer = praveOkoLayer
        self.ustaLayer = ustaLayer
    }
    
    func onHit() {
        
        for _ in 0..<weapon.hitEffectsIndex {
            krvaveFrkanceCollection.append(KrvaveFrkance(parent: effectsLayer))
        }
        
        guard Int(arc4random_uniform(10)) < weapon.hitEffectsIndex else {
            return
        }
        
        guard !availableEffects.isEmpty else {
            return
        }
        let effectIndex = Int(arc4random_uniform(UInt32(availableEffects.count)))
        let effectType = availableEffects.remove(at: effectIndex)
        
        switch effectType {
        case is LaveOko.Type:
            effectsInUse.append((effectType as! LaveOko.Type).init(parent: effectsLayer, face: faceLayer, laveOko: laveOkoLayer))
            break
        case is LaveOkoFlak.Type:
            effectsInUse.append((effectType as! LaveOkoFlak.Type).init(parent: effectsLayer, face: faceLayer, laveOko: laveOkoLayer))
            break
        case is Soplik.Type:
            effectsInUse.append((effectType as! Soplik.Type).init(parent: effectsLayer, face: faceLayer, usta: ustaLayer))
            break
        case is Usta.Type:
            effectsInUse.append((effectType as! Usta.Type).init(parent: effectsLayer, face: faceLayer, usta: ustaLayer))
            break
        case is PraveOkoSlzy.Type:
            effectsInUse.append((effectType as! PraveOkoSlzy.Type).init(parent: effectsLayer, face: faceLayer, praveOko: praveOkoLayer))
        case is PraveUchoCeruzka.Type:
            effectsInUse.append((effectType as! PraveUchoCeruzka.Type).init(parent: effectsLayer, face: faceLayer, praveOko: praveOkoLayer))
        case is CeloPot.Type:
            effectsInUse.append((effectType as! CeloPot.Type).init(parent: effectsLayer, face: faceLayer))
            break
        case is HlavaZmrzka.Type:
            effectsInUse.append((effectType as! HlavaZmrzka.Type).init(parent: effectsLayer, face: faceLayer))
            break
        case is Macko.Type:
            effectsInUse.append((effectType as! Macko.Type).init(parent: effectsLayer, face: faceLayer))
            break
            
        default:
            #if DEBUG
                fatalError()
            #else
                return
            #endif
        }
    }
    
    func updateFrames() {
        for effect in effectsInUse {
            effect.updateLayerFrameAgainsParent()
        }
    }
    
    func hideFrames() {
        for effect in effectsInUse {
            effect.hideLayerFrame()
        }
    }
    
    func hideRandKrvaveFrkance() {
        let cnt = Int(arc4random_uniform(UInt32(krvaveFrkanceCollection.count)))
        for i in 0..<cnt {
            krvaveFrkanceCollection[i].layer.removeFromSuperlayer()
        }
        krvaveFrkanceCollection.removeFirst(cnt)
    }
}

fileprivate class BaseHitEffect {
    
    var audioPlayer: AVAudioPlayer?
    
    let layer = CALayer()
    
    let parentLayer: CALayer!
    
    var soundData: NSDataAsset?
    
    required init(parent parentLayer: CALayer) {
        layer.contentsGravity = kCAGravityResizeAspect
        
        self.parentLayer = parentLayer
        self.parentLayer.addSublayer(layer)
    }
    
    func updateLayerFrameAgainsParent() {}
    
    func hideLayerFrame() {}
    
    fileprivate func playSound() {
        guard soundData != nil else {
            return
        }
        try? audioPlayer = AVAudioPlayer(data: soundData!.data, fileTypeHint: AVFileTypeCoreAudioFormat)
        audioPlayer?.play()
    }
}

//MARK: - KrvaveFrkance
fileprivate class KrvaveFrkance : BaseHitEffect {
    
    let scaleAgainstParent = CGFloat(arc4random_uniform(6)) / 10
    
    required init(parent parentLayer: CALayer) {
        super.init(parent: parentLayer)
        
        layer.contents = BloodMode.shared.isBloodModeActive ? #imageLiteral(resourceName: "FE-krvave-frkance").cgImage : #imageLiteral(resourceName: "FE-krvave-frkance-modre").cgImage
        soundData = NSDataAsset(name: "FE-krvave-frkance-sound")
        
        updateLayerFrameAgainsParent()
//        playSound()
    }
    
    override func updateLayerFrameAgainsParent() {
        let size = CGSize(width: parentLayer.bounds.width * scaleAgainstParent,
                          height: parentLayer.bounds.height * scaleAgainstParent)
        
        let maxX = parentLayer.frame.maxX - size.width
        let maxY = parentLayer.frame.maxY - size.height
        let randX = CGFloat(arc4random_uniform(UInt32(maxX < 0 ? 0 : maxX)))
        let randY = CGFloat(arc4random_uniform(UInt32(maxY < 0 ? 0 : maxY)))
        
        layer.frame = CGRect(x: randX, y: randY, width: size.width, height: size.height)
    }
}

//MARK: - LaveOko
fileprivate class LaveOko: BaseHitEffect {
    
    let scaleAgainstParent: CGFloat = 0.2

    var faceLayer: CALayer!
    var okoLayer: CALayer!

    required convenience init(parent parentLayer: CALayer, face faceLayer: CALayer!, laveOko okoLayer: CALayer) {
        self.init(parent: parentLayer)
        self.faceLayer = faceLayer
        self.okoLayer = okoLayer
        updateLayerFrameAgainsParent()
    }

    required init(parent parentLayer: CALayer) {
        super.init(parent: parentLayer)

        layer.contents = #imageLiteral(resourceName: "FE-lave-oko").cgImage
        soundData = NSDataAsset(name: "FE-lave-oko-sound")

        playSound()
    }

    fileprivate override func updateLayerFrameAgainsParent() {
        let size = CGSize(width: faceLayer.bounds.width * scaleAgainstParent, height: faceLayer.bounds.height * scaleAgainstParent)

        layer.frame = CGRect(x: okoLayer.frame.minX - size.width / 2,
                             y: okoLayer.frame.minY - size.height / 2,
                             width: size.width,
                             height: size.height)
    }

    fileprivate override func hideLayerFrame() {
        layer.frame = CGRect(x: layer.frame.minX, y: layer.frame.minY, width: 0, height: 0)
    }
}

//MARK: - LaveOkoFlak
fileprivate class LaveOkoFlak: BaseHitEffect {

    let scaleAgainstParent: CGFloat = 0.3
    
    var faceLayer: CALayer!
    var okoLayer: CALayer!

    required convenience init(parent parentLayer: CALayer, face faceLayer: CALayer!, laveOko okoLayer: CALayer) {
        self.init(parent: parentLayer)
        self.faceLayer = faceLayer
        self.okoLayer = okoLayer
        updateLayerFrameAgainsParent()
    }

    required init(parent parentLayer: CALayer) {
        super.init(parent: parentLayer)

        layer.contents = #imageLiteral(resourceName: "FE-lave-oko-flak").cgImage
        soundData = NSDataAsset(name: "FE-lave-oko-flak-sound")

        playSound()
    }

    fileprivate override func updateLayerFrameAgainsParent() {
        let size = CGSize(width: faceLayer.bounds.width * scaleAgainstParent, height: faceLayer.bounds.height * scaleAgainstParent)

        layer.frame = CGRect(x: okoLayer.frame.minX - size.width / 2,
                             y: okoLayer.frame.maxY,
                             width: size.width,
                             height: size.height)
    }

    fileprivate override func hideLayerFrame() {
        layer.frame = CGRect(x: layer.frame.minX, y: layer.frame.minY, width: 0, height: 0)
    }
}

//MARK: - Soplik
fileprivate class Soplik: BaseHitEffect {

    let scaleAgainstParent: CGFloat = 0.4

    var faceLayer: CALayer!
    var ustaLayer: CALayer!

    required convenience init(parent parentLayer: CALayer, face faceLayer: CALayer!, usta ustaLayer: CALayer) {
        self.init(parent: parentLayer)
        self.faceLayer = faceLayer
        self.ustaLayer = ustaLayer
        updateLayerFrameAgainsParent()
    }

    required init(parent parentLayer: CALayer) {
        super.init(parent: parentLayer)

        layer.contents = #imageLiteral(resourceName: "FE-soplik").cgImage

        soundData = NSDataAsset(name: "FE-soplik-sound")

        playSound()
    }

    fileprivate override func updateLayerFrameAgainsParent() {
        let size = CGSize(width: faceLayer.bounds.width * scaleAgainstParent, height: faceLayer.bounds.height * scaleAgainstParent)

        layer.frame = CGRect(x: ustaLayer.frame.minX - size.width / 2,
                             y: ustaLayer.frame.maxY - size.height / 2,
                             width: size.width,
                             height: size.height)
    }

    fileprivate override func hideLayerFrame() {
        layer.frame = CGRect(x: layer.frame.minX, y: layer.frame.minY, width: 0, height: 0)
    }
}

//MARK: - Usta
fileprivate class Usta: BaseHitEffect {
    
    let scaleAgainstParent: CGFloat = 0.4
    
    var faceLayer: CALayer!
    var ustaLayer: CALayer!
    
    required convenience init(parent parentLayer: CALayer, face faceLayer: CALayer!, usta ustaLayer: CALayer) {
        self.init(parent: parentLayer)
        self.faceLayer = faceLayer
        self.ustaLayer = ustaLayer
        updateLayerFrameAgainsParent()
    }
    
    required init(parent parentLayer: CALayer) {
        super.init(parent: parentLayer)
        
        layer.contents = #imageLiteral(resourceName: "FE-usta").cgImage
        
        soundData = NSDataAsset(name: "FE-usta-sound")
        
        playSound()
    }
    
    fileprivate override func updateLayerFrameAgainsParent() {
        let size = CGSize(width: faceLayer.bounds.width * scaleAgainstParent, height: faceLayer.bounds.height * scaleAgainstParent)
        
        layer.frame = CGRect(x: ustaLayer.frame.minX - size.width / 2,
                             y: ustaLayer.frame.minY - size.height / 3,
                             width: size.width,
                             height: size.height)
    }
    
    fileprivate override func hideLayerFrame() {
        layer.frame = CGRect(x: layer.frame.minX, y: layer.frame.minY, width: 0, height: 0)
    }
}

//MARK: - PraveOkoSlzy
fileprivate class PraveOkoSlzy: BaseHitEffect {

    let scaleAgainstParent: CGFloat = 0.4

    var faceLayer: CALayer!
    var okoLayer: CALayer!

    required convenience init(parent parentLayer: CALayer, face faceLayer: CALayer!, praveOko okoLayer: CALayer) {
        self.init(parent: parentLayer)
        self.faceLayer = faceLayer
        self.okoLayer = okoLayer
        updateLayerFrameAgainsParent()
    }

    required init(parent parentLayer: CALayer) {
        super.init(parent: parentLayer)

        layer.contents = #imageLiteral(resourceName: "FE-prave-oko-slzy").cgImage
        soundData = NSDataAsset(name: "FE-prave-oko-slzy-sound")

        playSound()
    }

    fileprivate override func updateLayerFrameAgainsParent() {
        let size = CGSize(width: faceLayer.bounds.width * scaleAgainstParent, height: faceLayer.bounds.height * scaleAgainstParent)

        layer.frame = CGRect(x: okoLayer.frame.minX - size.width / 4,
                             y: okoLayer.frame.maxY,
                             width: size.width,
                             height: size.height)
    }

    fileprivate override func hideLayerFrame() {
        layer.frame = CGRect(x: layer.frame.minX, y: layer.frame.minY, width: 0, height: 0)
    }
}

//MARK: - PraveUchoCeruzka
fileprivate class PraveUchoCeruzka: BaseHitEffect {
    
    let scaleAgainstParent: CGFloat = 0.4
    
    var faceLayer: CALayer!
    var okoLayer: CALayer!
    
    required convenience init(parent parentLayer: CALayer, face faceLayer: CALayer!, praveOko okoLayer: CALayer) {
        self.init(parent: parentLayer)
        self.faceLayer = faceLayer
        self.okoLayer = okoLayer
        updateLayerFrameAgainsParent()
    }
    
    required init(parent parentLayer: CALayer) {
        super.init(parent: parentLayer)
        
        layer.contents = #imageLiteral(resourceName: "FE-prave-ucho-ceruzka").cgImage
        soundData = NSDataAsset(name: "FE-prave-ucho-ceruzka-sound")
        
        playSound()
    }
    
    fileprivate override func updateLayerFrameAgainsParent() {
        let size = CGSize(width: faceLayer.bounds.width * scaleAgainstParent, height: faceLayer.bounds.height * scaleAgainstParent)
        
        layer.frame = CGRect(x: okoLayer.frame.maxX + size.width / 5,
                             y: okoLayer.frame.maxY,
                             width: size.width,
                             height: size.height)
    }
    
    fileprivate override func hideLayerFrame() {
        layer.frame = CGRect(x: layer.frame.minX, y: layer.frame.minY, width: 0, height: 0)
    }
}

//MARK: - CeloPot
fileprivate class CeloPot: BaseHitEffect {

    let scaleAgainstParent: CGFloat = 0.5

    var faceLayer: CALayer!

    required convenience init(parent parentLayer: CALayer, face faceLayer: CALayer!) {
        self.init(parent: parentLayer)
        self.faceLayer = faceLayer
        updateLayerFrameAgainsParent()
    }

    required init(parent parentLayer: CALayer) {
        super.init(parent: parentLayer)

        layer.contents = #imageLiteral(resourceName: "FE-celo-pot").cgImage
        soundData = NSDataAsset(name: "FE-celo-pot-sound")

        playSound()
    }

    override func updateLayerFrameAgainsParent() {
        let size = CGSize(width: faceLayer.bounds.width * scaleAgainstParent,
                          height: faceLayer.bounds.height * scaleAgainstParent)

        layer.frame = CGRect(x: faceLayer.frame.midX - size.width / 2,
                             y: faceLayer.frame.minY,
                             width: size.width,
                             height: size.height)
    }

    override func hideLayerFrame() {
        layer.frame = CGRect(x: layer.frame.minX, y: layer.frame.minY, width: 0, height: 0)
    }
}

//MARK: - HlavaZmrzka
fileprivate class HlavaZmrzka: BaseHitEffect {

    let scaleAgainstParent: CGFloat = 0.8

    var faceLayer: CALayer!

    required convenience init(parent parentLayer: CALayer, face faceLayer: CALayer!) {
        self.init(parent: parentLayer)
        self.faceLayer = faceLayer
        updateLayerFrameAgainsParent()
    }

    required init(parent parentLayer: CALayer) {
        super.init(parent: parentLayer)

        layer.contents = #imageLiteral(resourceName: "FE-hlava-zmrzka").cgImage
        soundData = NSDataAsset(name: "FE-hlava-zmrzka-sound")

        playSound()
    }

    override func updateLayerFrameAgainsParent() {
        let size = CGSize(width: faceLayer.bounds.width * scaleAgainstParent,
                          height: faceLayer.bounds.height * scaleAgainstParent)

        layer.frame = CGRect(x: faceLayer.frame.midX - size.width / 2,
                             y: faceLayer.frame.minY - size.height / 2,
                             width: size.width,
                             height: size.height)
    }

    override func hideLayerFrame() {
        layer.frame = CGRect(x: layer.frame.minX, y: layer.frame.minY, width: 0, height: 0)
    }
}

fileprivate class Macko: BaseHitEffect {

    let scaleAgainstParent: CGFloat = 0.3

    var faceLayer: CALayer!

    required convenience init(parent parentLayer: CALayer, face faceLayer: CALayer!) {
        self.init(parent: parentLayer)
        self.faceLayer = faceLayer
        updateLayerFrameAgainsParent()
    }

    required init(parent parentLayer: CALayer) {
        super.init(parent: parentLayer)

        layer.contents = #imageLiteral(resourceName: "FE-macko").cgImage
        soundData = NSDataAsset(name: "FE-macko-sound")

        playSound()
    }

    override func updateLayerFrameAgainsParent() {
        let size = CGSize(width: faceLayer.bounds.width * scaleAgainstParent,
                          height: faceLayer.bounds.height * scaleAgainstParent)

        layer.frame = CGRect(x: faceLayer.frame.maxX - size.width,
                             y: faceLayer.frame.maxY - size.height,
                             width: size.width,
                             height: size.height)
    }

    override func hideLayerFrame() {
        layer.frame = CGRect(x: layer.frame.minX, y: layer.frame.minY, width: 0, height: 0)
    }
}
