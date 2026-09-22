import SwiftUI
import AVFoundation

// MARK: - IV Background Audio Manager (Looped, Quiet Volume)
public final class IVAudioManager {
    public static let shared = IVAudioManager()
    private var player: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?
    private var wipePlayer: AVAudioPlayer?
    private var wetWipePlayer: AVAudioPlayer?
    private var youDidItPlayer: AVAudioPlayer?
    
    public var isMuted: Bool = false {
        didSet {
            if isMuted {
                player?.pause()
                sfxPlayer?.stop()
                wipePlayer?.pause()
                wetWipePlayer?.pause()
                youDidItPlayer?.pause()
            } else {
                if player != nil {
                    player?.play()
                }
            }
        }
    }
    
    private init() {}
    
    public func startBackgroundMusic() {
        if isMuted { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session configuration error: \(error)")
        }
        
        if player == nil {
            // Priority 1: Load from Asset Catalog NSDataAsset
            if let dataAsset = NSDataAsset(name: "MusicBG") {
                do {
                    player = try AVAudioPlayer(data: dataAsset.data)
                } catch {
                    print("Failed to initialize player from data asset: \(error)")
                }
            }
            
            // Priority 2: Fallback to Bundle resource URLs
            if player == nil {
                var soundURL: URL? = Bundle.main.url(forResource: "Music BG 6", withExtension: "mp3")
                    ?? Bundle.main.url(forResource: "Music BG", withExtension: "mp3")
                    ?? Bundle.main.url(forResource: "MusicBG", withExtension: "mp3")
                
                #if SWIFT_PACKAGE
                if soundURL == nil {
                    soundURL = Bundle.module.url(forResource: "Music BG 6", withExtension: "mp3")
                        ?? Bundle.module.url(forResource: "Music BG", withExtension: "mp3")
                        ?? Bundle.module.url(forResource: "MusicBG", withExtension: "mp3")
                }
                #endif
                
                if let url = soundURL {
                    do {
                        player = try AVAudioPlayer(contentsOf: url)
                    } catch {
                        print("Failed to initialize player from URL: \(error)")
                    }
                }
            }
            
            player?.numberOfLoops = -1 // Continuous loop throughout preparation
            player?.volume = 0.22      // Discreet background volume so sound effects take prominence
            player?.prepareToPlay()
        }
        
        player?.play()
    }
    
    public func stopBackgroundMusic() {
        player?.stop()
        player?.currentTime = 0
        player = nil
        stopClothWipeSound(reset: true)
        stopClothWetWipeSound(reset: true)
        stopYouDidItSound(reset: true)
    }
    
    // MARK: - Introduction Bag Open Sound Effect (Volume 0.85)
    public func playBagOpenSound() {
        guard !isMuted else { return }
        if let dataAsset = NSDataAsset(name: "BoxOpen") {
            do {
                sfxPlayer = try AVAudioPlayer(data: dataAsset.data)
                sfxPlayer?.volume = 0.85
                sfxPlayer?.prepareToPlay()
                sfxPlayer?.play()
                return
            } catch {
                print("Failed to initialize BoxOpen player: \(error)")
            }
        }
        var soundURL: URL? = Bundle.main.url(forResource: "BoxOpen", withExtension: "mp3")
            ?? Bundle.main.url(forResource: "Box Open", withExtension: "mp3")
        #if SWIFT_PACKAGE
        if soundURL == nil {
            soundURL = Bundle.module.url(forResource: "BoxOpen", withExtension: "mp3")
        }
        #endif
        if let url = soundURL {
            do {
                sfxPlayer = try AVAudioPlayer(contentsOf: url)
                sfxPlayer?.volume = 0.85
                sfxPlayer?.prepareToPlay()
                sfxPlayer?.play()
            } catch {
                print("Failed to play BoxOpen audio: \(error)")
            }
        }
    }
    
    // MARK: - Step 1 Ointment Squeeze Sound Effect (Volume 0.90)
    public func playSlimeSound() {
        guard !isMuted else { return }
        // Priority 1: Load from Asset Catalog NSDataAsset
        if let dataAsset = NSDataAsset(name: "Slime2") {
            do {
                sfxPlayer = try AVAudioPlayer(data: dataAsset.data)
                sfxPlayer?.volume = 0.90
                sfxPlayer?.prepareToPlay()
                sfxPlayer?.play()
                return
            } catch {
                print("Failed to initialize Slime2 player from data asset: \(error)")
            }
        }
        
        // Priority 2: Fallback to Bundle resource URLs
        var soundURL: URL? = Bundle.main.url(forResource: "Slime 2", withExtension: "mp3")
            ?? Bundle.main.url(forResource: "Slime2", withExtension: "mp3")
        
        #if SWIFT_PACKAGE
        if soundURL == nil {
            soundURL = Bundle.module.url(forResource: "Slime 2", withExtension: "mp3")
                ?? Bundle.module.url(forResource: "Slime2", withExtension: "mp3")
        }
        #endif
        
        if let url = soundURL {
            do {
                sfxPlayer = try AVAudioPlayer(contentsOf: url)
                sfxPlayer?.volume = 0.90
                sfxPlayer?.prepareToPlay()
                sfxPlayer?.play()
            } catch {
                print("Failed to initialize Slime2 player from URL: \(error)")
            }
        }
    }
    
    // MARK: - Step 2 & 3 Bandage Placement & Removal Sound Effect (Volume 0.90)
    public func playBandageSound() {
        guard !isMuted else { return }
        // Priority 1: Load from Asset Catalog NSDataAsset
        if let dataAsset = NSDataAsset(name: "Bandage") {
            do {
                sfxPlayer = try AVAudioPlayer(data: dataAsset.data)
                sfxPlayer?.volume = 0.90
                sfxPlayer?.prepareToPlay()
                sfxPlayer?.play()
                return
            } catch {
                print("Failed to initialize Bandage player from data asset: \(error)")
            }
        }
        
        // Priority 2: Fallback to Bundle resource URLs
        var soundURL: URL? = Bundle.main.url(forResource: "Bandage", withExtension: "mp3")
        
        #if SWIFT_PACKAGE
        if soundURL == nil {
            soundURL = Bundle.module.url(forResource: "Bandage", withExtension: "mp3")
        }
        #endif
        
        if let url = soundURL {
            do {
                sfxPlayer = try AVAudioPlayer(contentsOf: url)
                sfxPlayer?.volume = 0.90
                sfxPlayer?.prepareToPlay()
                sfxPlayer?.play()
            } catch {
                print("Failed to play Bandage audio: \(error)")
            }
        }
    }
    
    // MARK: - Step 4 Cloth Wipe Sound Effect (Volume 0.90)
    public func startClothWipeSound() {
        guard !isMuted else { return }
        if wipePlayer == nil {
            // Priority 1: Load from Asset Catalog NSDataAsset
            if let dataAsset = NSDataAsset(name: "ClothWipe") {
                do {
                    wipePlayer = try AVAudioPlayer(data: dataAsset.data)
                    wipePlayer?.numberOfLoops = -1
                    wipePlayer?.volume = 0.90
                    wipePlayer?.prepareToPlay()
                } catch {
                    print("Failed to initialize ClothWipe player from data asset: \(error)")
                }
            }
            
            // Priority 2: Fallback to Bundle resource URLs
            if wipePlayer == nil {
                var soundURL: URL? = Bundle.main.url(forResource: "Cloth Wipe", withExtension: "mp3")
                    ?? Bundle.main.url(forResource: "ClothWipe", withExtension: "mp3")
                
                #if SWIFT_PACKAGE
                if soundURL == nil {
                    soundURL = Bundle.module.url(forResource: "Cloth Wipe", withExtension: "mp3")
                        ?? Bundle.module.url(forResource: "ClothWipe", withExtension: "mp3")
                }
                #endif
                
                if let url = soundURL {
                    do {
                        wipePlayer = try AVAudioPlayer(contentsOf: url)
                        wipePlayer?.numberOfLoops = -1
                        wipePlayer?.volume = 0.90
                        wipePlayer?.prepareToPlay()
                    } catch {
                        print("Failed to initialize Cloth Wipe player from URL: \(error)")
                    }
                }
            }
        }
        
        if let player = wipePlayer, !player.isPlaying {
            player.play()
        }
    }
    
    public func stopClothWipeSound(reset: Bool = false) {
        wipePlayer?.pause()
        if reset {
            wipePlayer?.currentTime = 0
        }
    }
    
    // MARK: - Step 5 Tourniquet Band Sound Effect (Volume 0.90)
    public func playRubberBandSound() {
        guard !isMuted else { return }
        // Priority 1: Load from Asset Catalog NSDataAsset
        if let dataAsset = NSDataAsset(name: "RubberBand") {
            do {
                sfxPlayer = try AVAudioPlayer(data: dataAsset.data)
                sfxPlayer?.volume = 0.90
                sfxPlayer?.prepareToPlay()
                sfxPlayer?.play()
                return
            } catch {
                print("Failed to initialize RubberBand player from data asset: \(error)")
            }
        }
        
        // Priority 2: Fallback to Bundle resource URLs
        var soundURL: URL? = Bundle.main.url(forResource: "Rubber Band", withExtension: "mp3")
            ?? Bundle.main.url(forResource: "RubberBand", withExtension: "mp3")
        
        #if SWIFT_PACKAGE
        if soundURL == nil {
            soundURL = Bundle.module.url(forResource: "Rubber Band", withExtension: "mp3")
                ?? Bundle.module.url(forResource: "RubberBand", withExtension: "mp3")
        }
        #endif
        
        if let url = soundURL {
            do {
                sfxPlayer = try AVAudioPlayer(contentsOf: url)
                sfxPlayer?.volume = 0.90
                sfxPlayer?.prepareToPlay()
                sfxPlayer?.play()
            } catch {
                print("Failed to play Rubber Band audio: \(error)")
            }
        }
    }
    
    // MARK: - Step 6 Packet Rip Sound Effect (Volume 0.90)
    public func playRipSound() {
        guard !isMuted else { return }
        // Priority 1: Load from Asset Catalog NSDataAsset
        if let dataAsset = NSDataAsset(name: "Rip") {
            do {
                sfxPlayer = try AVAudioPlayer(data: dataAsset.data)
                sfxPlayer?.volume = 0.90
                sfxPlayer?.prepareToPlay()
                sfxPlayer?.play()
                return
            } catch {
                print("Failed to initialize Rip player from data asset: \(error)")
            }
        }
        
        // Priority 2: Fallback to Bundle resource URLs
        var soundURL: URL? = Bundle.main.url(forResource: "Rip", withExtension: "mp3")
        
        #if SWIFT_PACKAGE
        if soundURL == nil {
            soundURL = Bundle.module.url(forResource: "Rip", withExtension: "mp3")
        }
        #endif
        
        if let url = soundURL {
            do {
                sfxPlayer = try AVAudioPlayer(contentsOf: url)
                sfxPlayer?.volume = 0.90
                sfxPlayer?.prepareToPlay()
                sfxPlayer?.play()
            } catch {
                print("Failed to play Rip audio: \(error)")
            }
        }
    }
    
