import SwiftUI
import AVFoundation

// MARK: - NG Tube Procedure Step
public enum NGTubeStep: Equatable {
    case intro
    case askingRelaxMedicine
    case dragMedicineToNose
    case medicineDelivered
    case decidedNo
    case waitingDrinkTap
    case drinksReady
    case maze
    case mazeWon
}

// MARK: - Bezier Curve Helper for Maze Geometry
struct NGTubeBezierCurve {
    let p0: CGPoint
    let p1: CGPoint
    let p2: CGPoint
    let p3: CGPoint

    func point(at t: CGFloat) -> CGPoint {
        let mt = 1.0 - t
        let x = mt * mt * mt * p0.x + 3 * mt * mt * t * p1.x + 3 * mt * t * t * p2.x + t * t * t * p3.x
        let y = mt * mt * mt * p0.y + 3 * mt * mt * t * p1.y + 3 * mt * t * t * p2.y + t * t * t * p3.y
        return CGPoint(x: x, y: y)
    }
}

// MARK: - NG Tube Procedure View
public struct NGTubeProcedureView: View {
    @Environment(\.presentationMode) var presentationMode
    public var onDismiss: (() -> Void)? = nil
    public var onBackToHome: (() -> Void)? = nil

    @State private var currentStep: NGTubeStep = .intro
    @State private var promptText: String = "We will now prepare our patient for an NG tube."
    @State private var showVersed: Bool = false
    @State private var isSoundMuted: Bool = false
    @State private var introTimer: Timer? = nil
    @State private var mazeTransitionTimer: Timer? = nil

    // Medicine drag & spray states
    @State private var isMedicineDelivered: Bool = false
    @State private var isDraggingSyringe: Bool = false
    @State private var syringeDragOffset: CGSize = .zero
    @State private var showSprayMist: Bool = false
    @State private var showDrinks: Bool = false
    @State private var drinksPopScale: CGFloat = 0.0
    @State private var sprayAudioPlayer: AVAudioPlayer? = nil
    @State private var cupsAudioPlayer: AVAudioPlayer? = nil
    @State private var bumpAudioPlayer: AVAudioPlayer? = nil
    @State private var victoryAudioPlayer: AVAudioPlayer? = nil

    // Maze game states
    @State private var mazeTouches: Int = 0
    @State private var drawnPoints: [CGPoint] = [] // in 1366 x 1024 coordinate space
    @State private var isDrawingPath: Bool = false
    @State private var showMazeBumpFlash: Bool = false
    @State private var lastCollisionTime: TimeInterval = 0
    @State private var showMazeVictoryModal: Bool = false
    @State private var showMazeTryAgainModal: Bool = false
    @State private var showMazeStrikeOverlay: Bool = false
    @State private var currentStrikeNumber: Int = 0
    @State private var strikeDismissTimer: DispatchWorkItem? = nil
    @State private var stomachAuraPulse: Bool = false

    public init(
        onDismiss: (() -> Void)? = nil,
        onBackToHome: (() -> Void)? = nil
    ) {
        self.onDismiss = onDismiss
        self.onBackToHome = onBackToHome
    }

    public var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            let isLandscape = screenSize.width > screenSize.height
            let stageTargetAspect: CGFloat = 1366.0 / 1024.0

