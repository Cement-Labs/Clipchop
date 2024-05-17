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
        if hasSound {
            SoundPlayer.playSound(named: assetName)
        }
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
                return .defaultSound
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
    static var defaultSound: Sound {
        pop
    }
    
    static var currentSound: Sound {
        Defaults[.sound]
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
    
    static func setSound(to sound: Sound) {
        print("Sound set to: \(sound.assetName)")
        Defaults[.sound] = sound
        sound.play()
    }
}
