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
                mriAudioPlayer?.stop()
                mriAudioPlayer = nil
                avPlayer?.pause()
                avPlayer = nil
                waveAnimationToken = UUID()
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
                    if !hasTransitioned {
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
            if !hasTransitioned {
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
        
        hasTransitioned = false
        selectedPartId = nil
        clickedPartIds.removeAll()
        allSpotsClicked = false
        lightsOff = false
        isInsideScreen = false
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
            // Stop the program
            withAnimation(.easeInOut(duration: 0.25)) {
                isVideoPlaying = false
            }
            avPlayer?.pause()
            avPlayer = nil
            remoteTapped = false
            withAnimation(.easeInOut(duration: 0.25)) {
                promptText = "Program stopped! Click on the remote anytime to play your movie, or squish the stress ball to chat with staff."
            }
        } else {
            // Start playing MRI Video
            remoteTapped = true
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
                
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        self.isVideoPlaying = false
                        self.remoteTapped = false
                        self.promptText = "The MRI is finished! You did a fantastic job staying still!"
                    }
                }
            }
            
            withAnimation(.easeInOut(duration: 0.25)) {
                promptText = "Program started! Put on your movie or music with headphones while the MRI takes pictures!"
            }
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