    // MARK: - Step 6B Cloth Wet Wipe Sound Effect (Volume 0.90)
    public func startClothWetWipeSound() {
        guard !isMuted else { return }
        if wetWipePlayer == nil {
            // Priority 1: Load from Asset Catalog NSDataAsset
            if let dataAsset = NSDataAsset(name: "ClothWetWipe") {
                do {
                    wetWipePlayer = try AVAudioPlayer(data: dataAsset.data)
                    wetWipePlayer?.numberOfLoops = -1
                    wetWipePlayer?.volume = 0.90
                    wetWipePlayer?.prepareToPlay()
                } catch {
                    print("Failed to initialize ClothWetWipe player from data asset: \(error)")
                }
            }
            
            // Priority 2: Fallback to Bundle resource URLs
            if wetWipePlayer == nil {
                var soundURL: URL? = Bundle.main.url(forResource: "Cloth Wet Wipe", withExtension: "mp3")
                    ?? Bundle.main.url(forResource: "ClothWetWipe", withExtension: "mp3")
                
                #if SWIFT_PACKAGE
                if soundURL == nil {
                    soundURL = Bundle.module.url(forResource: "Cloth Wet Wipe", withExtension: "mp3")
                        ?? Bundle.module.url(forResource: "ClothWetWipe", withExtension: "mp3")
                }
                #endif
                
                if let url = soundURL {
                    do {
                        wetWipePlayer = try AVAudioPlayer(contentsOf: url)
                        wetWipePlayer?.numberOfLoops = -1
                        wetWipePlayer?.volume = 0.90
                        wetWipePlayer?.prepareToPlay()
                    } catch {
                        print("Failed to initialize Cloth Wet Wipe player from URL: \(error)")
                    }
                }
            }
        }
        
        if let player = wetWipePlayer, !player.isPlaying {
            player.play()
        }
    }
    
    public func stopClothWetWipeSound(reset: Bool = false) {
        wetWipePlayer?.pause()
        if reset {
            wetWipePlayer?.currentTime = 0
        }
    }
    
    // MARK: - Step 8 IV Shot Insertion Sound Effect (Volume 0.90)
    public func playShotSound() {
        guard !isMuted else { return }
        // Priority 1: Load from Asset Catalog NSDataAsset
        if let dataAsset = NSDataAsset(name: "Shot") {
            do {
                sfxPlayer = try AVAudioPlayer(data: dataAsset.data)
                sfxPlayer?.volume = 0.90
                sfxPlayer?.prepareToPlay()
                sfxPlayer?.play()
                return
            } catch {
                print("Failed to initialize Shot player from data asset: \(error)")
            }
        }
        
        // Priority 2: Fallback to Bundle resource URLs
        var soundURL: URL? = Bundle.main.url(forResource: "Shot", withExtension: "mp3")
        
        #if SWIFT_PACKAGE
        if soundURL == nil {
            soundURL = Bundle.module.url(forResource: "Shot", withExtension: "mp3")
        }
        #endif
        
        if let url = soundURL {
            do {
                sfxPlayer = try AVAudioPlayer(contentsOf: url)
                sfxPlayer?.volume = 0.90
                sfxPlayer?.prepareToPlay()
                sfxPlayer?.play()
            } catch {
                print("Failed to play Shot audio: \(error)")
            }
        }
    }
    
    // MARK: - Step 10 You Did It Celebration Sound Effect (Volume 0.90)
    public func playYouDidItSound() {
        guard !isMuted else { return }
        if youDidItPlayer == nil {
            // Priority 1: Load from Asset Catalog NSDataAsset
            if let dataAsset = NSDataAsset(name: "YouDidIt") {
                do {
                    youDidItPlayer = try AVAudioPlayer(data: dataAsset.data)
                    youDidItPlayer?.volume = 0.90
                    youDidItPlayer?.prepareToPlay()
                } catch {
                    print("Failed to initialize YouDidIt player from data asset: \(error)")
                }
            }
            
            // Priority 2: Fallback to Bundle resource URLs
            if youDidItPlayer == nil {
                var soundURL: URL? = Bundle.main.url(forResource: "You Did It Chime", withExtension: "mp3")
                    ?? Bundle.main.url(forResource: "YouDidItChime", withExtension: "mp3")
                    ?? Bundle.main.url(forResource: "You Did It", withExtension: "mp3")
                    ?? Bundle.main.url(forResource: "YouDidIt", withExtension: "mp3")
                
                #if SWIFT_PACKAGE
                if soundURL == nil {
                    soundURL = Bundle.module.url(forResource: "You Did It Chime", withExtension: "mp3")
                        ?? Bundle.module.url(forResource: "YouDidItChime", withExtension: "mp3")
                        ?? Bundle.module.url(forResource: "You Did It", withExtension: "mp3")
                        ?? Bundle.module.url(forResource: "YouDidIt", withExtension: "mp3")
                }
                #endif
                
                if let url = soundURL {
                    do {
                        youDidItPlayer = try AVAudioPlayer(contentsOf: url)
                        youDidItPlayer?.volume = 0.90
                        youDidItPlayer?.prepareToPlay()
                    } catch {
                        print("Failed to play You Did It audio: \(error)")
                    }
                }
            }
        }
        
        youDidItPlayer?.currentTime = 0
        youDidItPlayer?.play()
    }
    
    public func stopYouDidItSound(reset: Bool = false) {
        youDidItPlayer?.pause()
        if reset {
            youDidItPlayer?.currentTime = 0
        }
    }
}

// MARK: - Game Step Definition
public enum IVGameStep: Int {
    case ointment = 1
    case bandage = 2
    case removeBandage = 3
    case washcloth = 4
    case tourniquet = 5
    case cleanWipePacket = 6
    case cleanWipeArm = 7
    case insertIV = 8
    case tapeIV = 9
    case completed = 10
}

// MARK: - IV Game View (Numbing Ointment, Clear Bandage, Washcloth Wipe, Tourniquet Band, Clean Wipe & IV Placement)
public struct IVGameView: View {
    @Environment(\.presentationMode) var presentationMode
    public var onDismiss: (() -> Void)? = nil
    
    // Game State
    @State private var currentStep: IVGameStep = .ointment
    @State private var isBandPlaced: Bool = false
    @State private var isBandagePlaced: Bool = false
    @State private var bandDragOffset: CGSize = .zero
    @State private var isBandDragging: Bool = false
    @State private var isBandOverTarget: Bool = false
    
    // Step 1: Numbing Ointment State
    @State private var ointmentDragOffset: CGSize = .zero
    @State private var isOintmentDragging: Bool = false
    @State private var isOintmentOverElbow: Bool = false
    @State private var isSqueezing: Bool = false
    @State private var squeezeProgress: CGFloat = 0.0
    @State private var squeezeTimer: Timer? = nil
    
    // Step 2: Clear Bandage State
    @State private var bandageDragOffset: CGSize = .zero
    @State private var isBandageDragging: Bool = false
    @State private var isBandageOverElbow: Bool = false
    
    // Step 3: Remove Bandage State
    @State private var isBandagePeeled: Bool = false
    @State private var bandagePeelOffset: CGSize = .zero
    @State private var bandagePeelRotation: Double = 0.0
    @State private var bandagePeelOpacity: Double = 1.0
    
    // Step 4: Washcloth Wipe State
    @State private var washclothDragOffset: CGSize = .zero
    @State private var isWashclothDragging: Bool = false
    @State private var washclothPivotAngle: Double = 0.0
    @State private var isWashclothOverLotion: Bool = false
    @State private var washclothCursorSide: Int = 0 // -1: left, 1: right, 0: unset
    @State private var washclothCursorSideY: Int = 0 // -1: top, 1: bottom, 0: unset
    @State private var washclothSweepCount: Int = 0
    private let totalWipeSweeps: Int = 6
    
    // Step 6: Clean Wipe Packet State
    @State private var isPacketRipped: Bool = false
    @State private var showRipEffect: Bool = false
    
    // Step 8: IV Needle & Catheter State
    @State private var ivDragOffset: CGSize = .zero
    @State private var isIVDragging: Bool = false
    @State private var isIVLockedToVein: Bool = false
    @State private var isIVOverVein: Bool = false
    @State private var isIVOverArm: Bool = false
    @State private var ivCountdownValue: Int = 3
    @State private var isCountingDown: Bool = false
    @State private var canPokeIV: Bool = false
    @State private var isIVInserted: Bool = false
    @State private var needleRetractOpacity: Double = 1.0
    @State private var catheterOpacity: Double = 0.0
    
    // Step 9: IV Tape State
    @State private var tapeDragOffset: CGSize = .zero
    @State private var isTapeDragging: Bool = false
    @State private var isTapePlaced: Bool = false
    @State private var isTapeOverArm: Bool = false
    @State private var isTapeOverTarget: Bool = false
    
    // Step 7: Clean Wipe Arm State
    @State private var packetWipeDragOffset: CGSize = .zero
    @State private var isPacketWipeDragging: Bool = false
    @State private var packetWipePivotAngle: Double = 0.0
    @State private var isPacketWipeOverElbow: Bool = false
    @State private var packetWipeCursorSide: Int = 0 // -1: left, 1: right, 0: unset
    @State private var packetWipeCursorSideY: Int = 0 // -1: top, 1: bottom, 0: unset
    @State private var packetWipeSweepCount: Int = 0
    private let totalPacketWipeSweeps: Int = 4 // 2 back-and-forth passes
    
    @State private var showSuccessModal: Bool = false
    @State private var isFloating: Bool = false
    @State private var isSoundMuted: Bool = false
    
    // Introduction Entrance Animation State
    @State private var isBagBouncedIn: Bool = false
    @State private var isBagOpen: Bool = false
    @State private var isOintmentEmerged: Bool = false
    @State private var introStepText: String? = "Getting Supplies Ready..."
    @State private var isStepHighlighting: Bool = false
    
    public init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            let isLandscape = screenSize.width > screenSize.height
            
