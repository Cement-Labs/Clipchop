//
//  Sound.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults

struct Sound: Hashable, Defaults.Serializable {
    var hasSound: Bool = true
    var name: String?
    var assetName: String
    var unlockThreshold: Int
    
    func play() {
        Self.play(sound: self)
    }
    
    func setClipSound() {
        print("setClipSound")
        Self.setClipSound(to: self)
    }
    
    func setPasteSound() {
        print("setPasteSound")
        Self.setPasteSound(to: self)
    }
    
    struct Bridge: Defaults.Bridge {
        typealias Value = Sound
        typealias Serializable = String
        
        func serialize(_ value: Sound?) -> String? {
            value?.assetName
        }
        
        func deserialize(_ object: String?) -> Sound? {
            if let object {
                return .sounds.first { $0.assetName == object }
            } else {
                return .pop
            }
        }
    }
    
    static let bridge = Bridge()
}

extension Sound {
    static let none = Sound(
        hasSound: false,
        name: .init(localized: "Sound: None", defaultValue: "None"),
        assetName: "",
        unlockThreshold: 0
    )
    
    static let pop = Sound(
        name: .init(localized: "Sound: Pop", defaultValue: "Pop"),
        assetName: "happy-pop",
        unlockThreshold: 0
    )
    
    static let bloop = Sound(
        name: .init(localized: "Sound: Bloop", defaultValue: "Bloop"),
        assetName: "marimba-bloop",
        unlockThreshold: 0
    )
    
    static let tap = Sound(
        name: .init(localized: "Sound: Tap", defaultValue: "Tap"),
        assetName: "tap-notification",
        unlockThreshold: 25
    )
}

extension Sound {
    static var defaultClipSound: Sound {
        pop
    }
    static var defaultPasteSound: Sound {
        bloop
    }
    
    static var clipSound: Sound {
        Defaults[.clipSound]
    }
    static var pasteSound: Sound {
        Defaults[.pasteSound]
    }
    
    static let sounds: [Sound] = [
        none,
        pop,
        bloop,
        tap
    ]
}
    
extension Sound {
    static var unlockedSounds: [Sound] {
        var returnValue: [Sound] = []
        for sound in sounds where sound.unlockThreshold <= Defaults[.timesClipped] {
            returnValue.append(sound)
        }
        return returnValue.reversed()
    }
    
    static func play(sound: Sound) {
        if sound.hasSound {
            SoundPlayer.playSound(named: sound.assetName, volume: Defaults[.volume])
        }
    }
    
    static func setClipSound(to sound: Sound) {
        log(self, "Clip sound set to: \(sound.assetName)")
        Defaults[.clipSound] = sound
    }
    
    static func setPasteSound(to sound: Sound) {
        log(self, "Paste sound set to: \(sound.assetName)")
        Defaults[.pasteSound] = sound
    }
}
