//
//  SoundPlayer.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import AVFAudio

class SoundPlayer: Identifiable{
    private static var audioPlayer: AVAudioPlayer?
    
    static func playSound(named assetName: String) {
        if let soundURL = Bundle.main.url(forResource: assetName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
                
                print("Audio played: \(assetName)")
            } catch {
                print("Unable to play audio: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found for \(assetName)!")
        }
    }
}
