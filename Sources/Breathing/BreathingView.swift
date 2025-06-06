import SwiftUI
import SDWebImageSwiftUI

public struct BreathingView: View {
    private let steps: [BreathingStep]
    private let rectangleColor: Color
    private let backgroundImageURL: URL?
    private let title: String
    
    public var onClose: (() -> Void)?
    
    @StateObject private var viewModel: BreathingViewModel
    
    @State private var safeAreaTop: CGFloat = 0
    
    public init(
        steps: [BreathingStep],
        rectangleColorHex: String,
        backgroundImageURL: URL?,
        title: String,
        onClose: (() -> Void)? = nil
    ) {
        self.steps = steps
        self.rectangleColor = Color(hex: rectangleColorHex)
        self.backgroundImageURL = backgroundImageURL
        self.title = title
        self.onClose = onClose
        _viewModel = StateObject(wrappedValue: BreathingViewModel(steps: steps))
    }
    
    public var body: some View {
        ZStack {
            WebImage(url: backgroundImageURL)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height)
                .clipped()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.3))
            
            VStack(spacing: 16) {
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
                .padding(.leading, 8)
                
                Spacer()
            }
            
            VStack {
                VStack(spacing: 4) {
                    Text(title)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text(dynamicPhrase())
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 80)
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(rectangleColor, lineWidth: 5)
                        .frame(width: 180, height: 180)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(rectangleColor.opacity(0.2))
                        .frame(width: 160, height: 160)
                        .scaleEffect(viewModel.scale)
                        .animation(.easeInOut(duration: Double(steps[viewModel.currentStepIndex].duration)), value: viewModel.scale)
                    
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
                        }
                    }
                }
                
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
    }
    
    private func dynamicPhrase() -> String {
        steps.map { "\($0.phase.rawValue.capitalized) (\($0.duration)s)" }.joined(separator: " > ")
    }
}
