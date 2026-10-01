import SwiftUI
import AVFoundation
import AVKit

// MARK: - MRI Room Discovery Part Model
public struct MRIPart: Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let xRatio: CGFloat
    public let yRatio: CGFloat
    public let widthRatio: CGFloat
    public let heightRatio: CGFloat
}

// MARK: - Staying Still Game State
enum StillGameState {
    case move
    case freeze
    case success
    case complete
}

// MARK: - MRI Procedure View
public struct MRIProcedureView: View {
    @Environment(\.presentationMode) var presentationMode
    public var onDismiss: (() -> Void)? = nil
    public var onBackToHome: (() -> Void)? = nil
    
    // Sequence States
    @State private var hasTransitioned: Bool = false
    @State private var promptText: String = "Welcome to MRI! Lets find all the different parts of the MRI room together!"
    @State private var selectedPartId: String? = nil
    @State private var clickedPartIds: Set<String> = []
    @State private var allSpotsClicked: Bool = false
    @State private var lightsOff: Bool = false
    @State private var isInsideScreen: Bool = false
    @State private var leftWaveOpacities: [Double] = [0, 0, 0, 0]
    @State private var rightWaveOpacities: [Double] = [0, 0, 0, 0]
    @State private var waveAnimationToken: UUID = UUID()
    @State private var showTapHint: Bool = true
    @State private var autoTransitionTimer: Timer? = nil
    @State private var endPromptTimer: Timer? = nil
    @State private var insideTransitionTimer: Timer? = nil
    @State private var insidePromptTimer: Timer? = nil
    @State private var tappedButtons: Set<SoundSide> = []
    @State private var showItems: Bool = false
    @State private var stressBallSquishFrame: Int = 0
    @State private var mriAudioPlayer: AVAudioPlayer? = nil
    @State private var isVideoPlaying: Bool = false
    @State private var avPlayer: AVPlayer? = nil
    @State private var remoteTapped: Bool = false
    @State private var allDoneTimer: Timer? = nil
    @State private var showAllDoneButton: Bool = false
    @State private var showCelebrationModal: Bool = false
    @State private var isBedScreen: Bool = false
    @State private var isBedFull: Bool = false
    @State private var showGlowBackground: Bool = false
    @State private var isBedSlidIn: Bool = false
    @State private var bedSlideDragOffset: CGFloat = 0.0
    
    // Staying Still Game States
    @State private var showStillGamePromptButton: Bool = false
    @State private var isStillGameActive: Bool = false
    @State private var isStillGameDone: Bool = false
    @State private var stillGameState: StillGameState = .move
    @State private var stillGamePauseCount: Int = 0
    @State private var stillGameTimer: Timer? = nil
    @State private var stillGameMetronomeTimer: Timer? = nil
    @State private var stillWarningTimer: Timer? = nil
    @State private var showStillWarningToast: Bool = false
    @State private var stillWarningMessage: String = "Hold still! Freeze like a statue! 🤫"
    @State private var stillVideoPlayer: AVPlayer? = nil
    @State private var keyboardChordNoteIdx: Int = 0
    @State private var handbellTappedAnim: Bool = false
    @State private var keyboardTappedAnim: Bool = false
    @State private var tambourineTappedAnim: Bool = false
    @State private var stillConfettiActive: Bool = false
    @State private var sfxTonePlayer: AVAudioPlayer? = nil
    @State private var metronomeAudioPlayer: AVAudioPlayer? = nil
    
    // Interactive Room Discovery Parts (Medical Equipment)
    private let roomParts: [MRIPart] = [
        MRIPart(
            id: "scanner",
            title: "MRI Scanner",
            description: "The MRI scanner is a giant donut camera that uses magnets and sound waves to take pictures!",
            xRatio: 0.16,
            yRatio: 0.57,
            widthRatio: 0.22,
            heightRatio: 0.62
        ),
        MRIPart(
            id: "bed",
            title: "Cozy Moving Bed",
            description: "The cozy moving bed slides smoothly inside the donut while you lie down and listen to music!",
            xRatio: 0.50,
            yRatio: 0.72,
            widthRatio: 0.48,
            heightRatio: 0.28
        ),
        MRIPart(
            id: "monitors",
            title: "Monitors",
            description: "The medical team uses these computer monitors to see the amazing pictures of your body!",
            xRatio: 0.87,
            yRatio: 0.46,
            widthRatio: 0.12,
            heightRatio: 0.42
        )
    ]
    
    private let switchPart = MRIPart(
        id: "switch",
        title: "Turn Off Lights",
        description: "Great job! The lights are off and the room is nice and cozy. Ready to begin!",
        xRatio: 0.805,
        yRatio: 0.130,
        widthRatio: 0.07,
        heightRatio: 0.08
    )
    