            // Stage sizing to preserve 1366 x 1024 aspect ratio
            let stageAspectRatio: CGFloat = 1366.0 / 1024.0
            let stageSize = calculateStageSize(containerWidth: screenSize.width, containerHeight: screenSize.height, aspectRatio: stageAspectRatio)
            
            ZStack(alignment: .bottom) {
                // Background Fill: Carpet color fallback + full bleed GameBackground
                Color(red: 96/255, green: 51/255, blue: 53/255)
                    .ignoresSafeArea()
                
                Image("GameBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: screenSize.width, height: screenSize.height)
                    .clipped()
                    .ignoresSafeArea()
                
                // MARK: - Game Stage Area
                VStack(spacing: 0) {
                    // Top Navigation Header
                    topGameHeader(screenSize: screenSize)
                    
                    Spacer(minLength: 0)
                    
                    // Game Canvas
                    gameCanvas(stageSize: stageSize)
                        .frame(width: stageSize.width, height: stageSize.height)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // MARK: - Accessible Bottom Step Instruction Bar
                bottomStepInstructionBar
                    .padding(.bottom, 16)
                    .allowsHitTesting(false)
                
                // MARK: - Success Modal Celebration Overlay
                if showSuccessModal {
                    successOverlayView
                        .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                isFloating = true
            }
            IVAudioManager.shared.startBackgroundMusic()
            startIVIntroSequence()
        }
        .onDisappear {
            IVAudioManager.shared.stopBackgroundMusic()
        }
        .onChange(of: currentStep) { _ in
            triggerStepHighlight()
        }
        .onChange(of: introStepText) { _ in
            triggerStepHighlight()
        }
    }
    
    // MARK: - Top Navigation Header
    @ViewBuilder
    private func topGameHeader(screenSize: CGSize) -> some View {
        HStack {
            Button(action: {
                HapticManager.shared.lightTap()
                IVAudioManager.shared.stopBackgroundMusic()
                if let onDismiss = onDismiss {
                    onDismiss()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                    Text("Procedures")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.18))
                .clipShape(Capsule())
            }
            
            Spacer()
            
            // Top Right Action Buttons: Sound Toggle & Reset
            HStack(spacing: 8) {
                Button(action: {
                    isSoundMuted.toggle()
                    IVAudioManager.shared.isMuted = isSoundMuted
                    HapticManager.shared.lightTap()
                }) {
                    Image(systemName: isSoundMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(9)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Circle())
                }
                .accessibilityLabel(isSoundMuted ? "Unmute Sound" : "Mute Sound")
                
                Button(action: {
                    resetGame()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(9)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Reset Preparation")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }
    
    // MARK: - Accessible Bottom Step Instruction Bar (Non-button Text Presentation, WCAG AAA Contrast)
    @ViewBuilder
    private var bottomStepInstructionBar: some View {
        HStack(spacing: 9) {
            // Accessible Status Indicator Dot (visual confirmation that this is an active status readout)
            Circle()
                .fill(isStepHighlighting ? Color(red: 0.98, green: 0.75, blue: 0.14) : Color(red: 0.98, green: 0.75, blue: 0.14, opacity: 0.85))
                .frame(width: 8, height: 8)
                .scaleEffect(isStepHighlighting ? 1.35 : 1.0)
            
            Text(headerBadgeTitle)
                .font(.system(size: 15.5, weight: .bold, design: .rounded))
                .foregroundColor(isStepHighlighting ? Color(red: 1.0, green: 0.98, blue: 0.92) : .white)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    isStepHighlighting
                    ? LinearGradient(
                        colors: [Color(red: 0.19, green: 0.09, blue: 0.35, opacity: 0.96), Color(red: 0.30, green: 0.14, blue: 0.52, opacity: 0.94)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    : LinearGradient(
                        colors: [Color(red: 0.07, green: 0.04, blue: 0.15, opacity: 0.92), Color(red: 0.12, green: 0.06, blue: 0.24, opacity: 0.90)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(
                    isStepHighlighting
                    ? Color(red: 0.98, green: 0.75, blue: 0.14, opacity: 0.95)
                    : Color.white.opacity(0.24),
                    lineWidth: isStepHighlighting ? 2.0 : 1.5
                )
        )
        .shadow(
            color: isStepHighlighting ? Color(red: 0.98, green: 0.75, blue: 0.14, opacity: 0.58) : Color.black.opacity(0.45),
            radius: isStepHighlighting ? 16 : 8,
            x: 0,
            y: isStepHighlighting ? 0 : 4
        )
        .scaleEffect(isStepHighlighting ? 1.06 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isStepHighlighting)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(headerBadgeTitle)
        .accessibilityAddTraits(.isStaticText)
    }
    
    private func triggerStepHighlight() {
        withAnimation(.easeOut(duration: 0.22)) {
            isStepHighlighting = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            withAnimation(.easeInOut(duration: 0.35)) {
                isStepHighlighting = false
            }
        }
    }
    
    private var headerBadgeTitle: String {
        if let introText = introStepText {
            return introText
        }
        switch currentStep {
        case .ointment: return "Step 1: Apply Numbing Ointment"
        case .bandage: return "Step 2: Place Clear Bandage"
        case .removeBandage: return "Step 3: Tap Bandage to Remove"
        case .washcloth: return "Step 4: Wipe Away Lotion"
        case .tourniquet: return "Step 5: Place Tourniquet Band"
        case .cleanWipePacket: return "Step 6: Rip Open Clean Wipe"
        case .cleanWipeArm: return "Step 7: Wipe Arm Clean"
        case .insertIV: return "Step 8: Place the IV"
        case .tapeIV: return "Step 9: Tape the IV"
        case .completed: return "Arm Prepared & IV Placed!"
        }
    }
    
    // MARK: - Interactive Game Canvas (1366x1024 native layers)
    @ViewBuilder
    private func gameCanvas(stageSize: CGSize) -> some View {
        ZStack {
            // Layer 1: Background (Window, Wall, Counter)
            Image("GameBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: stageSize.width, height: stageSize.height)
                .allowsHitTesting(false)
            
            // Layer 2: Table
            Image("GameTable")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: stageSize.width, height: stageSize.height)
                .allowsHitTesting(false)
            
            // Layer 3: Medical Supply Kit Bag (Closed Entrance -> Open Bag)
            if !isBagOpen {
                Image("GameBagClosed")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: stageSize.width, height: stageSize.height)
                    .offset(x: isBagBouncedIn ? 0 : -stageSize.width * 0.95, y: 0)
                    .scaleEffect(isBagBouncedIn ? 1.0 : 0.94)
                    .transition(.opacity.combined(with: .scale(scale: 1.03)))
                    .allowsHitTesting(false)
            } else {
                Image("GameBag")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: stageSize.width, height: stageSize.height)
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                    .allowsHitTesting(false)
            }
            
            // Layer 4 & 5: Arm Layers (Bare vs Arm With Band)
            Image("GameArm")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: stageSize.width, height: stageSize.height)
                .opacity(isBandPlaced ? 0 : 1)
                .animation(.easeInOut(duration: 0.35), value: isBandPlaced)
                .allowsHitTesting(false)
            
            Image("GameArmWithBand")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: stageSize.width, height: stageSize.height)
                .opacity(isBandPlaced ? 1 : 0)
                .animation(.easeInOut(duration: 0.35), value: isBandPlaced)
                .allowsHitTesting(false)
            
            // Layer 6: Numbing Lotion on Elbow (dispensed during Step 1, centered under Clear Bandage)
            let lotionCenter = CGPoint(x: stageSize.width * 0.742, y: stageSize.height * 0.551)
            let lotionWidth = stageSize.width * 0.145
            let lotionHeight = stageSize.height * 0.181
            
            let wipeFactor = max(0.0, 1.0 - Double(washclothSweepCount) / Double(totalWipeSweeps))
            let lotionOpacity: Double = {
                switch currentStep {
                case .ointment:
                    return squeezeProgress > 0 ? min(1.0, Double(0.25 + squeezeProgress * 0.75)) : 0.0
                case .bandage, .removeBandage:
                    return 1.0
                case .washcloth:
                    return wipeFactor * 0.95
                case .tourniquet, .cleanWipePacket, .cleanWipeArm, .insertIV, .completed:
                    return 0.0
                }
            }()
            let lotionScale: CGFloat = {
                switch currentStep {
                case .ointment:
                    return squeezeProgress
                case .bandage, .removeBandage:
                    return 1.0
                case .washcloth:
                    return 0.35 + CGFloat(wipeFactor) * 0.65
                case .tourniquet, .cleanWipePacket, .cleanWipeArm, .insertIV, .completed:
                    return 0.0
                }
            }()
            
            Image("GameLotionItem")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: lotionWidth, height: lotionHeight)
                .scaleEffect(lotionScale)
                .opacity(lotionOpacity)
                .position(lotionCenter)
                .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
                .animation(.easeInOut(duration: 0.22), value: washclothSweepCount)
                .allowsHitTesting(false)
            
            // Layer 7: Clear Bandage Wrapped on Arm (placed during Step 2, tapped to peel off in Step 3)
            if isBandagePlaced && !isBandagePeeled {
                Image("GameBandageWrapped")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: stageSize.width, height: stageSize.height)
                    .offset(bandagePeelOffset)
                    .rotationEffect(.degrees(bandagePeelRotation))
                    .opacity(bandagePeelOpacity)
                    .animation(.easeInOut(duration: 0.35), value: isBandagePlaced)
                    .allowsHitTesting(currentStep == .removeBandage)
                    .onTapGesture {
                        removeBandageAction()
                    }
                
                if currentStep == .removeBandage {
                    Button(action: {
                        removeBandageAction()
                    }) {
                        Text("Tap to peel off!")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.black.opacity(0.82))
                        .overlay(
                            Capsule().stroke(Color(red: 0/255, green: 229/255, blue: 255/255), lineWidth: 2)
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 0/255, green: 229/255, blue: 255/255).opacity(0.7), radius: 10, x: 0, y: 3)
                    }
                    .position(lotionCenter)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            
            // Target Drop Zone Highlight on Elbow for Ointment (Step 1), Bandage (Step 2) and Clean Wipe (Step 7)
            let elbowDropZoneRect = CGRect(
                x: stageSize.width * 0.652,
                y: stageSize.height * 0.451,
                width: stageSize.width * 0.18,
                height: stageSize.height * 0.20
            )
            
            if currentStep == .ointment || currentStep == .bandage || currentStep == .cleanWipeArm {
                let isHighlighted: Bool = {
                    switch currentStep {
                    case .ointment: return isOintmentOverElbow
                    case .bandage: return isBandageOverElbow
                    case .cleanWipeArm: return isPacketWipeOverElbow
                    default: return false
                    }
                }()
                Circle()
                    .strokeBorder(
                        isHighlighted ? Color(red: 0/255, green: 215/255, blue: 255/255) : Color.clear,
                        style: StrokeStyle(lineWidth: 3, dash: [8, 4])
                    )
                    .background(
                        Circle()
                            .fill(isHighlighted ? Color(red: 0/255, green: 215/255, blue: 255/255).opacity(0.22) : Color.clear)
                    )
                    .frame(width: elbowDropZoneRect.width, height: elbowDropZoneRect.height)
                    .position(x: elbowDropZoneRect.midX, y: elbowDropZoneRect.midY)
                    .animation(.easeInOut(duration: 0.2), value: isHighlighted)
                    .allowsHitTesting(false)
            }
            
            // Target Drop Zone Highlight on Arm for Tourniquet (Step 5)
            let bandDropZoneRect = CGRect(
                x: stageSize.width * 0.70,
                y: stageSize.height * 0.26,
                width: stageSize.width * 0.27,
                height: stageSize.height * 0.35
            )
            
            if currentStep == .tourniquet {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(
                        isBandOverTarget ? Color.yellow : Color.clear,
                        style: StrokeStyle(lineWidth: 3, dash: [8, 4])
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(isBandOverTarget ? Color.yellow.opacity(0.2) : Color.clear)
                    )
                    .frame(width: bandDropZoneRect.width, height: bandDropZoneRect.height)
                    .position(x: bandDropZoneRect.midX, y: bandDropZoneRect.midY)
                    .animation(.easeInOut(duration: 0.2), value: isBandOverTarget)
                    .allowsHitTesting(false)
            }
            
            // Layer 8: Floating Interactive Numbing Ointment Tube (Step 1)
            if currentStep == .ointment && isOintmentEmerged {
                floatingOintmentItem(stageSize: stageSize, elbowZoneRect: elbowDropZoneRect)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.35).combined(with: .offset(y: 45)).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
            // Layer 9: Floating Interactive Clear Bandage (Step 2)
            if currentStep == .bandage {
                floatingBandageItem(stageSize: stageSize, elbowZoneRect: elbowDropZoneRect)
            }
            
            // Layer 10: Floating Interactive Washcloth (Step 4)
            if currentStep == .washcloth {
                floatingWashclothItem(stageSize: stageSize, lotionCenter: lotionCenter, lotionSize: CGSize(width: lotionWidth, height: lotionHeight))
            }
            
            // Layer 11: Floating Interactive Elastic Tourniquet Band (Step 5)
            if currentStep == .tourniquet {
                floatingBandItem(stageSize: stageSize, dropZoneRect: bandDropZoneRect)
            }
            
            // Layer 12: Floating Interactive Clean Wipe Packet (Step 6)
            if currentStep == .cleanWipePacket {
                floatingPacketItem(stageSize: stageSize)
            }
            
            // Layer 13: Floating Interactive Clean Wipe Cloth (Step 7)
            if currentStep == .cleanWipeArm {
                floatingPacketWipeItem(stageSize: stageSize, elbowCenter: CGPoint(x: elbowDropZoneRect.midX, y: elbowDropZoneRect.midY), elbowSize: elbowDropZoneRect.size)
            }
            
            // Layer 14: Floating Interactive IV Needle & Placed Catheter (Step 8, Step 9 & Completed)
            if currentStep >= .insertIV {
                if currentStep == .insertIV && (isIVOverArm || isIVLockedToVein) {
                    veinDropZoneView(stageSize: stageSize)
                        .transition(.opacity)
                }
                floatingIVItem(stageSize: stageSize)
                
                // When ready to poke, tapping anywhere on screen inserts the needle
                if currentStep == .insertIV && canPokeIV && !isIVInserted {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            pokeInsertNeedleSwiftUI()
                        }
                }
            }
            
            // Layer 15: Floating Interactive IV Tape (Step 9) & Placed Tape (Completed)
            if currentStep >= .tapeIV {
                if isTapePlaced {
                    Image("GameTapeWrapped")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: stageSize.width, height: stageSize.height)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
                
                if currentStep == .tapeIV && !isTapePlaced && isTapeOverArm {
                    tapeDropZoneView(stageSize: stageSize)
                        .transition(.opacity)
                }
                floatingTapeItem(stageSize: stageSize)
            }
        }
    }
    
    // MARK: - Floating Tourniquet Band Component (Step 3)
    @ViewBuilder
    private func floatingBandItem(stageSize: CGSize, dropZoneRect: CGRect) -> some View {
        let bandWidth = stageSize.width * 0.143
        let bandHeight = stageSize.height * 0.325
        let initialX = stageSize.width * 0.254
        let initialY = stageSize.height * 0.188
        
        let floatOffset: CGFloat = (isFloating && !isBandDragging) ? -10 : 0
        
        VStack(spacing: 6) {
            Image("GameBandItem")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: bandWidth, height: bandHeight)
                .shadow(
                    color: Color.yellow.opacity(isBandDragging ? 1.0 : 0.85),
                    radius: isBandDragging ? 26 : 14
                )
                .shadow(
                    color: Color(red: 1.0, green: 0.9, blue: 0.3).opacity(isBandDragging ? 0.8 : 0.6),
                    radius: isBandDragging ? 40 : 26
                )
                .scaleEffect(isBandDragging ? 1.10 : 1.0)
            
            if !isBandDragging {
                Text("Drag band to arm!")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.yellow)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.72))
                    .clipShape(Capsule())
                    .transition(.opacity)
            }
        }
        .position(x: initialX, y: initialY)
        .offset(x: bandDragOffset.width, y: bandDragOffset.height + floatOffset)
        .gesture(
            DragGesture(coordinateSpace: .local)
                .onChanged { value in
                    isBandDragging = true
                    bandDragOffset = value.translation
                    
                    let currentX = initialX + bandDragOffset.width
                    let currentY = initialY + bandDragOffset.height
                    
                    let buffer: CGFloat = 40
                    let isInside = (
                        currentX >= dropZoneRect.minX - buffer &&
                        currentX <= dropZoneRect.maxX + buffer &&
                        currentY >= dropZoneRect.minY - buffer &&
                        currentY <= dropZoneRect.maxY + buffer
                    )
                    
                    if isInside != isBandOverTarget {
                        isBandOverTarget = isInside
                        if isInside {
                            HapticManager.shared.lightTap()
                        }
                    }
                }
                .onEnded { _ in
                    if isBandOverTarget {
                        IVAudioManager.shared.playRubberBandSound()
                        HapticManager.shared.successNotification()
                        withAnimation(.easeOut(duration: 0.25)) {
                            isBandPlaced = true
                            isBandDragging = false
                            isBandOverTarget = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                currentStep = .cleanWipePacket
                            }
                        }
                    } else {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                            bandDragOffset = .zero
                            isBandDragging = false
                            isBandOverTarget = false
                        }
                    }
                }
        )
    }
    
    // MARK: - Floating Clean Wipe Packet Component (Step 6)
    @ViewBuilder
    private func floatingPacketItem(stageSize: CGSize) -> some View {
        let packetWidth = stageSize.width * 0.178
        let packetHeight = packetWidth * (366.0 / 586.0)
        let initialX = stageSize.width * 0.254
        let initialY = stageSize.height * 0.188
        
        let floatOffset: CGFloat = (isFloating && !isPacketRipped) ? -10 : 0
        
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                // Packet Image (Swaps to Ripped on gesture)
                Image(isPacketRipped ? "GamePacketRippedItem" : "GamePacketItem")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: packetWidth, height: packetHeight)
                    .shadow(
                        color: Color.yellow.opacity(0.85),
                        radius: 14
                    )
                    .shadow(
                        color: Color(red: 1.0, green: 0.9, blue: 0.3).opacity(0.6),
                        radius: 26
                    )
                
                // RRRRRIP! Effect Image
                if showRipEffect {
                    Image("GameRipEffectItem")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: packetWidth * 0.44)
                        .rotationEffect(.degrees(-14))
                        .offset(x: packetWidth * 0.15, y: -packetHeight * 0.25)
                        .transition(.scale(scale: 0.2).combined(with: .opacity))
                }
                
                // Dotted Rip Guide Line & Arrow placed right over rip seam (x = 80.4%)
                if !isPacketRipped {
                    let ripLineX = packetWidth * 0.804 - packetWidth / 2
                    
                    Path { path in
                        path.move(to: CGPoint(x: ripLineX, y: -packetHeight * 0.44))
                        path.addLine(to: CGPoint(x: ripLineX, y: packetHeight * 0.32))
                    }
                    .stroke(
                        Color(red: 1.0, green: 0.9, blue: 0.0),
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round, dash: [4, 6])
                    )
                    .shadow(color: Color.black, radius: 2, x: 0, y: 0)
                    .shadow(color: Color.yellow.opacity(0.8), radius: 6, x: 0, y: 0)
                    
                    Text("▼")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.0))
                        .shadow(color: Color.black, radius: 3, x: 0, y: 1)
                        .shadow(color: Color.yellow, radius: 8, x: 0, y: 0)
                        .offset(x: ripLineX, y: -packetHeight * 0.52 + (isFloating ? 5 : 0))
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.height > 15 || abs(value.translation.width) > 15 {
                            ripOpenPacketAction()
                        }
                    }
            )
            .onTapGesture {
                ripOpenPacketAction()
            }
            
            Text(isPacketRipped ? "Ripped open!" : "Trace the dotted line to rip open!")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.0))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.78))
                .clipShape(Capsule())
                .transition(.opacity)
        }
        .position(x: initialX, y: initialY)
        .offset(y: floatOffset)
    }
    
    private func ripOpenPacketAction() {
        guard !isPacketRipped else { return }
        IVAudioManager.shared.playRipSound()
        HapticManager.shared.lightTap()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
            isPacketRipped = true
            showRipEffect = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.easeInOut(duration: 0.28)) {
                currentStep = .cleanWipeArm
                packetWipeDragOffset = .zero
                packetWipeSweepCount = 0
                packetWipeCursorSide = 0
                packetWipeCursorSideY = 0
            }
        }
    }
    
    // MARK: - Floating Clean Wipe Cloth Component (Step 7)
    @ViewBuilder
    private func floatingPacketWipeItem(stageSize: CGSize, elbowCenter: CGPoint, elbowSize: CGSize) -> some View {
        let wipeWidth = stageSize.width * 0.145
        let wipeHeight = wipeWidth * (620.0 / 509.0)
        let initialX = stageSize.width * 0.254
        let initialY = stageSize.height * 0.188
        
        let floatOffset: CGFloat = (isFloating && !isPacketWipeDragging) ? -10 : 0
        
        VStack(spacing: 6) {
            Image("GamePacketWipeItem")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: wipeWidth, height: wipeHeight)
                .rotationEffect(.degrees(packetWipePivotAngle))
                .shadow(
                    color: Color(red: 0/255, green: 229/255, blue: 255/255).opacity(isPacketWipeDragging ? 1.0 : 0.85),
                    radius: isPacketWipeDragging ? 26 : 14
                )
                .shadow(
                    color: Color(red: 0/255, green: 168/255, blue: 255/255).opacity(isPacketWipeDragging ? 0.8 : 0.6),
                    radius: isPacketWipeDragging ? 40 : 26
                )
                .scaleEffect(isPacketWipeDragging ? 1.10 : 1.0)
            
            Text(packetWipePromptText)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 0/255, green: 229/255, blue: 255/255))
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.72))
                .clipShape(Capsule())
                .transition(.opacity)
        }
        .position(x: initialX, y: initialY)
        .offset(x: packetWipeDragOffset.width, y: packetWipeDragOffset.height + floatOffset)
        .gesture(
            DragGesture(coordinateSpace: .local)
                .onChanged { value in
                    isPacketWipeDragging = true
                    let prevX = packetWipeDragOffset.width
                    packetWipeDragOffset = value.translation
                    
                    let moveDx = value.translation.width - prevX
                    let targetPivot = max(-18.0, min(18.0, Double(moveDx * 2.2)))
                    withAnimation(.interactiveSpring(response: 0.12, dampingFraction: 0.65)) {
                        packetWipePivotAngle = targetPivot
                    }
                    
                    let cursorX = (initialX - wipeWidth / 2) + value.startLocation.x + value.translation.width
                    let cursorY = (initialY - wipeHeight / 2) + value.startLocation.y + value.translation.height
                    
                    checkCursorPacketWipe(
                        cursor: CGPoint(x: cursorX, y: cursorY),
                        elbowCenter: elbowCenter,
                        elbowSize: elbowSize
                    )
                }
                .onEnded { _ in
                    isPacketWipeDragging = false
                    packetWipeCursorSide = 0
                    packetWipeCursorSideY = 0
                    IVAudioManager.shared.stopClothWetWipeSound()
                    withAnimation(.easeOut(duration: 0.2)) {
                        packetWipePivotAngle = 0
                    }
                    if packetWipeSweepCount < totalPacketWipeSweeps {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                            packetWipeDragOffset = .zero
                        }
                    }
                }
        )
    }
    
    private var packetWipePromptText: String {
        if packetWipeSweepCount >= totalPacketWipeSweeps {
            return "Arm clean and ready for IV!"
        }
        let completedPasses = packetWipeSweepCount / 2
        let remainingPasses = 2 - completedPasses
        if remainingPasses == 1 {
            return "Almost clean! Keep wiping!"
        } else if isPacketWipeDragging {
            return "Wipe back and forth over elbow!"
        } else {
            return "Wipe the arm clean!"
        }
    }
    
    private func checkCursorPacketWipe(cursor: CGPoint, elbowCenter: CGPoint, elbowSize: CGSize) {
        let deadbandX: CGFloat = max(24, elbowSize.width * 0.18)
        let deadbandY: CGFloat = max(24, elbowSize.height * 0.18)
        let maxHoriz: CGFloat = max(elbowSize.width * 0.95, 85)
        let maxVert: CGFloat = max(elbowSize.height * 0.95, 75)
        
        let distX = abs(cursor.x - elbowCenter.x)
        let distY = abs(cursor.y - elbowCenter.y)
        let isOver = distX <= maxHoriz && distY <= maxVert
        isPacketWipeOverElbow = isOver
        
        guard isOver else {
            packetWipeCursorSide = 0
            packetWipeCursorSideY = 0
            IVAudioManager.shared.stopClothWetWipeSound()
            return
        }
        
        if isPacketWipeDragging && packetWipeSweepCount < totalPacketWipeSweeps {
            IVAudioManager.shared.startClothWetWipeSound()
        }
        
        // 1. Horizontal crossing
        if packetWipeCursorSide == 0 {
            if cursor.x < elbowCenter.x - deadbandX {
                packetWipeCursorSide = -1
            } else if cursor.x > elbowCenter.x + deadbandX {
                packetWipeCursorSide = 1
            }
        } else if packetWipeCursorSide == -1 && cursor.x > elbowCenter.x + deadbandX {
            packetWipeCursorSide = 1
            registerPacketWipeSweepSwiftUI()
        } else if packetWipeCursorSide == 1 && cursor.x < elbowCenter.x - deadbandX {
            packetWipeCursorSide = -1
            registerPacketWipeSweepSwiftUI()
        }
        
        // 2. Vertical crossing
        if packetWipeCursorSideY == 0 {
            if cursor.y < elbowCenter.y - deadbandY {
                packetWipeCursorSideY = -1
            } else if cursor.y > elbowCenter.y + deadbandY {
                packetWipeCursorSideY = 1
            }
        } else if packetWipeCursorSideY == -1 && cursor.y > elbowCenter.y + deadbandY {
            packetWipeCursorSideY = 1
            registerPacketWipeSweepSwiftUI()
        } else if packetWipeCursorSideY == 1 && cursor.y < elbowCenter.y - deadbandY {
            packetWipeCursorSideY = -1
            registerPacketWipeSweepSwiftUI()
        }
    }
    
    private func registerPacketWipeSweepSwiftUI() {
        guard packetWipeSweepCount < totalPacketWipeSweeps else { return }
        packetWipeSweepCount += 1
        HapticManager.shared.lightTap()
        
        if packetWipeSweepCount >= totalPacketWipeSweeps {
            IVAudioManager.shared.stopClothWetWipeSound(reset: true)
            HapticManager.shared.successNotification()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    currentStep = .insertIV
                    isPacketWipeDragging = false
                    packetWipeDragOffset = .zero
                    packetWipeCursorSide = 0
                    packetWipeCursorSideY = 0
                }
            }
        }
    }
    
    // MARK: - Step 8: IV Needle Guiding, Countdown, Poke & Catheter Placement
    @ViewBuilder
    private func veinDropZoneView(stageSize: CGSize) -> some View {
        let veinCenter = CGPoint(x: stageSize.width * 0.742, y: stageSize.height * 0.551)
        let zoneWidth = stageSize.width * 0.16
        let zoneHeight = stageSize.height * 0.19
        
        Circle()
            .stroke(
                isIVOverVein ? Color(red: 0/255, green: 255/255, blue: 180/255) : Color(red: 0/255, green: 229/255, blue: 255/255).opacity(0.65),
                style: StrokeStyle(lineWidth: 3, dash: [8, 6])
            )
            .background(
                Circle()
                    .fill(isIVOverVein ? Color(red: 0/255, green: 255/255, blue: 180/255).opacity(0.22) : Color(red: 0/255, green: 229/255, blue: 255/255).opacity(0.08))
            )
            .frame(width: zoneWidth, height: zoneHeight)
            .position(veinCenter)
            .shadow(
                color: isIVOverVein ? Color(red: 0/255, green: 255/255, blue: 180/255).opacity(0.85) : Color(red: 0/255, green: 229/255, blue: 255/255).opacity(0.35),
                radius: isIVOverVein ? 24 : 12
            )
            .scaleEffect(isIVOverVein ? 1.06 : 1.0)
            .animation(.easeInOut(duration: 0.25), value: isIVOverVein)
            .allowsHitTesting(false)
    }
    
    @ViewBuilder
    private func floatingIVItem(stageSize: CGSize) -> some View {
        let itemWidth = stageSize.width * 0.19
        let itemHeight = itemWidth * (324.0 / 340.0)
        let initialX = stageSize.width * 0.254
        let initialY = stageSize.height * 0.188
        let veinCenter = CGPoint(x: stageSize.width * 0.742, y: stageSize.height * 0.551)
        let targetCenter = CGPoint(x: stageSize.width * 0.697, y: stageSize.height * 0.608)
        
        let floatOffset: CGFloat = (isFloating && !isIVDragging && !isIVLockedToVein) ? -10 : 0
        let currentPos: CGPoint = isIVLockedToVein ? targetCenter : CGPoint(x: initialX + ivDragOffset.width, y: initialY + ivDragOffset.height + floatOffset)
        let advanceOffset: CGSize = isIVInserted ? CGSize(width: stageSize.width * 0.015, height: -stageSize.height * 0.015) : .zero
        
        ZStack {
            // Soft Catheter cannula + wings (becomes visible when inserted into arm)
            Image("GameIVCatheterItem")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: itemWidth, height: itemHeight)
                .opacity(catheterOpacity)
            
            // Needle plunger + catheter assembly
            Image("GameIVNeedleItem")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: itemWidth, height: itemHeight)
                .opacity(needleRetractOpacity)
                .shadow(
                    color: Color(red: 0/255, green: 229/255, blue: 255/255).opacity(isIVDragging ? 1.0 : (canPokeIV ? 0.95 : 0.75)),
                    radius: isIVDragging ? 26 : (canPokeIV ? 22 : 14)
                )
            
            // 3-Second Countdown Badge
            if isCountingDown {
                Text("\(ivCountdownValue)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0/255, green: 229/255, blue: 255/255))
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.85))
                    .overlay(
                        Circle().stroke(Color(red: 0/255, green: 229/255, blue: 255/255), lineWidth: 2.5)
                    )
                    .clipShape(Circle())
                    .shadow(color: Color(red: 0/255, green: 229/255, blue: 255/255).opacity(0.85), radius: 10)
                    .offset(y: -itemHeight * 0.5 - 18)
            }
            
            // Prompt Text Box
            if currentStep == .insertIV {
                Text(ivPromptText)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.78))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
                    .offset(y: itemHeight * 0.5 + 16)
            }
        }
        .contentShape(Rectangle())
        .position(x: currentPos.x + advanceOffset.width, y: currentPos.y + advanceOffset.height)
        .gesture(
            DragGesture(coordinateSpace: .local)
                .onChanged { value in
                    guard currentStep == .insertIV && !isIVLockedToVein else { return }
                    isIVDragging = true
                    ivDragOffset = value.translation
                    
                    let curX = initialX + ivDragOffset.width
                    let curY = initialY + ivDragOffset.height
                    let dist = min(hypot(curX - veinCenter.x, curY - veinCenter.y), hypot(curX - targetCenter.x, curY - targetCenter.y))
                    
                    let overArm = (curX >= stageSize.width * 0.48) || (dist <= stageSize.width * 0.28)
                    let overVein = dist <= max(90, stageSize.width * 0.08)
                    
                    if isIVOverArm != overArm || isIVOverVein != overVein {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isIVOverArm = overArm
                            isIVOverVein = overVein
                        }
                    }
                    
                    if dist <= max(55, stageSize.width * 0.045) {
                        lockIVToVeinSwiftUI()
                    }
                }
                .onEnded { value in
                    guard currentStep == .insertIV && !isIVLockedToVein else { return }
                    isIVDragging = false
                    let curX = initialX + ivDragOffset.width
                    let curY = initialY + ivDragOffset.height
                    let dist = min(hypot(curX - veinCenter.x, curY - veinCenter.y), hypot(curX - targetCenter.x, curY - targetCenter.y))
                    if dist <= max(90, stageSize.width * 0.08) {
                        lockIVToVeinSwiftUI()
                    } else {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                            ivDragOffset = .zero
                            isIVOverArm = false
                            isIVOverVein = false
                        }
                    }
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    if currentStep == .insertIV && isIVLockedToVein && canPokeIV && !isIVInserted {
                        pokeInsertNeedleSwiftUI()
                    }
                }
        )
    }
    
    private var ivPromptText: String {
        if isIVInserted {
            return "IV placed safely!"
        } else if canPokeIV {
            return "Poke to insert!"
        } else if isCountingDown {
            return "Ready in \(ivCountdownValue)..."
        } else {
            return "Guide the needle to the vein!"
        }
    }
    
    private func lockIVToVeinSwiftUI() {
        guard !isIVLockedToVein else { return }
        isIVDragging = false
        withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
            isIVLockedToVein = true
            isIVOverArm = true
            isIVOverVein = true
        }
        HapticManager.shared.mediumTap()
        startIVCountdownSwiftUI()
    }
    
    private func startIVCountdownSwiftUI() {
        ivCountdownValue = 3
        isCountingDown = true
        
        let timer = Timer(timeInterval: 1.0, repeats: true) { timer in
            if ivCountdownValue > 1 {
                ivCountdownValue -= 1
                HapticManager.shared.lightTap()
            } else {
                timer.invalidate()
                withAnimation {
                    isCountingDown = false
                    canPokeIV = true
                }
                HapticManager.shared.successNotification()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
    }
    
    private func pokeInsertNeedleSwiftUI() {
        guard canPokeIV && !isIVInserted else { return }
        canPokeIV = false
        isIVInserted = true
        IVAudioManager.shared.playShotSound()
        HapticManager.shared.successNotification()
        
        // Needle plunges and immediately becomes the soft IV catheter asset
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            needleRetractOpacity = 0.0
            catheterOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                currentStep = .tapeIV
            }
        }
    }
    
    // MARK: - Floating Interactive IV Tape Component (Step 9)
    @ViewBuilder
    private func tapeDropZoneView(stageSize: CGSize) -> some View {
        let zoneWidth = stageSize.width * 0.16
        let zoneHeight = stageSize.height * 0.19
        let centerX = stageSize.width * 0.697 + stageSize.width * 0.012
        let centerY = stageSize.height * 0.608 - stageSize.height * 0.010
        
        Circle()
            .strokeBorder(
                Color(red: 0/255, green: 229/255, blue: 255/255).opacity(isTapeOverTarget ? 0.95 : 0.6),
                style: StrokeStyle(lineWidth: 3, dash: [8, 6])
            )
            .background(
                Circle()
                    .fill(Color(red: 0/255, green: 229/255, blue: 255/255).opacity(isTapeOverTarget ? 0.22 : 0.08))
            )
            .frame(width: zoneWidth, height: zoneHeight)
            .position(x: centerX, y: centerY)
            .shadow(
                color: Color(red: 0/255, green: 229/255, blue: 255/255).opacity(isTapeOverTarget ? 0.85 : 0.35),
                radius: isTapeOverTarget ? 24 : 12
            )
            .scaleEffect(isTapeOverTarget ? 1.06 : 1.0)
            .animation(.easeInOut(duration: 0.25), value: isTapeOverTarget)
            .allowsHitTesting(false)
    }
    
    @ViewBuilder
    private func floatingTapeItem(stageSize: CGSize) -> some View {
        let itemWidth = stageSize.width * 0.205
        let itemHeight = itemWidth * (192.0 / 439.0)
        let initialX = stageSize.width * 0.255
        let initialY = stageSize.height * 0.178
        let targetCenter = CGPoint(x: stageSize.width * 0.697 + stageSize.width * 0.012, y: stageSize.height * 0.608 - stageSize.height * 0.010)
        
        let floatOffset: CGFloat = (isFloating && !isTapeDragging && !isTapePlaced) ? -10 : 0
        let currentPos: CGPoint = isTapePlaced ? targetCenter : CGPoint(x: initialX + tapeDragOffset.width, y: initialY + tapeDragOffset.height + floatOffset)
        
        ZStack {
            Image("GameTapeItem")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: itemWidth, height: itemHeight)
                .opacity(isTapePlaced ? 0 : 1)
                .shadow(
                    color: isTapePlaced ? Color.black.opacity(0.25) : Color(red: 0/255, green: 229/255, blue: 255/255).opacity(isTapeDragging ? 0.95 : 0.7),
                    radius: isTapePlaced ? 6 : (isTapeDragging ? 22 : 14)
                )
            
            // Prompt Text Box
            if currentStep == .tapeIV {
                Text(isTapePlaced ? "IV secured safely!" : "Tape the IV down!")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.78))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
                    .offset(y: itemHeight * 0.5 + 16)
            }
        }
        .rotationEffect(.degrees(isTapePlaced ? 43 : 0))
        .contentShape(Rectangle())
        .position(x: currentPos.x, y: currentPos.y)
        .gesture(
            DragGesture(coordinateSpace: .local)
                .onChanged { value in
                    guard currentStep == .tapeIV && !isTapePlaced else { return }
                    isTapeDragging = true
                    tapeDragOffset = value.translation
                    
                    let curX = initialX + tapeDragOffset.width
                    let curY = initialY + tapeDragOffset.height
                    let dist = hypot(curX - targetCenter.x, curY - targetCenter.y)
                    
                    let overArm = (curX >= stageSize.width * 0.48) || (dist <= stageSize.width * 0.28)
                    let overTarget = dist <= max(90, stageSize.width * 0.08)
                    
                    if isTapeOverArm != overArm || isTapeOverTarget != overTarget {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isTapeOverArm = overArm
                            isTapeOverTarget = overTarget
                        }
                    }
                    
                    if dist <= max(55, stageSize.width * 0.045) {
                        lockTapeToArmSwiftUI()
                    }
                }
                .onEnded { value in
                    guard currentStep == .tapeIV && !isTapePlaced else { return }
                    isTapeDragging = false
                    let curX = initialX + tapeDragOffset.width
                    let curY = initialY + tapeDragOffset.height
                    let dist = hypot(curX - targetCenter.x, curY - targetCenter.y)
                    if dist <= max(90, stageSize.width * 0.08) {
                        lockTapeToArmSwiftUI()
                    } else {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                            tapeDragOffset = .zero
                            isTapeOverArm = false
                            isTapeOverTarget = false
                        }
                    }
                }
        )
    }
    
    private func lockTapeToArmSwiftUI() {
        guard !isTapePlaced else { return }
        isTapeDragging = false
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            isTapePlaced = true
            isTapeOverArm = false
            isTapeOverTarget = false
        }
        IVAudioManager.shared.playBandageSound()
        HapticManager.shared.successNotification()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                currentStep = .completed
                showSuccessModal = true
            }
            IVAudioManager.shared.playYouDidItSound()
        }
    }
    
    // MARK: - Floating Clear Bandage Component (Step 2)
    @ViewBuilder
    private func floatingBandageItem(stageSize: CGSize, elbowZoneRect: CGRect) -> some View {
        let bandageWidth = stageSize.width * 0.221
        let bandageHeight = stageSize.height * 0.200
        let initialX = stageSize.width * 0.254
        let initialY = stageSize.height * 0.145
        
        let floatOffset: CGFloat = (isFloating && !isBandageDragging) ? -10 : 0
        
        VStack(spacing: 6) {
            Image("GameBandageItem")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: bandageWidth, height: bandageHeight)
                .shadow(
                    color: Color(red: 0/255, green: 229/255, blue: 255/255).opacity(isBandageDragging ? 1.0 : 0.85),
                    radius: isBandageDragging ? 26 : 14
                )
                .shadow(
                    color: Color(red: 0/255, green: 168/255, blue: 255/255).opacity(isBandageDragging ? 0.8 : 0.6),
                    radius: isBandageDragging ? 40 : 26
                )
                .scaleEffect(isBandageDragging ? 1.10 : 1.0)
            
            if !isBandageDragging {
                Text("Drag bandage to elbow!")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0/255, green: 229/255, blue: 255/255))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.72))
                    .clipShape(Capsule())
                    .transition(.opacity)
            }
        }
        .position(x: initialX, y: initialY)
        .offset(x: bandageDragOffset.width, y: bandageDragOffset.height + floatOffset)
        .gesture(
            DragGesture(coordinateSpace: .local)
                .onChanged { value in
                    isBandageDragging = true
                    bandageDragOffset = value.translation
                    
                    let currentX = initialX + bandageDragOffset.width
                    let currentY = initialY + bandageDragOffset.height
                    
                    let buffer: CGFloat = 45
                    let isInside = (
                        currentX >= elbowZoneRect.minX - buffer &&
                        currentX <= elbowZoneRect.maxX + buffer &&
                        currentY >= elbowZoneRect.minY - buffer &&
                        currentY <= elbowZoneRect.maxY + buffer
                    )
                    
                    if isInside != isBandageOverElbow {
                        isBandageOverElbow = isInside
                        if isInside {
                            HapticManager.shared.lightTap()
                        }
                    }
                }
                .onEnded { _ in
                    if isBandageOverElbow {
                        IVAudioManager.shared.playBandageSound()
                        HapticManager.shared.successNotification()
                        withAnimation(.easeOut(duration: 0.25)) {
                            isBandagePlaced = true
                            isBandageDragging = false
                            isBandageOverElbow = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                currentStep = .removeBandage
                            }
                        }
                    } else {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                            bandageDragOffset = .zero
                            isBandageDragging = false
                            isBandageOverElbow = false
                        }
                    }
                }
        )
    }
    
    // MARK: - Remove Bandage Action (Step 3)
    private func removeBandageAction() {
        guard currentStep == .removeBandage else { return }
        IVAudioManager.shared.playBandageSound()
        HapticManager.shared.lightTap()
        withAnimation(.easeInOut(duration: 0.55)) {
            bandagePeelOffset = CGSize(width: -85, height: -110)
            bandagePeelRotation = -24
            bandagePeelOpacity = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.58) {
            isBandagePeeled = true
            isBandagePlaced = false
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                currentStep = .washcloth
                washclothDragOffset = .zero
                washclothSweepCount = 0
                washclothCursorSide = 0
                washclothCursorSideY = 0
            }
        }
    }

    // MARK: - Floating Washcloth Component (Step 4)
    @ViewBuilder
    private func floatingWashclothItem(stageSize: CGSize, lotionCenter: CGPoint, lotionSize: CGSize) -> some View {
        let washclothWidth = stageSize.width * 0.175
        let washclothHeight = stageSize.height * 0.255
        let initialX = stageSize.width * 0.254
        let initialY = stageSize.height * 0.165
        
        let floatOffset: CGFloat = (isFloating && !isWashclothDragging) ? -10 : 0
        
        VStack(spacing: 6) {
            Image("GameWashclothItem")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: washclothWidth, height: washclothHeight)
                .rotationEffect(.degrees(washclothPivotAngle))
                .shadow(
                    color: Color(red: 0/255, green: 229/255, blue: 255/255).opacity(isWashclothDragging ? 1.0 : 0.85),
                    radius: isWashclothDragging ? 26 : 14
                )
                .shadow(
                    color: Color(red: 0/255, green: 168/255, blue: 255/255).opacity(isWashclothDragging ? 0.8 : 0.6),
                    radius: isWashclothDragging ? 40 : 26
                )
                .scaleEffect(isWashclothDragging ? 1.08 : 1.0)
            
            Text(washclothPromptText)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(isWashclothDragging ? .white : Color(red: 0/255, green: 229/255, blue: 255/255))
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(isWashclothDragging ? Color(red: 0/255, green: 114/255, blue: 255/255).opacity(0.9) : Color.black.opacity(0.72))
                .clipShape(Capsule())
                .transition(.opacity)
        }
        .position(x: initialX, y: initialY)
        .offset(x: washclothDragOffset.width, y: washclothDragOffset.height + floatOffset)
        .gesture(
            DragGesture(coordinateSpace: .local)
                .onChanged { value in
                    isWashclothDragging = true
                    let prevX = washclothDragOffset.width
                    washclothDragOffset = value.translation
                    
                    let moveDx = value.translation.width - prevX
                    let targetPivot = max(-18.0, min(18.0, Double(moveDx * 2.2)))
                    withAnimation(.interactiveSpring(response: 0.12, dampingFraction: 0.65)) {
                        washclothPivotAngle = targetPivot
                    }
                    
                    let cursorX = (initialX - washclothWidth / 2) + value.startLocation.x + value.translation.width
                    let cursorY = (initialY - washclothHeight / 2) + value.startLocation.y + value.translation.height
                    
                    checkCursorWipeSwiftUI(
                        cursor: CGPoint(x: cursorX, y: cursorY),
                        lotionCenter: lotionCenter,
                        lotionSize: lotionSize
                    )
                }
                .onEnded { _ in
                    isWashclothDragging = false
                    IVAudioManager.shared.stopClothWipeSound()
                    washclothCursorSide = 0
                    washclothCursorSideY = 0
                    withAnimation(.easeOut(duration: 0.2)) {
                        washclothPivotAngle = 0
                    }
                    if washclothSweepCount < totalWipeSweeps {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                            washclothDragOffset = .zero
                        }
                    }
                }
        )
    }

    private var washclothPromptText: String {
        if washclothSweepCount >= totalWipeSweeps {
            return "Arm clean and ready!"
        }
        let completedPasses = washclothSweepCount / 2
        let remainingPasses = 3 - completedPasses
        if remainingPasses == 2 {
            return "Wipe 2 more times!"
        } else if remainingPasses == 1 {
            return "Almost clean! 1 more time!"
        } else if isWashclothDragging {
            return "Wipe back and forth over lotion!"
        } else {
            return "Wipe away the lotion!"
        }
    }

    private func checkCursorWipeSwiftUI(cursor: CGPoint, lotionCenter: CGPoint, lotionSize: CGSize) {
        let deadbandX: CGFloat = max(24, lotionSize.width * 0.18)
        let deadbandY: CGFloat = max(24, lotionSize.height * 0.18)
        let maxHoriz: CGFloat = max(lotionSize.width * 0.95, 80)
        let maxVert: CGFloat = max(lotionSize.height * 0.95, 70)
        
        let distX = abs(cursor.x - lotionCenter.x)
        let distY = abs(cursor.y - lotionCenter.y)
        let isOver = distX <= maxHoriz && distY <= maxVert
        isWashclothOverLotion = isOver
        
        guard isOver else {
            washclothCursorSide = 0
            washclothCursorSideY = 0
            IVAudioManager.shared.stopClothWipeSound()
            return
        }
        
        if isWashclothDragging && washclothSweepCount < totalWipeSweeps {
            IVAudioManager.shared.startClothWipeSound()
        }
        
        // 1. Horizontal crossing across lotion center
        if washclothCursorSide == 0 {
            if cursor.x < lotionCenter.x - deadbandX {
                washclothCursorSide = -1 // left
            } else if cursor.x > lotionCenter.x + deadbandX {
                washclothCursorSide = 1 // right
            }
        } else if washclothCursorSide == -1 && cursor.x > lotionCenter.x + deadbandX {
            washclothCursorSide = 1
            registerSweepSwiftUI()
        } else if washclothCursorSide == 1 && cursor.x < lotionCenter.x - deadbandX {
            washclothCursorSide = -1
            registerSweepSwiftUI()
        }
        
        // 2. Vertical crossing across lotion center (along arm axis)
        if washclothCursorSideY == 0 {
            if cursor.y < lotionCenter.y - deadbandY {
                washclothCursorSideY = -1 // top
            } else if cursor.y > lotionCenter.y + deadbandY {
                washclothCursorSideY = 1 // bottom
            }
        } else if washclothCursorSideY == -1 && cursor.y > lotionCenter.y + deadbandY {
            washclothCursorSideY = 1
            registerSweepSwiftUI()
        } else if washclothCursorSideY == 1 && cursor.y < lotionCenter.y - deadbandY {
            washclothCursorSideY = -1
            registerSweepSwiftUI()
        }
    }

    private func registerSweepSwiftUI() {
        guard washclothSweepCount < totalWipeSweeps else { return }
        washclothSweepCount += 1
        HapticManager.shared.lightTap()
        
        if washclothSweepCount >= totalWipeSweeps {
            IVAudioManager.shared.stopClothWipeSound(reset: true)
            HapticManager.shared.successNotification()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    currentStep = .tourniquet
                    isWashclothDragging = false
                    washclothDragOffset = .zero
                    washclothCursorSide = 0
                    washclothCursorSideY = 0
                }
            }
        }
    }
    
    // MARK: - Floating Ointment Component (Step 1)
    @ViewBuilder
    private func floatingOintmentItem(stageSize: CGSize, elbowZoneRect: CGRect) -> some View {
        let tubeWidth = stageSize.width * 0.143
        let tubeHeight = stageSize.height * 0.325
        let initialX = stageSize.width * 0.254
        let initialY = stageSize.height * 0.188
        
        let floatOffset: CGFloat = (isFloating && !isOintmentDragging) ? -10 : 0
        
        VStack(spacing: 6) {
            ZStack {
                Image("GameOintmentItem")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: tubeWidth, height: tubeHeight)
                    .shadow(
                        color: Color(red: 0/255, green: 215/255, blue: 255/255).opacity(isOintmentDragging ? 1.0 : 0.85),
                        radius: isOintmentDragging ? 26 : 14
                    )
                    .shadow(
                        color: Color(red: 0/255, green: 168/255, blue: 255/255).opacity(isOintmentDragging ? 0.8 : 0.6),
                        radius: isOintmentDragging ? 40 : 26
                    )
                    .scaleEffect(isSqueezing ? 0.94 : (isOintmentDragging ? 1.10 : 1.0))
                    .rotationEffect(.degrees(isSqueezing ? -3 : 0))
                
                // Circular Squeeze Progress Gauge
                if isSqueezing || squeezeProgress > 0 {
                    ZStack {
                        Circle()
                            .stroke(Color.black.opacity(0.55), lineWidth: 4.5)
                        Circle()
                            .trim(from: 0, to: squeezeProgress)
                            .stroke(Color(red: 0/255, green: 229/255, blue: 255/255), style: StrokeStyle(lineWidth: 4.5, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text("\(Int(squeezeProgress * 100))%")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    .frame(width: 48, height: 48)
                    .transition(.opacity)
                }
            }
            
            if !isOintmentDragging && !isSqueezing {
                Text("Drag ointment to elbow!")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0/255, green: 229/255, blue: 255/255))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.72))
                    .clipShape(Capsule())
                    .transition(.opacity)
            } else if isSqueezing {
                Text("Hold to squeeze!")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Color(red: 0/255, green: 114/255, blue: 255/255).opacity(0.92))
                    .clipShape(Capsule())
                    .transition(.opacity)
            }
        }
        .position(x: initialX, y: initialY)
        .offset(x: ointmentDragOffset.width, y: ointmentDragOffset.height + floatOffset)
        .gesture(
            DragGesture(coordinateSpace: .local)
                .onChanged { value in
                    isOintmentDragging = true
                    ointmentDragOffset = value.translation
                    
                    let currentNozzleX = initialX + ointmentDragOffset.width
                    let currentNozzleY = initialY + ointmentDragOffset.height + tubeHeight * 0.35
                    
                    let buffer: CGFloat = 45
                    let isInside = (
                        currentNozzleX >= elbowZoneRect.minX - buffer &&
                        currentNozzleX <= elbowZoneRect.maxX + buffer &&
                        currentNozzleY >= elbowZoneRect.minY - buffer &&
                        currentNozzleY <= elbowZoneRect.maxY + buffer
                    )
                    
                    if isInside {
                        if !isOintmentOverElbow {
                            isOintmentOverElbow = true
                            HapticManager.shared.lightTap()
                        }
                        startSwiftUISqueeze()
                    } else {
                        if isOintmentOverElbow {
                            isOintmentOverElbow = false
                        }
                        stopSwiftUISqueeze()
                    }
                }
                .onEnded { _ in
                    isOintmentDragging = false
                    stopSwiftUISqueeze()
                    
                    if squeezeProgress >= 1.0 {
                        completeOintmentStep()
                    } else if isOintmentOverElbow {
                        // User can press again to continue squeezing
                    } else {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                            ointmentDragOffset = .zero
                            isOintmentOverElbow = false
                        }
                    }
                }
        )
    }
    
    private func startSwiftUISqueeze() {
        guard squeezeTimer == nil, squeezeProgress < 1.0 else { return }
        isSqueezing = true
        IVAudioManager.shared.playSlimeSound()
        squeezeTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            squeezeProgress = min(1.0, squeezeProgress + 0.05 / 1.2)
            if squeezeProgress >= 1.0 {
                timer.invalidate()
                squeezeTimer = nil
                completeOintmentStep()
            }
        }
    }
    
    private func stopSwiftUISqueeze() {
        isSqueezing = false
        squeezeTimer?.invalidate()
        squeezeTimer = nil
    }
    
    private func completeOintmentStep() {
        stopSwiftUISqueeze()
        HapticManager.shared.successNotification()
        withAnimation(.easeOut(duration: 0.35)) {
            currentStep = .bandage
            isOintmentDragging = false
            isOintmentOverElbow = false
        }
    }
    
    // MARK: - Success Celebration Overlay
    @ViewBuilder
    private var successOverlayView: some View {
        ZStack {
            Color.black.opacity(0.50)
                .ignoresSafeArea()
            
            // Confetti animation behind You Did It asset
            ConfettiAnimationView()
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            VStack(spacing: 22) {
                Image("GameYouDidIt")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 460)
                    .shadow(color: Color.black.opacity(0.7), radius: 20, x: 0, y: 10)
                
                Button(action: {
                    HapticManager.shared.buttonTap()
                    resetGame()
                }) {
                    Text("Play Again")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 13)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0/255, green: 198/255, blue: 255/255), Color(red: 0/255, green: 114/255, blue: 255/255)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 0, green: 114/255, blue: 255/255).opacity(0.45), radius: 12, x: 0, y: 6)
                }
            }
            .padding(.horizontal, 30)
            .scaleEffect(isSuccessModalPresented ? 1.0 : 0.85)
            .animation(.spring(response: 0.45, dampingFraction: 0.75), value: isSuccessModalPresented)
        }
    }
    
    // MARK: - Bottom Navigation Bar (5 Tabs)
    @ViewBuilder
    private func bottomBarView(availableWidth: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Image("Bottom_Toolbar_Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: availableWidth, height: height)
                .clipped()
            
            HStack(spacing: 4) {
                // Preparations Tab
                Button(action: {
                    HapticManager.shared.buttonTap()
                    IVAudioManager.shared.stopBackgroundMusic()
                    if let onDismiss = onDismiss {
                        onDismiss()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image("Isolated_Preparations_Not_Selected")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: height)
                }
                .accessibilityLabel("Preparations tab")
                
                // Glossary Tab
                Button(action: {
                    HapticManager.shared.buttonTap()
                }) {
                    Image("Isolated_Glossary_Not_Selected")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: height)
                }
                .accessibilityLabel("Glossary tab")
                
                // Anatomy Explorer Tab
                Button(action: {
                    HapticManager.shared.buttonTap()
                }) {
                    Image("Isolated_Anat_Explorer_Not_Selected")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: height)
                }
                .accessibilityLabel("Anatomy Explorer tab")
                
                // Gallery Tab
                Button(action: {
                    HapticManager.shared.buttonTap()
                }) {
                    Image("Isolated_Gallery_Not_Selected")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: height)
                }
                .accessibilityLabel("Gallery tab")
                
                // Games Tab (Current Active)
                Button(action: {
                    HapticManager.shared.buttonTap()
                    resetGame()
                }) {
                    Image("Isolated_Games_Selected")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: height)
                }
                .accessibilityLabel("Games tab, currently active. Tap to reset game.")
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: 1366)
        }
        .frame(width: availableWidth, height: height)
        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: -2)
    }
    
    // MARK: - Helper Methods
    private func resetGame() {
        stopSwiftUISqueeze()
        IVAudioManager.shared.stopClothWipeSound(reset: true)
        IVAudioManager.shared.stopClothWetWipeSound(reset: true)
        IVAudioManager.shared.stopYouDidItSound(reset: true)
        withAnimation(.spring()) {
            currentStep = .ointment
            isBandPlaced = false
            bandDragOffset = .zero
            isBandDragging = false
            isBandOverTarget = false
            
            isBandagePlaced = false
            isBandagePeeled = false
            bandageDragOffset = .zero
            bandagePeelOffset = .zero
            bandagePeelRotation = 0.0
            bandagePeelOpacity = 1.0
            isBandageDragging = false
            isBandageOverElbow = false
            
            washclothDragOffset = .zero
            isWashclothDragging = false
            washclothPivotAngle = 0.0
            isWashclothOverLotion = false
            washclothCursorSide = 0
            washclothCursorSideY = 0
            washclothSweepCount = 0
            
            isPacketRipped = false
            showRipEffect = false
            packetWipeDragOffset = .zero
            isPacketWipeDragging = false
            packetWipePivotAngle = 0.0
            isPacketWipeOverElbow = false
            packetWipeCursorSide = 0
            packetWipeCursorSideY = 0
            packetWipeSweepCount = 0
            
            ivDragOffset = .zero
            isIVDragging = false
            isIVLockedToVein = false
            isIVOverVein = false
            isIVOverArm = false
            ivCountdownValue = 3
            isCountingDown = false
            canPokeIV = false
            isIVInserted = false
            needleRetractOpacity = 1.0
            catheterOpacity = 0.0
            
            tapeDragOffset = .zero
            isTapeDragging = false
            isTapePlaced = false
            isTapeOverArm = false
            isTapeOverTarget = false
            
            ointmentDragOffset = .zero
            isOintmentDragging = false
            isOintmentOverElbow = false
            isSqueezing = false
            squeezeProgress = 0.0
            showSuccessModal = false
        }
        startIVIntroSequence()
    }
    
    private func startIVIntroSequence() {
        isBagBouncedIn = false
        isBagOpen = false
        isOintmentEmerged = false
        introStepText = "Getting Supplies Ready..."
        
        // Step 1: Slide & bounce closed bag onto table from off-screen left
        withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 60, damping: 9.2, initialVelocity: 6)) {
            isBagBouncedIn = true
        }
        
        // Step 2: Pop bag open with audio once settled
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            IVAudioManager.shared.playBagOpenSound()
            HapticManager.shared.lightTap()
            withAnimation(.easeInOut(duration: 0.28)) {
                isBagOpen = true
            }
        }
        
        // Step 3: Ointment emerges upwards out of the open bag
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.32) {
            introStepText = nil
            withAnimation(.spring(response: 0.65, dampingFraction: 0.68, blendDuration: 0)) {
                isOintmentEmerged = true
            }
        }
    }
    
    private func calculateStageSize(containerWidth: CGFloat, containerHeight: CGFloat, aspectRatio: CGFloat) -> CGSize {
        let widthBasedHeight = containerWidth / aspectRatio
        if widthBasedHeight <= containerHeight {
            return CGSize(width: containerWidth, height: widthBasedHeight)
        } else {
            return CGSize(width: containerHeight * aspectRatio, height: containerHeight)
        }
    }
}

