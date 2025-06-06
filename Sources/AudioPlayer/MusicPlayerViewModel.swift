//
//  Untitled.swift
//  Health Lifestyle
//
//  Created by Sagar on 01/06/25.
//

import Foundation

@MainActor
final class MusicPlayerViewModel: ObservableObject {
    @Published public var duration: TimeInterval = 0
    @Published public var currentTime: TimeInterval = 0
    @Published public var isPlaying = false

    private let playerActor = AudioPlayerActor()
    private var timer: Timer?

    public init() {}

    public func loadAudio(from url: URL) async {
        do {
            duration = try await playerActor.loadAudio(from: url)
        } catch {
            print("Failed to load audio: \(error)")
        }
    }

    func playPause() {
        isPlaying.toggle()
        Task {
            if isPlaying {
                await playerActor.play()
                startTimer()
            } else {
                await playerActor.pause()
                stopTimer()
            }
        }
    }
    
    func stop() {
        Task {
            await playerActor.pause()
            await MainActor.run {
                isPlaying = false
            }
        }
        stopTimer()
    }

    public func seek(to time: TimeInterval) {
        Task {
            await playerActor.seek(to: time)
            currentTime = time
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            Task {
                let time = await self.playerActor.currentTime()
                await MainActor.run {
                    self.currentTime = time
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
