import SwiftUI
import AVFoundation

public struct AnatomicalOrganItem: Identifiable {
    public let id: String
    public let name: String
    public let left: CGFloat
    public let top: CGFloat
    public let width: CGFloat
    public let height: CGFloat
    public let zIndex: Double
    public let imageName: String

    public init(id: String, name: String, left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat, zIndex: Double, imageName: String) {
        self.id = id
        self.name = name
        self.left = left
        self.top = top
        self.width = width
        self.height = height
        self.zIndex = zIndex
        self.imageName = imageName
    }
}

public struct AnatomyExplorerView: View {
    public var onBackToHome: () -> Void
    public var onSettingsTapped: () -> Void
    
    // Animation states
    @State private var isLowered = false
    @State private var isRisingUp = false
    @State private var litBulbs: Set<Int> = []
    @State private var flickeringBulbs: Set<Int> = []
    @State private var isMarqueeChasing = false
    @State private var isParting = false
    @State private var curtainsCleared = false
    @State private var curtainBackdropOpacity: Double = 1.0
    @State private var curtainClosedOpacity: Double = 1.0
    @State private var curtainPartedOpacity: Double = 0.0
    @State private var vignetteOpacity: Double = 1.0
    @State private var isPromptVisible = false
    @State private var chasePhase = 0
    @State private var chaseTimer: Timer? = nil
    @State private var selectedCharacter: String? = nil
    @State private var isConfirmed = false
    @State private var isMagnifierActive = false
    @State private var magnifierOffset: CGSize = .zero
    @State private var magnifierBaseOffset: CGSize = .zero
    @State private var magnifierTiltAngle: Angle = .zero
    @State private var magnifierDragAnchor: UnitPoint = .center
    @State private var lastDragLocationX: CGFloat = 0
    @State private var isDraggingMagnifier = false
    @State private var isMagnifierOverCharacter = false
    @State private var isSystemSelectionSecondary = false
    @State private var skinToneProgress: CGFloat = 0.50
    @State private var hasInteractedWithSkinTone = false
    @State private var isDraggingSkinTone = false
    @State private var selectedOrganId: String? = nil
    private let speechSynthesizer = AVSpeechSynthesizer()

    private let frontalOrgans: [AnatomicalOrganItem] = [
        AnatomicalOrganItem(id: "lungs", name: "Lungs", left: 0.0105, top: 0.2944, width: 0.9832, height: 0.3215, zIndex: 1, imageName: "AnatomyOrganLungs"),
        AnatomicalOrganItem(id: "kidneys", name: "Kidneys", left: 0.1195, top: 0.6639, width: 0.7484, height: 0.1301, zIndex: 2, imageName: "AnatomyOrganKidneys"),
        AnatomicalOrganItem(id: "intestines", name: "Intestines", left: 0.0000, top: 0.6260, width: 0.9539, height: 0.3171, zIndex: 3, imageName: "AnatomyOrganIntestines"),
        AnatomicalOrganItem(id: "stomach", name: "Stomach", left: 0.3270, top: 0.5723, width: 0.5430, height: 0.1478, zIndex: 4, imageName: "AnatomyOrganStomach"),
        AnatomicalOrganItem(id: "liver", name: "Liver", left: 0.1363, top: 0.5395, width: 0.7400, height: 0.1522, zIndex: 5, imageName: "AnatomyOrganLiver"),
        AnatomicalOrganItem(id: "heart", name: "Heart", left: 0.4507, top: 0.4043, width: 0.3774, height: 0.1541, zIndex: 6, imageName: "AnatomyOrganHeart"),
        AnatomicalOrganItem(id: "thyroid", name: "Thyroid", left: 0.3690, top: 0.2293, width: 0.2704, height: 0.0878, zIndex: 7, imageName: "AnatomyOrganThyroid"),
        AnatomicalOrganItem(id: "bladder", name: "Bladder", left: 0.2746, top: 0.8351, width: 0.4654, height: 0.1636, zIndex: 8, imageName: "AnatomyOrganBladder"),
        AnatomicalOrganItem(id: "brain", name: "Brain", left: 0.1782, top: 0.0000, width: 0.6478, height: 0.1889, zIndex: 9, imageName: "AnatomyOrganBrain")
    ]

    private let sideOrgans: [AnatomicalOrganItem] = [
        AnatomicalOrganItem(id: "lung", name: "Lungs", left: 0.0000, top: 0.2946, width: 0.9868, height: 0.3109, zIndex: 1, imageName: "AnatomyOrganLungSide"),
        AnatomicalOrganItem(id: "kidneys", name: "Kidneys", left: 0.1320, top: 0.7111, width: 0.7987, height: 0.1334, zIndex: 2, imageName: "AnatomyOrganKidneysSide"),
        AnatomicalOrganItem(id: "intestines", name: "Intestines", left: 0.0528, top: 0.6814, width: 0.9472, height: 0.3023, zIndex: 3, imageName: "AnatomyOrganIntestinesSide"),
        AnatomicalOrganItem(id: "stomach", name: "Stomach", left: 0.3003, top: 0.5393, width: 0.5974, height: 0.1564, zIndex: 4, imageName: "AnatomyOrganStomachSide"),
        AnatomicalOrganItem(id: "liver", name: "Liver", left: 0.1122, top: 0.5566, width: 0.6964, height: 0.1392, zIndex: 5, imageName: "AnatomyOrganLiverSide"),
        AnatomicalOrganItem(id: "heart", name: "Heart", left: 0.4488, top: 0.4155, width: 0.3927, height: 0.1555, zIndex: 6, imageName: "AnatomyOrganHeartSide"),
        AnatomicalOrganItem(id: "thyroid", name: "Thyroid", left: 0.3597, top: 0.2486, width: 0.2541, height: 0.0787, zIndex: 7, imageName: "AnatomyOrganThyroidSide"),
        AnatomicalOrganItem(id: "bladder", name: "Bladder", left: 0.3168, top: 0.8541, width: 0.4257, height: 0.1459, zIndex: 8, imageName: "AnatomyOrganBladderSide"),
        AnatomicalOrganItem(id: "brain", name: "Brain", left: 0.1992, top: 0.0000, width: 0.7063, height: 0.1891, zIndex: 9, imageName: "AnatomyOrganBrainSide")
    ]
    