            ZStack(alignment: .top) {
                // Background dark teal color matching hospital illustration
                Color(red: 22/255, green: 44/255, blue: 48/255)
                    .ignoresSafeArea()

                // MARK: - Procedure Stage Area (Center, Fills remaining space, maintaining 1366:1024)
                GeometryReader { stageGeo in
                    let availableW = stageGeo.size.width
                    let availableH = stageGeo.size.height

                    let (stageW, stageH) = calculateStageSize(
                        containerW: availableW,
                        containerH: availableH,
                        aspectRatio: stageTargetAspect
                    )

                    ZStack {
                        Color(red: 13/255, green: 30/255, blue: 34/255)
                            .ignoresSafeArea()

                        if currentStep == .maze || currentStep == .mazeWon {
                            // Phase 2: NG Tube Maze Game Stage
                            mazeStageView(stageW: stageW, stageH: stageH)
                        } else {
                            // Phase 1: Welcome & Relaxant Medicine Stage
                            welcomeStageView(stageW: stageW, stageH: stageH)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if currentStep == .intro {
                            advanceToAskingMedicine()
                        } else if currentStep == .waitingDrinkTap {
                            handleTabletopTap()
                        } else if currentStep == .drinksReady {
                            advanceToMaze()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // MARK: - Top Transparent Prompt Bar (Overlapping screen at top)
                topPromptBar
                    .frame(maxWidth: max(screenSize.width - 240, 240))
                    .padding(.top, max(geometry.safeAreaInsets.top, 10) + 4)
                    .zIndex(20)

                // MARK: - Top Header (Consistent with IV Start, Transparent background)
                topHeaderBar(geometry: geometry, isLandscape: isLandscape)
                    .zIndex(25)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startWelcomeSequence()
        }
        .onDisappear {
            cleanupTimers()
        }
    }

    // MARK: - Phase 1: Welcome Stage View
    @ViewBuilder
    private func welcomeStageView(stageW: CGFloat, stageH: CGFloat) -> some View {
        let targetNoseX = stageW * 0.780
        let targetNoseY = stageH * 0.259

        let syringeW = stageW * 0.188
        let syringeH = syringeW * (270.0 / 257.0)
        let tipOffsetX = syringeW * 0.95
        let tipOffsetY = syringeH * 0.08

        let initialSyringeX = stageW * 0.15
        let initialSyringeY = stageH * 0.55
        let snappedSyringeX = targetNoseX - tipOffsetX
        let snappedSyringeY = targetNoseY - tipOffsetY

        let currentSyringeX = isMedicineDelivered ? snappedSyringeX : (initialSyringeX + syringeDragOffset.width)
        let currentSyringeY = isMedicineDelivered ? snappedSyringeY : (initialSyringeY + syringeDragOffset.height)

        ZStack(alignment: .topLeading) {
            // Layer 1: Welcome / BG Screen
            Image("NGTubeWelcomeBG")
                .resizable()
                .scaledToFill()
                .frame(width: stageW, height: stageH)
                .clipped()

            // Layer 2: Draggable Versed Medicine Syringe
            if (currentStep == .dragMedicineToNose || currentStep == .medicineDelivered) && showVersed {
                Image("NGTubeVersedItem")
                    .resizable()
                    .scaledToFit()
                    .frame(width: syringeW, height: syringeH)
                    .shadow(color: isMedicineDelivered ? Color.clear : Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.85), radius: 16, x: 0, y: 0)
                    .shadow(color: isMedicineDelivered ? Color.clear : Color(red: 14/255, green: 165/255, blue: 233/255).opacity(0.55), radius: 28, x: 0, y: 0)
                    .shadow(color: Color.black.opacity(isDraggingSyringe ? 0.45 : 0.3), radius: isDraggingSyringe ? 14 : 8, x: 0, y: isDraggingSyringe ? 8 : 4)
                    .scaleEffect(isDraggingSyringe ? 1.08 : 1.0)
                    .position(x: currentSyringeX + syringeW / 2, y: currentSyringeY + syringeH / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                guard !isMedicineDelivered else { return }
                                isDraggingSyringe = true
                                syringeDragOffset = gesture.translation

                                let tipX = initialSyringeX + gesture.translation.width + tipOffsetX
                                let tipY = initialSyringeY + gesture.translation.height + tipOffsetY
                                let dist = hypot(tipX - targetNoseX, tipY - targetNoseY)
                                if dist < stageW * 0.085 {
                                    deliverMedicine()
                                }
                            }
                            .onEnded { gesture in
                                guard !isMedicineDelivered else { return }
                                isDraggingSyringe = false
                                let tipX = initialSyringeX + gesture.translation.width + tipOffsetX
                                let tipY = initialSyringeY + gesture.translation.height + tipOffsetY
                                let dist = hypot(tipX - targetNoseX, tipY - targetNoseY)
                                if dist < stageW * 0.10 {
                                    deliverMedicine()
                                } else {
                                    withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                                        syringeDragOffset = .zero
                                    }
                                }
                            }
                    )
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            }

            // Layer 3: Spray Mist Effect at Patient Nose
            if showSprayMist {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.9), Color(red: 186/255, green: 230/255, blue: 253/255).opacity(0.6), Color.clear],
                                center: .center,
                                startRadius: 4,
                                endRadius: 36
                            )
                        )
                        .frame(width: 72, height: 72)

                    Circle()
                        .stroke(Color(red: 125/255, green: 211/255, blue: 252/255), lineWidth: 2)
                        .frame(width: 86, height: 86)
                        .opacity(0.7)
                }
                .position(x: targetNoseX, y: targetNoseY)
                .transition(.scale(scale: 0.4).combined(with: .opacity))
            }

            // Layer 4: Drinks PNG on Tabletop (popping up when ready)
            if showDrinks {
                Image("NGTubeDrinks")
                    .resizable()
                    .scaledToFill()
                    .frame(width: stageW, height: stageH)
                    .scaleEffect(drinksPopScale, anchor: UnitPoint(x: 0.215, y: 0.670))
                    .allowsHitTesting(false)
            }

            // Layer 5: Table Glowing Item (Table Transparent PNG glowing as a whole)
            if currentStep == .waitingDrinkTap {
                Button(action: {
                    handleTabletopTap()
                }) {
                    Image("NGTubeTableTransparent")
                        .resizable()
                        .scaledToFill()
                        .frame(width: stageW, height: stageH)
                        .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.85), radius: 16)
                        .shadow(color: Color(red: 14/255, green: 165/255, blue: 233/255).opacity(0.6), radius: 30)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: stageW, height: stageH)
                .transition(.opacity)
            }

            // Tap Hint (during intro)
            if currentStep == .intro {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 13, weight: .bold))
                        Text("Tap anywhere to continue")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.65))
                    .cornerRadius(20)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity)
                }
                .transition(.opacity)
            }

            // Decision Buttons
            if currentStep == .askingRelaxMedicine {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        decisionActionButtons
                        Spacer()
                    }
                    Spacer()
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.82).combined(with: .opacity),
                    removal: .scale(scale: 0.92).combined(with: .opacity)
                ))
            }
        }
        .frame(width: stageW, height: stageH)
        .contentShape(Rectangle())
        .onTapGesture {
            if currentStep == .intro {
                advanceToAskingMedicine()
            } else if currentStep == .waitingDrinkTap {
                handleTabletopTap()
            } else if currentStep == .drinksReady {
                advanceToMaze()
            }
        }
    }

    // MARK: - Phase 2: Maze Stage View
    @ViewBuilder
    private func mazeStageView(stageW: CGFloat, stageH: CGFloat) -> some View {
        let sx = stageW / 1366.0
        let sy = stageH / 1024.0

        let syringeW = 146.0 * sx
        let syringeH = 311.0 * sy
        let syringeCenter = CGPoint(x: (40.0 + 146.0 / 2.0) * sx, y: (380.0 + 311.0 / 2.0) * sy)

        let stomachW = 211.0 * sx
        let stomachH = 241.0 * sy
        let stomachCenter = CGPoint(x: (1145.0 + 211.0 / 2.0) * sx, y: (190.0 + 241.0 / 2.0) * sy)

        let beaconPt = CGPoint(x: 160.0 * sx, y: 405.0 * sy)

        ZStack(alignment: .topLeading) {
            // 1. Warm organ-blush background gradient
            RadialGradient(
                colors: [
                    Color(red: 255/255, green: 248/255, blue: 246/255),
                    Color(red: 253/255, green: 238/255, blue: 233/255),
                    Color(red: 249/255, green: 219/255, blue: 211/255)
                ],
                center: UnitPoint(x: 0.65, y: 0.45),
                startRadius: 40,
                endRadius: stageW * 0.75
            )

            // 2. Subtle translucent anatomical organ contours
            Path { p in
                p.move(to: CGPoint(x: 120 * sx, y: 160 * sy))
                p.addQuadCurve(to: CGPoint(x: 600 * sx, y: 110 * sy), control: CGPoint(x: 340 * sx, y: 70 * sy))
                p.addQuadCurve(to: CGPoint(x: 1050 * sx, y: 160 * sy), control: CGPoint(x: 820 * sx, y: 135 * sy))
                p.addQuadCurve(to: CGPoint(x: 1280 * sx, y: 580 * sy), control: CGPoint(x: 1260 * sx, y: 220 * sy))
                p.addQuadCurve(to: CGPoint(x: 1080 * sx, y: 920 * sy), control: CGPoint(x: 1280 * sx, y: 750 * sy))
                p.addQuadCurve(to: CGPoint(x: 400 * sx, y: 930 * sy), control: CGPoint(x: 740 * sx, y: 990 * sy))
                p.closeSubpath()
            }
            .fill(Color(red: 253/255, green: 186/255, blue: 196/255).opacity(0.24))

            // 3. Maze walls (Dark charcoal 96px stroke)
            NGTubeMazePaths()
                .stroke(
                    Color(red: 30/255, green: 41/255, blue: 58/255),
                    style: StrokeStyle(lineWidth: 96.0 * sx, lineCap: .round, lineJoin: .round)
                )
                .shadow(color: Color(red: 201/255, green: 122/255, blue: 122/255).opacity(0.18), radius: 8, x: 0, y: 4)

            // 4. Maze corridors (White 82px stroke)
            NGTubeMazePaths()
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 82.0 * sx, lineCap: .round, lineJoin: .round)
                )

            // 5. Syringe Image on left
            Image("NGTubeMazeSyringe")
                .resizable()
                .scaledToFit()
                .frame(width: syringeW, height: syringeH)
                .position(syringeCenter)

            // 6. Stomach Image on right with aura glow when won
            ZStack {
                if currentStep == .mazeWon {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.45))
                        .frame(width: stomachW * 1.15, height: stomachH * 1.15)
                        .blur(radius: 20)
                        .scaleEffect(stomachAuraPulse ? 1.08 : 0.98)
                        .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: stomachAuraPulse)
                }

                Image("NGTubeMazeStomach")
                    .resizable()
                    .scaledToFit()
                    .frame(width: stomachW, height: stomachH)
            }
            .position(stomachCenter)

            // 7. Start Beacon Indicator at Syringe outlet
            if (drawnPoints.isEmpty || !isDrawingPath) && currentStep == .maze {
                ZStack {
                    Circle()
                        .fill(Color(red: 44/255, green: 119/255, blue: 150/255).opacity(0.45))
                        .frame(width: 54 * sx, height: 54 * sx)

                    Circle()
                        .fill(Color(red: 56/255, green: 189/255, blue: 248/255))
                        .frame(width: 22 * sx, height: 22 * sx)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))

                    Text("Start Here")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color(red: 2/255, green: 132/255, blue: 199/255))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white, lineWidth: 1.5))
                        .offset(y: -28 * sy)
                }
                .position(beaconPt)
                .allowsHitTesting(false)
            }

            // 8. User Drawn Tubing Path
            if drawnPoints.count >= 2 {
                let path = Path { p in
                    p.move(to: CGPoint(x: drawnPoints[0].x * sx, y: drawnPoints[0].y * sy))
                    for pt in drawnPoints.dropFirst() {
                        p.addLine(to: CGPoint(x: pt.x * sx, y: pt.y * sy))
                    }
                }

                // Outer tube body (matching syringe #257593)
                path.stroke(
                    Color(red: 37/255, green: 117/255, blue: 147/255),
                    style: StrokeStyle(lineWidth: 22.0 * sx, lineCap: .round, lineJoin: .round)
                )

                // Fluid core (#5ebad6)
                path.stroke(
                    Color(red: 94/255, green: 186/255, blue: 214/255),
                    style: StrokeStyle(lineWidth: 14.0 * sx, lineCap: .round, lineJoin: .round)
                )

                // Specular highlight (#dff4fb)
                path.stroke(
                    Color(red: 223/255, green: 244/255, blue: 251/255),
                    style: StrokeStyle(lineWidth: 4.0 * sx, lineCap: .round, lineJoin: .round)
                )

                // Current tip cap
                if let lastPt = drawnPoints.last {
                    Circle()
                        .fill(Color(red: 56/255, green: 189/255, blue: 248/255))
                        .frame(width: 18 * sx, height: 18 * sx)
                        .position(x: lastPt.x * sx, y: lastPt.y * sy)
                }
            }

            // 9. Bump Flash Overlay
            if showMazeBumpFlash {
                Color.red.opacity(0.35)
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }

            // 10. Strike Warning Popup Overlay (Strikes 1-3)
            if showMazeStrikeOverlay {
                ZStack {
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())

                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 252/255, green: 165/255, blue: 165/255))
                            Text("Strike \(currentStrikeNumber) of 3!")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(red: 252/255, green: 165/255, blue: 165/255))
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Color(red: 239/255, green: 68/255, blue: 68/255).opacity(0.2))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color(red: 239/255, green: 68/255, blue: 68/255).opacity(0.6), lineWidth: 1.5))

                        Text(strikeSubtitle(for: currentStrikeNumber))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 22)
                    .background(Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(red: 239/255, green: 68/255, blue: 68/255), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.6), radius: 20, x: 0, y: 10)
                    .shadow(color: Color(red: 239/255, green: 68/255, blue: 68/255).opacity(0.4), radius: 18)
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                }
                .transition(.opacity)
                .zIndex(22)
            }

            // 11. Try Again Replay Modal (Strike 3 of 3 Trigger)
            if showMazeTryAgainModal {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 245/255, green: 158/255, blue: 11/255).opacity(0.18))
                                .frame(width: 64, height: 64)
                                .overlay(Circle().stroke(Color(red: 245/255, green: 158/255, blue: 11/255).opacity(0.55), lineWidth: 2))
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(Color(red: 251/255, green: 191/255, blue: 36/255))
                        }

                        Text("Strike 3 of 3!")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(red: 251/255, green: 191/255, blue: 36/255))

                        Text("You touched the sides 3 times. Let's give it another shot!")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)

                        Button(action: {
                            restartMaze()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Try Again")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 26)
                            .padding(.vertical, 13)
                            .background(Color(red: 16/255, green: 185/255, blue: 129/255))
                            .clipShape(Capsule())
                        }
                        .padding(.top, 4)
                    }
                    .padding(28)
                    .frame(maxWidth: 360)
                    .background(Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color(red: 245/255, green: 158/255, blue: 11/255).opacity(0.65), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.55), radius: 24, x: 0, y: 12)
                    .shadow(color: Color(red: 245/255, green: 158/255, blue: 11/255).opacity(0.3), radius: 20)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
                .transition(.opacity)
                .zIndex(25)
            }

            // 12. Victory Overlay Modal
            if showMazeVictoryModal {
                ZStack {
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()

                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.18))
                                .frame(width: 68, height: 68)
                                .overlay(Circle().stroke(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.55), lineWidth: 2))
                            Image(systemName: "star.fill")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(Color(red: 56/255, green: 189/255, blue: 248/255))
                        }

                        Text("Way to go!")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(Color(red: 56/255, green: 189/255, blue: 248/255))

                        Text("The tube is safely in the stomach!")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 6)

                        HStack(spacing: 14) {
                            Button(action: {
                                restartMaze()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("Play Again")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color(red: 16/255, green: 185/255, blue: 129/255))
                                .clipShape(Capsule())
                            }

                            Button(action: {
                                if let onDismiss = onDismiss {
                                    onDismiss()
                                } else {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }) {
                                Text("Done")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(28)
                    .background(Color(red: 22/255, green: 34/255, blue: 48/255))
                    .cornerRadius(28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.55), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 24, x: 0, y: 12)
                }
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .frame(width: stageW, height: stageH)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    handleMazeDragChanged(location: gesture.location, stageW: stageW, stageH: stageH)
                }
                .onEnded { _ in
                    isDrawingPath = false
                }
        )
    }

    // MARK: - Top Header Bar
    @ViewBuilder
    private func topHeaderBar(geometry: GeometryProxy, isLandscape: Bool) -> some View {
        let topPadding = max(geometry.safeAreaInsets.top, 10)

        HStack {
            Button(action: {
                HapticManager.shared.lightTap()
                cleanupTimers()
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
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.18))
                .clipShape(Capsule())
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: {
                    isSoundMuted.toggle()
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
                    HapticManager.shared.buttonTap()
                    if currentStep == .maze || currentStep == .mazeWon {
                        restartMaze()
                    } else {
                        startWelcomeSequence()
                    }
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(9)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Reset Preparation")

                Button(action: {
                    HapticManager.shared.buttonTap()
                    cleanupTimers()
                    if let onBackToHome = onBackToHome {
                        onBackToHome()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(9)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Home")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, topPadding)
        .padding(.bottom, 6)
    }

    // MARK: - Top Transparent Prompt Bar
    @ViewBuilder
    private var topPromptBar: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(red: 251/255, green: 191/255, blue: 36/255))
                .frame(width: 8, height: 8)
                .shadow(color: Color(red: 251/255, green: 191/255, blue: 36/255).opacity(0.8), radius: 4)

            Text(promptText)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(Color(red: 14/255, green: 28/255, blue: 32/255).opacity(0.32))
                .background(.ultraThinMaterial, in: Capsule())
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 3)
        .contentShape(Capsule())
        .onTapGesture {
            if currentStep == .intro {
                advanceToAskingMedicine()
            } else if currentStep == .waitingDrinkTap {
                handleTabletopTap()
            } else if currentStep == .drinksReady {
                advanceToMaze()
            }
        }
    }

    // MARK: - Decision Action Buttons
    @ViewBuilder
    private var decisionActionButtons: some View {
        HStack(spacing: 20) {
            Button(action: {
                handleDecision(wantsMedicine: true)
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .black))
                    Text("Yes")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(minWidth: 130)
                .padding(.horizontal, 24)
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
                        .stroke(Color.white.opacity(0.45), lineWidth: 2)
                )
                .shadow(color: Color(red: 16/255, green: 185/255, blue: 129/255).opacity(0.55), radius: 12, x: 0, y: 6)
                .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
            }

            Button(action: {
                handleDecision(wantsMedicine: false)
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .black))
                    Text("No")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(minWidth: 130)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color(red: 239/255, green: 68/255, blue: 68/255), Color(red: 220/255, green: 38/255, blue: 38/255)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.45), lineWidth: 2)
                )
                .shadow(color: Color(red: 239/255, green: 68/255, blue: 68/255).opacity(0.55), radius: 12, x: 0, y: 6)
                .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
            }
        }
    }

    // MARK: - Logic & Actions
    private func cleanupTimers() {
        introTimer?.invalidate()
        introTimer = nil
        mazeTransitionTimer?.invalidate()
        mazeTransitionTimer = nil
        strikeDismissTimer?.cancel()
        strikeDismissTimer = nil
    }

    private func startWelcomeSequence() {
        cleanupTimers()
        withAnimation(.easeOut(duration: 0.3)) {
            currentStep = .intro
            promptText = "We will now prepare our patient for an NG tube."
            showVersed = false
            isMedicineDelivered = false
            isDraggingSyringe = false
            syringeDragOffset = .zero
            showSprayMist = false
            showDrinks = false
            drinksPopScale = 0.0
            mazeTouches = 0
            drawnPoints = []
            isDrawingPath = false
            showMazeBumpFlash = false
            showMazeVictoryModal = false
            showMazeTryAgainModal = false
            showMazeStrikeOverlay = false
            stomachAuraPulse = false
        }

        introTimer = Timer.scheduledTimer(withTimeInterval: 2.6, repeats: false) { _ in
            advanceToAskingMedicine()
        }
    }

    private func advanceToAskingMedicine() {
        cleanupTimers()
        guard currentStep == .intro else { return }

        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            currentStep = .askingRelaxMedicine
            promptText = "Would you like to give your patient medicine to help relax?"
        }
        HapticManager.shared.lightTap()
    }

    private func handleDecision(wantsMedicine: Bool) {
        if wantsMedicine {
            HapticManager.shared.success()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                currentStep = .dragMedicineToNose
                isMedicineDelivered = false
                syringeDragOffset = .zero
                showVersed = true
                promptText = "Drag the medicine to the patient's nose."
            }
        } else {
            HapticManager.shared.buttonTap()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                currentStep = .decidedNo
                showVersed = false
                isMedicineDelivered = false
                promptText = "Okay! We will prepare our patient without relaxation medicine."
            }
            mazeTransitionTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
                promptForDrinkPreparation()
            }
        }
    }

    private func deliverMedicine() {
        guard !isMedicineDelivered else { return }
        isMedicineDelivered = true
        isDraggingSyringe = false
        HapticManager.shared.success()
        playSpraySound()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            currentStep = .medicineDelivered
            showSprayMist = true
            promptText = "Great job! The medicine helps relax your patient."
        }
        // Remove medicine item and mist after spray animation is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            withAnimation(.easeOut(duration: 0.35)) {
                showVersed = false
                showSprayMist = false
            }
        }
        mazeTransitionTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
            promptForDrinkPreparation()
        }
    }

    private func promptForDrinkPreparation() {
        cleanupTimers()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            currentStep = .waitingDrinkTap
            promptText = "Tap the tabletop to get a drink ready to help with the NG tube."
        }
    }

    private func handleTabletopTap() {
        guard currentStep == .waitingDrinkTap else { return }
        cleanupTimers()
        currentStep = .drinksReady
        HapticManager.shared.success()
        playCupsSound()

        withAnimation(.spring(response: 0.52, dampingFraction: 0.62)) {
            showDrinks = true
            drinksPopScale = 1.0
            promptText = "Great! Having a drink ready helps with swallowing during the NG tube."
        }

        mazeTransitionTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { _ in
            advanceToMaze()
        }
    }

    private func playCupsSound() {
        guard !isSoundMuted else { return }
        if let url = Bundle.main.url(forResource: "Cups", withExtension: "mp3") {
            do {
                cupsAudioPlayer = try AVAudioPlayer(contentsOf: url)
                cupsAudioPlayer?.volume = 0.95
                cupsAudioPlayer?.play()
            } catch {}
        }
    }

    private func advanceToMaze() {
        cleanupTimers()
        guard currentStep != .maze && currentStep != .mazeWon else { return }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            currentStep = .maze
            promptText = "Guide the tube from the syringe to the stomach!"
            mazeTouches = 0
            drawnPoints = []
            isDrawingPath = false
            showMazeBumpFlash = false
            showMazeVictoryModal = false
            showMazeTryAgainModal = false
            showMazeStrikeOverlay = false
            stomachAuraPulse = false
        }
        HapticManager.shared.lightTap()
    }

    private func handleMazeDragChanged(location: CGPoint, stageW: CGFloat, stageH: CGFloat) {
        guard currentStep == .maze && !showMazeStrikeOverlay && !showMazeTryAgainModal && mazeTouches < 3 else { return }

        let sx = stageW / 1366.0
        let sy = stageH / 1024.0
        let normX = location.x / sx
        let normY = location.y / sy

        let distToStart = hypot(normX - 160.0, normY - 405.0)
        let isNearStart = distToStart < 95.0 || (normX <= 220.0 && abs(normY - 405.0) <= 100.0)

        var isNearTip = false
        if let lastPt = drawnPoints.last {
            isNearTip = hypot(normX - lastPt.x, normY - lastPt.y) < 70.0
        }

        if !isDrawingPath {
            if isNearStart || isNearTip {
                isDrawingPath = true
                if isNearStart && (!isNearTip || drawnPoints.isEmpty) {
                    drawnPoints = [CGPoint(x: 160.0, y: 405.0)]
                }
                drawnPoints.append(CGPoint(x: normX, normY))
            }
            return
        }

        // Win check (distance to stomach entrance at 1170, 300)
        let distToStomach = hypot(normX - 1170.0, normY - 300.0)
        if distToStomach <= 65.0 {
            completeMaze()
            return
        }

        // Collision check against corridor centerline
        let minDist = minDistanceToCenterlines(x: normX, y: normY)
        if minDist > 38.0 {
            handleMazeCollision()
            if mazeTouches >= 3 {
                return
            }
        }

        drawnPoints.append(CGPoint(x: normX, normY))
    }

    private func handleMazeCollision() {
        let now = Date().timeIntervalSince1970
        guard now - lastCollisionTime > 0.5 else { return }
        lastCollisionTime = now

        mazeTouches += 1
        isDrawingPath = false
        HapticManager.shared.warning()
        playBumpSound()

        withAnimation(.easeInOut(duration: 0.15)) {
            showMazeBumpFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeOut(duration: 0.2)) {
                showMazeBumpFlash = false
            }
        }

        // Prune last few points of drawn path so tip is pulled back away from wall
        if drawnPoints.count > 2 {
            drawnPoints.removeLast(min(3, drawnPoints.count - 1))
        }

        if mazeTouches >= 3 {
            // Strike 3 of 3 (3/3): Triggers Try Again to replay
            strikeDismissTimer?.cancel()
            withAnimation(.easeOut(duration: 0.15)) {
                showMazeStrikeOverlay = false
            }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                showMazeTryAgainModal = true
                promptText = "Strike 3 of 3! Tap Try Again to replay."
            }
        } else {
            // Strikes 1, 2: Pop up "Strike X of 3!" and briefly disable/dim the screen
            currentStrikeNumber = mazeTouches
            strikeDismissTimer?.cancel()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                showMazeStrikeOverlay = true
            }
            let work = DispatchWorkItem {
                withAnimation(.easeOut(duration: 0.2)) {
                    showMazeStrikeOverlay = false
                }
            }
            strikeDismissTimer = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: work)
        }
    }

    private func strikeSubtitle(for strike: Int) -> String {
        switch strike {
        case 1:
            return "Careful! Stay inside the path."
        default:
            return "Watch out! One more touch will restart."
        }
    }

    private func completeMaze() {
        guard currentStep == .maze else { return }
        currentStep = .mazeWon
        isDrawingPath = false
        drawnPoints.append(CGPoint(x: 1170.0, y: 300.0))
        strikeDismissTimer?.cancel()
        showMazeStrikeOverlay = false

        HapticManager.shared.success()
        playVictorySound()
        stomachAuraPulse = true

        promptText = "You guided the tube all the way to the stomach! Fantastic job!"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                showMazeVictoryModal = true
            }
        }
    }

    private func restartMaze() {
        strikeDismissTimer?.cancel()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            currentStep = .maze
            drawnPoints = []
            isDrawingPath = false
            mazeTouches = 0
            showMazeVictoryModal = false
            showMazeTryAgainModal = false
            showMazeStrikeOverlay = false
            showMazeBumpFlash = false
            stomachAuraPulse = false
            promptText = "Guide the tube from the syringe to the stomach!"
        }
    }

    private func minDistanceToCenterlines(x: CGFloat, y: CGFloat) -> CGFloat {
        var minD: CGFloat = 9999.0
        for pt in Self.mazeCenterlinePoints {
            let d = hypot(pt.x - x, pt.y - y)
            if d < minD {
                minD = d
            }
        }
        return minD
    }

    private func playSpraySound() {
        guard !isSoundMuted else { return }
        playAudio(name: "Spray", player: &sprayAudioPlayer)
    }

    private func playBumpSound() {
        guard !isSoundMuted else { return }
        playAudio(name: "RubberBand", player: &bumpAudioPlayer)
    }

    private func playVictorySound() {
        guard !isSoundMuted else { return }
        playAudio(name: "YouDidIt", player: &victoryAudioPlayer)
    }

    private func playAudio(name: String, player: inout AVAudioPlayer?) {
        if let dataAsset = NSDataAsset(name: name) {
            do {
                player = try AVAudioPlayer(data: dataAsset.data)
                player?.volume = 0.95
                player?.play()
                return
            } catch {}
        }
        var soundURL: URL? = Bundle.main.url(forResource: name, withExtension: "mp3")
        #if SWIFT_PACKAGE
        if soundURL == nil {
            soundURL = Bundle.module.url(forResource: name, withExtension: "mp3")
        }
        #endif
        if let url = soundURL {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.volume = 0.95
                player?.play()
            } catch {}
        }
    }

    private func calculateStageSize(containerW: CGFloat, containerH: CGFloat, aspectRatio: CGFloat) -> (CGFloat, CGFloat) {
        guard containerW > 0, containerH > 0 else { return (0, 0) }
        if containerW / containerH > aspectRatio {
            let h = containerH
            let w = h * aspectRatio
            return (w, h)
        } else {
            let w = containerW
            let h = w / aspectRatio
            return (w, h)
        }
    }

    // 20 Bezier segments defining the winding, non-direct maze corridors
    private static let mazeCurves: [NGTubeBezierCurve] = [
        // 1. Entrance from syringe
        NGTubeBezierCurve(p0: CGPoint(x: 160, y: 405), p1: CGPoint(x: 190, y: 405), p2: CGPoint(x: 220, y: 415), p3: CGPoint(x: 250, y: 420)),

        // 2. Upper-left loop (Branch A)
        NGTubeBezierCurve(p0: CGPoint(x: 250, y: 420), p1: CGPoint(x: 240, y: 320), p2: CGPoint(x: 200, y: 230), p3: CGPoint(x: 270, y: 200)),
        NGTubeBezierCurve(p0: CGPoint(x: 270, y: 200), p1: CGPoint(x: 340, y: 170), p2: CGPoint(x: 390, y: 260), p3: CGPoint(x: 330, y: 330)),
        NGTubeBezierCurve(p0: CGPoint(x: 330, y: 330), p1: CGPoint(x: 275, y: 395), p2: CGPoint(x: 240, y: 430), p3: CGPoint(x: 330, y: 460)),
        NGTubeBezierCurve(p0: CGPoint(x: 330, y: 460), p1: CGPoint(x: 400, y: 485), p2: CGPoint(x: 440, y: 370), p3: CGPoint(x: 480, y: 280)),

        // 3. Top arch ascending to crest
        NGTubeBezierCurve(p0: CGPoint(x: 480, y: 280), p1: CGPoint(x: 520, y: 190), p2: CGPoint(x: 600, y: 135), p3: CGPoint(x: 690, y: 145)),

        // 4. Top-right dead end (blocks direct route to stomach)
        NGTubeBezierCurve(p0: CGPoint(x: 690, y: 145), p1: CGPoint(x: 770, y: 150), p2: CGPoint(x: 840, y: 180), p3: CGPoint(x: 890, y: 240)),

        // 5. Central vertical plunging channel
        NGTubeBezierCurve(p0: CGPoint(x: 690, y: 145), p1: CGPoint(x: 750, y: 220), p2: CGPoint(x: 740, y: 360), p3: CGPoint(x: 700, y: 480)),
        NGTubeBezierCurve(p0: CGPoint(x: 700, y: 480), p1: CGPoint(x: 660, y: 590), p2: CGPoint(x: 640, y: 660), p3: CGPoint(x: 620, y: 730)),

        // 6. Lower-left flank and pretzel (Branch B)
        NGTubeBezierCurve(p0: CGPoint(x: 250, y: 420), p1: CGPoint(x: 210, y: 500), p2: CGPoint(x: 200, y: 620), p3: CGPoint(x: 210, y: 740)),
        NGTubeBezierCurve(p0: CGPoint(x: 210, y: 740), p1: CGPoint(x: 220, y: 860), p2: CGPoint(x: 310, y: 915), p3: CGPoint(x: 430, y: 895)),
        NGTubeBezierCurve(p0: CGPoint(x: 430, y: 895), p1: CGPoint(x: 510, y: 880), p2: CGPoint(x: 560, y: 810), p3: CGPoint(x: 530, y: 720)),
        NGTubeBezierCurve(p0: CGPoint(x: 530, y: 720), p1: CGPoint(x: 490, y: 630), p2: CGPoint(x: 405, y: 660), p3: CGPoint(x: 435, y: 760)),
        NGTubeBezierCurve(p0: CGPoint(x: 435, y: 760), p1: CGPoint(x: 455, y: 825), p2: CGPoint(x: 550, y: 820), p3: CGPoint(x: 620, y: 730)),

        // 7. Lower-right sweeping curve
        NGTubeBezierCurve(p0: CGPoint(x: 620, y: 730), p1: CGPoint(x: 660, y: 820), p2: CGPoint(x: 740, y: 905), p3: CGPoint(x: 860, y: 895)),
        NGTubeBezierCurve(p0: CGPoint(x: 860, y: 895), p1: CGPoint(x: 970, y: 885), p2: CGPoint(x: 1055, y: 805), p3: CGPoint(x: 1065, y: 675)),

        // 8. Right-hand loop
        NGTubeBezierCurve(p0: CGPoint(x: 1065, y: 675), p1: CGPoint(x: 1075, y: 550), p2: CGPoint(x: 990, y: 450), p3: CGPoint(x: 905, y: 475)),
        NGTubeBezierCurve(p0: CGPoint(x: 905, y: 475), p1: CGPoint(x: 825, y: 500), p2: CGPoint(x: 835, y: 625), p3: CGPoint(x: 915, y: 645)),
        NGTubeBezierCurve(p0: CGPoint(x: 915, y: 645), p1: CGPoint(x: 990, y: 660), p2: CGPoint(x: 1020, y: 540), p3: CGPoint(x: 975, y: 440)),

        // 9. Exit channel into stomach
        NGTubeBezierCurve(p0: CGPoint(x: 975, y: 440), p1: CGPoint(x: 945, y: 350), p2: CGPoint(x: 1040, y: 310), p3: CGPoint(x: 1170, y: 300))
    ]

    private static let mazeCenterlinePoints: [CGPoint] = {
        var pts: [CGPoint] = []
        for curve in mazeCurves {
            for s in 0...16 {
                pts.append(curve.point(at: CGFloat(s) / 16.0))
            }
        }
        return pts
    }()
}

