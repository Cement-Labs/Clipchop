//
//  SoundPlayer.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import AVFAudio

class SoundPlayer: Identifiable {
    private static var audioPlayer: AVAudioPlayer?
    
    static func playSound(named assetName: String) {
        if let soundURL = Bundle.main.url(forResource: assetName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
                
                log(self, "Audio played: \(assetName)")
            } catch {
                log(self, "Unable to play audio: \(error.localizedDescription)")
            }
        } else {
            log(self, "Audio file not found for \(assetName)!")
        }
    }
}
