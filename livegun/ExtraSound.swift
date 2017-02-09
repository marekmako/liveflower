//
//  Sound.swift
//  livegun
//
//  Created by Marek Mako on 27/01/2017.
//  Copyright © 2017 Marek Mako. All rights reserved.
//

import UIKit
import AVFoundation

class ExtraSound {
    
    private var player: AVAudioPlayer?
    
    func playStart() {
        let soundName = ["start-sound1", "start-sound2", "start-sound3", "start-sound4", "start-sound5",]
        let randSoundNameIndex = Int(arc4random_uniform(UInt32(soundName.count)))
        
        player = try? AVAudioPlayer(data: NSDataAsset(name: soundName[randSoundNameIndex])!.data, fileTypeHint: AVFileTypeCoreAudioFormat)
        player?.play()
    }
    
    func playKill() {
        let soundName = ["kill-sound1", "kill-sound2", "kill-sound3", "kill-sound4"]
        let randSoundNameIndex = Int(arc4random_uniform(UInt32(soundName.count)))
        
        player = try? AVAudioPlayer(data: NSDataAsset(name: soundName[randSoundNameIndex])!.data, fileTypeHint: AVFileTypeCoreAudioFormat)
        player?.play()
    }
    
    func addKill() {
        player = try? AVAudioPlayer(data: NSDataAsset(name: "add-kill-sound")!.data, fileTypeHint: AVFileTypeCoreAudioFormat)
        player?.play()
    }
}
