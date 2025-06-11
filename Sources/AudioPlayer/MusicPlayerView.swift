import SwiftUI
import SDWebImageSwiftUI

public struct MusicPlayerView: View {
    @StateObject private var viewModel = MusicPlayerViewModel()
    
    let title: String
    let subtitle: String
    let imageUrl: URL?
    let audioUrl: URL?
    let onDismiss: (() -> Void)?
    
    public init(title: String, subtitle: String, imageUrl: URL?, audioUrl: URL?, onDismiss: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.audioUrl = audioUrl
        self.onDismiss = onDismiss
    }
    
    @State private var safeAreaTop: CGFloat = 0
    @State private var showDurationSheet = false
    @State private var selectedDuration: TimeInterval = 0
    
    public var body: some View {
        ZStack {
            // Background image fills whole screen
            WebImage(url: imageUrl)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height)
                .clipped()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.3))
            
            VStack(spacing: 16) {
                // Top header with manual safe area padding
                ZStack {
                    HStack {
                        Button(action: { onDismiss?() }) {
                            Image(systemName: "chevron.down")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.leading)
                        }
                        Spacer()
                    }
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.top, safeAreaTop)
                .padding(.leading, 8)
                
                Spacer()
                
                // Player content
                VStack(spacing: 16) {
                    Text(subtitle)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    Button(action: {
                        showDurationSheet = true
                    }) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.white)
                            Text("Set duration: \(formatTime(selectedDuration == 0 ? viewModel.duration : selectedDuration))")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(10)
                    }
                    
                    Slider(value: $viewModel.currentTime,
                           in: 0...(viewModel.duration > 0 ? viewModel.duration : 1),
                           onEditingChanged: { editing in
                        if !editing {
                            viewModel.seek(to: viewModel.currentTime)
                        }
                    })
                    .accentColor(.white)
                    
                    HStack {
                        Text(formatTime(viewModel.currentTime))
                        Spacer()
                        Text(formatTime(viewModel.duration))
                    }
                    .foregroundColor(.white)
                    .font(.caption)
                    
                    HStack(spacing: 40) {
                        Button {
                            viewModel.seek(to: max(viewModel.currentTime - 10, 0))
                        } label: {
                            Image(systemName: "gobackward.10")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        
                        Button {
                            viewModel.playPause()
                        } label: {
                            Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 50))
                        }
                        
                        Button {
                            viewModel.seek(to: min(viewModel.currentTime + 10, viewModel.duration))
                        } label: {
                            Image(systemName: "goforward.10")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
                .padding(.bottom, 30 + safeAreaTop)
            }
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                // Read safe area insets once on appear
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    safeAreaTop = window.safeAreaInsets.top
                }
            }
        }
        .onAppear {
            Task {
                guard let audioUrl else { return }
                await viewModel.loadAudio(from: audioUrl)
            }
        }
        .onDisappear {
            viewModel.stop()
        }
        .sheet(isPresented: $showDurationSheet, onDismiss: {
            // Sync the selected duration with the playback limit
            if selectedDuration > 0 {
                viewModel.playbackLimit = selectedDuration
            } else {
                viewModel.playbackLimit = nil
            }
        }) {
            if #available(iOS 16.0, *) {
                DurationPickerSheet(
                    isPresented: $showDurationSheet,
                    selectedDuration: $selectedDuration,
                    durations: [120, 300, 600, 900, 1200, 1800, 3600]
                )
                .presentationDetents([.height(200)])
            } else {
                // Fallback for iOS 15
                DurationPickerSheet(
                    isPresented: $showDurationSheet,
                    selectedDuration: $selectedDuration,
                    durations: [120, 300, 600, 900, 1200, 1800, 3600]
                )
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