    // 36 clockwise bulb coordinate percentages (in 1366x1024 coordinate space)
    private let bulbCoords: [(x: CGFloat, y: CGFloat)] = [
        // Top row (left to right)
        (0.2005, 0.2545), (0.2483, 0.2441), (0.3026, 0.2421), (0.3586, 0.2447),
        (0.4204, 0.2445), (0.4761, 0.2452), (0.5286, 0.2443), (0.5799, 0.2457),
        (0.6403, 0.2479), (0.6944, 0.2462), (0.7479, 0.2453), (0.8001, 0.2552),
        // Right column (top to bottom)
        (0.8121, 0.3234), (0.8125, 0.3952), (0.8137, 0.4637), (0.8122, 0.5354),
        (0.8133, 0.6041), (0.8129, 0.6769),
        // Bottom row (right to left)
        (0.8014, 0.7483), (0.7496, 0.7584), (0.6949, 0.7577), (0.6413, 0.7566),
        (0.5847, 0.7552), (0.5294, 0.7575), (0.4731, 0.7573), (0.4185, 0.7571),
        (0.3622, 0.7567), (0.3067, 0.7548), (0.2523, 0.7575), (0.2010, 0.7477),
        // Left column (bottom to top)
        (0.1887, 0.6760), (0.1886, 0.6037), (0.1897, 0.5336), (0.1892, 0.4628),
        (0.1892, 0.3942), (0.1894, 0.3219)
    ]
    
