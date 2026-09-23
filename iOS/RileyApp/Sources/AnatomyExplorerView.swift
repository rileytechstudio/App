import SwiftUI

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
                    
                    Image("AnatomyOlderBoy")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                    
                    Image("AnatomyYoungerBoy")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                    
                    Image("AnatomyOlderGirl")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                    
                    Image("AnatomyYoungerGirl")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }
                .zIndex(1)
                
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
                if isPromptVisible {
                    bottomPromptBar
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        ))
                        .zIndex(5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .allowsHitTesting(false)
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
            Button(action: onBackToHome) {
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
            
            Text("Anatomy Explorer")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 6, y: 2)
            
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
        HStack(spacing: 9) {
            Circle()
                .fill(Color(red: 0.98, green: 0.75, blue: 0.14))
                .frame(width: 8, height: 8)
                .shadow(color: Color(red: 0.98, green: 0.75, blue: 0.14, opacity: 0.7), radius: 4)
            
            Text("Pick your character to get started")
                .font(.system(size: 15.5, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(
            LinearGradient(
                colors: [
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
                .fill(Color.white.opacity(0.16))
                .frame(height: 1.0),
            alignment: .top
        )
        .shadow(color: Color.black.opacity(0.32), radius: 10, y: -3)
    }
}
