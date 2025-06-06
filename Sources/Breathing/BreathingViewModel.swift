//
//  ViewModel.swift
//  Health Lifestyle
//
//  Created by Sagar on 06/06/25.
//

import SwiftUI
import AVFoundation

@MainActor
public class BreathingViewModel: ObservableObject {
    @Published public var currentStepIndex: Int = 0
    @Published public var timerValue: Int = 0
    @Published public var scale: CGFloat = 1.0
    @Published public var countdown: Int = 3
    @Published public var isPaused = false
    
    private let timerManager: BreathingTimerManager
    private var timer: Timer?
    
    private var backgroundPlayer: AVAudioPlayer?
    private var phasePlayer: AVAudioPlayer?
    
    public init(steps: [BreathingStep]) {
        self.timerManager = BreathingTimerManager(steps: steps)
    }
    
    public func startCountdown() {
        countdown = 3
        Task { @MainActor in
            while countdown > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                countdown -= 1
            }
            await startBreathing()
        }
    }

    
    private func startBreathing() async {
        await timerManager.start()
        await updateStateFromManager()
        playBackgroundMusic()
        advanceStepAnimationAndAudio()
        startTimerLoop()
    }
    
    public func stop() {
        timer?.invalidate()
        backgroundPlayer?.stop()
        phasePlayer?.stop()
    }
    
    private func startTimerLoop() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task {
                await self?.timerTick()
            }
        }
    }
    
    private func timerTick() async {
        guard !isPaused else { return }
        
        await timerManager.decrementTimer()
        await updateStateFromManager()
        
        let isZero = await timerManager.isTimerZero()
        if isZero {
            await timerManager.advanceStep()
            await updateStateFromManager()
            advanceStepAnimationAndAudio()
        }
    }
    
    private func updateStateFromManager() async {
        let step = await timerManager.getCurrentStep()
        let index = await timerManager.currentStepIndex
        let time = await timerManager.timerValue
        
        await MainActor.run {
            self.currentStepIndex = index
            self.timerValue = time
            
            switch step.phase {
            case .inhale:
                self.scale = 1.5
            case .hold:
                self.scale = 1.0
            case .exhale:
                self.scale = 0.7
            }
        }
    }
    
    private func advanceStepAnimationAndAudio() {
        Task {
            let step = await timerManager.getCurrentStep()
            playPhaseAudio(for: step.phase)
        }
    }
    
    private func playBackgroundMusic() {
        guard let url = Bundle.module.url(forResource: "background", withExtension: "mp3") else { return }
        backgroundPlayer = try? AVAudioPlayer(contentsOf: url)
        backgroundPlayer?.numberOfLoops = -1
        backgroundPlayer?.play()
    }
    
    private func playPhaseAudio(for phase: BreathingPhase) {
        guard let url = Bundle.module.url(forResource: phase.audioFileName, withExtension: "mp3") else { return }
        phasePlayer = try? AVAudioPlayer(contentsOf: url)
        phasePlayer?.play()
    }
}
