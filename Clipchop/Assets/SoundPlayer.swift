//
//  SoundPlayer.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import AVFAudio

class SoundPlayer: Identifiable {
    private static var audioPlayer: AVAudioPlayer?
    static func playSound(named assetName: String, volume: Float = 1.0) {
        if let soundURL = Bundle.main.url(forResource: assetName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.volume = volume
                audioPlayer?.play()

                log(self, "Audio played: \(assetName) at volume: \(volume)")
            } catch {
                log(self, "Unable to play audio: \(error.localizedDescription)")
            }
        } else {
            log(self, "Audio file not found for \(assetName)!")
        }
    }

    static func setVolume(_ volume: Float) {
        guard let player = audioPlayer else {
            log(self, "Audio player not initialized.")
            return
        }
        player.volume = volume
        log(self, "Volume set to \(volume)")
    }
}
