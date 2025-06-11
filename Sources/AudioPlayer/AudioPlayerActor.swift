//
//  AudioPlayerActor.swift
//  Health Lifestyle
//
//  Created by Sagar on 01/06/25.
//

import Foundation
import AVFoundation

actor AudioPlayerActor {
    private var player: AVAudioPlayer?

    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    func loadAudio(from url: URL) async throws -> TimeInterval {
        if AVAudioSession.sharedInstance().category != .playback {
            configureAudioSession()
        }
        let data = try Data(contentsOf: url)
        player = try AVAudioPlayer(data: data)
        player?.prepareToPlay()
        return player?.duration ?? 0
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func seek(to time: TimeInterval) {
        player?.currentTime = time
    }

    func currentTime() -> TimeInterval {
        return player?.currentTime ?? 0
    }
    
    func isPlaying() -> Bool {
        return player?.isPlaying ?? false
    }
}
