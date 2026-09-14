import SwiftUI

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
    case completed = 9
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
    @State private var ivCountdownValue: Int = 3
    @State private var isCountingDown: Bool = false
    @State private var canPokeIV: Bool = false
    @State private var isIVInserted: Bool = false
    @State private var needleRetractOpacity: Double = 1.0
    @State private var catheterOpacity: Double = 0.0
    
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
    
    public init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            let isLandscape = screenSize.width > screenSize.height
            let bottomBarHeight: CGFloat = min(max(screenSize.height * 0.09, 48), 85)
            let availableHeight = max(screenSize.height - bottomBarHeight, 100)
            
            // Stage sizing to preserve 1366 x 1024 aspect ratio
            let stageAspectRatio: CGFloat = 1366.0 / 1024.0
            let stageSize = calculateStageSize(containerWidth: screenSize.width, containerHeight: availableHeight, aspectRatio: stageAspectRatio)
            
            ZStack(alignment: .bottom) {
                // Background Fill
                Color(red: 35/255, green: 18/255, blue: 71/255)
                    .ignoresSafeArea()
                
                // MARK: - Game Stage Area
                VStack(spacing: 0) {
                    // Top Navigation Header
                    topGameHeader(screenSize: screenSize)
                    
                    // Centered Game Canvas
                    ZStack {
                        gameCanvas(stageSize: stageSize)
                            .frame(width: stageSize.width, height: stageSize.height)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 8)
                }
                .padding(.bottom, bottomBarHeight)
                
                // MARK: - Fixed Bottom 5-Tab Navigation Bar (Games Highlighted)
                bottomBarView(availableWidth: screenSize.width, height: bottomBarHeight)
                
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
        }
    }
    
    // MARK: - Top Navigation Header
    @ViewBuilder
    private func topGameHeader(screenSize: CGSize) -> some View {
        HStack {
            Button(action: {
                HapticManager.shared.lightTap()
                if let onDismiss = onDismiss {
                    onDismiss()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                    Text("Home")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.18))
                .clipShape(Capsule())
            }
            
            Spacer()
            
            // Educational Activity Title Badge
            HStack(spacing: 6) {
                Image(systemName: headerBadgeIcon)
                    .foregroundColor(Color.yellow)
                Text(headerBadgeTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.18))
            .clipShape(Capsule())
            
            Spacer()
            
            // Reset Button
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
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }
    
    private var headerBadgeIcon: String {
        switch currentStep {
        case .ointment: return "cross.case.fill"
        case .bandage: return "bandage.fill"
        case .removeBandage: return "hand.tap.fill"
        case .washcloth: return "sparkles"
        case .tourniquet: return "hand.draw.fill"
        case .cleanWipePacket: return "scissors"
        case .cleanWipeArm: return "sparkles"
        case .insertIV: return "cross.vial.fill"
        case .completed: return "checkmark.circle.fill"
        }
    }
    
    private var headerBadgeTitle: String {
        switch currentStep {
        case .ointment: return "Step 1: Apply Numbing Ointment"
        case .bandage: return "Step 2: Place Clear Bandage"
        case .removeBandage: return "Step 3: Tap Bandage to Remove"
        case .washcloth: return "Step 4: Wipe Away Lotion"
        case .tourniquet: return "Step 5: Place Tourniquet Band"
        case .cleanWipePacket: return "Step 6: Rip Open Clean Wipe"
        case .cleanWipeArm: return "Step 7: Wipe Arm Clean"
        case .insertIV: return "Step 8: Place the IV"
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
            
            // Layer 3: Medical Supply Kit Bag
            Image("GameBag")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: stageSize.width, height: stageSize.height)
                .allowsHitTesting(false)
            
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
            if currentStep == .ointment {
                floatingOintmentItem(stageSize: stageSize, elbowZoneRect: elbowDropZoneRect)
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
            
            // Layer 14: Floating Interactive IV Needle & Catheter (Step 8)
            if currentStep == .insertIV {
                veinDropZoneView(stageSize: stageSize)
                floatingIVItem(stageSize: stageSize)
                
                // When ready to poke, tapping anywhere on screen inserts the needle
                if canPokeIV && !isIVInserted {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            pokeInsertNeedleSwiftUI()
                        }
                }
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
            return
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
        let targetCenter = CGPoint(x: stageSize.width * 0.742, y: stageSize.height * 0.551)
        
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
        .contentShape(Rectangle())
        .position(x: currentPos.x + advanceOffset.width, y: currentPos.y + advanceOffset.height)
        .gesture(
            DragGesture(coordinateSpace: .local)
                .onChanged { value in
                    guard !isIVLockedToVein else { return }
                    isIVDragging = true
                    ivDragOffset = value.translation
                    
                    let curX = initialX + ivDragOffset.width
                    let curY = initialY + ivDragOffset.height
                    let dist = hypot(curX - targetCenter.x, curY - targetCenter.y)
                    isIVOverVein = dist <= max(90, stageSize.width * 0.08)
                    
                    if dist <= max(55, stageSize.width * 0.045) {
                        lockIVToVeinSwiftUI()
                    }
                }
                .onEnded { value in
                    guard !isIVLockedToVein else { return }
                    isIVDragging = false
                    let curX = initialX + ivDragOffset.width
                    let curY = initialY + ivDragOffset.height
                    let dist = hypot(curX - targetCenter.x, curY - targetCenter.y)
                    if dist <= max(90, stageSize.width * 0.08) {
                        lockIVToVeinSwiftUI()
                    } else {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                            ivDragOffset = .zero
                            isIVOverVein = false
                        }
                    }
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    if isIVLockedToVein && canPokeIV && !isIVInserted {
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
        HapticManager.shared.successNotification()
        
        // Needle plunges and immediately becomes the soft IV catheter asset
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            needleRetractOpacity = 0.0
            catheterOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                currentStep = .completed
                showSuccessModal = true
            }
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
            return
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
    
    // MARK: - Success Celebration Modal
    @ViewBuilder
    private var successOverlayView: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                Text("✨ 🩺 🩹 🧴 🧼 ✨")
                    .font(.system(size: 44))
                
                Text("Great Job!")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(AppTheme.primaryPurple)
                
                Text("You applied numbing ointment, wrapped the clear bandage, wiped off the lotion, placed the tourniquet band, cleaned the arm with the wipe, and safely guided and placed the IV catheter!")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 10)
                
                Button(action: {
                    HapticManager.shared.buttonTap()
                    resetGame()
                }) {
                    Text("Play Again")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0/255, green: 198/255, blue: 255/255), Color(red: 0/255, green: 114/255, blue: 255/255)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 0, green: 114/255, blue: 255/255).opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.top, 8)
            }
            .padding(28)
            .frame(maxWidth: 380)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.3), radius: 25, x: 0, y: 12)
            .padding(.horizontal, 30)
        }
    }
    
    // MARK: - Bottom Navigation Bar (5 Tabs)
    @ViewBuilder
    private func bottomBarView(availableWidth: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Image("BottomBarGames")
                .resizable()
                .aspectRatio(AppTheme.bottomBarAspectRatio, contentMode: .fit)
                .frame(width: availableWidth)
            
            // Tap zones for bottom bar tabs
            HStack(spacing: 0) {
                // Preparations Tab
                Button(action: {
                    HapticManager.shared.buttonTap()
                    if let onDismiss = onDismiss {
                        onDismiss()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Color.clear
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Preparations tab")
                
                // Glossary Tab
                Button(action: {
                    HapticManager.shared.buttonTap()
                }) {
                    Color.clear
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Glossary tab")
                
                // Anatomy Explorer Tab
                Button(action: {
                    HapticManager.shared.buttonTap()
                }) {
                    Color.clear
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Anatomy Explorer tab")
                
                // Gallery Tab
                Button(action: {
                    HapticManager.shared.buttonTap()
                }) {
                    Color.clear
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Gallery tab")
                
                // Games Tab (Current Active)
                Button(action: {
                    HapticManager.shared.buttonTap()
                    resetGame()
                }) {
                    Color.clear
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Games tab, currently active. Tap to reset game.")
            }
        }
        .frame(height: height)
    }
    
    // MARK: - Helper Methods
    private func resetGame() {
        stopSwiftUISqueeze()
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
            ivCountdownValue = 3
            isCountingDown = false
            canPokeIV = false
            isIVInserted = false
            needleRetractOpacity = 1.0
            catheterOpacity = 0.0
            
            ointmentDragOffset = .zero
            isOintmentDragging = false
            isOintmentOverElbow = false
            isSqueezing = false
            squeezeProgress = 0.0
            showSuccessModal = false
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