// MARK: - NG Tube Maze Corridor Shape
struct NGTubeMazePaths: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let sx = rect.width / 1366.0
        let sy = rect.height / 1024.0

        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: x * sx, y: y * sy)
        }

        // 1. Entrance from syringe
        path.move(to: pt(160, 405))
        path.addCurve(to: pt(250, 420), control1: pt(190, 405), control2: pt(220, 415))

        // 2. Upper-left loop (Branch A)
        path.move(to: pt(250, 420))
        path.addCurve(to: pt(270, 200), control1: pt(240, 320), control2: pt(200, 230))
        path.addCurve(to: pt(330, 330), control1: pt(340, 170), control2: pt(390, 260))
        path.addCurve(to: pt(330, 460), control1: pt(275, 395), control2: pt(240, 430))
        path.addCurve(to: pt(480, 280), control1: pt(400, 485), control2: pt(440, 370))

        // 3. Top arch ascending to crest
        path.move(to: pt(480, 280))
        path.addCurve(to: pt(690, 145), control1: pt(520, 190), control2: pt(600, 135))

        // 4. Top-right dead end (blocks direct route to stomach)
        path.move(to: pt(690, 145))
        path.addCurve(to: pt(890, 240), control1: pt(770, 150), control2: pt(840, 180))

        // 5. Central vertical plunging channel
        path.move(to: pt(690, 145))
        path.addCurve(to: pt(700, 480), control1: pt(750, 220), control2: pt(740, 360))
        path.addCurve(to: pt(620, 730), control1: pt(660, 590), control2: pt(640, 660))

        // 6. Lower-left flank and pretzel (Branch B)
        path.move(to: pt(250, 420))
        path.addCurve(to: pt(210, 740), control1: pt(210, 500), control2: pt(200, 620))
        path.addCurve(to: pt(430, 895), control1: pt(220, 860), control2: pt(310, 915))
        path.addCurve(to: pt(530, 720), control1: pt(510, 880), control2: pt(560, 810))
        path.addCurve(to: pt(435, 760), control1: pt(490, 630), control2: pt(405, 660))
        path.addCurve(to: pt(620, 730), control1: pt(455, 825), control2: pt(550, 820))

        // 7. Lower-right sweeping curve
        path.move(to: pt(620, 730))
        path.addCurve(to: pt(860, 895), control1: pt(660, 820), control2: pt(740, 905))
        path.addCurve(to: pt(1065, 675), control1: pt(970, 885), control2: pt(1055, 805))

        // 8. Right-hand loop
        path.move(to: pt(1065, 675))
        path.addCurve(to: pt(905, 475), control1: pt(1075, 550), control2: pt(990, 450))
        path.addCurve(to: pt(915, 645), control1: pt(825, 500), control2: pt(835, 625))
        path.addCurve(to: pt(975, 440), control1: pt(990, 660), control2: pt(1020, 540))

        // 9. Exit channel into stomach
        path.move(to: pt(975, 440))
        path.addCurve(to: pt(1170, 300), control1: pt(945, 350), control2: pt(1040, 310))

        return path
    }
}
