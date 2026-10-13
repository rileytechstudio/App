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
    case waitingTapeTap
    case dragTapeToBelly
    case tapeMeasured
    case prepTube
    case jellyApplied
    case mazeIntro
    case maze
    case mazeWon
    case secureFaceTape
    case faceTapeSecured
    case swipeCups
    case cupsSwiped
    case tapTableForWhiteboard
    case tapMiniWhiteboard
    case largeWhiteboard
    case miniWhiteboardDisplay
    case procedureComplete
}

// MARK: - Whiteboard Tool & Stroke Models
public enum WhiteboardTool: Equatable {
    case blue
    case green
    case red
    case eraser

    var color: Color {
        switch self {
        case .blue: return Color(red: 2/255, green: 132/255, blue: 199/255)
        case .green: return Color(red: 22/255, green: 163/255, blue: 74/255)
        case .red: return Color(red: 220/255, green: 38/255, blue: 38/255)
        case .eraser: return Color.clear
        }
    }

    var lineWidth: CGFloat {
        switch self {
        case .eraser: return 54
        default: return 10
        }
    }
}

public struct WhiteboardStroke: Identifiable, Equatable {
    public let id = UUID()
    public var points: [CGPoint]
    public var tool: WhiteboardTool

    public init(points: [CGPoint], tool: WhiteboardTool) {
        self.points = points
        self.tool = tool
    }
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

    // Tape measuring states
    @State private var showTapeOnTable: Bool = false
    @State private var tapeTableScale: CGFloat = 0.0
    @State private var isTapeDelivered: Bool = false
    @State private var isDraggingTape: Bool = false
    @State private var tapeDragProgress: CGFloat = 0.0
    @State private var tapeDragOffset: CGSize = .zero
    @State private var tapePromptTimer: Timer? = nil
    @State private var tapeAudioPlayer: AVAudioPlayer? = nil
    @State private var tapeGlowPulse: Bool = false
    @State private var showTapePopOut: Bool = false

    // Tube preparation states
    @State private var showPrepSyringe: Bool = false
    @State private var showJellyTarget: Bool = false
    @State private var isJellyApplied: Bool = false
    @State private var showMazeIntroModal: Bool = false
    @State private var jellyAudioPlayer: AVAudioPlayer? = nil
    @State private var popAudioPlayer: AVAudioPlayer? = nil

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

    // Face tape states
    @State private var showPatientWithTube: Bool = false
    @State private var showFaceTape: Bool = false
    @State private var isFaceTapeSecured: Bool = false
    @State private var isDraggingFaceTape: Bool = false
    @State private var faceTapeDragOffset: CGSize = .zero
    @State private var showFinalVictoryModal: Bool = false

    // Cups swipe states
    @State private var isDrinksSwiped: Bool = false
    @State private var drinksDragOffset: CGFloat = 0.0
    @State private var showCupsSwipeHint: Bool = false

    // Tabletop Whiteboard states
    @State private var showWhiteboardTableBeacon: Bool = false
    @State private var showMiniWhiteboard: Bool = false
    @State private var whiteboardDelayTimer: DispatchWorkItem? = nil

    // Large Whiteboard screen & drawing states
    @State private var showLargeWhiteboardModal: Bool = false
    @State private var whiteboardCurrentTool: WhiteboardTool = .blue
    @State private var whiteboardStrokes: [WhiteboardStroke] = []
    @State private var currentStrokePoints: [CGPoint] = []

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
            let isMazeActive = (currentStep == .maze || currentStep == .mazeWon)