    public init(onDismiss: (() -> Void)? = nil, onBackToHome: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
        self.onBackToHome = onBackToHome
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            
            ZStack {
                Color(red: 11.0 / 255.0, green: 23.0 / 255.0, blue: 28.0 / 255.0)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Navigation Header
                    topBarView(screenSize: screenSize)
                    
                    // Main MRI Stage View (Fills remaining space, maintaining 1366:1024)
                    stageAreaView(screenSize: screenSize)
                    
                    // Accessible Bottom Prompt Banner (Anatomy Explorer Standard)
                    bottomPromptBar
                }
                
                // Celebration Overlay Modal
                if showCelebrationModal {
                    celebrationOverlayView(screenSize: screenSize)
                }
            }
            .onAppear {
                startWelcomeSequence()
            }
            .onDisappear {
                autoTransitionTimer?.invalidate()
                autoTransitionTimer = nil
                endPromptTimer?.invalidate()
                endPromptTimer = nil
                insideTransitionTimer?.invalidate()
                insideTransitionTimer = nil
                insidePromptTimer?.invalidate()
                insidePromptTimer = nil
                allDoneTimer?.invalidate()
                allDoneTimer = nil
                mriAudioPlayer?.stop()
                mriAudioPlayer = nil
                avPlayer?.pause()
                avPlayer = nil
                waveAnimationToken = UUID()
                
                stillGameTimer?.invalidate()
                stillGameTimer = nil
                stillGameMetronomeTimer?.invalidate()
                stillGameMetronomeTimer = nil
                stillWarningTimer?.invalidate()
                stillWarningTimer = nil
                stillVideoPlayer?.pause()
                stillVideoPlayer = nil
                metronomeAudioPlayer?.stop()
                metronomeAudioPlayer = nil
                sfxTonePlayer?.stop()
                sfxTonePlayer = nil
            }
        }
    }
    
    // MARK: - Top Navigation Header
    @ViewBuilder
    private func topBarView(screenSize: CGSize) -> some View {
        HStack(spacing: 12) {
            // Procedures Back Button
            Button(action: {
                HapticManager.shared.buttonTap()
                autoTransitionTimer?.invalidate()
                insideTransitionTimer?.invalidate()
                insidePromptTimer?.invalidate()
                mriAudioPlayer?.stop()
                avPlayer?.pause()
                avPlayer = nil
                if let onDismiss = onDismiss {
                    onDismiss()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .bold))
                    Text("Procedures")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.15))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
            }
            
            Spacer()
            
            // Replay Welcome Sequence Button
            Button(action: {
                HapticManager.shared.buttonTap()
                startWelcomeSequence()
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
            }
            .accessibilityLabel("Replay Welcome Sequence")
            
            // Home Button
            Button(action: {
                HapticManager.shared.buttonTap()
                autoTransitionTimer?.invalidate()
                insideTransitionTimer?.invalidate()
                mriAudioPlayer?.stop()
                avPlayer?.pause()
                avPlayer = nil
                if let onBackToHome = onBackToHome {
                    onBackToHome()
                } else if let onDismiss = onDismiss {
                    onDismiss()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Image("Home")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
            }
            .accessibilityLabel("Home")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Color(red: 11.0 / 255.0, green: 23.0 / 255.0, blue: 28.0 / 255.0).opacity(0.85)
                .background(.ultraThinMaterial)
        )
    }
    
    // MARK: - Stage Area View
    @ViewBuilder
    private func stageAreaView(screenSize: CGSize) -> some View {
        GeometryReader { stageGeo in
            let stageWidth = stageGeo.size.width
            let stageHeight = stageGeo.size.height
            
            // Calculate fitted size for 1366:1024
            let targetAspect: CGFloat = 1366.0 / 1024.0
            let currentAspect = stageWidth / stageHeight
            let contentWidth: CGFloat = currentAspect > targetAspect ? stageHeight * targetAspect : stageWidth
            let contentHeight: CGFloat = currentAspect > targetAspect ? stageHeight : stageWidth / targetAspect
            
            ZStack {
                Color(red: 8.0 / 255.0, green: 17.0 / 255.0, blue: 21.0 / 255.0)
                    .ignoresSafeArea()
                
                // Content Canvas (Exact 1366:1024 Proportions)
                ZStack {
                    // Layer 0: Room Lights Off Screen (revealed when lights turn off)
                    Image("MRIRoomLightsOff")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: contentWidth, height: contentHeight)

                    // Layer 1: Room Lights On Screen (the interactive exploration layer)
                    Image("MRIRoomLightsOn")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: contentWidth, height: contentHeight)
                        .opacity(lightsOff ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 0.8), value: lightsOff)
                    
                    // Layer 2: Interactive Room Parts (Active after transition, while lights are on)
                    if hasTransitioned && !lightsOff {
                        // Equipment discovery spots (removed once clicked)
                        ForEach(roomParts.filter { !clickedPartIds.contains($0.id) }) { part in
                            let partX = contentWidth * part.xRatio
                            let partY = contentHeight * part.yRatio
                            let partW = contentWidth * part.widthRatio
                            let partH = contentHeight * part.heightRatio
                            
                            Button(action: {
                                selectRoomPart(part)
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedPartId == part.id ? Color.white.opacity(0.18) : Color.white.opacity(0.01))
                                    
                                    // Pulsing Cyan Discovery Indicator
                                    Circle()
                                        .stroke(Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), lineWidth: 3)
                                        .frame(width: 38, height: 38)
                                        .shadow(color: Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), radius: 6)
                                    
                                    // Part Label Pill
                                    Text(part.title)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color(red: 224 / 255.0, green: 242 / 255.0, blue: 254 / 255.0))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color(red: 15 / 255.0, green: 23 / 255.0, blue: 42 / 255.0).opacity(0.88))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0).opacity(0.6), lineWidth: 1)
                                        )
                                        .offset(y: 46)
                                }
                                .frame(width: partW, height: partH)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .position(x: partX, y: partY)
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Active Light Switch Hotspot (shown when all spots have been clicked)
                        if allSpotsClicked {
                            let partX = contentWidth * switchPart.xRatio
                            let partY = contentHeight * switchPart.yRatio
                            let partW = contentWidth * switchPart.widthRatio
                            let partH = contentHeight * switchPart.heightRatio

                            Button(action: {
                                turnOffLights()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.01))
                                    
                                    // Pulsing Cyan Discovery Indicator
                                    Circle()
                                        .stroke(Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), lineWidth: 3)
                                        .frame(width: 38, height: 38)
                                        .shadow(color: Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), radius: 6)
                                    
                                    // Part Label Pill
                                    Text(switchPart.title)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color(red: 224 / 255.0, green: 242 / 255.0, blue: 254 / 255.0))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color(red: 15 / 255.0, green: 23 / 255.0, blue: 42 / 255.0).opacity(0.88))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0).opacity(0.6), lineWidth: 1)
                                        )
                                        .offset(y: 56)
                                }
                                .frame(width: partW, height: partH)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .position(x: partX, y: partY)
                            .transition(.scale.combined(with: .opacity))

                            // Secondary ceiling light fixture tap target for switch
                            Button(action: {
                                turnOffLights()
                            }) {
                                Color.clear
                                    .frame(width: contentWidth * 0.48, height: contentHeight * 0.09)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .position(x: contentWidth * 0.50, y: contentHeight * 0.08)
                        } else {
                            // Tapping switch before all spots are clicked gives gentle guidance
                            Button(action: {
                                HapticManager.shared.lightTap()
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    promptText = "Tap on all the medical equipment first, then turn off the lights to begin!"
                                }
                            }) {
                                Color.clear
                                    .frame(width: contentWidth * switchPart.widthRatio, height: contentHeight * switchPart.heightRatio)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .position(x: contentWidth * switchPart.xRatio, y: contentHeight * switchPart.yRatio)
                        }
                    }
                    
                    // Layer 3: MRI Inside Screen (revealed after lights turn off)
                    Image("MRIInside")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: contentWidth, height: contentHeight)
                        .opacity(isInsideScreen ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8), value: isInsideScreen)
                    
                    // Video Player Overlay (Active when remote red button is pressed, positioned over screen)
                    if isInsideScreen && isVideoPlaying, let player = avPlayer {
                        MRIInlinePlayerView(player: player)
                            .frame(width: contentWidth * 0.1420, height: contentHeight * 0.0840)
                            .cornerRadius(3)
                            .shadow(color: Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0).opacity(0.45), radius: 6)
                            .position(x: contentWidth * 0.5007, y: contentHeight * 0.1064)
                            .transition(.opacity)
                            .zIndex(6)
                    }
                    
                    // Sound Wave Overlays & Interactive Buttons (active when inside screen is visible)
                    if isInsideScreen {
                        // Left sound wave ripple arcs (L1 to L4, innermost to outermost)
                        ForEach(1...4, id: \.self) { idx in
                            Image("MRISoundL\(idx)")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: contentWidth, height: contentHeight)
                                .opacity(leftWaveOpacities[idx - 1])
                                .allowsHitTesting(false)
                        }
                        
                        // Right sound wave ripple arcs (R1 to R4, innermost to outermost)
                        ForEach(1...4, id: \.self) { idx in
                            Image("MRISoundR\(idx)")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: contentWidth, height: contentHeight)
                                .opacity(rightWaveOpacities[idx - 1])
                                .allowsHitTesting(false)
                        }
                        
                        // Left Black Button Hotspot: x = 5.93%, y = 63.0% (Originates at black button, disappears once pressed)
                        if !tappedButtons.contains(.left) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.001))
                                    .frame(width: 48, height: 48)
                                    
                                // Cyan ring originating at the black button
                                Circle()
                                    .stroke(Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), lineWidth: 3)
                                    .frame(width: 30, height: 30)
                                    .shadow(color: Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), radius: 6)
                            }
                            .contentShape(Circle())
                            .position(x: contentWidth * 0.0593, y: contentHeight * 0.630)
                            .onTapGesture {
                                toggleMRISound(side: .left)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }

                        // Right Black Button Hotspot: x = 94.0%, y = 63.0% (Originates at black button, disappears once pressed)
                        if !tappedButtons.contains(.right) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.001))
                                    .frame(width: 48, height: 48)
                                    
                                // Cyan ring originating at the black button
                                Circle()
                                    .stroke(Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), lineWidth: 3)
                                    .frame(width: 30, height: 30)
                                    .shadow(color: Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), radius: 6)
                            }
                            .contentShape(Circle())
                            .position(x: contentWidth * 0.9400, y: contentHeight * 0.630)
                            .onTapGesture {
                                toggleMRISound(side: .right)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }

                        // MARK: - Remote Controller and Stress Ball Items
                        if showItems {
                            // Remote Controller Layer (Bottom Right)
                            Image("MRIRemoteController")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: contentWidth, height: contentHeight)
                                .transition(.opacity)
                                .allowsHitTesting(false)
                            
                            // Stress Ball Layer (Bottom Left)
                            Image(stressBallImageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: contentWidth, height: contentHeight)
                                .transition(.opacity)
                                .allowsHitTesting(false)
                            
                            // Stress Ball Hotspot (Center: x = 15.4%, y = 84.0%)
                            Button(action: {
                                squishStressBall()
                            }) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.01))
                                    .frame(width: contentWidth * 0.20, height: contentHeight * 0.27)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .position(x: contentWidth * 0.154, y: contentHeight * 0.840)
                            
                            // Remote Controller Hotspot (Allows tapping the remote body as well)
                            Button(action: {
                                tapRemote()
                            }) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.01))
                                    .frame(width: contentWidth * 0.21, height: contentHeight * 0.32)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .position(x: contentWidth * 0.853, y: contentHeight * 0.857)

                            // Cyan glowing ring originating directly over the red button (x: 86.75%, y: 71.68%)
                            if !isVideoPlaying {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.001))
                                        .frame(width: 48, height: 48)
                                    
                                    // Cyan ring originating over the red power button
                                    Circle()
                                        .stroke(Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), lineWidth: 3)
                                        .frame(width: 34, height: 34)
                                        .shadow(color: Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), radius: 6)
                                }
                                .contentShape(Circle())
                                .position(x: contentWidth * 0.8675, y: contentHeight * 0.7168)
                                .onTapGesture {
                                    tapRemote()
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    
                    // Layer 3.5: All Done Button (Pops up in center after 30 seconds)
                    if isInsideScreen && showAllDoneButton && !showCelebrationModal {
                        Button(action: {
                            tapAllDone()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18, weight: .black))
                                Text("All Done!")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 16/255, green: 185/255, blue: 129/255), Color(red: 5/255, green: 150/255, blue: 105/255)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                            )
                            .shadow(color: Color(red: 16/255, green: 185/255, blue: 129/255).opacity(0.6), radius: 14, x: 0, y: 6)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .position(x: contentWidth * 0.5, y: contentHeight * 0.5)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Layer 3.8: Bed Preparation & Slide Screen
                    if isBedScreen {
                        let maxDist = contentHeight * 0.22
                        let currentProgress = min(1.0, max(0.0, -bedSlideDragOffset / maxDist))
                        let currentOffset = isBedSlidIn ? 0 : (maxDist + bedSlideDragOffset)
                        
                        ZStack {
                            // Base MRI Scanner Room Background
                            Image("MRIBedEmpty")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: contentWidth, height: contentHeight)
                            
                            // Glowing MRI Room Background (smoothly cross-fades in on top)
                            Image("MRIGlow")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: contentWidth, height: contentHeight)
                                .opacity(showGlowBackground ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.8), value: showGlowBackground)
                            
                            // Empty Bed (fades out after child is fully in bed, preventing mattress dimming)
                            Image("MRIFullBedEmpty")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: contentWidth, height: contentHeight)
                                .offset(y: contentHeight * 0.22)
                                .opacity(isBedFull ? 0.0 : 1.0)
                                .animation(.easeInOut(duration: 0.3).delay(isBedFull ? 0.35 : 0.0), value: isBedFull)
                            
                            // Bed with Child (persistent view: fades in on tap, then slides into machine)
                            Image("MRIFullBedGirl")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: contentWidth, height: contentHeight)
                                .offset(y: currentOffset)
                                .opacity(isBedFull ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.5), value: isBedFull)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            guard showGlowBackground && !isBedSlidIn else { return }
                                            let translation = value.translation.height
                                            if translation < 0 {
                                                bedSlideDragOffset = max(-maxDist, translation)
                                            } else {
                                                bedSlideDragOffset = 0
                                            }
                                        }
                                        .onEnded { value in
                                            guard showGlowBackground && !isBedSlidIn else { return }
                                            if -bedSlideDragOffset >= (maxDist * 0.35) || abs(value.translation.height) < 10 {
                                                completeBedSlide(maxDist: maxDist)
                                            } else {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                    bedSlideDragOffset = 0
                                                }
                                            }
                                        }
                                )
                                .onTapGesture {
                                    if !isBedFull {
                                        tapBed()
                                    } else if showGlowBackground && !isBedSlidIn {
                                        completeBedSlide(maxDist: maxDist)
                                    }
                                }
                            
                            // MRI Glow Top Layer - placed OVER draggable bed so bed slides INTO the machine bore
                            Image("MRIGlowTop")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: contentWidth, height: contentHeight)
                                .allowsHitTesting(false)
                                .opacity(showGlowBackground ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.8), value: showGlowBackground)
                            
                            // Bouncing slide guide arrow if ready to slide and not slid in yet
                            if showGlowBackground && !isBedSlidIn {
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color(red: 0.01, green: 0.12, blue: 0.19))
                                        .frame(width: 52, height: 52)
                                        .background(
                                            Circle()
                                                .fill(Color(red: 0.0, green: 0.9, blue: 1.0))
                                                .shadow(color: Color(red: 0.0, green: 0.9, blue: 1.0).opacity(0.8), radius: 12)
                                        )
                                    
                                    Text("Slide into the machine!")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(red: 0.88, green: 0.95, blue: 1.0))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color(red: 0.06, green: 0.09, blue: 0.16).opacity(0.92))
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color(red: 0.0, green: 0.9, blue: 1.0).opacity(0.7), lineWidth: 1)
                                                )
                                        )
                                }
                                .position(x: contentWidth * 0.50, y: contentHeight * 0.50)
                                .opacity(1.0 - currentProgress * 2.0)
                                .onTapGesture {
                                    completeBedSlide(maxDist: maxDist)
                                }
                                .transition(.opacity)
                            }
                            
                            if !isBedFull {
                                // Hotspot to tap bed
                                Button(action: {
                                    tapBed()
                                }) {
                                    VStack(spacing: 8) {
                                        Circle()
                                            .stroke(Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), lineWidth: 3.5)
                                            .frame(width: 68, height: 68)
                                            .shadow(color: Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), radius: 8)
                                            .overlay(
                                                Circle()
                                                    .fill(Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0).opacity(0.2))
                                            )
                                        
                                        Text("Tap the bed to get ready")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(Color(red: 224 / 255.0, green: 242 / 255.0, blue: 254 / 255.0))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 6)
                                            .background(Color(red: 15 / 255.0, green: 23 / 255.0, blue: 42 / 255.0).opacity(0.92))
                                            .cornerRadius(14)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0).opacity(0.6), lineWidth: 1)
                                            )
                                    }
                                    .frame(width: contentWidth * 0.44, height: contentHeight * 0.44)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .position(x: contentWidth * 0.50, y: contentHeight * 0.60)
                                .transition(.opacity)
                            }
                            
                            // Floating prompt button to practice holding still
                            if isBedFull && !isStillGameDone {
                                Button(action: {
                                    startStillGame()
                                }) {
                                    HStack(spacing: 10) {
                                        Text("🎮")
                                            .font(.system(size: 22))
                                        Text("Practice Holding Still!")
                                            .font(.system(size: 18, weight: .black, design: .rounded))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(red: 6/255, green: 182/255, blue: 212/255), Color(red: 2/255, green: 132/255, blue: 199/255)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.85), lineWidth: 2.5)
                                    )
                                    .shadow(color: Color(red: 6/255, green: 182/255, blue: 212/255).opacity(0.75), radius: 14)
                                }
                                .position(x: contentWidth * 0.50, y: contentHeight * 0.68)
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .transition(.opacity)
                    }
                    
                    // Layer 3.9: Staying Still Game Overlay
                    if isStillGameActive {
                        stillGameOverlayView(contentWidth: contentWidth, contentHeight: contentHeight)
                    }
                    
                    // Layer 4: Welcome Screen (shown in beginning, transitions to Room Lights On)
                    Image("MRIWelcomeScreen")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: contentWidth, height: contentHeight)
                        .opacity(hasTransitioned ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 1.1), value: hasTransitioned)
                        .allowsHitTesting(!hasTransitioned)
                    
                    // Tap Hint (fades on transition)
                    if showTapHint && !hasTransitioned {
                        VStack {
                            HStack {
                                Spacer()
                                HStack(spacing: 6) {
                                    Image(systemName: "hand.tap.fill")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text("Tap anywhere to begin")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.65))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                )
                                .padding(24)
                            }
                            Spacer()
                        }
                        .transition(.opacity)
                    }
                }
                .frame(width: contentWidth, height: contentHeight)
                .clipped()
                .contentShape(Rectangle())
                .onTapGesture {
                    if isStillGameActive {
                        return
                    }
                    if isBedScreen && !isBedFull {
                        tapBed()
                    } else if isBedScreen && isBedFull && !isStillGameDone {
                        startStillGame()
                    } else if isBedScreen && isBedFull && !isBedSlidIn {
                        let maxDist = contentHeight * 0.22
                        completeBedSlide(maxDist: maxDist)
                    } else if !hasTransitioned {
                        triggerTransition()
                    } else if lightsOff && !isInsideScreen {
                        insideTransitionTimer?.invalidate()
                        insideTransitionTimer = nil
                        triggerInsideTransition()
                    } else if isInsideScreen && insidePromptTimer != nil {
                        showMRISoundPrompt()
                    } else if allSpotsClicked && !lightsOff && endPromptTimer != nil {
                        endPromptTimer?.invalidate()
                        endPromptTimer = nil
                        showTurnOffLightsPrompt()
                    }
                }
            }
            .frame(width: stageWidth, height: stageHeight)
        }
    }
    
    // MARK: - Accessible Bottom Instruction & Prompt Banner (Anatomy Explorer Standard)
    @ViewBuilder
    private var bottomPromptBar: some View {
        Button(action: {
            HapticManager.shared.lightTap()
            if isStillGameActive {
                return
            }
            if isBedScreen && !isBedFull {
                tapBed()
            } else if isBedScreen && isBedFull && !isStillGameDone {
                startStillGame()
            } else if isBedScreen && isBedFull && !isBedSlidIn {
                completeBedSlide()
            } else if !hasTransitioned {
                triggerTransition()
            } else if lightsOff && !isInsideScreen {
                insideTransitionTimer?.invalidate()
                insideTransitionTimer = nil
                triggerInsideTransition()
            } else if showItems {
                withAnimation(.easeInOut(duration: 0.25)) {
                    promptText = "You can choose to watch a program, or chat with a staff member while the MRI is happening! Click on the remote to start a program, or squish the stress ball to chat with staff."
                }
            } else if isInsideScreen && insidePromptTimer != nil {
                showMRISoundPrompt()
            } else if isInsideScreen && tappedButtons.count == 1 {
                withAnimation(.easeInOut(duration: 0.2)) {
                    promptText = "Listen to the sounds the MRI makes! Try tapping the other black button to hear more!"
                }
            } else if allSpotsClicked && !lightsOff {
                turnOffLights()
            } else if !allSpotsClicked {
                selectedPartId = nil
                withAnimation(.easeInOut(duration: 0.2)) {
                    promptText = "Tap on a piece of medical equipment to learn more!"
                }
            }
        }) {
            HStack(spacing: 9) {
                // Status Indicator Dot (glowing amber with pulse during welcome/confirmation)
                Circle()
                    .fill((!hasTransitioned || (allSpotsClicked && !lightsOff) || isInsideScreen) ? Color(red: 1.0, green: 0.84, blue: 0.0) : Color(red: 0.98, green: 0.75, blue: 0.14))
                    .frame(width: (!hasTransitioned || (allSpotsClicked && !lightsOff) || isInsideScreen) ? 10 : 8, height: (!hasTransitioned || (allSpotsClicked && !lightsOff) || isInsideScreen) ? 10 : 8)
                    .shadow(
                        color: (!hasTransitioned || (allSpotsClicked && !lightsOff) || isInsideScreen)
                            ? Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.85)
                            : Color(red: 0.98, green: 0.75, blue: 0.14, opacity: 0.7),
                        radius: 4
                    )
                
                Text(promptText)
                    .font(.system(size: 15.5, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.70)
                    .multilineTextAlignment(.leading)
                
                if isBedScreen && isBedFull && !isStillGameDone {
                    Spacer(minLength: 6)
                    Button(action: {
                        startStillGame()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 11, weight: .bold))
                            Text("Practice Holding Still!")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 6/255, green: 182/255, blue: 212/255), Color(red: 2/255, green: 132/255, blue: 199/255)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.85), lineWidth: 1.5)
                        )
                        .shadow(color: Color(red: 6/255, green: 182/255, blue: 212/255).opacity(0.7), radius: 8)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .padding(.vertical, 4)
            .background(
                LinearGradient(
                    colors: (!hasTransitioned || (allSpotsClicked && !lightsOff)) ? [
                        Color(red: 0.10, green: 0.05, blue: 0.20, opacity: 0.78),
                        Color(red: 0.15, green: 0.07, blue: 0.28, opacity: 0.86)
                    ] : [
                        Color(red: 0.06, green: 0.03, blue: 0.13, opacity: 0.65),
                        Color(red: 0.09, green: 0.05, blue: 0.19, opacity: 0.72)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .background(.ultraThinMaterial)
            )
            .overlay(
                Rectangle()
                    .fill((!hasTransitioned || (allSpotsClicked && !lightsOff)) ? Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.38) : Color.white.opacity(0.16))
                    .frame(height: 1.0),
                alignment: .top
            )
            .shadow(color: Color.black.opacity(0.32), radius: 10, y: -3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - State Controllers
    private func startWelcomeSequence() {
        autoTransitionTimer?.invalidate()
        autoTransitionTimer = nil
        endPromptTimer?.invalidate()
        endPromptTimer = nil
        insideTransitionTimer?.invalidate()
        insideTransitionTimer = nil
        insidePromptTimer?.invalidate()
        insidePromptTimer = nil
        allDoneTimer?.invalidate()
        allDoneTimer = nil
        
        showAllDoneButton = false
        showCelebrationModal = false
        hasTransitioned = false
        selectedPartId = nil
        clickedPartIds.removeAll()
        allSpotsClicked = false
        lightsOff = false
        isInsideScreen = false
        isBedScreen = false
        isBedFull = false
        showGlowBackground = false
        isBedSlidIn = false
        bedSlideDragOffset = 0.0
        waveAnimationToken = UUID()
        leftWaveOpacities = [0, 0, 0, 0]
        rightWaveOpacities = [0, 0, 0, 0]
        tappedButtons.removeAll()
        showItems = false
        remoteTapped = false
        isVideoPlaying = false
        avPlayer?.pause()
        avPlayer = nil
        stressBallSquishFrame = 0
        mriAudioPlayer?.stop()
        mriAudioPlayer = nil
        
        showStillGamePromptButton = false
        isStillGameActive = false
        isStillGameDone = false
        stillGameState = .move
        stillGamePauseCount = 0
        stillConfettiActive = false
        stillGameTimer?.invalidate()
        stillGameTimer = nil
        stillGameMetronomeTimer?.invalidate()
        stillGameMetronomeTimer = nil
        stillWarningTimer?.invalidate()
        stillWarningTimer = nil
        stillVideoPlayer?.pause()
        stillVideoPlayer = nil
        metronomeAudioPlayer?.stop()
        metronomeAudioPlayer = nil
        sfxTonePlayer?.stop()
        sfxTonePlayer = nil
        
        showTapHint = true
        promptText = "Welcome to MRI! Lets find all the different parts of the MRI room together!"
        
        // Auto transition after 2.8 seconds
        autoTransitionTimer = Timer.scheduledTimer(withTimeInterval: 2.8, repeats: false) { _ in
            triggerTransition()
        }
    }
    
    private func triggerTransition() {
        guard !hasTransitioned else { return }
        hasTransitioned = true
        autoTransitionTimer?.invalidate()
        autoTransitionTimer = nil
        
        HapticManager.shared.lightTap()
        
        // 1. Hide tap hint
        withAnimation(.easeOut(duration: 0.3)) {
            showTapHint = false
        }
        
        // 2. Transition from Welcome Screen to Room Lights On
        withAnimation(.easeInOut(duration: 1.1)) {
            hasTransitioned = true
        }
        
        // 3. Update prompt to explore room
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeInOut(duration: 0.3)) {
                promptText = "Tap on a piece of medical equipment to learn more!"
            }
        }
    }
    
    private func selectRoomPart(_ part: MRIPart) {
        guard !clickedPartIds.contains(part.id) else { return }
        HapticManager.shared.lightTap()
        selectedPartId = part.id
        withAnimation(.easeOut(duration: 0.3)) {
            _ = clickedPartIds.insert(part.id)
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            promptText = part.description
        }
        
        if clickedPartIds.count >= roomParts.count {
            allSpotsClicked = true
            endPromptTimer?.invalidate()
            endPromptTimer = Timer.scheduledTimer(withTimeInterval: 2.8, repeats: false) { _ in
                showTurnOffLightsPrompt()
            }
        }
    }

    private func showTurnOffLightsPrompt() {
        guard !lightsOff else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            promptText = "Turn off the lights to begin!"
        }
    }

    private func turnOffLights() {
        guard !lightsOff else { return }
        HapticManager.shared.success()
        endPromptTimer?.invalidate()
        endPromptTimer = nil
        withAnimation(.easeInOut(duration: 0.8)) {
            lightsOff = true
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            promptText = "Great job! The lights are off and the room is nice and cozy. Ready to begin!"
        }
        
        // Transition to Inside Screen after 2.4 seconds
        insideTransitionTimer?.invalidate()
        insideTransitionTimer = Timer.scheduledTimer(withTimeInterval: 2.4, repeats: false) { _ in
            triggerInsideTransition()
        }
    }
    
    // MARK: - Inside Screen & Sound Controls
    private func triggerInsideTransition() {
        guard !isInsideScreen else { return }
        HapticManager.shared.lightTap()
        insideTransitionTimer?.invalidate()
        insideTransitionTimer = nil
        
        withAnimation(.easeInOut(duration: 0.8)) {
            isInsideScreen = true
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            promptText = "First, lets explore the inside of the MRI machine!"
        }
        
        insidePromptTimer?.invalidate()
        insidePromptTimer = Timer.scheduledTimer(withTimeInterval: 2.8, repeats: false) { _ in
            showMRISoundPrompt()
        }
    }
    
    private func showMRISoundPrompt() {
        insidePromptTimer?.invalidate()
        insidePromptTimer = nil
        withAnimation(.easeInOut(duration: 0.3)) {
            promptText = "Try tapping on the black buttons to hear what an MRI sounds like"
        }
    }
    
    enum SoundSide {
        case left
        case right
    }
    
    private var stressBallImageName: String {
        switch stressBallSquishFrame {
        case 1:
            return "MRIStressSquish1"
        case 2:
            return "MRIStressSquish2"
        default:
            return "MRIStressBall"
        }
    }
    
    private func playMRISound() {
        if let soundURL = Bundle.main.url(forResource: "MRISound", withExtension: "mp3") {
            do {
                mriAudioPlayer?.stop()
                mriAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                mriAudioPlayer?.play()
            } catch {
                print("Could not play MRI sound: \(error)")
            }
        }
    }
    
    private func triggerWaveRipple(side: SoundSide) {
        playMRISound()
        let currentToken = waveAnimationToken
        
        // 2 sequential ripple cycles (1.35s each, total ~2.7s)
        for cycle in 0..<2 {
            let cycleBase = Double(cycle) * 1.35
            for i in 0..<4 {
                let waveDelay = cycleBase + Double(i) * 0.18
                // Fade in one wave at a time
                DispatchQueue.main.asyncAfter(deadline: .now() + waveDelay) {
                    guard self.waveAnimationToken == currentToken else { return }
                    withAnimation(.easeIn(duration: 0.22)) {
                        if side == .left {
                            self.leftWaveOpacities[i] = 1.0
                        } else {
                            self.rightWaveOpacities[i] = 1.0
                        }
                    }
                }
                // Fade out one wave at a time
                DispatchQueue.main.asyncAfter(deadline: .now() + waveDelay + 0.32) {
                    guard self.waveAnimationToken == currentToken else { return }
                    withAnimation(.easeOut(duration: 0.40)) {
                        if side == .left {
                            self.leftWaveOpacities[i] = 0.0
                        } else {
                            self.rightWaveOpacities[i] = 0.0
                        }
                    }
                }
            }
        }
        
        // Disappear altogether when sound completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
            guard self.waveAnimationToken == currentToken else { return }
            if side == .left {
                self.leftWaveOpacities = [0, 0, 0, 0]
            } else {
                self.rightWaveOpacities = [0, 0, 0, 0]
            }
        }
    }
    
    private func toggleMRISound(side: SoundSide) {
        HapticManager.shared.lightTap()
        
        insidePromptTimer?.invalidate()
        insidePromptTimer = nil
        
        withAnimation(.easeOut(duration: 0.3)) {
            _ = tappedButtons.insert(side)
        }
        
        triggerWaveRipple(side: side)
        
        // If BOTH buttons have been tapped, delay bringUpItems until waves finish (~2.7s)
        if tappedButtons.contains(.left) && tappedButtons.contains(.right) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                bringUpItems()
            }
            return
        }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            promptText = "Listen to the sounds the MRI makes! Try tapping the other black button to hear more!"
        }
    }
    
    private func bringUpItems() {
        withAnimation(.easeInOut(duration: 0.6)) {
            showItems = true
            promptText = "You can choose to watch a program, or chat with a staff member while the MRI is happening! Click on the remote to start a program, or squish the stress ball to chat with staff."
        }
        
        // Have the All Done button appear a few seconds after the remote and stress ball appear
        allDoneTimer?.invalidate()
        allDoneTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { _ in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                showAllDoneButton = true
            }
        }
    }
    
    private func squishStressBall() {
        HapticManager.shared.mediumTap()
        stressBallSquishFrame = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            stressBallSquishFrame = 2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
            stressBallSquishFrame = 0
        }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            promptText = "Squish! You can squeeze the stress ball to talk with staff anytime through the speaker!"
        }
    }
    
    private func tapRemote() {
        HapticManager.shared.lightTap()
        
        // Stop any sound waves and audio
        waveAnimationToken = UUID()
        leftWaveOpacities = [0, 0, 0, 0]
        rightWaveOpacities = [0, 0, 0, 0]
        mriAudioPlayer?.stop()
        mriAudioPlayer = nil
        
        if isVideoPlaying {
            // Stop / Pause the program (preserves avPlayer and playback position)
            withAnimation(.easeInOut(duration: 0.25)) {
                isVideoPlaying = false
            }
            avPlayer?.pause()
            remoteTapped = false
            withAnimation(.easeInOut(duration: 0.25)) {
                promptText = "Program stopped! Click on the remote anytime to resume your movie, or squish the stress ball to chat with staff."
            }
        } else {
            // Start or Resume playing MRI Video
            remoteTapped = true
            
            if let existingPlayer = avPlayer {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.isVideoPlaying = true
                }
                existingPlayer.play()
                withAnimation(.easeInOut(duration: 0.25)) {
                    promptText = "Program resumed! Put on your movie or music with headphones while the MRI takes pictures!"
                }
            } else {
                let videoURL = Bundle.main.url(forResource: "MRIVideo", withExtension: "mp4") ??
                               Bundle.main.url(forResource: "MRI Video 2", withExtension: "mp4") ??
                               Bundle.main.url(forResource: "MRIVideo2", withExtension: "mp4") ??
                               Bundle.main.url(forResource: "MRI Video", withExtension: "mp4")
                if let videoURL = videoURL {
                    let player = AVPlayer(url: videoURL)
                    self.avPlayer = player
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.isVideoPlaying = true
                    }
                    player.play()
                    
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak player] _ in
                        withAnimation(.easeInOut(duration: 0.25)) {
                            self.isVideoPlaying = false
                            self.remoteTapped = false
                            self.promptText = "The MRI is finished! You did a fantastic job staying still!"
                        }
                        player?.seek(to: .zero)
                        self.avPlayer = nil
                    }
                }
                
                withAnimation(.easeInOut(duration: 0.25)) {
                    promptText = "Program started! Put on your movie or music with headphones while the MRI takes pictures!"
                }
            }
        }
    }
    
    // MARK: - All Done & Celebration
    private func tapAllDone() {
        HapticManager.shared.lightTap()
        
        // Pause video
        isVideoPlaying = false
        avPlayer?.pause()
        
        // Stop mri audio
        mriAudioPlayer?.stop()
        mriAudioPlayer = nil
        
        withAnimation(.easeInOut(duration: 0.6)) {
            showAllDoneButton = false
            isInsideScreen = false
            isBedScreen = true
            isBedFull = false
            showGlowBackground = false
            isBedSlidIn = false
            bedSlideDragOffset = 0.0
            showStillGamePromptButton = false
            isStillGameActive = false
            isStillGameDone = false
            stillGameState = .move
            stillGamePauseCount = 0
            stillConfettiActive = false
            promptText = "Tap the bed to get ready for your MRI!"
        }
    }
    
    private func tapBed() {
        guard isBedScreen && !isBedFull else { return }
        HapticManager.shared.success()
        playYouDidItSound()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            isBedFull = true
        }
        
        // After person is in the bed, prompt that their most important job is to hold perfectly still!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            guard self.isBedScreen && self.isBedFull && !self.isStillGameDone else { return }
            withAnimation(.easeInOut(duration: 0.35)) {
                self.promptText = "Your most important job during the MRI is to hold perfectly still!"
                self.showStillGamePromptButton = true
            }
        }
    }
    
    private func completeBedSlide(maxDist: CGFloat = 160.0) {
        guard !isBedSlidIn else { return }
        HapticManager.shared.success()
        playYouDidItSound()
        withAnimation(.spring(response: 0.65, dampingFraction: 0.75)) {
            bedSlideDragOffset = -maxDist
            isBedSlidIn = true
            promptText = "Great job! You are all cozy and ready for your MRI!"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isBedScreen && self.isBedSlidIn else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                self.showCelebrationModal = true
            }
        }
    }
    
    private func playYouDidItSound() {
        if let chimeURL = Bundle.main.url(forResource: "YouDidItChime", withExtension: "mp3") ??
                          Bundle.main.url(forResource: "YouDidIt", withExtension: "mp3") {
            do {
                mriAudioPlayer = try AVAudioPlayer(contentsOf: chimeURL)
                mriAudioPlayer?.play()
            } catch {
                print("Could not play YouDidIt chime: \(error)")
            }
        }
    }
    
    // MARK: - Layer 3.9: Staying Still Game Overlay Screen
    @ViewBuilder
    private func stillGameOverlayView(contentWidth: CGFloat, contentHeight: CGFloat) -> some View {
        ZStack {
            // Pure Black Stage Background
            Color.black
                .frame(width: contentWidth, height: contentHeight)
                .contentShape(Rectangle())
                .onTapGesture {
                    if stillGameState == .freeze {
                        showStillWarningToastAlert(msg: "Hold still! Freeze like a statue! 🤫")
                    }
                }
            
            // Top HUD
            VStack {
                HStack(spacing: 12) {
                    // Back button
                    Button(action: {
                        exitStillGame(isCompleted: false)
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                            Text("Back")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    // Status Pill
                    HStack(spacing: 8) {
                        Circle()
                            .fill(stillGameState == .freeze ? Color.red : (stillGameState == .complete ? Color.green : Color.yellow))
                            .frame(width: 8, height: 8)
                        
                        Text(statusPillText)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(statusPillGradient)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                    )
                    .shadow(color: statusPillGlowColor, radius: 10)
                    
                    Spacer()
                    
                    // Freeze count badge
                    Text("Freezes: \(stillGamePauseCount)/3")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
            }
            .zIndex(10)
            
            // Center Dancing Skeleton (Video if available, or animated image)
            Group {
                if let player = stillVideoPlayer {
                    MRIInlinePlayerView(player: player)
                        .frame(width: contentWidth * 0.44, height: contentHeight * 0.52)
                        .position(x: contentWidth * 0.50, y: contentHeight * 0.40)
                } else {
                    Image("MRIDance")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: contentWidth * 0.44, height: contentHeight * 0.52)
                        .scaleEffect(stillGameState == .move ? 1.03 : 1.0)
                        .rotationEffect(.degrees(stillGameState == .move ? -2.0 : 0.0))
                        .animation(stillGameState == .move ? Animation.easeInOut(duration: 0.45).repeatForever(autoreverses: true) : .default, value: stillGameState)
                        .position(x: contentWidth * 0.50, y: contentHeight * 0.40)
                }
            }
            .allowsHitTesting(false)
            
            // Handbell (Lower Left)
            ZStack {
                Image("Handbell")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: contentWidth, height: contentHeight)
                    .scaleEffect(handbellTappedAnim ? 1.14 : 1.0, anchor: UnitPoint(x: 0.104, y: 0.641))
                    .rotationEffect(.degrees(handbellTappedAnim ? 7.0 : 0.0), anchor: UnitPoint(x: 0.104, y: 0.641))
                    .animation(.spring(response: 0.28, dampingFraction: 0.5), value: handbellTappedAnim)
                
                // Touch Hotspot for Handbell
                Color.clear
                    .frame(width: contentWidth * 0.16, height: contentHeight * 0.28)
                    .contentShape(Rectangle())
                    .position(x: contentWidth * 0.104, y: contentHeight * 0.641)
                    .onTapGesture {
                        onTapInstrument(type: "bell")
                    }
            }
            
            // Keyboard (Bottom Center)
            ZStack {
                Image("Keyboard")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: contentWidth, height: contentHeight)
                    .scaleEffect(keyboardTappedAnim ? 1.08 : 1.0, anchor: UnitPoint(x: 0.50, y: 0.82))
                    .animation(.spring(response: 0.28, dampingFraction: 0.5), value: keyboardTappedAnim)
                
                // Touch Hotspot for Keyboard
                Color.clear
                    .frame(width: contentWidth * 0.56, height: contentHeight * 0.30)
                    .contentShape(Rectangle())
                    .position(x: contentWidth * 0.50, y: contentHeight * 0.82)
                    .onTapGesture {
                        onTapInstrument(type: "keyboard")
                    }
            }
            
            // Tambourine (Lower Right)
            ZStack {
                Image("Tambourine")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: contentWidth, height: contentHeight)
                    .scaleEffect(tambourineTappedAnim ? 1.14 : 1.0, anchor: UnitPoint(x: 0.90, y: 0.633))
                    .rotationEffect(.degrees(tambourineTappedAnim ? -8.0 : 0.0), anchor: UnitPoint(x: 0.90, y: 0.633))
                    .animation(.spring(response: 0.28, dampingFraction: 0.5), value: tambourineTappedAnim)
                
                // Touch Hotspot for Tambourine
                Color.clear
                    .frame(width: contentWidth * 0.18, height: contentHeight * 0.26)
                    .contentShape(Rectangle())
                    .position(x: contentWidth * 0.90, y: contentHeight * 0.633)
                    .onTapGesture {
                        onTapInstrument(type: "tambourine")
                    }
            }
            
            // Freeze Warning Toast
            if showStillWarningToast {
                HStack(spacing: 8) {
                    Text("🛑")
                        .font(.system(size: 20))
                    Text(stillWarningMessage)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(red: 220/255, green: 38/255, blue: 38/255).opacity(0.96))
                .clipShape(Capsule())
                .shadow(color: Color.red.opacity(0.6), radius: 10, y: 3)
                .position(x: contentWidth * 0.50, y: contentHeight * 0.68)
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
            }
            
            // Confetti in Still Game
            if stillConfettiActive {
                ConfettiAnimationView()
                    .allowsHitTesting(false)
                    .zIndex(25)
            }
        }
        .frame(width: contentWidth, height: contentHeight)
        .transition(.opacity)
        .zIndex(15)
    }
    
    // MARK: - Still Game Helpers & Lifecycle
    private var statusPillText: String {
        switch stillGameState {
        case .move:
            return "🎵 Move & Play Music! Tap the instruments! 🎶"
        case .freeze:
            return "🛑 FREEZE! Hold perfectly still! 🤫"
        case .success:
            return "🌟 Great job holding still! Get ready to move!"
        case .complete:
            return "🎉 Great job! You are an expert at holding still!"
        }
    }
    
    private var statusPillGradient: LinearGradient {
        switch stillGameState {
        case .move:
            return LinearGradient(
                colors: [Color(red: 6/255, green: 182/255, blue: 212/255), Color(red: 2/255, green: 132/255, blue: 199/255)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .freeze:
            return LinearGradient(
                colors: [Color(red: 239/255, green: 68/255, blue: 68/255), Color(red: 185/255, green: 28/255, blue: 28/255)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .success:
            return LinearGradient(
                colors: [Color(red: 245/255, green: 158/255, blue: 11/255), Color(red: 217/255, green: 119/255, blue: 6/255)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .complete:
            return LinearGradient(
                colors: [Color(red: 16/255, green: 185/255, blue: 129/255), Color(red: 5/255, green: 150/255, blue: 105/255)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private var statusPillGlowColor: Color {
        switch stillGameState {
        case .move:
            return Color(red: 6/255, green: 182/255, blue: 212/255).opacity(0.6)
        case .freeze:
            return Color(red: 239/255, green: 68/255, blue: 68/255).opacity(0.8)
        case .success:
            return Color(red: 245/255, green: 158/255, blue: 11/255).opacity(0.6)
        case .complete:
            return Color(red: 16/255, green: 185/255, blue: 129/255).opacity(0.7)
        }
    }
    
    private func setupStillVideoPlayer() {
        if stillVideoPlayer == nil {
            let videoURL = Bundle.main.url(forResource: "MRIDance", withExtension: "mp4") ??
                           Bundle.main.url(forResource: "MRI Dance", withExtension: "mp4")
            if let url = videoURL {
                let player = AVPlayer(url: url)
                player.isMuted = true
                player.actionAtItemEnd = .none
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: player.currentItem,
                    queue: .main
                ) { [weak player] _ in
                    player?.seek(to: .zero)
                    player?.play()
                }
                stillVideoPlayer = player
            }
        }
    }
    
    private func startStillGame() {
        HapticManager.shared.buttonTap()
        playYouDidItSound()
        
        showStillGamePromptButton = false
        isStillGameActive = true
        stillGamePauseCount = 0
        stillConfettiActive = false
        
        setupStillVideoPlayer()
        enterStillGameMovePhase()
    }
    
    private func enterStillGameMovePhase() {
        guard isStillGameActive else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            stillGameState = .move
        }
        stillVideoPlayer?.play()
        startMetronome()
        
        stillGameTimer?.invalidate()
        let moveDuration = 3.5 + Double.random(in: 0.0...1.5)
        stillGameTimer = Timer.scheduledTimer(withTimeInterval: moveDuration, repeats: false) { _ in
            self.enterStillGameFreezePhase()
        }
    }
    
    private func enterStillGameFreezePhase() {
        guard isStillGameActive else { return }
        stopMetronome()
        stillVideoPlayer?.pause()
        
        stillGamePauseCount += 1
        withAnimation(.easeInOut(duration: 0.25)) {
            stillGameState = .freeze
        }
        
        playFreezeCueSound()
        HapticManager.shared.mediumTap()
        
        stillGameTimer?.invalidate()
        stillGameTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            self.onStillGameFreezeCompleted()
        }
    }
    
    private func onStillGameFreezeCompleted() {
        guard isStillGameActive else { return }
        playYouDidItSound()
        HapticManager.shared.success()
        
        if stillGamePauseCount < 3 {
            withAnimation(.easeInOut(duration: 0.25)) {
                stillGameState = .success
            }
            stillGameTimer?.invalidate()
            stillGameTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
                self.enterStillGameMovePhase()
            }
        } else {
            finishStillGameSuccess()
        }
    }
    
    private func onTapInstrument(type: String) {
        guard isStillGameActive else { return }
        if stillGameState == .freeze {
            showStillWarningToastAlert(msg: "Oops! Hold still! Freeze like a statue! 🤫")
            playStillWarningSound()
            HapticManager.shared.mediumTap()
            return
        }
        
        HapticManager.shared.lightTap()
        if type == "bell" {
            playHandbellSound()
            handbellTappedAnim = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.handbellTappedAnim = false
            }
        } else if type == "keyboard" {
            playKeyboardSound()
            keyboardTappedAnim = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.keyboardTappedAnim = false
            }
        } else if type == "tambourine" {
            playTambourineSound()
            tambourineTappedAnim = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.tambourineTappedAnim = false
            }
        }
    }
    
    private func showStillWarningToastAlert(msg: String) {
        stillWarningMessage = msg
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showStillWarningToast = true
        }
        stillWarningTimer?.invalidate()
        stillWarningTimer = Timer.scheduledTimer(withTimeInterval: 1.6, repeats: false) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                self.showStillWarningToast = false
            }
        }
    }
    
    private func finishStillGameSuccess() {
        stopMetronome()
        withAnimation(.easeInOut(duration: 0.3)) {
            stillGameState = .complete
            stillConfettiActive = true
        }
        playYouDidItSound()
        HapticManager.shared.success()
        
        stillGameTimer?.invalidate()
        stillGameTimer = Timer.scheduledTimer(withTimeInterval: 2.3, repeats: false) { _ in
            self.exitStillGame(isCompleted: true)
        }
    }
    
    private func exitStillGame(isCompleted: Bool) {
        stopMetronome()
        stillVideoPlayer?.pause()
        stillGameTimer?.invalidate()
        stillGameTimer = nil
        stillWarningTimer?.invalidate()
        stillWarningTimer = nil
        showStillWarningToast = false
        
        withAnimation(.easeInOut(duration: 0.4)) {
            isStillGameActive = false
            stillConfettiActive = false
        }
        
        if isCompleted {
            isStillGameDone = true
            withAnimation(.easeInOut(duration: 0.8)) {
                showGlowBackground = true
                promptText = "Great job! You're ready for your MRI! Slide the bed into the machine!"
            }
        } else {
            promptText = "Your most important job during the MRI is to hold perfectly still!"
            showStillGamePromptButton = true
        }
    }
    
    private func startMetronome() {
        stopMetronome()
        playMetronomeTick()
        stillGameMetronomeTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.playMetronomeTick()
        }
    }
    
    private func stopMetronome() {
        stillGameMetronomeTimer?.invalidate()
        stillGameMetronomeTimer = nil
    }
    
    // MARK: - In-Memory Sound Synthesis
    private func createWavData(samples: [Int16], sampleRate: Int = 44100) -> Data {
        var data = Data()
        let numSamples = Int32(samples.count)
        let subChunk2Size = numSamples * 2
        let chunkSize = 36 + subChunk2Size
        
        data.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
        var chunkSizeLE = chunkSize.littleEndian
        data.append(Data(bytes: &chunkSizeLE, count: 4))
        data.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // "WAVE"
        
        data.append(contentsOf: [0x66, 0x6D, 0x74, 0x20]) // "fmt "
        var subChunk1Size: Int32 = 16
        data.append(Data(bytes: &subChunk1Size, count: 4))
        var audioFormat: Int16 = 1
        data.append(Data(bytes: &audioFormat, count: 2))
        var numChannels: Int16 = 1
        data.append(Data(bytes: &numChannels, count: 2))
        var sr = Int32(sampleRate).littleEndian
        data.append(Data(bytes: &sr, count: 4))
        var byteRate = (Int32(sampleRate) * 2).littleEndian
        data.append(Data(bytes: &byteRate, count: 4))
        var blockAlign: Int16 = 2
        data.append(Data(bytes: &blockAlign, count: 2))
        var bitsPerSample: Int16 = 16
        data.append(Data(bytes: &bitsPerSample, count: 2))
        
        data.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // "data"
        var subChunk2SizeLE = subChunk2Size.littleEndian
        data.append(Data(bytes: &subChunk2SizeLE, count: 4))
        
        samples.withUnsafeBufferPointer { buffer in
            data.append(Data(buffer: buffer))
        }
        return data
    }
    
    private func playTone(samples: [Int16], sampleRate: Int = 44100) {
        let wav = createWavData(samples: samples, sampleRate: sampleRate)
        do {
            sfxTonePlayer = try AVAudioPlayer(data: wav)
            sfxTonePlayer?.play()
        } catch {
            print("Could not play synthesized tone: \(error)")
        }
    }
    
    private func playMetronomeTick() {
        let sr = 44100
        let n = Int(0.026 * Double(sr))
        var samples = [Int16](repeating: 0, count: n)
        for i in 0..<n {
            let t = Double(i) / Double(sr)
            let f = 1150.0 + (320.0 - 1150.0) * (t / 0.026)
            let env = exp(-Double(i) / (Double(n) * 0.25))
            samples[i] = Int16(sin(2.0 * .pi * f * t) * env * 22000)
        }
        let wav = createWavData(samples: samples, sampleRate: sr)
        try? metronomeAudioPlayer = AVAudioPlayer(data: wav)
        metronomeAudioPlayer?.play()
    }
    
    private func playHandbellSound() {
        let sr = 44100
        let n = Int(1.1 * Double(sr))
        var samples = [Int16](repeating: 0, count: n)
        let freqs = [1046.5, 2093.0, 3135.9]
        let gains = [0.45, 0.25, 0.12]
        let decays = [1.1, 0.65, 0.35]
        for i in 0..<n {
            let t = Double(i) / Double(sr)
            var val = 0.0
            for (idx, f) in freqs.enumerated() {
                let env = exp(-t / decays[idx])
                val += sin(2.0 * .pi * f * t) * gains[idx] * env
            }
            samples[i] = Int16(max(-32767, min(32767, val * 26000)))
        }
        playTone(samples: samples)
    }
    
    private func playKeyboardSound() {
        let chordNotes = [523.25, 659.25, 783.99, 1046.50, 880.00, 783.99, 659.25]
        let freq = chordNotes[keyboardChordNoteIdx % chordNotes.count]
        keyboardChordNoteIdx += 1
        let sr = 44100
        let n = Int(0.65 * Double(sr))
        var samples = [Int16](repeating: 0, count: n)
        for i in 0..<n {
            let t = Double(i) / Double(sr)
            let env = exp(-t / 0.28)
            let val = (sin(2.0 * .pi * freq * t) * 0.6 + sin(2.0 * .pi * freq * 2.0 * t) * 0.3) * env
            samples[i] = Int16(max(-32767, min(32767, val * 26000)))
        }
        playTone(samples: samples)
    }
    
    private func playTambourineSound() {
        let sr = 44100
        let n = Int(0.18 * Double(sr))
        var samples = [Int16](repeating: 0, count: n)
        for i in 0..<n {
            let t = Double(i) / Double(sr)
            let env = exp(-Double(i) / (Double(n) * 0.28))
            let noise = Double.random(in: -1.0...1.0) * 0.75
            let jingle = sin(2.0 * .pi * 5200.0 * t) * 0.35 * exp(-t / 0.12)
            let val = (noise + jingle) * env
            samples[i] = Int16(max(-32767, min(32767, val * 24000)))
        }
        playTone(samples: samples)
    }
    
    private func playFreezeCueSound() {
        let sr = 44100
        let n = Int(0.32 * Double(sr))
        var samples = [Int16](repeating: 0, count: n)
        for i in 0..<n {
            let t = Double(i) / Double(sr)
            let f = 920.0 + (420.0 - 920.0) * (t / 0.32)
            let env = exp(-Double(i) / (Double(n) * 0.4))
            samples[i] = Int16(sin(2.0 * .pi * f * t) * env * 24000)
        }
        playTone(samples: samples)
    }
    
    private func playStillWarningSound() {
        let sr = 44100
        let n = Int(0.22 * Double(sr))
        var samples = [Int16](repeating: 0, count: n)
        for i in 0..<n {
            let t = Double(i) / Double(sr)
            let f = t < 0.08 ? 240.0 : 180.0
            let env = exp(-t / 0.16)
            let phase = f * t
            let saw = (phase - floor(phase + 0.5)) * 2.0
            samples[i] = Int16(saw * env * 20000)
        }
        playTone(samples: samples)
    }
    
    @ViewBuilder
    private func celebrationOverlayView(screenSize: CGSize) -> some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture { }
            
            ConfettiAnimationView()
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            VStack(spacing: 20) {
                Image("GameYouDidIt")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 420)
                    .shadow(color: Color.black.opacity(0.6), radius: 16, x: 0, y: 8)
                
                Text("You completed your MRI procedure! You did a fantastic job staying still!")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                HStack(spacing: 16) {
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        showCelebrationModal = false
                        startWelcomeSequence()
                    }) {
                        Text("Explore Again")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.2), radius: 6, y: 3)
                    }
                    
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        showCelebrationModal = false
                        if let onDismiss = onDismiss {
                            onDismiss()
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Back to Procedures")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 14/255, green: 165/255, blue: 233/255), Color(red: 2/255, green: 132/255, blue: 199/255)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color(red: 2/255, green: 132/255, blue: 199/255).opacity(0.4), radius: 8, y: 4)
                    }
                }
            }
            .padding(28)
            .background(
                Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.92)
                    .background(.ultraThinMaterial)
            )
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.5), radius: 24, y: 12)
            .padding(.horizontal, 24)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Native Borderless Video Player (No Controls, Aspect Fill)
struct MRIInlinePlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.player = player
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.player = player
    }
    
    class PlayerUIView: UIView {
        var player: AVPlayer? {
            get { playerLayer.player }
            set { playerLayer.player = newValue }
        }
        
        var playerLayer: AVPlayerLayer {
            return layer as! AVPlayerLayer
        }
        
        override static var layerClass: AnyClass {
            return AVPlayerLayer.self
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            playerLayer.videoGravity = .resizeAspectFill
            backgroundColor = .clear
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            playerLayer.frame = bounds
        }
    }
}