// MARK: - Confetti Particle Animation (Behind You Did It)
struct ConfettiParticle: Identifiable {
    let id: Int
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var color: Color
    var rotation: Double
    var rotationSpeed: Double
    var vx: CGFloat
    var vy: CGFloat
    var wobble: Double
    var wobbleSpeed: Double
    var isCircle: Bool
}

struct ConfettiAnimationView: View {
    @State private var particles: [ConfettiParticle] = []
    
    private static let colors: [Color] = [
        Color(red: 1.0, green: 0.30, blue: 0.43), // Bright Pink
        Color(red: 1.0, green: 0.72, blue: 0.01), // Sunny Gold
        Color(red: 0.0, green: 0.78, blue: 1.0),  // Electric Cyan
        Color(red: 0.62, green: 0.31, blue: 0.87),// Riley Purple
        Color(red: 0.02, green: 0.84, blue: 0.63),// Mint Green
        Color(red: 1.0, green: 0.62, blue: 0.0),  // Bright Orange
        Color(red: 0.28, green: 0.79, blue: 0.90) // Sky Blue
    ]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                for particle in particles {
                    let animY = (particle.y + particle.vy * CGFloat(now * 60)).truncatingRemainder(dividingBy: max(size.height + 60, 100)) - 30
                    let animX = particle.x + sin(particle.wobble + now * particle.wobbleSpeed) * 15
                    let rot = particle.rotation + particle.rotationSpeed * now * 60
                    let flip = cos(particle.wobble + now * particle.wobbleSpeed)
                    
                    var pContext = context
                    pContext.translateBy(x: animX, y: animY)
                    pContext.rotate(by: Angle.degrees(rot))
                    pContext.scaleBy(x: flip, y: 1.0)
                    
                    let rect = CGRect(x: -particle.width / 2, y: -particle.height / 2, width: particle.width, height: particle.height)
                    if particle.isCircle {
                        pContext.fill(Path(ellipseIn: rect), with: .color(particle.color))
                    } else {
                        pContext.fill(Path(roundedRect: rect, cornerRadius: 2.5), with: .color(particle.color))
                    }
                }
            }
        }
        .onAppear {
            setupParticles()
        }
    }
    
    private func setupParticles() {
        var newParticles: [ConfettiParticle] = []
        for i in 0..<110 {
            let color = Self.colors[i % Self.colors.count]
            let w = CGFloat.random(in: 8...14)
            let h = CGFloat.random(in: 12...22)
            let p = ConfettiParticle(
                id: i,
                x: CGFloat.random(in: 10...1356),
                y: CGFloat.random(in: 0...1024),
                width: w,
                height: h,
                color: color,
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -3...3),
                vx: CGFloat.random(in: -1.5...1.5),
                vy: CGFloat.random(in: 2.2...4.5),
                wobble: Double.random(in: 0...(2 * .pi)),
                wobbleSpeed: Double.random(in: 2.5...5.0),
                isCircle: i % 4 == 0
            )
            newParticles.append(p)
        }
        particles = newParticles
    }
}

#if DEBUG
struct IVGameView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            IVGameView()
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad Pro Landscape")
                .previewInterfaceOrientation(.landscapeLeft)
            
            IVGameView()
                .previewDevice("iPhone 16 Pro")
                .previewDisplayName("iPhone 16 Pro")
        }
    }
}
#endif
