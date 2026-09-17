import SwiftUI
import AVKit
import AVFoundation

// MARK: - Bouncy Button Style
public struct BouncyButtonStyle: ButtonStyle {
    public var scaleAmount: CGFloat = 0.94
    
    public init(scaleAmount: CGFloat = 0.94) {
        self.scaleAmount = scaleAmount
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Category Card Button
public struct CategoryCardButton: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    public let imageName: String
    public let title: String
    public let width: CGFloat
    public let videoName: String?
    public let action: () -> Void
    
    @State private var isAnimating: Bool = false
    @State private var player: AVPlayer? = nil
    
    public init(
        imageName: String,
        title: String,
        width: CGFloat,
        videoName: String? = nil,
        action: @escaping () -> Void
    ) {
        self.imageName = imageName
        self.title = title
        self.width = width
        self.videoName = videoName
        self.action = action
    }
    
    public var body: some View {
        Button(action: handleTap) {
            ZStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(AppTheme.cardAspectRatio, contentMode: .fit)
                
                if isAnimating, let player = player {
                    VideoOverlayView(player: player)
                        .aspectRatio(AppTheme.cardAspectRatio, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: width * 0.08, style: .continuous))
                        .scaleEffect(1.15)
                        .accessibilityHidden(true)
                        .transition(.opacity)
                }
            }
            .frame(width: width)
            .scaleEffect(isAnimating ? 1.045 : 1.0)
            .shadow(color: isAnimating ? Color.black.opacity(0.35) : Color.clear, radius: 12, y: 6)
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isAnimating)
        }
        .buttonStyle(BouncyButtonStyle())
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text("Opens \(title)"))
    }
    
    private func handleTap() {
        HapticManager.shared.buttonTap()
        
        // WCAG 2.1 Criterion 2.3.3: Immediately trigger without animation if reduced motion is preferred
        if reduceMotion || videoName == nil {
            action()
            return
        }
        
        // If already animating, double tap cancels delay and opens destination immediately
        if isAnimating {
            stopAnimation()
            action()
            return
        }
        
        // Setup & play video
        if let videoName = videoName {
            var targetURL: URL? = Bundle.main.url(forResource: videoName, withExtension: "mp4")
            #if SWIFT_PACKAGE
            if targetURL == nil {
                targetURL = Bundle.module.url(forResource: videoName, withExtension: "mp4")
            }
            #endif
            
            if let url = targetURL {
                let p = AVPlayer(url: url)
                p.isMuted = true
                self.player = p
                p.play()
            }
        }
        
        isAnimating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.58) {
            if isAnimating {
                action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                    stopAnimation()
                }
            }
        }
    }
    
    private func stopAnimation() {
        isAnimating = false
        player?.pause()
        player?.seek(to: .zero)
        player = nil
    }
}

// MARK: - Video Overlay View (Muted, without playback controls)
public struct VideoOverlayView: UIViewControllerRepresentable {
    public let player: AVPlayer
    
    public init(player: AVPlayer) {
        self.player = player
    }
    
    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        controller.view.backgroundColor = .clear
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}

// MARK: - Footer Pill Button
public struct FooterPillButton: View {
    public let imageName: String
    public let title: String
    public let width: CGFloat
    public let action: () -> Void
    
    public init(imageName: String, title: String, width: CGFloat, action: @escaping () -> Void) {
        self.imageName = imageName
        self.title = title
        self.width = width
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            Image(imageName)
                .resizable()
                .aspectRatio(AppTheme.footerAspectRatio, contentMode: .fit)
                .frame(width: width)
        }
        .buttonStyle(BouncyButtonStyle(scaleAmount: 0.92))
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text("Opens \(title) information"))
    }
}

// MARK: - Header Icon Button
public struct HeaderIconButton: View {
    public let imageName: String
    public let title: String
    public let size: CGFloat
    public let action: () -> Void
    
    public init(imageName: String, title: String, size: CGFloat, action: @escaping () -> Void) {
        self.imageName = imageName
        self.title = title
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            Image(imageName)
                .resizable()
                .aspectRatio(AppTheme.iconAspectRatio, contentMode: .fit)
                .frame(width: size, height: size)
        }
        .buttonStyle(BouncyButtonStyle(scaleAmount: 0.90))
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text("Activates \(title)"))
    }
}

// MARK: - Destination Detail Sheet
public struct DestinationDetailSheet: View {
    public let destination: HomeDestination
    @Environment(\.presentationMode) var presentationMode
    
    public init(destination: HomeDestination) {
        self.destination = destination
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                AppTheme.primaryPurple
                    .opacity(0.08)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Image(systemName: destination.iconName)
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(AppTheme.primaryPurple)
                        .padding(.top, 40)
                    
                    Text(destination.rawValue)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(AppTheme.primaryPurple)
                    
                    Text(destination.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                    
                    if destination == .about {
                        VStack(spacing: 16) {
                            Text("Generously Supported By")
                                .font(.headline)
                                .foregroundColor(AppTheme.darkPurple)
                            HStack(spacing: 20) {
                                Text("🎮 Child's Play")
                                    .font(.subheadline)
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                Text("☕ Dunkin' Joy in Childhood")
                                    .font(.subheadline)
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Back to Home")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppTheme.primaryPurple)
                            .cornerRadius(16)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitle(Text(destination.rawValue), displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
