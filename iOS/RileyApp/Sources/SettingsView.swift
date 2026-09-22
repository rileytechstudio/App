import SwiftUI

public struct SettingsView: View {
    public var onBack: () -> Void
    public var onHomeTapped: () -> Void
    public var onAboutTapped: (() -> Void)? = nil
    
    @AppStorage("riley_voice_assistant") private var voiceAssistantEnabled: Bool = false
    @AppStorage("riley_haptics") private var hapticsEnabled: Bool = true
    @AppStorage("riley_sound_effects") private var soundEffectsEnabled: Bool = true
    
    // Background scroll offset animation state
    @State private var patternOffset: CGPoint = .zero
    
    public init(
        onBack: @escaping () -> Void,
        onHomeTapped: @escaping () -> Void,
        onAboutTapped: (() -> Void)? = nil
    ) {
        self.onBack = onBack
        self.onHomeTapped = onHomeTapped
        self.onAboutTapped = onAboutTapped
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height
            
            VStack(spacing: 0) {
                // Top Apple Glass Navigation Bar (Matching About Header Style)
                headerView(isLandscape: isLandscape)
                
                // Settings Body with Animated Repeating Gear Background
                ZStack {
                    // Background Color Layer
                    AppTheme.primaryPurple
                        .ignoresSafeArea()
                    
                    // Animated Scrolling Gear Background Pattern
                    scrollingPatternLayer(size: proxy.size)
                    
                    // Settings Windows Scroll View
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            Spacer(minLength: 16)
                            
                            // Card 1: Voice Assistant
                            settingsCard(
                                titleImageName: "SettingsTitleVoiceAssistant",
                                fallbackTitle: "VOICE ASSISTANT",
                                description: "Read text and descriptions out loud automatically",
                                isOn: $voiceAssistantEnabled
                            )
                            
                            // Card 2: Haptics
                            settingsCard(
                                titleImageName: "SettingsTitleHaptics",
                                fallbackTitle: "HAPTICS",
                                description: "Vibrations & taps when pressing buttons",
                                isOn: $hapticsEnabled
                            ) { newValue in
                                if newValue {
                                    HapticManager.shared.lightTap()
                                }
                            }
                            
                            // Card 3: Sound Effects (Replacing Language)
                            settingsCard(
                                titleImageName: "SettingsTitleSoundEffects",
                                fallbackTitle: "SOUND EFFECTS",
                                description: "Play sound effects and audio feedback throughout the app",
                                isOn: $soundEffectsEnabled
                            ) { _ in
                                if hapticsEnabled {
                                    HapticManager.shared.buttonTap()
                                }
                            }
                            
                            Spacer(minLength: 32)
                        }
                        .padding(.horizontal, isLandscape ? 48 : 24)
                        .frame(maxWidth: 860)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                startSlowBackgroundScroll()
            }
        }
    }
    
    // MARK: - Header
    private func headerView(isLandscape: Bool) -> some View {
        HStack(spacing: 12) {
            // Left: Back button & Title
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "1e293b"))
                        .frame(width: 42, height: 42)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "e2e8f0"), lineWidth: 1.5)
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                }
                
                Text("Settings")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(hex: "1e293b"))
            }
            
            Spacer()
            
            // Right: Home button
            HStack(spacing: 12) {
                Button(action: onHomeTapped) {
                    if let uiImg = UIImage(named: "AboutHomeButton") ?? UIImage(named: "IconHome") {
                        Image(uiImage: uiImg)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 42, height: 42)
                    } else {
                        Image(systemName: "house.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background(AppTheme.primaryPurple)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: isLandscape ? 58 : 54)
        .background(
            ZStack {
                Color.white.opacity(0.82)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.35),
                        Color.white.opacity(0.08),
                        Color.black.opacity(0.02)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .overlay(
            VStack {
                Spacer()
                Divider()
                    .background(Color.white.opacity(0.65))
            }
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        .zIndex(10)
    }
    
    // MARK: - Animated Background Pattern
    private func scrollingPatternLayer(size: CGSize) -> some View {
        GeometryReader { _ in
            if let pattern = UIImage(named: "SettingsBackgroundPattern") {
                Image(uiImage: pattern)
                    .resizable(resizingMode: .tile)
                    .frame(width: size.width + 650, height: size.height + 650)
                    .offset(x: patternOffset.x, y: patternOffset.y)
                    .opacity(0.95)
                    .allowsHitTesting(false)
            }
        }
        .clipped()
    }
    
    private func startSlowBackgroundScroll() {
        withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
            // Slowly scrolls down and to the left (dx < 0, dy > 0)
            patternOffset = CGPoint(x: -650, y: 650)
        }
    }
    
    // MARK: - Settings Card View
    private func settingsCard(
        titleImageName: String,
        fallbackTitle: String,
        description: String,
        isOn: Binding<Bool>,
        onChange: ((Bool) -> Void)? = nil
    ) -> some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                if let uiImg = UIImage(named: titleImageName) {
                    Image(uiImage: uiImg)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                } else {
                    Text(fallbackTitle)
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "555555"))
                }
                
                Text(description)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "1e293b"))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding<Bool>(
                get: { isOn.wrappedValue },
                set: { val in
                    isOn.wrappedValue = val
                    onChange?(val)
                }
            ))
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "34c759")))
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 6)
    }
}
