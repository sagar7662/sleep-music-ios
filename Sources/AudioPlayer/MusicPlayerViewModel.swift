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
    @Published public var playbackLimit: TimeInterval?

    private let playerActor = AudioPlayerActor()
    private var timer: Timer?
    private var cumulativePlayTime: TimeInterval = 0
    private var lastTimerTick: Date?

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
                playbackLimit = nil
            }
        }
        stopTimer()
        cumulativePlayTime = 0
        lastTimerTick = nil
    }


    public func seek(to time: TimeInterval) {
        Task {
            await playerActor.seek(to: time)
            currentTime = time
        }
    }

    private func startTimer() {
        Task { @MainActor in
            self.lastTimerTick = Date()
        }

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            Task {
                let now = Date()

                let _: TimeInterval = await MainActor.run {
                    let previous = self.lastTimerTick ?? now
                    let elapsed = now.timeIntervalSince(previous)
                    self.lastTimerTick = now
                    self.cumulativePlayTime += elapsed
                    return elapsed
                }

                let time = await self.playerActor.currentTime()
                let isPlaying = await self.playerActor.isPlaying()

                await MainActor.run {
                    self.currentTime = time

                    if let limit = self.playbackLimit, self.cumulativePlayTime >= limit {
                        self.stop()
                    } else if !isPlaying && self.cumulativePlayTime < (self.playbackLimit ?? .infinity) {
                        // Audio has finished — loop it
                        Task {
                            await self.playerActor.seek(to: 0)
                            await self.playerActor.play()
                        }
                    }
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
