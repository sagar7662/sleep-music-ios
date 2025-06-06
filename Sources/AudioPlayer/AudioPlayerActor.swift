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

    func loadAudio(from url: URL) async throws -> TimeInterval {
        let data = try Data(contentsOf: url)
        player = try AVAudioPlayer(data: data)
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
}
