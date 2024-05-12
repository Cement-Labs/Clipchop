//
//  Sounds.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults


class Sounds {
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
            
            func serialize(_ value: Sounds.Sound?) -> String? {
                value?.assetName
            }
            
            func deserialize(_ object: String?) -> Sounds.Sound? {
                if let object {
                    return Sounds.sounds.first { $0.assetName == object }
                } else {
                    return Sounds.defaultSound
                }
            }
        }
        
        static let bridge = Bridge()
    }
    
    static var defaultSound: Sound {
        sounds.first!
    }
    
    static var currentSound: Sound {
        Defaults[.sound]
    }
    
    static let sounds: [Sound] = [
        Sound(
            hasSound: false,
            name: .init(localized: .init("Sound: None", defaultValue: "None")),
            assetName: "",
            unlockThreshold: 0
        ),
        Sound(
            name: .init(localized: .init("Sound: Pop", defaultValue: "Pop")),
            assetName: "happy-pop",
            unlockThreshold: 0
        ),
        Sound(
            name: .init(localized: .init("Sound: Bloop", defaultValue: "Bloop")),
            assetName: "marimba-bloop",
            unlockThreshold: 0
        ),
        Sound(
            name: .init(localized: .init("Sound: Tap", defaultValue: "Tap")),
            assetName: "tap-notification",
            unlockThreshold: 25
        )
    ]
    
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