            ZStack(alignment: .top) {
                // Background dark teal color matching hospital illustration OR light warm maze background extending to the top
                if isMazeActive {
                    RadialGradient(
                        colors: [
                            Color(red: 255/255, green: 248/255, blue: 246/255),
                            Color(red: 253/255, green: 238/255, blue: 233/255),
                            Color(red: 249/255, green: 219/255, blue: 211/255)
                        ],
                        center: UnitPoint(x: 0.65, y: 0.45),
                        startRadius: 40,
                        endRadius: max(screenSize.width, screenSize.height)
                    )
                    .ignoresSafeArea()
                } else {
                    Color(red: 22/255, green: 44/255, blue: 48/255)
                        .ignoresSafeArea()
                }

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
                        if isMazeActive {
                            Color.clear
                                .ignoresSafeArea()
                        } else {
                            Color(red: 13/255, green: 30/255, blue: 34/255)
                                .ignoresSafeArea()
                        }

                        if isMazeActive {
                            // Phase 2: NG Tube Maze Game Stage
                            mazeStageView(stageW: stageW, stageH: stageH)
                        } else {
                            // Phase 1: Welcome & Relaxant Medicine Stage (fills full screen edge-to-edge)
                            welcomeStageView(stageW: availableW, stageH: availableH)
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
                            promptForMeasuringTape()
                        } else if currentStep == .prepTube {
                            applyJelly()
                        } else if currentStep == .tapeMeasured {
                            startTubePreparation()
                        } else if currentStep == .jellyApplied || currentStep == .mazeIntro || currentStep == .mazeWon {
                            advanceToMaze()
                        } else if currentStep == .tapTableForWhiteboard {
                            handleWhiteboardTableTap()
                        } else if currentStep == .tapMiniWhiteboard || currentStep == .miniWhiteboardDisplay {
                            openLargeWhiteboard()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // MARK: - Top Header & Full-Width Prompt Bar
                VStack(spacing: 0) {
                    topHeaderBar(geometry: geometry, isLandscape: isLandscape)
                    topPromptBar
                }
                .zIndex(25)

                // MARK: - Large Whiteboard Screen Modal
                if showLargeWhiteboardModal {
                    GeometryReader { modalGeo in
                        let (mStageW, mStageH) = calculateStageSize(
                            containerW: modalGeo.size.width,
                            containerH: modalGeo.size.height,
                            aspectRatio: stageTargetAspect
                        )
                        largeWhiteboardModalView(stageW: mStageW, stageH: mStageH)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .zIndex(45)
                    .transition(.opacity)
                }

                // MARK: - Final Victory Modal
                if showFinalVictoryModal {
                    finalVictoryModalView
                        .zIndex(50)
                }
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
        let targetNoseX = stageW * 0.770
        let targetNoseY = stageH * 0.345

        let tapeCenterX = stageW * (718.0 / 1366.0)
        let tapeStartY = stageH * 0.345
        let tapeEndY = stageH * 0.700
        let totalPathDist = tapeEndY - tapeStartY

        let syringeW = stageW * 0.150
        let syringeH = syringeW * (270.0 / 257.0)
        let tipOffsetX = syringeW * 0.94
        let tipOffsetY = syringeH * 0.05

        let initialSyringeX = stageW * 0.15
        let initialSyringeY = stageH * 0.55
        let snappedSyringeX = targetNoseX - tipOffsetX
        let snappedSyringeY = targetNoseY - tipOffsetY

        let currentSyringeX = isMedicineDelivered ? snappedSyringeX : (initialSyringeX + syringeDragOffset.width)
        let currentSyringeY = isMedicineDelivered ? snappedSyringeY : (initialSyringeY + syringeDragOffset.height)

        // Draggable tape casing constants
        let casingW = stageW * 0.095
        let casingH = casingW * (158.0 / 120.0)
        let casingHalfH = casingH / 2.0

        let effectiveProgress = isTapeDelivered ? 1.0 : tapeDragProgress
        let currentCasingTop = tapeStartY + effectiveProgress * totalPathDist
        let currentCasingCenterX = tapeCenterX
        let currentCasingCenterY = currentCasingTop + casingHalfH

        // Dynamic ribbon calculations (straight vertical line)
        let ribbonHeight = max(8.0, effectiveProgress * totalPathDist + 8.0)

        let tableTapeW = stageW * 0.092
        let tableTapeH = tableTapeW * (158.0 / 120.0)
        let tableTapeX = stageW * 0.14 + tableTapeW / 2.0
        let tableTapeY = stageH * 0.80 + tableTapeH / 2.0

        // Face tape on cheek coordinates
        let cheekTargetX = stageW * 0.8433
        let cheekTargetY = stageH * 0.3711
        let initialTapeX = stageW * 0.50
        let initialTapeY = stageH * 0.50
        let faceTapeW = stageW * 0.02736
        let faceTapeH = faceTapeW * (243.0 / 95.0)

        let currentTapeX = isFaceTapeSecured ? cheekTargetX : (initialTapeX + faceTapeDragOffset.width)
        let currentTapeY = isFaceTapeSecured ? cheekTargetY : (initialTapeY + faceTapeDragOffset.height)

        ZStack(alignment: .topLeading) {
            // Layer 1: Welcome / BG Screen
            Image("NGTubeWelcomeBG")
                .resizable()
                .frame(width: stageW, height: stageH)
                .clipped()

            // Layer 1b: Patient with NG Tube (Shown for cheek tape step after maze)
            if showPatientWithTube {
                Image("NGTubePatientWithTube")
                    .resizable()
                    .frame(width: stageW, height: stageH)
                    .clipped()
            }

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
                                if dist < stageW * 0.095 {
                                    deliverMedicine()
                                }
                            }
                            .onEnded { gesture in
                                guard !isMedicineDelivered else { return }
                                isDraggingSyringe = false
                                let tipX = initialSyringeX + gesture.translation.width + tipOffsetX
                                let tipY = initialSyringeY + gesture.translation.height + tipOffsetY
                                let dist = hypot(tipX - targetNoseX, tipY - targetNoseY)
                                if dist < stageW * 0.12 {
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

            // Layer 4: Drinks PNG on Tabletop (popping up when ready & swipeable away)
            if showDrinks {
                ZStack {
                    Image("NGTubeDrinks")
                        .resizable()
                        .frame(width: stageW, height: stageH)
                        .scaleEffect(drinksPopScale, anchor: UnitPoint(x: 0.236, y: 0.709))
                        .offset(x: drinksDragOffset, y: 0)
                        .rotationEffect(Angle(degrees: Double(drinksDragOffset) * 0.04))
                        .opacity(isDrinksSwiped ? 0.0 : max(0.2, 1.0 + Double(drinksDragOffset) / 300.0))

                    if currentStep == .swipeCups && showCupsSwipeHint {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 13, weight: .bold))
                            Text("Swipe Away")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(Color(red: 56/255, green: 189/255, blue: 248/255))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.9))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.65), lineWidth: 1.5)
                        )
                        .shadow(color: Color.black.opacity(0.4), radius: 8, y: 3)
                        .position(x: stageW * 0.236, y: stageH * 0.67)
                        .allowsHitTesting(false)
                    }
                }
                .allowsHitTesting(currentStep == .swipeCups)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            guard currentStep == .swipeCups && !isDrinksSwiped else { return }
                            let dragX = gesture.translation.width
                            if dragX < 0 {
                                drinksDragOffset = dragX
                                if dragX < -stageW * 0.075 {
                                    finishCupsSwipe(stageW: stageW)
                                }
                            }
                        }
                        .onEnded { gesture in
                            guard currentStep == .swipeCups && !isDrinksSwiped else { return }
                            if gesture.translation.width < -stageW * 0.04 || gesture.predictedEndTranslation.width < -stageW * 0.08 {
                                finishCupsSwipe(stageW: stageW)
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    drinksDragOffset = 0
                                }
                            }
                        }
                )
            }

            // Layer 4b: Bedside Table Glow (Table itself glows and pulses)
            if showWhiteboardTableBeacon && currentStep == .tapTableForWhiteboard {
                Button(action: {
                    handleWhiteboardTableTap()
                }) {
                    Image("NGTubeTableTransparent")
                        .resizable()
                        .frame(width: stageW, height: stageH)
                        .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(tapeGlowPulse ? 0.95 : 0.6), radius: tapeGlowPulse ? 24 : 12)
                        .shadow(color: Color.white.opacity(tapeGlowPulse ? 0.8 : 0.3), radius: tapeGlowPulse ? 36 : 18)
                        .brightness(tapeGlowPulse ? 0.15 : 0.05)
                        .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: tapeGlowPulse)
                }
                .buttonStyle(PlainButtonStyle())
                .transition(.opacity)
            }

            // Layer 4c: Mini Whiteboard on Bedside Table (renders live downscaled user design!)
            if showMiniWhiteboard {
                Button(action: {
                    openLargeWhiteboard()
                }) {
                    ZStack {
                        Image("TransparentMiniWhiteboard")
                            .resizable()
                            .frame(width: stageW, height: stageH)

                        Canvas { context, size in
                            let scaleX = size.width / 984.0
                            let scaleY = size.height / 758.0
                            context.drawLayer { layer in
                                for stroke in whiteboardStrokes {
                                    var path = Path()
                                    guard let first = stroke.points.first else { continue }
                                    path.move(to: CGPoint(x: first.x * scaleX, y: first.y * scaleY))
                                    for pt in stroke.points.dropFirst() {
                                        path.addLine(to: CGPoint(x: pt.x * scaleX, y: pt.y * scaleY))
                                    }
                                    if stroke.tool == .eraser {
                                        layer.blendMode = .clear
                                        layer.stroke(path, with: .color(.black), style: StrokeStyle(lineWidth: stroke.tool.lineWidth * scaleX, lineCap: .round, lineJoin: .round))
                                    } else {
                                        layer.blendMode = .normal
                                        layer.stroke(path, with: .color(stroke.tool.color), style: StrokeStyle(lineWidth: stroke.tool.lineWidth * scaleX, lineCap: .round, lineJoin: .round))
                                    }
                                }
                            }
                        }
                        .frame(width: stageW * (342.0 / 1366.0), height: stageH * (264.0 / 1024.0))
                        .position(x: stageW * (285.0 / 1366.0), y: stageH * (704.0 / 1024.0))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .transition(.scale(scale: 0.6).combined(with: .opacity))
            }

            // Layer 5: Table Glowing Item (Table Transparent PNG glowing as a whole)
            if currentStep == .waitingDrinkTap {
                Button(action: {
                    handleTabletopTap()
                }) {
                    Image("NGTubeTableTransparent")
                        .resizable()
                        .frame(width: stageW, height: stageH)
                        .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.85), radius: 16)
                        .shadow(color: Color(red: 14/255, green: 165/255, blue: 233/255).opacity(0.6), radius: 30)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: stageW, height: stageH)
                .transition(.opacity)
            }

            // Layer 6: Measuring Tape Item on Bedside Table (Glowing for click)
            if showTapeOnTable && currentStep == .waitingTapeTap {
                Button(action: {
                    startTapeMeasurementAtNose()
                }) {
                    Image("NGTubeMeasuringTapeItem")
                        .resizable()
                        .scaledToFit()
                        .frame(width: tableTapeW, height: tableTapeH)
                        .shadow(color: Color(red: 249/255, green: 115/255, blue: 22/255).opacity(0.95), radius: 14)
                        .shadow(color: Color(red: 234/255, green: 88/255, blue: 12/255).opacity(0.65), radius: 26)
                        .scaleEffect(tapeTableScale)
                }
                .buttonStyle(PlainButtonStyle())
                .position(x: tableTapeX, y: tableTapeY)
                .transition(.scale(scale: 0.5).combined(with: .opacity))
            }

            // Layer 7: Measuring Tape Interaction (Extending Yellow Ribbon, Draggable Casing)
            if (currentStep == .dragTapeToBelly || currentStep == .tapeMeasured) && !showTapePopOut {
                Group {
                    // 7a: Extending Yellow Tape Ribbon using authentic NGTubeLongTape asset
                    ZStack(alignment: .top) {
                        Image("NGTubeLongTape")
                            .resizable()
                            .frame(width: stageW, height: stageH)
                            .offset(y: -stageH * (23.0 / 1024.0))
                    }
                    .frame(width: stageW, height: ribbonHeight, alignment: .top)
                    .clipped()
                    .position(x: stageW / 2.0, y: tapeStartY + ribbonHeight / 2.0)
                    .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
                    .allowsHitTesting(false)

                    // 7c: Draggable Orange Tape Measure Casing
                    Image("NGTubeMeasuringTapeItem")
                        .resizable()
                        .scaledToFit()
                        .frame(width: casingW, height: casingH)
                        .shadow(
                            color: isTapeDelivered ? Color(red: 34/255, green: 197/255, blue: 94/255).opacity(0.95) : Color(red: 249/255, green: 115/255, blue: 22/255).opacity(isDraggingTape ? 1.0 : 0.85),
                            radius: isTapeDelivered ? 18 : (isDraggingTape ? 22 : 14),
                            x: 0,
                            y: 0
                        )
                        .shadow(color: Color.black.opacity(isDraggingTape ? 0.45 : 0.3), radius: isDraggingTape ? 14 : 8, x: 0, y: isDraggingTape ? 8 : 4)
                        .scaleEffect(isDraggingTape ? 1.08 : 1.0, anchor: .top)
                        .position(x: currentCasingCenterX, y: currentCasingCenterY)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    guard !isTapeDelivered else { return }
                                    if !isDraggingTape {
                                        isDraggingTape = true
                                        playTapeSound()
                                    }
                                    let dragY = max(0.0, gesture.translation.height)
                                    let progress = min(1.0, dragY / totalPathDist)
                                    tapeDragProgress = progress

                                    if progress >= 0.88 {
                                        deliverTapeAtBelly()
                                    }
                                }
                                .onEnded { gesture in
                                    guard !isTapeDelivered else { return }
                                    isDraggingTape = false
                                    if tapeDragProgress >= 0.82 {
                                        deliverTapeAtBelly()
                                    } else {
                                        withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                                            tapeDragProgress = 0.0
                                        }
                                    }
                                }
                        )
                }
                .scaleEffect(showTapePopOut ? 0.05 : 1.0)
                .opacity(showTapePopOut ? 0.0 : 1.0)
                .animation(.spring(response: 0.38, dampingFraction: 0.65), value: showTapePopOut)
            }

            // Layer 8: Tube Preparation (Syringe with NG Tube + Jelly on Tip)
            if currentStep == .prepTube || currentStep == .jellyApplied || currentStep == .mazeIntro {
                ZStack {
                    // 8a: Syringe with Tube PNG in middle of screen with gentle medical aura glow
                    Image("NGTubeSyringe")
                        .resizable()
                        .scaledToFit()
                        .frame(width: stageW, height: stageH)
                        .shadow(color: Color.white.opacity(0.85), radius: 24)
                        .shadow(color: Color.white.opacity(0.55), radius: 44)
                        .position(x: stageW / 2.0, y: stageH / 2.0)
                        .scaleEffect(showPrepSyringe ? 1.0 : 0.35)
                        .opacity(showPrepSyringe ? 1.0 : 0.0)

                    // 8b: Glowing circle at the tip of the tube furthest from syringe (matching MRI prep)
                    if showJellyTarget && !isJellyApplied {
                        Button(action: {
                            applyJelly()
                        }) {
                            ZStack {
                                // Touch area
                                Circle()
                                    .fill(Color.white.opacity(0.001))
                                    .frame(width: 54, height: 54)

                                // Pulsing expanding outer ring (matching MRI pulse ring)
                                Circle()
                                    .stroke(Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), lineWidth: 2.5)
                                    .frame(width: 38, height: 38)
                                    .scaleEffect(tapeGlowPulse ? 1.55 : 0.85)
                                    .opacity(tapeGlowPulse ? 0.0 : 0.95)
                                    .animation(Animation.easeOut(duration: 1.8).repeatForever(autoreverses: false), value: tapeGlowPulse)

                                // Core glowing circle with cyan aura (matching MRI prep discovery ring)
                                Circle()
                                    .stroke(Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), lineWidth: 3)
                                    .background(Circle().fill(Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0).opacity(0.14)))
                                    .frame(width: 38, height: 38)
                                    .shadow(color: Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0), radius: 8)
                                    .shadow(color: Color(red: 0, green: 229 / 255.0, blue: 255 / 255.0).opacity(0.6), radius: 16)
                                    .scaleEffect(tapeGlowPulse ? 1.05 : 0.95)
                                    .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: tapeGlowPulse)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .position(x: stageW * 0.362, y: stageH * 0.576)
                    }

                    // 8c: Jelly 2 PNG on the very tip of the tube (furthest from syringe)
                    if isJellyApplied {
                        Image("NGTubeJelly")
                            .resizable()
                            .scaledToFit()
                            .frame(width: stageW, height: stageH)
                            .shadow(color: Color(red: 129/255, green: 245/255, blue: 246/255).opacity(0.95), radius: 16)
                            .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.7), radius: 28)
                            .position(x: stageW / 2.0, y: stageH / 2.0)
                            .transition(.scale(scale: 0.2, anchor: UnitPoint(x: 0.362, y: 0.576)).combined(with: .opacity))
                    }
                }
            }



            // Layer 10: Draggable Soft Face Tape
            if showFaceTape {
                Image(isFaceTapeSecured ? "NGTubeFaceTapeSecured" : "NGTubeFaceTapeItem")
                    .resizable()
                    .scaledToFit()
                    .frame(width: faceTapeW, height: faceTapeH)
                    .shadow(
                        color: isFaceTapeSecured ? Color.clear : Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.9),
                        radius: isFaceTapeSecured ? 0 : 16,
                        x: 0,
                        y: 0
                    )
                    .shadow(
                        color: isFaceTapeSecured ? Color.black.opacity(0.3) : Color.white.opacity(0.8),
                        radius: isFaceTapeSecured ? 4 : 28,
                        x: 0,
                        y: isFaceTapeSecured ? 2 : 0
                    )
                    .rotationEffect(Angle(degrees: isFaceTapeSecured ? -12 : (isDraggingFaceTape ? -8 : 0)))
                    .scaleEffect(isDraggingFaceTape ? 1.15 : (isFaceTapeSecured ? 0.92 : 1.0))
                    .position(x: currentTapeX, y: currentTapeY)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                guard !isFaceTapeSecured else { return }
                                isDraggingFaceTape = true
                                faceTapeDragOffset = gesture.translation
                                let curX = initialTapeX + gesture.translation.width
                                let curY = initialTapeY + gesture.translation.height
                                let dist = hypot(curX - cheekTargetX, curY - cheekTargetY)
                                if dist < stageW * 0.075 {
                                    secureFaceTapeOnCheek()
                                }
                            }
                            .onEnded { gesture in
                                guard !isFaceTapeSecured else { return }
                                isDraggingFaceTape = false
                                let curX = initialTapeX + gesture.translation.width
                                let curY = initialTapeY + gesture.translation.height
                                let dist = hypot(curX - cheekTargetX, curY - cheekTargetY)
                                if dist < stageW * 0.115 {
                                    secureFaceTapeOnCheek()
                                } else {
                                    withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                                        faceTapeDragOffset = .zero
                                    }
                                }
                            }
                    )
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
                    .padding(.bottom, 64)
                    .frame(maxWidth: .infinity)
                }
                .transition(.opacity)
            }

            // Decision Buttons
            if currentStep == .askingRelaxMedicine {
                VStack {
                    Spacer().frame(height: max(16, stageH * 0.22))
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

            // Maze Intro Overlay (dimmed pause & friendly modal before maze)
            if showMazeIntroModal && currentStep == .mazeIntro {
                ZStack {
                    Color.black.opacity(0.68)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            advanceToMaze()
                        }

                    VStack(spacing: 16) {
                        // Badge / Icon
                        HStack(spacing: 8) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 56/255, green: 189/255, blue: 248/255))
                            Text("Practice Activity")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 56/255, green: 189/255, blue: 248/255))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.16))
                        .clipShape(Capsule())

                        Text("Let's practice guiding the tube!")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Trace a path from the syringe to the stomach.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 6)

                        Button(action: {
                            advanceToMaze()
                        }) {
                            HStack(spacing: 10) {
                                Text("Start")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 14/255, green: 165/255, blue: 233/255),
                                        Color(red: 2/255, green: 132/255, blue: 199/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(26)
                            .overlay(
                                RoundedRectangle(cornerRadius: 26)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                            )
                            .shadow(color: Color(red: 14/255, green: 165/255, blue: 233/255).opacity(0.5), radius: 12, y: 4)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 28)
                    .frame(maxWidth: 420)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.96),
                                Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.98)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.6), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.55), radius: 30, y: 15)
                    .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.3), radius: 24)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        advanceToMaze()
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.92)),
                    removal: .opacity.combined(with: .scale(scale: 0.96))
                ))
                .zIndex(35)
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
                promptForMeasuringTape()
            } else if currentStep == .prepTube {
                applyJelly()
            } else if currentStep == .jellyApplied || currentStep == .mazeIntro {
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
                p.move(to: CGPoint(x: 120 * sx, y: 240 * sy))
                p.addQuadCurve(to: CGPoint(x: 600 * sx, y: 195 * sy), control: CGPoint(x: 340 * sx, y: 160 * sy))
                p.addQuadCurve(to: CGPoint(x: 1050 * sx, y: 230 * sy), control: CGPoint(x: 820 * sx, y: 210 * sy))
                p.addQuadCurve(to: CGPoint(x: 1280 * sx, y: 580 * sy), control: CGPoint(x: 1260 * sx, y: 280 * sy))
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
                        Text("Strike \(currentStrikeNumber) of 3")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(red: 252/255, green: 165/255, blue: 165/255))
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

                        Text("Strike 3 of 3")
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

                        HStack(spacing: 10) {
                            Button(action: {
                                startFaceTapeStep()
                            }) {
                                Text("Continue")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 9)
                                    .background(Color(red: 16/255, green: 185/255, blue: 129/255))
                                    .clipShape(Capsule())
                            }

                            Button(action: {
                                restartMaze()
                            }) {
                                Text("Play Again")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 9)
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
        let isMazeActive = (currentStep == .maze || currentStep == .mazeWon)

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
                .background(
                    isMazeActive
                        ? Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.58)
                        : Color.white.opacity(0.18)
                )
                .background(.ultraThinMaterial.opacity(isMazeActive ? 0.70 : 0.0), in: Capsule())
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isMazeActive
                                ? Color.white.opacity(0.24)
                                : Color.white.opacity(0.25),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isMazeActive
                        ? Color.black.opacity(0.22)
                        : Color.clear,
                    radius: 5, x: 0, y: 2
                )
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
                        .background(
                            isMazeActive
                                ? Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.58)
                                : Color.white.opacity(0.18)
                        )
                        .background(.ultraThinMaterial.opacity(isMazeActive ? 0.70 : 0.0), in: Circle())
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    isMazeActive
                                        ? Color.white.opacity(0.24)
                                        : Color.white.opacity(0.25),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: isMazeActive
                                ? Color.black.opacity(0.22)
                                : Color.clear,
                            radius: 5, x: 0, y: 2
                        )
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
                        .background(
                            isMazeActive
                                ? Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.58)
                                : Color.white.opacity(0.18)
                        )
                        .background(.ultraThinMaterial.opacity(isMazeActive ? 0.70 : 0.0), in: Circle())
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    isMazeActive
                                        ? Color.white.opacity(0.24)
                                        : Color.white.opacity(0.25),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: isMazeActive
                                ? Color.black.opacity(0.22)
                                : Color.clear,
                            radius: 5, x: 0, y: 2
                        )
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
                        .background(
                            isMazeActive
                                ? Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.58)
                                : Color.white.opacity(0.18)
                        )
                        .background(.ultraThinMaterial.opacity(isMazeActive ? 0.70 : 0.0), in: Circle())
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    isMazeActive
                                        ? Color.white.opacity(0.24)
                                        : Color.white.opacity(0.25),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: isMazeActive
                                ? Color.black.opacity(0.22)
                                : Color.clear,
                            radius: 5, x: 0, y: 2
                        )
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
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 9)
        .background(
            Rectangle()
                .fill(Color(red: 14/255, green: 28/255, blue: 32/255).opacity(0.16))
                .background(.ultraThinMaterial.opacity(0.65), in: Rectangle())
        )
        .overlay(
            VStack {
                Divider().background(Color.white.opacity(0.12))
                Spacer()
                Divider().background(Color.white.opacity(0.08))
            }
        )
        .shadow(color: Color.black.opacity(0.14), radius: 5, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            if currentStep == .intro {
                advanceToAskingMedicine()
            } else if currentStep == .waitingDrinkTap {
                handleTabletopTap()
            } else if currentStep == .drinksReady {
                promptForMeasuringTape()
            } else if currentStep == .prepTube {
                applyJelly()
            } else if currentStep == .jellyApplied || currentStep == .mazeIntro {
                advanceToMaze()
            } else if currentStep == .tapTableForWhiteboard {
                handleWhiteboardTableTap()
            } else if currentStep == .tapMiniWhiteboard || currentStep == .miniWhiteboardDisplay {
                openLargeWhiteboard()
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
        tapePromptTimer?.invalidate()
        tapePromptTimer = nil
        strikeDismissTimer?.cancel()
        strikeDismissTimer = nil
        whiteboardDelayTimer?.cancel()
        whiteboardDelayTimer = nil
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
            showTapeOnTable = false
            tapeTableScale = 0.0
            isTapeDelivered = false
            isDraggingTape = false
            tapeDragProgress = 0.0
            tapeDragOffset = .zero
            tapeGlowPulse = true
            showTapePopOut = false
            showPrepSyringe = false
            showJellyTarget = false
            isJellyApplied = false
            mazeTouches = 0
            drawnPoints = []
            isDrawingPath = false
            showMazeBumpFlash = false
            showMazeVictoryModal = false
            showMazeTryAgainModal = false
            showMazeStrikeOverlay = false
            showMazeIntroModal = false
            stomachAuraPulse = false
            showPatientWithTube = false
            showFaceTape = false
            isFaceTapeSecured = false
            isDraggingFaceTape = false
            faceTapeDragOffset = .zero
            showFinalVictoryModal = false

            // Cups swipe & whiteboard states reset
            isDrinksSwiped = false
            drinksDragOffset = 0.0
            showCupsSwipeHint = false
            showWhiteboardTableBeacon = false
            showMiniWhiteboard = false
            showLargeWhiteboardModal = false
            whiteboardCurrentTool = .blue
            whiteboardStrokes = []
            currentStrokePoints = []
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

        tapePromptTimer = Timer.scheduledTimer(withTimeInterval: 2.4, repeats: false) { _ in
            promptForMeasuringTape()
        }
    }

    private func promptForMeasuringTape() {
        cleanupTimers()
        withAnimation(.spring(response: 0.48, dampingFraction: 0.72)) {
            currentStep = .dragTapeToBelly
            showTapeOnTable = false
            tapeDragProgress = 0.0
            tapeDragOffset = .zero
            isDraggingTape = false
            isTapeDelivered = false
            promptText = "Drag the measuring tape down from nose level to belly level."
        }
        playTapeSound()
    }

    private func startTapeMeasurementAtNose() {
        promptForMeasuringTape()
    }

    private func deliverTapeAtBelly() {
        guard (currentStep == .dragTapeToBelly || currentStep == .waitingTapeTap) && !isTapeDelivered else { return }
        isTapeDelivered = true
        isDraggingTape = false
        tapeDragProgress = 1.0
        currentStep = .tapeMeasured
        HapticManager.shared.success()
        playTapeSound()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            tapeDragOffset = .zero
            promptText = "Great job! Measuring ensures the NG tube is the perfect length."
        }

        // Measuring tape disappears with a pop effect!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            playPopSound()
            withAnimation(.spring(response: 0.38, dampingFraction: 0.65)) {
                showTapePopOut = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
                startTubePreparation()
            }
        }
    }

    private func startTubePreparation() {
        cleanupTimers()
        currentStep = .prepTube
        isJellyApplied = false

        withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) {
            showPrepSyringe = true
            showJellyTarget = true
            promptText = "Excellent work! Now we can prepare our tube!"
        }

        tapePromptTimer = Timer.scheduledTimer(withTimeInterval: 1.4, repeats: false) { _ in
            guard currentStep == .prepTube && !isJellyApplied else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                promptText = "Tap the end of the tube to add a little jelly."
            }
        }
    }

    private func applyJelly() {
        guard (currentStep == .prepTube || currentStep == .tapeMeasured) && !isJellyApplied else { return }
        cleanupTimers()
        isJellyApplied = true
        currentStep = .jellyApplied
        HapticManager.shared.success()
        playJellySound()

        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
            showJellyTarget = false
            promptText = "Great job! Lubricating jelly helps the tube slide smoothly and comfortably."
        }

        mazeTransitionTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            showMazeIntroduction()
        }
    }

    private func showMazeIntroduction() {
        cleanupTimers()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
            currentStep = .mazeIntro
            showMazeIntroModal = true
            promptText = "Let's practice guiding the tube to the stomach!"
        }
        HapticManager.shared.lightTap()
    }

    private func playTapeSound() {
        guard !isSoundMuted else { return }
        playAudio(name: "MeasuringTape", player: &tapeAudioPlayer)
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
            showMazeIntroModal = false
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
                promptText = "Strike 3 of 3. Tap Try Again to replay."
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

    private func playPopSound() {
        guard !isSoundMuted else { return }
        playAudio(name: "YouDidItChime", player: &popAudioPlayer)
    }

    private func playJellySound() {
        guard !isSoundMuted else { return }
        playAudio(name: "Jelly", player: &jellyAudioPlayer)
    }

    private func playBandageSound() {
        guard !isSoundMuted else { return }
        playAudio(name: "Bandage", player: &tapeAudioPlayer)
    }

    private func startFaceTapeStep() {
        cleanupTimers()
        showMazeVictoryModal = false
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            currentStep = .secureFaceTape
            showPatientWithTube = true
            showDrinks = true
            drinksPopScale = 1.0
            isDrinksSwiped = false
            drinksDragOffset = 0.0
            showCupsSwipeHint = false
            showWhiteboardTableBeacon = false
            showMiniWhiteboard = false
            showLargeWhiteboardModal = false
            whiteboardCurrentTool = .blue
            whiteboardStrokes = []
            currentStrokePoints = []
            showFinalVictoryModal = false
            showTapeOnTable = false
            isTapeDelivered = false
            showPrepSyringe = false
            showJellyTarget = false
            isJellyApplied = false
            showFaceTape = true
            isFaceTapeSecured = false
            isDraggingFaceTape = false
            faceTapeDragOffset = .zero
            promptText = "Secure the NG tube on the patient's cheek using soft tape!"
        }
        HapticManager.shared.lightTap()
    }

    private func secureFaceTapeOnCheek() {
        guard !isFaceTapeSecured else { return }
        withAnimation(.spring(response: 0.32, dampingFraction: 0.75)) {
            isFaceTapeSecured = true
            isDraggingFaceTape = false
            currentStep = .faceTapeSecured
            faceTapeDragOffset = .zero
            promptText = "Great job! The NG tube is securely taped in place!"
        }
        HapticManager.shared.success()
        playBandageSound()

        // Transition to post-tape cups swipe step after celebratory pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            startCupsSwipeStep()
        }
    }

    // MARK: - Post-Tape Sequence: Cups Swipe & Whiteboard
    private func startCupsSwipeStep() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = .swipeCups
            promptText = "Swipe away the cups on the bedside table to clear space!"
            showCupsSwipeHint = true
            isDrinksSwiped = false
            drinksDragOffset = 0.0
        }
        HapticManager.shared.lightTap()
    }

    private func finishCupsSwipe(stageW: CGFloat) {
        guard !isDrinksSwiped else { return }
        isDrinksSwiped = true
        currentStep = .cupsSwiped
        showCupsSwipeHint = false
        playBandageSound()
        HapticManager.shared.mediumTap()
        withAnimation(.easeInOut(duration: 0.45)) {
            drinksDragOffset = -stageW * 0.8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showDrinks = false
            promptForWhiteboardTable()
        }
    }

    private func promptForWhiteboardTable() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = .tapTableForWhiteboard
            promptText = "Sometimes, patients like having a whiteboard to communicate right after getting an NG tube. Tap the table to get a whiteboard!"
            showWhiteboardTableBeacon = true
        }
        HapticManager.shared.lightTap()
    }

    private func handleWhiteboardTableTap() {
        guard currentStep == .tapTableForWhiteboard else { return }
        playBandageSound()
        HapticManager.shared.mediumTap()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            showWhiteboardTableBeacon = false
            showMiniWhiteboard = true
            currentStep = .tapMiniWhiteboard
            promptText = "Finish the preparation by drawing something silly on the whiteboard! Tap the whiteboard to begin."
        }
    }

    private func openLargeWhiteboard() {
        guard currentStep == .tapMiniWhiteboard || currentStep == .miniWhiteboardDisplay else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = .largeWhiteboard
            showLargeWhiteboardModal = true
        }
        HapticManager.shared.lightTap()
    }

    private func selectWhiteboardTool(_ tool: WhiteboardTool) {
        whiteboardCurrentTool = tool
        HapticManager.shared.lightTap()
    }

    private func clearWhiteboard() {
        whiteboardStrokes = []
        currentStrokePoints = []
        HapticManager.shared.mediumTap()
    }

    private func finishWhiteboard() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showLargeWhiteboardModal = false
            currentStep = .miniWhiteboardDisplay
            promptText = "Look at your wonderful drawing! What a great way for your patient to communicate."
        }
        playBandageSound()
        HapticManager.shared.success()

        // Pause for a moment (~3.2s) to admire the user's drawing before congratulating them with You Did It celebration
        whiteboardDelayTimer?.cancel()
        let timer = DispatchWorkItem {
            playVictorySound()
            playChimeSound()
            HapticManager.shared.success()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                showFinalVictoryModal = true
                currentStep = .procedureComplete
            }
        }
        whiteboardDelayTimer = timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2, execute: timer)
    }

    // MARK: - Large Whiteboard Modal View
    @ViewBuilder
    private func largeWhiteboardModalView(stageW: CGFloat, stageH: CGFloat) -> some View {
        let canvasW = stageW * (984.0 / 1366.0)
        let canvasH = stageH * (758.0 / 1024.0)
        let canvasCenterX = stageW * 0.50
        let canvasCenterY = stageH * (480.0 / 1024.0)

        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            ZStack {
                // Background whiteboard on table
                Image("NGTubeWhiteboardGame")
                    .resizable()
                    .frame(width: stageW, height: stageH)

                // Interactive Large Drawing Surface
                Canvas { context, size in
                    context.drawLayer { layer in
                        for stroke in whiteboardStrokes {
                            var path = Path()
                            guard let first = stroke.points.first else { continue }
                            path.move(to: first)
                            for pt in stroke.points.dropFirst() {
                                path.addLine(to: pt)
                            }
                            if stroke.tool == .eraser {
                                layer.blendMode = .clear
                                layer.stroke(path, with: .color(.black), style: StrokeStyle(lineWidth: stroke.tool.lineWidth, lineCap: .round, lineJoin: .round))
                            } else {
                                layer.blendMode = .normal
                                layer.stroke(path, with: .color(stroke.tool.color), style: StrokeStyle(lineWidth: stroke.tool.lineWidth, lineCap: .round, lineJoin: .round))
                            }
                        }

                        if !currentStrokePoints.isEmpty {
                            var activePath = Path()
                            let first = currentStrokePoints[0]
                            activePath.move(to: first)
                            for pt in currentStrokePoints.dropFirst() {
                                activePath.addLine(to: pt)
                            }
                            if whiteboardCurrentTool == .eraser {
                                layer.blendMode = .clear
                                layer.stroke(activePath, with: .color(.black), style: StrokeStyle(lineWidth: whiteboardCurrentTool.lineWidth, lineCap: .round, lineJoin: .round))
                            } else {
                                layer.blendMode = .normal
                                layer.stroke(activePath, with: .color(whiteboardCurrentTool.color), style: StrokeStyle(lineWidth: whiteboardCurrentTool.lineWidth, lineCap: .round, lineJoin: .round))
                            }
                        }
                    }
                }
                .frame(width: canvasW, height: canvasH)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .position(x: canvasCenterX, y: canvasCenterY)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let loc = gesture.location
                            if loc.x >= 0 && loc.x <= canvasW && loc.y >= 0 && loc.y <= canvasH {
                                let refX = loc.x * (984.0 / canvasW)
                                let refY = loc.y * (758.0 / canvasH)
                                currentStrokePoints.append(CGPoint(x: refX, y: refY))
                            }
                        }
                        .onEnded { gesture in
                            if !currentStrokePoints.isEmpty {
                                whiteboardStrokes.append(
                                    WhiteboardStroke(points: currentStrokePoints, tool: whiteboardCurrentTool)
                                )
                                currentStrokePoints = []
                            }
                        }
                )

                // Interactive Eraser Tool on Table
                Button(action: {
                    selectWhiteboardTool(.eraser)
                }) {
                    Image("NGTubeWhiteboardEraserItem")
                        .resizable()
                        .scaledToFit()
                        .frame(width: stageW * (319.0 / 1366.0), height: stageH * (196.0 / 1024.0))
                        .shadow(
                            color: whiteboardCurrentTool == .eraser ? Color.white.opacity(0.9) : Color.black.opacity(0.2),
                            radius: whiteboardCurrentTool == .eraser ? 16 : 4
                        )
                        .scaleEffect(whiteboardCurrentTool == .eraser ? 1.08 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .position(x: stageW * (218.5 / 1366.0), y: stageH * (897.0 / 1024.0))

                // Interactive Blue Marker
                Button(action: {
                    selectWhiteboardTool(.blue)
                }) {
                    Image("NGTubeWhiteboardBlueMarkerItem")
                        .resizable()
                        .scaledToFit()
                        .frame(width: stageW * (284.0 / 1366.0), height: stageH * (86.0 / 1024.0))
                        .shadow(
                            color: whiteboardCurrentTool == .blue ? Color(red: 2/255, green: 132/255, blue: 199/255).opacity(0.95) : Color.black.opacity(0.2),
                            radius: whiteboardCurrentTool == .blue ? 16 : 4
                        )
                        .scaleEffect(whiteboardCurrentTool == .blue ? 1.10 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .position(x: stageW * (1014.0 / 1366.0), y: stageH * (961.0 / 1024.0))

                // Interactive Green Marker
                Button(action: {
                    selectWhiteboardTool(.green)
                }) {
                    Image("NGTubeWhiteboardGreenMarkerItem")
                        .resizable()
                        .scaledToFit()
                        .frame(width: stageW * (70.0 / 1366.0), height: stageH * (283.0 / 1024.0))
                        .shadow(
                            color: whiteboardCurrentTool == .green ? Color(red: 22/255, green: 163/255, blue: 74/255).opacity(0.95) : Color.black.opacity(0.2),
                            radius: whiteboardCurrentTool == .green ? 16 : 4
                        )
                        .scaleEffect(whiteboardCurrentTool == .green ? 1.10 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .position(x: stageW * (1215.0 / 1366.0), y: stageH * (831.5 / 1024.0))

                // Interactive Red Marker
                Button(action: {
                    selectWhiteboardTool(.red)
                }) {
                    Image("NGTubeWhiteboardRedMarkerItem")
                        .resizable()
                        .scaledToFit()
                        .frame(width: stageW * (72.0 / 1366.0), height: stageH * (283.0 / 1024.0))
                        .shadow(
                            color: whiteboardCurrentTool == .red ? Color(red: 220/255, green: 38/255, blue: 38/255).opacity(0.95) : Color.black.opacity(0.2),
                            radius: whiteboardCurrentTool == .red ? 16 : 4
                        )
                        .scaleEffect(whiteboardCurrentTool == .red ? 1.10 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .position(x: stageW * (1306.0 / 1366.0), y: stageH * (780.5 / 1024.0))

                // Top Header Bar (Clear & All Done at Top Center)
                VStack {
                    HStack(spacing: 16) {
                        Button(action: {
                            clearWhiteboard()
                        }) {
                            Text("Clear")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.25))
                                .clipShape(Capsule())
                        }

                        Button(action: {
                            finishWhiteboard()
                        }) {
                            HStack(spacing: 6) {
                                Text("All Done")
                                Image(systemName: "checkmark")
                            }
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 10)
                            .background(Color(red: 16/255, green: 185/255, blue: 129/255))
                            .clipShape(Capsule())
                            .shadow(color: Color(red: 16/255, green: 185/255, blue: 129/255).opacity(0.5), radius: 8, y: 3)
                        }
                    }
                    .padding(.top, 20)

                    Spacer()
                }
            }
            .frame(width: stageW, height: stageH)
        }
        .transition(.opacity)
    }

    // MARK: - Final Procedure Complete Victory Modal
    @ViewBuilder
    private var finalVictoryModalView: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture { }

            // Confetti animation behind celebration card
            ConfettiAnimationView()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 20) {
                Image("GameYouDidIt")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 380)
                    .shadow(color: Color.black.opacity(0.6), radius: 16, x: 0, y: 8)

                Text("You helped your brave patient get a new NG tube!")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                HStack(spacing: 16) {
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        showFinalVictoryModal = false
                        if let onDismiss = onDismiss {
                            onDismiss()
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Finished")
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(Color(red: 16/255, green: 185/255, blue: 129/255))
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 16/255, green: 185/255, blue: 129/255).opacity(0.4), radius: 6, y: 3)
                    }

                    Button(action: {
                        HapticManager.shared.buttonTap()
                        showFinalVictoryModal = false
                        startFaceTapeStep()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Play Again")
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.2), radius: 6, y: 3)
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(red: 22/255, green: 34/255, blue: 48/255).opacity(0.96))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.55), lineWidth: 2)
                    )
            )
            .shadow(color: Color.black.opacity(0.55), radius: 28, x: 0, y: 14)
            .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.25), radius: 22)
        }
        .transition(.scale(scale: 0.9).combined(with: .opacity))
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
        NGTubeBezierCurve(p0: CGPoint(x: 250, y: 420), p1: CGPoint(x: 240, y: 350), p2: CGPoint(x: 210, y: 295), p3: CGPoint(x: 270, y: 275)),
        NGTubeBezierCurve(p0: CGPoint(x: 270, y: 275), p1: CGPoint(x: 330, y: 255), p2: CGPoint(x: 380, y: 310), p3: CGPoint(x: 330, y: 375)),
        NGTubeBezierCurve(p0: CGPoint(x: 330, y: 375), p1: CGPoint(x: 280, y: 420), p2: CGPoint(x: 250, y: 455), p3: CGPoint(x: 330, y: 480)),
        NGTubeBezierCurve(p0: CGPoint(x: 330, y: 480), p1: CGPoint(x: 395, y: 495), p2: CGPoint(x: 440, y: 410), p3: CGPoint(x: 480, y: 340)),

        // 3. Top arch ascending to crest
        NGTubeBezierCurve(p0: CGPoint(x: 480, y: 340), p1: CGPoint(x: 530, y: 280), p2: CGPoint(x: 610, y: 245), p3: CGPoint(x: 690, y: 250)),

        // 4. Top-right dead end (blocks direct route to stomach)
        NGTubeBezierCurve(p0: CGPoint(x: 690, y: 250), p1: CGPoint(x: 770, y: 255), p2: CGPoint(x: 840, y: 275), p3: CGPoint(x: 890, y: 320)),

        // 5. Central vertical plunging channel
        NGTubeBezierCurve(p0: CGPoint(x: 690, y: 250), p1: CGPoint(x: 740, y: 305), p2: CGPoint(x: 735, y: 400), p3: CGPoint(x: 700, y: 490)),
        NGTubeBezierCurve(p0: CGPoint(x: 700, y: 490), p1: CGPoint(x: 660, y: 590), p2: CGPoint(x: 640, y: 660), p3: CGPoint(x: 620, y: 730)),

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
        path.addCurve(to: pt(270, 275), control1: pt(240, 350), control2: pt(210, 295))
        path.addCurve(to: pt(330, 375), control1: pt(330, 255), control2: pt(380, 310))
        path.addCurve(to: pt(330, 480), control1: pt(280, 420), control2: pt(250, 455))
        path.addCurve(to: pt(480, 340), control1: pt(395, 495), control2: pt(440, 410))

        // 3. Top arch ascending to crest
        path.move(to: pt(480, 340))
        path.addCurve(to: pt(690, 250), control1: pt(530, 280), control2: pt(610, 245))

        // 4. Top-right dead end (blocks direct route to stomach)
        path.move(to: pt(690, 250))
        path.addCurve(to: pt(890, 320), control1: pt(770, 255), control2: pt(840, 275))

        // 5. Central vertical plunging channel
        path.move(to: pt(690, 250))
        path.addCurve(to: pt(700, 490), control1: pt(740, 305), control2: pt(735, 400))
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