    public init(onBackToHome: @escaping () -> Void, onSettingsTapped: @escaping () -> Void) {
        self.onBackToHome = onBackToHome
        self.onSettingsTapped = onSettingsTapped
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height
            let signWidth = min(proxy.size.width * (isLandscape ? 0.82 : 0.94), 860)
            let signHeight = signWidth * (1024.0 / 1366.0)
            
            ZStack {
                // 1. Revealed Stage Layer Underneath Curtains (Matching Screenshot)
                ZStack {
                    Image("AnatomyBG1")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                    
                    // Overhead Theatrical Follow Spotlight Cone (Layered under characters)
                    if let char = selectedCharacter {
                        Image("AnatomySpotlightCone")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: proxy.size.width * 0.44)
                            .position(
                                x: characterCenterX(for: char, in: proxy.size.width),
                                y: proxy.size.height * 0.44
                            )
                            .blendMode(.screen)
                            .opacity(isConfirmed ? 0.82 : 0.78)
                            .animation(.spring(response: 0.42, dampingFraction: 0.82), value: char)
                            .allowsHitTesting(false)
                    }
                    
                    // Theatrical Floor Glow Pool (Layered under characters)
                    if let char = selectedCharacter {
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "fff8c8").opacity(0.65),
                                        Color(hex: "ffd764").opacity(0.35),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 4,
                                    endRadius: 75
                                )
                            )
                            .frame(width: proxy.size.width * 0.17, height: proxy.size.height * 0.058)
                            .position(
                                x: characterCenterX(for: char, in: proxy.size.width),
                                y: proxy.size.height * 0.85
                            )
                            .blendMode(.screen)
                            .animation(.spring(response: 0.42, dampingFraction: 0.82), value: char)
                    }
                    
                    // 4 Character Silhouette Layers (Always 100% Opaque)
                    characterLayer("AnatomyOlderBoy", charId: "older-boy", proxy: proxy)
                    characterLayer("AnatomyYoungerBoy", charId: "younger-boy", proxy: proxy)
                    characterLayer("AnatomyOlderGirl", charId: "older-girl", proxy: proxy)
                    characterLayer("AnatomyYoungerGirl", charId: "younger-girl", proxy: proxy)
                    
                    // Ambient Stage Dimmer (Darkens the rest of the stage outside the spotlight cone in a conical shape)
                    if let char = selectedCharacter {
                        Color(hex: "04030e").opacity(0.46)
                            .mask(
                                StageDimmerConeMask(centerX: characterCenterX(for: char, in: proxy.size.width))
                                    .fill(style: FillStyle(eoFill: true))
                                    .blur(radius: 14)
                            )
                            .animation(.spring(response: 0.42, dampingFraction: 0.82), value: char)
                            .allowsHitTesting(false)
                    }
                    
                    // Hitboxes for Interactive Selection
                    if areCharactersInteractive {
                        characterHitboxes(proxy: proxy)
                    }
                }
                .zIndex(1)
                .opacity(isConfirmed ? 0 : 1)
                .allowsHitTesting(!isConfirmed)
                
                // 1b. Dedicated Anatomy Exploration View (Revealed Upon 2nd Tap Confirmation)
                if isConfirmed, let char = selectedCharacter {
                    explorationDetailView(for: char, proxy: proxy)
                        .zIndex(2)
                        .transition(.opacity.combined(with: .scale(scale: 0.97)))
                }
                
                // 2. Dual Curtains Assembly (Parting Outward on Reveal - Slower Pacing)
                if !curtainsCleared {
                    ZStack {
                        // Static Backdrop prevents subpixel seam prior to parting
                        Image("AnatomyCurtainBG")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                            .opacity(curtainBackdropOpacity)
                        
                        // Left Curtain Panel
                        ZStack {
                            Image("AnatomyCurtainClosedLeft")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipped()
                                .opacity(curtainClosedOpacity)
                            
                            Image("AnatomyCurtainPartingLeft")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipped()
                                .opacity(curtainPartedOpacity)
                        }
                        .offset(x: isParting ? -proxy.size.width * 1.05 : 0)
                        
                        // Right Curtain Panel
                        ZStack {
                            Image("AnatomyCurtainClosedRight")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipped()
                                .opacity(curtainClosedOpacity)
                            
                            Image("AnatomyCurtainPartingRight")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipped()
                                .opacity(curtainPartedOpacity)
                        }
                        .offset(x: isParting ? proxy.size.width * 1.05 : 0)
                    }
                    .zIndex(2)
                    .allowsHitTesting(false)
                }
                
                // 3. Vignette & Ambient Light Overlay (Fades out when scene transitions to remove dim borders)
                if vignetteOpacity > 0 {
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.08),
                            Color(hex: "140826").opacity(0.45),
                            Color(hex: "0a0414").opacity(0.85)
                        ]),
                        center: .center,
                        startRadius: 50,
                        endRadius: max(proxy.size.width, proxy.size.height) * 0.75
                    )
                    .opacity(vignetteOpacity)
                    .allowsHitTesting(false)
                    .zIndex(3)
                }
                
                VStack(spacing: 0) {
                    // Top Apple Glass Navigation Bar
                    headerBar(isLandscape: isLandscape)
                        .zIndex(10)
                    
                    // Main Theatrical Stage Area
                    ZStack {
                        // Theatrical Sign Assembly (Suspended Cables Layered Behind Sign)
                        signAssembly(width: signWidth, height: signHeight)
                            .offset(y: signVerticalOffset(in: proxy.size.height))
                            .animation(.spring(response: 1.4, dampingFraction: 0.82), value: isLowered)
                            .animation(.easeInOut(duration: 2.8), value: isRisingUp)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(4)
                }
                
                // 5. Accessible Bottom Character Selection Prompt Banner (Full-Width Horizontal Banner)
                if isPromptVisible && !isConfirmed {
                    bottomPromptBar
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        ))
                        .zIndex(5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .allowsHitTesting(selectedCharacter != nil && !isConfirmed)
                }
            }
        }
        .onAppear {
            startAnimationSequence()
        }
        .onDisappear {
            stopChaseTimer()
        }
    }
    
    private func signVerticalOffset(in screenHeight: CGFloat) -> CGFloat {
        if isRisingUp {
            return -screenHeight * 1.35
        } else if isLowered {
            return 0
        } else {
            return -screenHeight * 1.35
        }
    }
    
    // MARK: - Header Bar
    @ViewBuilder
    private func headerBar(isLandscape: Bool) -> some View {
        HStack(spacing: 14) {
            Button(action: {
                if isConfirmed {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.75)) {
                        isConfirmed = false
                        magnifierOffset = .zero
                        magnifierBaseOffset = .zero
                        isMagnifierOverCharacter = false
                    }
                } else {
                    onBackToHome()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(Color(hex: "281442").opacity(0.85))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.18), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isConfirmed && selectedCharacter != nil ? characterDisplayName(for: selectedCharacter!) : "Anatomy Explorer")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 6, y: 2)
                
                if isConfirmed {
                    Text("Anatomy Explorer")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.75))
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onSettingsTapped) {
                    if let uiImg = UIImage(named: "Settings") {
                        Image(uiImage: uiImg)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 38, height: 38)
                    } else {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Color(hex: "281442").opacity(0.85))
                            .clipShape(Circle())
                    }
                }
                
                Button(action: onBackToHome) {
                    if let uiImg = UIImage(named: "Home") {
                        Image(uiImage: uiImg)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 38, height: 38)
                    } else {
                        Image(systemName: "house.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Color(hex: "281442").opacity(0.85))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: isLandscape ? 58 : 54)
        .background(
            Color(hex: "1e0f37").opacity(0.78)
                .background(.ultraThinMaterial)
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Sign Assembly
    @ViewBuilder
    private func signAssembly(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Rigging Cables Layered Behind the Sign
            HStack {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color(hex: "3c2846").opacity(0.85),
                                Color(hex: "ffd778").opacity(0.6)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3, height: 1400)
                    .offset(x: -width * 0.255, y: -700 - height * 0.22)
                    .shadow(color: .black.opacity(0.8), radius: 3)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color(hex: "3c2846").opacity(0.85),
                                Color(hex: "ffd778").opacity(0.6)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3, height: 1400)
                    .offset(x: width * 0.255, y: -700 - height * 0.22)
                    .shadow(color: .black.opacity(0.8), radius: 3)
                Spacer()
            }
            .allowsHitTesting(false)
            .zIndex(1)

            // Sign Frame (Layered in front of cables)
            Image("AnatomyTitleSign")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
                .zIndex(2)
            
            // Title Graphic
            Image("AnatomyTitle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
                .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                .zIndex(3)
            
            // 36 Bulb Overlays
            ForEach(0..<bulbCoords.count, id: \.self) { idx in
                let coord = bulbCoords[idx]
                let bulbDiameter = width * 0.0215
                let isLit = litBulbs.contains(idx)
                let isFlickering = flickeringBulbs.contains(idx)
                let chaseActive = isMarqueeChasing && ((idx + chasePhase) % 4 == 0)
                
                ZStack {
                    if !isLit && !isFlickering {
                        // Unlit socket cover
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "735438"),
                                        Color(hex: "3a221b"),
                                        Color(hex: "1c0e0b")
                                    ]),
                                    center: .topLeading,
                                    startRadius: 1,
                                    endRadius: bulbDiameter * 0.6
                                )
                            )
                            .frame(width: bulbDiameter, height: bulbDiameter)
                            .shadow(color: .black.opacity(0.6), radius: 2, y: 1)
                    }
                    
                    if isLit || isFlickering {
                        // Glowing Bloom Halo
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color(hex: "ffeb82").opacity(0.85),
                                        Color(hex: "ffaf19").opacity(0.65),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: bulbDiameter * (chaseActive ? 1.8 : 1.3)
                                )
                            )
                            .frame(width: bulbDiameter * (chaseActive ? 3.2 : 2.6), height: bulbDiameter * (chaseActive ? 3.2 : 2.6))
                            .scaleEffect(isFlickering ? 1.25 : (chaseActive ? 1.18 : 0.92))
                            .opacity(isFlickering ? 0.95 : (chaseActive ? 1.0 : 0.45))
                            .animation(.easeInOut(duration: 0.15), value: isFlickering)
                            .animation(.easeInOut(duration: 0.22), value: chasePhase)
                        
                        // Bright Core Filament
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color(hex: "fffadb"),
                                        Color(hex: "ffd447"),
                                        Color(hex: "ff9d00")
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: bulbDiameter * 0.5
                                )
                            )
                            .frame(width: bulbDiameter * (chaseActive ? 0.95 : 0.75), height: bulbDiameter * (chaseActive ? 0.95 : 0.75))
                            .scaleEffect(chaseActive ? 1.12 : 0.85)
                            .opacity(chaseActive ? 1.0 : 0.6)
                            .shadow(color: .white, radius: chaseActive ? 5 : 2)
                            .shadow(color: Color(hex: "ffc107"), radius: chaseActive ? 10 : 4)
                            .animation(.easeInOut(duration: 0.22), value: chasePhase)
                    }
                }
                .position(x: coord.x * width, y: coord.y * height)
            }
            .zIndex(4)
        }
        .frame(width: width, height: height)
        .shadow(color: Color.black.opacity(0.65), radius: 25, y: 15)
        .onTapGesture {
            shimmerBulbs()
        }
    }
    
    // MARK: - Animation Sequence
    private func startAnimationSequence() {
        stopChaseTimer()
        isLowered = false
        isRisingUp = false
        litBulbs.removeAll()
        flickeringBulbs.removeAll()
        isMarqueeChasing = false
        isParting = false
        curtainsCleared = false
        curtainBackdropOpacity = 1.0
        curtainClosedOpacity = 1.0
        curtainPartedOpacity = 0.0
        vignetteOpacity = 1.0
        isPromptVisible = false
        selectedCharacter = nil
        isConfirmed = false
        areCharactersInteractive = false
        
        // 1. Lower sign from rafters
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 1.4, dampingFraction: 0.82)) {
                isLowered = true
            }
        }
        
        // 2. Once centered (~1.4s), start clockwise sequential bulb flicker
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            let bulbCount = bulbCoords.count
            let step = 0.038
            
            for i in 0..<bulbCount {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * step) {
                    flickeringBulbs.insert(i)
                    if i % 4 == 0 {
                        HapticManager.shared.lightTap()
                    }
                    
                    // Settle to lit after 0.32s
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                        flickeringBulbs.remove(i)
                        litBulbs.insert(i)
                    }
                }
            }
            
            // 3. Once all bulbs go around the sign one time, begin alternating blinking!
            let totalCircuitTime = Double(bulbCount) * step + 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + totalCircuitTime) {
                flickeringBulbs.removeAll()
                litBulbs = Set(0..<bulbCount)
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    isMarqueeChasing = true
                }
                startChaseTimer()
                
                // 4. Alternating blinking runs briefly (~1.0s), then sign hoists up & curtains part slowly!
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    stopChaseTimer()
                    isMarqueeChasing = false
                        
                        // Slower sign rise up (2.8s)
                        withAnimation(.easeInOut(duration: 2.8)) {
                            isRisingUp = true
                        }
                        
                        // Vignette fades out to remove dim borders on reveal (1.8s)
                        withAnimation(.easeInOut(duration: 1.8)) {
                            vignetteOpacity = 0.0
                        }
                        
                        // Reveal character selection prompt bar as curtains sweep open (~0.6s)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            withAnimation(.easeInOut(duration: 0.75)) {
                                isPromptVisible = true
                                areCharactersInteractive = true
                            }
                        }
                        
                        // Backdrop fades out (0.65s)
                        withAnimation(.easeOut(duration: 0.65)) {
                            curtainBackdropOpacity = 0.0
                        }
                        
                        // Closed curtain crossfades to parted drape (0.85s)
                        withAnimation(.easeInOut(duration: 0.85)) {
                            curtainClosedOpacity = 0.0
                            curtainPartedOpacity = 1.0
                        }
                        
                        // Curtains glide outward slowly (3.2s)
                        withAnimation(.timingCurve(0.22, 1, 0.36, 1, duration: 3.2)) {
                            isParting = true
                        }
                        
                        // 6. Curtains cleared
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.25) {
                            curtainsCleared = true
                        }
                    }
                }
            }
        }
    
    private func shimmerBulbs() {
        guard isLowered && !isRisingUp else { return }
        HapticManager.shared.lightTap()
        for i in 0..<bulbCoords.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i % 6) * 0.05) {
                litBulbs.remove(i)
                flickeringBulbs.insert(i)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    flickeringBulbs.remove(i)
                    litBulbs.insert(i)
                }
            }
        }
    }
    
    private func startChaseTimer() {
        stopChaseTimer()
        chaseTimer = Timer.scheduledTimer(withTimeInterval: 0.20, repeats: true) { _ in
            chasePhase = (chasePhase + 1) % 4
        }
    }
    
    private func stopChaseTimer() {
        chaseTimer?.invalidate()
        chaseTimer = nil
    }
    
    // MARK: - Accessible Bottom Character Selection Prompt Banner (Spanning Horizontal Screen Length, Semi-transparent)
    @ViewBuilder
    private var bottomPromptBar: some View {
        Button(action: {
            if let char = selectedCharacter, !isConfirmed {
                handleCharacterTap(char)
            }
        }) {
            HStack(spacing: 9) {
                Circle()
                    .fill(isConfirmed ? Color(hex: "34d399") : Color(red: 0.98, green: 0.75, blue: 0.14))
                    .frame(width: isConfirmed ? 10 : 8, height: isConfirmed ? 10 : 8)
                    .shadow(
                        color: isConfirmed ? Color(hex: "34d399").opacity(0.85) : Color(red: 0.98, green: 0.75, blue: 0.14, opacity: 0.7),
                        radius: 4
                    )
                
                Text(promptText)
                    .font(.system(size: 15.5, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: isConfirmed ? [
                        Color(hex: "0e2e20").opacity(0.85),
                        Color(hex: "14442e").opacity(0.92)
                    ] : (selectedCharacter != nil ? [
                        Color(hex: "1a0d32").opacity(0.78),
                        Color(hex: "261248").opacity(0.86)
                    ] : [
                        Color(red: 0.06, green: 0.03, blue: 0.13, opacity: 0.65),
                        Color(red: 0.09, green: 0.05, blue: 0.19, opacity: 0.72)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .background(.ultraThinMaterial)
            )
            .overlay(
                Rectangle()
                    .fill(isConfirmed ? Color(hex: "34d399").opacity(0.45) : (selectedCharacter != nil ? Color(hex: "ffd700").opacity(0.35) : Color.white.opacity(0.16)))
                    .frame(height: 1.0),
                alignment: .top
            )
            .shadow(color: Color.black.opacity(0.32), radius: 10, y: -3)
        }
        .buttonStyle(PlainButtonStyle())
        .allowsHitTesting(selectedCharacter != nil && !isConfirmed)
    }

    private var promptText: String {
        if isConfirmed, let char = selectedCharacter {
            return "\(characterDisplayName(for: char)) confirmed! Ready to explore"
        } else if selectedCharacter != nil {
            return "Tap again to confirm"
        } else {
            return "Pick your character to get started"
        }
    }

    // MARK: - Character Selection & Spotlight Helpers
    @ViewBuilder
    private func characterLayer(_ name: String, charId: String, proxy: GeometryProxy) -> some View {
        let isSelected = selectedCharacter == charId
        
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
            .opacity(1.0)
            .scaleEffect(isSelected ? (isConfirmed ? 1.04 : 1.02) : 1.0, anchor: .bottom)
            .shadow(
                color: isSelected ? Color(hex: "ffd764").opacity(isConfirmed ? 0.9 : 0.75) : .clear,
                radius: isSelected ? (isConfirmed ? 10 : 6) : 0
            )
            .animation(.spring(response: 0.38, dampingFraction: 0.68), value: selectedCharacter)
            .animation(.spring(response: 0.34, dampingFraction: 0.62), value: isConfirmed)
    }
    
    @ViewBuilder
    private func characterHitboxes(proxy: GeometryProxy) -> some View {
        ZStack {
            Button(action: { handleCharacterTap("older-boy") }) {
                Color.clear
            }
            .frame(width: proxy.size.width * 0.22, height: proxy.size.height * 0.72)
            .position(x: proxy.size.width * 0.1951, y: proxy.size.height * 0.50)
            
            Button(action: { handleCharacterTap("younger-boy") }) {
                Color.clear
            }
            .frame(width: proxy.size.width * 0.18, height: proxy.size.height * 0.60)
            .position(x: proxy.size.width * 0.3832, y: proxy.size.height * 0.56)
            
            Button(action: { handleCharacterTap("older-girl") }) {
                Color.clear
            }
            .frame(width: proxy.size.width * 0.20, height: proxy.size.height * 0.72)
            .position(x: proxy.size.width * 0.6025, y: proxy.size.height * 0.50)
            
            Button(action: { handleCharacterTap("younger-girl") }) {
                Color.clear
            }
            .frame(width: proxy.size.width * 0.20, height: proxy.size.height * 0.60)
            .position(x: proxy.size.width * 0.8195, y: proxy.size.height * 0.56)
        }
    }
    
    private func handleCharacterTap(_ charId: String) {
        if selectedCharacter == charId && !isConfirmed {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.62)) {
                isConfirmed = true
                magnifierOffset = .zero
                magnifierBaseOffset = .zero
                isMagnifierOverCharacter = false
            }
            HapticManager.shared.successNotification()
        } else {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                selectedCharacter = charId
                isConfirmed = false
                hasInteractedWithSkinTone = false
                magnifierOffset = .zero
                magnifierBaseOffset = .zero
                isMagnifierOverCharacter = false
            }
            HapticManager.shared.lightTap()
        }
    }
    
    private func characterCenterX(for charId: String, in width: CGFloat) -> CGFloat {
        switch charId {
        case "older-boy": return width * 0.1951
        case "younger-boy": return width * 0.3832
        case "older-girl": return width * 0.6025
        case "younger-girl": return width * 0.8195
        default: return width * 0.5
        }
    }
    
    private func characterDisplayName(for charId: String) -> String {
        switch charId {
        case "older-boy": return "Older Boy"
        case "younger-boy": return "Younger Boy"
        case "older-girl": return "Older Girl"
        case "younger-girl": return "Younger Girl"
        default: return "Character"
        }
    }
    
    // MARK: - Exploration Detail View (Centered Character, Magnifier, System Selection, Skin Tone Picker)
    @ViewBuilder
    private func explorationDetailView(for charId: String, proxy: GeometryProxy) -> some View {
        let magWidth = proxy.size.width * 0.249
        let magHeight = proxy.size.height * 0.542
        let dockX = proxy.size.width * 0.185
        let dockY = proxy.size.height * 0.48
        let charHeight = proxy.size.height * 0.903
        let charCenterX = proxy.size.width * 0.50
        let charCenterY = proxy.size.height * 0.495

        ZStack {
            // Selected Stage Background (Matching Screenshot)
            Image("AnatomySelectedBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
            
            // Centered Solo Confirmed Character Standing on Stage Platform
            ZStack {
                Image(soloCharacterImageName(for: charId))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                if hasInteractedWithSkinTone {
                    Image(soloCharacterImageName(for: charId))
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(skinToneColor(for: skinToneProgress))
                        .transition(.opacity)
                }
            }
            .frame(height: charHeight)
            .position(x: charCenterX, y: charCenterY)
            .shadow(color: Color.black.opacity(0.35), radius: 16)
            .zIndex(10)

            // Assembled Organs Layer (Revealed through magnifying glass lens when Heart System is active)
            if isSystemSelectionSecondary {
                let organCfg = organLayoutConfig(for: charId)
                let organH = charHeight * organCfg.scale
                let charTopY = charCenterY - (charHeight / 2)
                let organCenterY = charTopY + (charHeight * organCfg.offsetY) + (organH / 2)
                let organCenterX = charCenterX + (proxy.size.width * organCfg.offsetX)
                
                let currentCenterX = dockX + magnifierOffset.width
                let currentCenterY = dockY + magnifierOffset.height - (magHeight * 0.216)
                let lensRadius = magWidth * 0.35
                
                let isOlder = (charId == "older-boy" || charId == "older-girl")
                let organBoxW = isOlder ? (organH * (303.0 / 1042.0)) : (organH * (477.0 / 1583.0))
                let organList = isOlder ? sideOrgans : frontalOrgans
                
                ZStack {
                    ForEach(organList) { organ in
                        let isSel = (selectedOrganId == organ.id)
                        let w = organBoxW * organ.width
                        let h = organH * organ.height
                        let ox = -organBoxW / 2 + (organBoxW * organ.left) + w / 2
                        let oy = -organH / 2 + (organH * organ.top) + h / 2
                        
                        Image(organ.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: w, height: h)
                            .scaleEffect(isSel ? 1.07 : 1.0)
                            .shadow(color: isSel ? Color(hex: "ffd700") : Color.clear, radius: isSel ? 10 : 0)
                            .shadow(color: isSel ? Color(hex: "ffea00").opacity(0.85) : Color.clear, radius: isSel ? 18 : 0)
                            .offset(x: ox, y: oy)
                            .zIndex(isSel ? 35 : organ.zIndex)
                            .animation(.spring(response: 0.35, dampingFraction: 0.68), value: isSel)
                            .onTapGesture {
                                handleOrganTap(organ.id, organName: organ.name)
                            }
                    }
                }
                .frame(width: organBoxW, height: organH)
                .position(x: organCenterX, y: organCenterY)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .mask(
                    Circle()
                        .frame(width: lensRadius * 2, height: lensRadius * 2)
                        .position(x: currentCenterX, y: currentCenterY)
                )
                .opacity(isMagnifierOverCharacter ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.15), value: isMagnifierOverCharacter)
                .zIndex(15)
            }
            
            // Left: Magnifying Glass Dock (Permanently Displays Magnifying Glass 2 left behind)
            Image("AnatomyMagnifyingGlass2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: magWidth, height: magHeight)
                .shadow(color: Color(hex: "50a0ff").opacity(0.85), radius: 14)
                .position(x: dockX, y: dockY)
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                        magnifierOffset = .zero
                        magnifierBaseOffset = .zero
                        magnifierTiltAngle = .zero
                        magnifierDragAnchor = .center
                        isMagnifierOverCharacter = false
                    }
                    HapticManager.shared.lightTap()
                }
            
            // Left: Interactive Draggable Magnifying Glass Tool (80% transparent lens over central character)
            ZStack {
                Image("AnatomyMagnifyingGlass1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(isMagnifierOverCharacter ? 0 : 1)
                
                Image("AnatomyMagnifyingGlass1Transparent")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(isMagnifierOverCharacter ? 1 : 0)
            }
            .frame(width: magWidth, height: magHeight)
            .rotationEffect(magnifierTiltAngle, anchor: magnifierDragAnchor)
            .shadow(color: Color.black.opacity(isDraggingMagnifier ? 0.45 : 0.28), radius: isDraggingMagnifier ? 18 : 10, y: isDraggingMagnifier ? 10 : 5)
            .position(x: dockX, y: dockY)
            .offset(magnifierOffset)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isDraggingMagnifier {
                            isDraggingMagnifier = true
                            lastDragLocationX = value.location.x
                            let anchorX = max(0.05, min(0.95, value.startLocation.x / magWidth))
                            let anchorY = max(0.05, min(0.95, value.startLocation.y / magHeight))
                            magnifierDragAnchor = UnitPoint(x: anchorX, y: anchorY)
                            HapticManager.shared.selectionChanged()
                        }
                        
                        let deltaX = value.location.x - lastDragLocationX
                        lastDragLocationX = value.location.x
                        let targetDeg = max(-7.5, min(7.5, Double(deltaX) * 0.85))
                        withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.7)) {
                            magnifierTiltAngle = .degrees(targetDeg)
                        }
                        
                        magnifierOffset = CGSize(
                            width: magnifierBaseOffset.width + value.translation.width,
                            height: magnifierBaseOffset.height + value.translation.height
                        )
                        
                        let currentCenterX = dockX + magnifierOffset.width
                        let currentCenterY = dockY + magnifierOffset.height - (magHeight * 0.216)
                        
                        let charMinX = proxy.size.width * 0.36
                        let charMaxX = proxy.size.width * 0.64
                        let charMinY = proxy.size.height * 0.12
                        let charMaxY = proxy.size.height * 0.88
                        
                        let over = (currentCenterX >= charMinX && currentCenterX <= charMaxX &&
                                    currentCenterY >= charMinY && currentCenterY <= charMaxY)
                        
                        if over != isMagnifierOverCharacter {
                            isMagnifierOverCharacter = over
                            HapticManager.shared.lightTap()
                        }
                    }
                    .onEnded { value in
                        isDraggingMagnifier = false
                        magnifierBaseOffset = magnifierOffset
                        
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                            magnifierTiltAngle = .zero
                        }
                        
                        let dist = hypot(magnifierOffset.width, magnifierOffset.height)
                        let dragDist = hypot(value.translation.width, value.translation.height)
                        if dragDist < 6 {
                            // Tap on lens over character
                            if isMagnifierOverCharacter && isSystemSelectionSecondary {
                                hitTestOrganAtLens(charId: charId, proxy: proxy)
                            }
                        } else if dist < 60 {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                                magnifierOffset = .zero
                                magnifierBaseOffset = .zero
                                magnifierTiltAngle = .zero
                                magnifierDragAnchor = .center
                                isMagnifierOverCharacter = false
                                selectedOrganId = nil
                            }
                        }
                        HapticManager.shared.lightTap()
                    }
            )
            .animation(.easeInOut(duration: 0.2), value: isMagnifierOverCharacter)
            .zIndex(20)
            
            // Right Top: System Selection Card (Equivalent Area to Skin Tone Picker: ~48,300 px²)
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    isSystemSelectionSecondary.toggle()
                    if !isSystemSelectionSecondary {
                        selectedOrganId = nil
                    }
                }
                HapticManager.shared.lightTap()
            }) {
                Image(isSystemSelectionSecondary ? "AnatomySystemSelection2" : "AnatomySystemSelection")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: proxy.size.width * 0.22, height: proxy.size.height * 0.28)
                    .shadow(color: Color.black.opacity(0.28), radius: 12, y: 6)
            }
            .buttonStyle(PlainButtonStyle())
            .position(x: proxy.size.width * 0.83, y: proxy.size.height * 0.23)
            
            // Right Bottom: Interactive Skin Tone Slider Card
            skinToneSliderCard(proxy: proxy)

            // Bottom Organ Tap Prompt Banner (Persists even after tap to voice)
            if let selectedId = selectedOrganId,
               let organ = (charId == "older-boy" || charId == "older-girl" ? sideOrgans : frontalOrgans).first(where: { $0.id == selectedId }) {
                Button(action: {
                    speakOrgan(organ.name)
                }) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: "ffd700"))
                            .frame(width: 10, height: 10)
                            .shadow(color: Color(hex: "ffd700"), radius: 6)
                        
                        Text("\(organ.name) - Tap again to hear the name of the organ")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "ffd700"))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "1a0e34").opacity(0.92), Color(hex: "2a1450").opacity(0.98)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color(hex: "ffd700").opacity(0.75), lineWidth: 1.5)
                            )
                            .shadow(color: Color(hex: "ffd700").opacity(0.35), radius: 16)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .position(x: proxy.size.width * 0.50, y: proxy.size.height * 0.94)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(40)
            }
        }
    }
    
    private func handleOrganTap(_ organId: String, organName: String) {
        if selectedOrganId == organId {
            speakOrgan(organName)
        } else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                selectedOrganId = organId
            }
            HapticManager.shared.lightTap()
        }
    }
    
    private func speakOrgan(_ name: String) {
        // Keep prior text prompt up even after tap to voice
        HapticManager.shared.lightTap()
        let utterance = AVSpeechUtterance(string: name)
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.08
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.speak(utterance)
    }

    private func hitTestOrganAtLens(charId: String, proxy: GeometryProxy) {
        let isOlder = (charId == "older-boy" || charId == "older-girl")
        let organList = isOlder ? sideOrgans : frontalOrgans
        let organCfg = organLayoutConfig(for: charId)
        let charHeight = proxy.size.height * 0.903
        let organH = charHeight * organCfg.scale
        let charTopY = (proxy.size.height * 0.495) - (charHeight / 2)
        let organBoxY0 = charTopY + (charHeight * organCfg.offsetY)
        let organBoxW = isOlder ? (organH * (303.0 / 1042.0)) : (organH * (477.0 / 1583.0))
        let organBoxX0 = (proxy.size.width * 0.50) + (proxy.size.width * organCfg.offsetX) - (organBoxW / 2)
        
        let dockX = proxy.size.width * 0.185
        let dockY = proxy.size.height * 0.48
        let magHeight = proxy.size.height * 0.542
        let currentLensX = dockX + magnifierOffset.width
        let currentLensY = dockY + magnifierOffset.height - (magHeight * 0.216)
        
        for organ in organList.sorted(by: { $0.zIndex > $1.zIndex }) {
            let ox0 = organBoxX0 + (organBoxW * organ.left)
            let oy0 = organBoxY0 + (organH * organ.top)
            let ow = organBoxW * organ.width
            let oh = organH * organ.height
            if currentLensX >= ox0 && currentLensX <= (ox0 + ow) &&
               currentLensY >= oy0 && currentLensY <= (oy0 + oh) {
                handleOrganTap(organ.id, organName: organ.name)
                return
            }
        }
    }
    
    private func skinToneColor(for progress: CGFloat) -> Color {
        let t = max(0, min(1, progress))
        let stops: [(CGFloat, (Double, Double, Double))] = [
            (0.00, (250.0/255.0, 214.0/255.0, 166.0/255.0)),
            (0.25, (229.0/255.0, 180.0/255.0, 113.0/255.0)),
            (0.50, (183.0/255.0, 124.0/255.0, 62.0/255.0)),
            (0.75, (119.0/255.0, 69.0/255.0,  29.0/255.0)),
            (1.00, (70.0/255.0,  37.0/255.0,  14.0/255.0))
        ]
        
        for i in 0..<(stops.count - 1) {
            let (sA, colA) = stops[i]
            let (sB, colB) = stops[i + 1]
            if t >= sA && t <= sB {
                let factor = (t - sA) / (sB - sA)
                let r = colA.0 + factor * (colB.0 - colA.0)
                let g = colA.1 + factor * (colB.1 - colA.1)
                let b = colA.2 + factor * (colB.2 - colA.2)
                return Color(red: r, green: g, blue: b)
            }
        }
        let last = stops.last!.1
        return Color(red: last.0, green: last.1, blue: last.2)
    }
    
    @ViewBuilder
    private func skinToneSliderCard(proxy: GeometryProxy) -> some View {
        let cardWidth = proxy.size.width * 0.128
        let cardHeight = proxy.size.height * 0.48
        let trackWidth = max(24, cardWidth * 0.26)
        let trackHeight = cardHeight * 0.70
        let thumbSize = max(28, trackWidth * 1.15)
        let swatchSize = trackWidth
        
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.28), radius: 12, y: 6)
            
            VStack(spacing: 0) {
                Text("SKIN TONE")
                    .font(.system(size: 12.5, weight: .heavy))
                    .tracking(1.2)
                    .foregroundColor(Color(hex: "b4b4b4"))
                    .padding(.top, 14)
                
                Spacer(minLength: 4)
                
                GeometryReader { trackGeo in
                    ZStack(alignment: .top) {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "fad6a6"),
                                        Color(hex: "e5b471"),
                                        Color(hex: "b77c3e"),
                                        Color(hex: "77451d"),
                                        Color(hex: "46250e")
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: trackWidth, height: trackGeo.size.height)
                            .shadow(color: Color.black.opacity(0.18), radius: 2, y: 1)
                            .position(x: trackGeo.size.width / 2, y: trackGeo.size.height / 2)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: thumbSize, height: thumbSize)
                            .shadow(color: Color.black.opacity(0.35), radius: isDraggingSkinTone ? 6 : 4, y: isDraggingSkinTone ? 3 : 2)
                            .position(
                                x: trackGeo.size.width / 2,
                                y: skinToneProgress * trackGeo.size.height
                            )
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDraggingSkinTone = true
                                hasInteractedWithSkinTone = true
                                let newProgress = max(0, min(1, value.location.y / trackGeo.size.height))
                                skinToneProgress = newProgress
                                HapticManager.shared.selectionChanged()
                            }
                            .onEnded { _ in
                                isDraggingSkinTone = false
                                HapticManager.shared.lightTap()
                            }
                    )
                }
                .frame(width: max(thumbSize, trackWidth), height: trackHeight)
                
                Spacer(minLength: 4)
                
                Circle()
                    .fill(skinToneColor(for: skinToneProgress))
                    .frame(width: swatchSize, height: swatchSize)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 3, y: 1)
                    .padding(.bottom, 12)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .position(x: proxy.size.width * 0.83, y: proxy.size.height * 0.66)
    }
    
    private func soloCharacterImageName(for charId: String) -> String {
        switch charId {
        case "older-boy": return "Character_OlderBoy_Solo"
        case "younger-boy": return "Character_YoungerBoy_Solo"
        case "older-girl": return "Character_OlderGirl_Solo"
        case "younger-girl": return "Character_YoungerGirl_Solo"
        default: return "Character_YoungerBoy_Solo"
        }
    }
    
    private func organLayoutConfig(for charId: String) -> (scale: CGFloat, offsetX: CGFloat, offsetY: CGFloat) {
        switch charId {
        case "older-boy":
            return (scale: 0.548, offsetX: -0.012, offsetY: 0.022)
        case "older-girl":
            return (scale: 0.548, offsetX: -0.006, offsetY: 0.022)
        case "younger-girl":
            return (scale: 0.60, offsetX: 0.0, offsetY: 0.04)
        default: // younger-boy
            return (scale: 0.61, offsetX: 0.002, offsetY: 0.04)
        }
    }
}

