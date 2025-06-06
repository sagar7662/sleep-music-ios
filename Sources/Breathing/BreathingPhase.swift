public enum BreathingPhase: String, CaseIterable, Sendable {
    case inhale = "Inhale"
    case hold = "Hold"
    case exhale = "Exhale"

    public var duration: Int {
        switch self {
        case .inhale: return 4
        case .hold: return 7
        case .exhale: return 8
        }
    }

    public var audioFileName: String {
        self.rawValue
    }
}

public struct BreathingStep: Sendable {
    public let phase: BreathingPhase
    public let duration: Int
    
    public init(phase: BreathingPhase, duration: Int) {
        self.phase = phase
        self.duration = duration
    }
}

actor BreathingTimerManager {
    let steps: [BreathingStep]
    private(set) var currentStepIndex = 0
    private(set) var timerValue: Int = 0
    
    init(steps: [BreathingStep]) {
        self.steps = steps
    }
    
    func start() {
        currentStepIndex = 0
        timerValue = steps.first?.duration ?? 4
    }
    
    func advanceStep() {
        currentStepIndex += 1
        if currentStepIndex >= steps.count {
            currentStepIndex = 0
        }
        timerValue = steps[currentStepIndex].duration
    }
    
    func decrementTimer() {
        timerValue = max(timerValue - 1, 0)
    }
    
    func getCurrentStep() -> BreathingStep {
        steps[currentStepIndex]
    }
    
    func isTimerZero() -> Bool {
        timerValue <= 0
    }
}
