import SwiftUI
import SDWebImageSwiftUI

public struct BreathingView: View {
    private let steps: [BreathingStep]
    private let rectangleColor: Color
    private let backgroundImageURL: URL?
    private let title: String
    private let subTitle: String

    public var onClose: (() -> Void)?
    
    @StateObject private var viewModel: BreathingViewModel
    
    @State private var safeAreaTop: CGFloat = 0
    @State private var showDurationSheet = false
    @State private var selectedDuration: TimeInterval = 0
    
    public init(
        steps: [BreathingStep],
        rectangleColorHex: String,
        backgroundImageURL: URL?,
        title: String,
        subTitle: String,
        onClose: (() -> Void)? = nil
    ) {
        self.steps = steps
        self.rectangleColor = Color(hex: rectangleColorHex)
        self.backgroundImageURL = backgroundImageURL
        self.title = title
        self.subTitle = subTitle
        self.onClose = onClose
        _viewModel = StateObject(wrappedValue: BreathingViewModel(steps: steps))
    }
    
    public var body: some View {
        ZStack {
            // MARK: Background Image
            WebImage(url: backgroundImageURL)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height)
                .clipped()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.3))
            
            VStack(spacing: 8) {
                // MARK: Top Bar
                HStack {
                    Button(action: {
                        onClose?()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.leading)
                    }
                    Spacer()
                }
                .padding(.top, safeAreaTop)
                .padding(.horizontal, 16)

                // MARK: Title and Description
                VStack(spacing: 8) {
                    Text(title)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(dynamicPhrase())
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)

                    // Placeholder or subtitle
                    Text(subTitle)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 24)
                }
                .padding(.horizontal, 16)

                Spacer()

                // MARK: Breathing Animation
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(rectangleColor, lineWidth: 5)
                        .frame(width: 200, height: 200)

                    RoundedRectangle(cornerRadius: 16)
                        .fill(rectangleColor.opacity(0.2))
                        .frame(width: 180, height: 180)
                        .scaleEffect(viewModel.scale)
                        .animation(viewModel.isPaused ? nil : .easeInOut(duration: Double(steps[viewModel.currentStepIndex].duration)), value: viewModel.scale)

                    VStack {
                        if viewModel.countdown > 0 {
                            Text("\(viewModel.countdown)")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(viewModel.timerValue)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)

                            Text(steps[viewModel.currentStepIndex].phase.rawValue)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            Button(action: {
                                viewModel.togglePlayPause()
                            }) {
                                Image(systemName: viewModel.isPaused ? "play.circle.fill" : "pause.circle.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)
                            }
                        }
                    }
                }

                Spacer()
                
                // MARK: Controls
                HStack(spacing: 16) {
                    Button(action: {
                        showDurationSheet = true
                    }) {
                        HStack {
                            Image(systemName: "clock")
                            Text("\(formatTime(selectedDuration))")
                        }
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .padding(8)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(10)
                    }
                }
                .padding(.top, 32)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                safeAreaTop = window.safeAreaInsets.top
            }
            viewModel.startCountdown()
        }
        .onDisappear {
            viewModel.stop()
        }
        .sheet(isPresented: $showDurationSheet, onDismiss: {
            viewModel.playbackLimit = selectedDuration > 0 ? selectedDuration : nil
            viewModel.startCountdown()
        }) {
            if #available(iOS 16.0, *) {
                DurationPickerSheet(
                    isPresented: $showDurationSheet,
                    selectedDuration: $selectedDuration,
                    durations: [120, 300, 600, 900, 1200, 1800, 3600]
                )
                .presentationDetents([.height(200)])
            } else {
                DurationPickerSheet(
                    isPresented: $showDurationSheet,
                    selectedDuration: $selectedDuration,
                    durations: [120, 300, 600, 900, 1200, 1800, 3600]
                )
            }
        }
    }
    
    private func dynamicPhrase() -> String {
        steps.map { "\($0.phase.rawValue.capitalized) (\($0.duration)s)" }.joined(separator: " > ")
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        if minutes == 0 && seconds == 0 {
            return "Set duration"
        } else {
            return String(format: "Set duration: %02d:%02d", minutes, seconds)
        }
    }
}