// MARK: - Conical Stage Dimmer Mask (Matches Theatrical Spotlight Beam Shape)
struct StageDimmerConeMask: Shape {
    var centerX: CGFloat
    
    var animatableData: CGFloat {
        get { centerX }
        set { centerX = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Entire stage frame rectangle (covers full screen)
        path.addRect(rect)
        
        // Conical cutout matching the theatrical spotlight beam
        let topW: CGFloat = max(18, rect.width * 0.032)
        let bottomW: CGFloat = max(115, rect.width * 0.185)
        let floorY: CGFloat = rect.height * 0.85
        let floorRx: CGFloat = max(65, rect.width * 0.11)
        let floorRy: CGFloat = max(20, rect.height * 0.036)
        
        var cone = Path()
        cone.move(to: CGPoint(x: centerX - topW, y: 0))
        cone.addLine(to: CGPoint(x: centerX + topW, y: 0))
        cone.addLine(to: CGPoint(x: centerX + bottomW, y: rect.height))
        cone.addLine(to: CGPoint(x: centerX - bottomW, y: rect.height))
        cone.closeSubpath()
        
        var floor = Path()
        floor.addEllipse(in: CGRect(
            x: centerX - floorRx,
            y: floorY - floorRy,
            width: floorRx * 2,
            height: floorRy * 2
        ))
        
        path.addPath(cone)
        path.addPath(floor)
        return path
    }
}

