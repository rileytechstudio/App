import SwiftUI

public enum PuzzleDifficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    public var id: String { rawValue }
    
    public var grid: (cols: Int, rows: Int) {
        switch self {
        case .easy: return (3, 2)
        case .medium: return (4, 3)
        case .hard: return (5, 4)
        }
    }
    
    public var totalPieces: Int {
        let (c, r) = grid
        return c * r
    }
}

public struct CLZPuzzlePiece: Identifiable {
    public let id: Int
    public let col: Int
    public let row: Int
    public let cols: Int
    public let rows: Int
}

public struct CLZPuzzleView: View {
    public var onDismiss: () -> Void
    
    @State private var difficulty: PuzzleDifficulty = .easy
    @State private var placedPieces: Set<Int> = []
    @State private var showHint: Bool = false
    @State private var showCelebration: Bool = false
    @State private var selectedPieceId: Int? = nil
    
    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    private var pieces: [CLZPuzzlePiece] {
        let (cols, rows) = difficulty.grid
        var result: [CLZPuzzlePiece] = []
        for r in 0..<rows {
            for c in 0..<cols {
                result.append(CLZPuzzlePiece(id: r * cols + c, col: c, row: r, cols: cols, rows: rows))
            }
        }
        return result
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            
            ZStack(alignment: .top) {
                // Base purple color #5931bb
                Color(red: 0.35, green: 0.19, blue: 0.73)
                    .ignoresSafeArea()
                
                // Purple BG image
                if let purpleBg = UIImage(named: "PurpleBG") {
                    Image(uiImage: purpleBg)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenSize.width, height: screenSize.height)
                        .clipped()
                        .ignoresSafeArea()
                }
                
                // Table Texture overlay
                if let tableTexture = UIImage(named: "TableTexture") {
                    Image(uiImage: tableTexture)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenSize.width, height: screenSize.height)
                        .clipped()
                        .ignoresSafeArea()
                }
                
                VStack(spacing: 8) {
                    // Top Navigation Header (Matching Mask Decoration Game Header Style)
                    topBarView(screenSize: screenSize)
                    
                    // Main Puzzle Play Area (Centered Board + Perimeter Scattered Pieces)
                    mainStageView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Celebration Overlay
                if showCelebration {
                    celebrationOverlay(screenSize: screenSize)
                }
            }
        }
    }
    
    // MARK: - Game-Style Top Bar (Matching Mask Decoration Game Header)
    @ViewBuilder
    private func topBarView(screenSize: CGSize) -> some View {
        HStack(alignment: .center) {
            // Left: Back button
            Button(action: {
                HapticManager.shared.lightTap()
                onDismiss()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                    Text("Back")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.18))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
            }
            .buttonStyle(BouncyButtonStyle(scaleAmount: 0.95))
            
            Spacer()
            
            // Middle: Difficulty Selector + Guide Toggle Next to It
            HStack(spacing: 10) {
                // Difficulty Selector Pills
                HStack(spacing: 4) {
                    ForEach(PuzzleDifficulty.allCases) { diff in
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            difficulty = diff
                            placedPieces.removeAll()
                            selectedPieceId = nil
                            showCelebration = false
                        }) {
                            Text(diff.rawValue)
                                .font(.system(size: 13.5, weight: .bold, design: .rounded))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(difficulty == diff ? Color.white : Color.white.opacity(0.12))
                                .foregroundColor(difficulty == diff ? AppTheme.primaryPurple : Color.white.opacity(0.9))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(4)
                .background(Color.white.opacity(0.14))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.24), lineWidth: 1)
                )
                
                // Guide Toggle right next to it
                Button(action: {
                    HapticManager.shared.lightTap()
                    showHint.toggle()
                }) {
                    Text(showHint ? "Guide: On" : "Guide: Off")
                        .font(.system(size: 13.5, weight: .bold, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .background(showHint ? Color(red: 0.98, green: 0.75, blue: 0.18) : Color.white.opacity(0.14))
                        .foregroundColor(showHint ? Color(red: 0.24, green: 0.15, blue: 0.0) : Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.24), lineWidth: 1)
                        )
                }
                .buttonStyle(BouncyButtonStyle(scaleAmount: 0.95))
            }
            
            Spacer()
            
            // Right: Home button
            Button(action: {
                HapticManager.shared.lightTap()
                onDismiss()
            }) {
                Image(systemName: "house.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
            }
            .buttonStyle(BouncyButtonStyle(scaleAmount: 0.95))
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Main Interactive Stage
    @ViewBuilder
    private func mainStageView() -> some View {
        GeometryReader { stageGeo in
            let stageSize = stageGeo.size
            let isLandscape = stageSize.width >= stageSize.height * 1.05
            let boardWidth = isLandscape ? min(stageSize.width * 0.54, 560) : min(stageSize.width * 0.78, 440)
            let boardHeight = boardWidth * (1024.0 / 1366.0)
            let boardX0 = (stageSize.width - boardWidth) / 2
            let boardY0 = (stageSize.height - boardHeight) / 2
            let boardRect = CGRect(x: boardX0, y: boardY0, width: boardWidth, height: boardHeight)
            
            let unplaced = pieces.filter { !placedPieces.contains($0.id) }
            let total = difficulty.totalPieces
            
            let pieceTargetW = isLandscape ? (difficulty == .hard ? 66 : (difficulty == .medium ? 78 : 96)) : (difficulty == .hard ? 56 : (difficulty == .medium ? 66 : 82))
            let pieceTargetH = pieceTargetW * (1024.0 / 1366.0)
            
            ZStack {
                // Centered Puzzle Assembly Board
                boardView(width: boardWidth, height: boardHeight)
                    .position(x: stageSize.width / 2, y: stageSize.height / 2)
                
                // Border Scattered Pieces Layer
                ForEach(Array(unplaced.enumerated()), id: \.element.id) { index, p in
                    let slot = computeScatterSlot(index: p.id, total: total, stageSize: stageSize, boardRect: boardRect)
                    let isSelected = selectedPieceId == p.id
                    
                    Button(action: {
                        HapticManager.shared.lightTap()
                        if selectedPieceId == p.id {
                            selectedPieceId = nil
                        } else {
                            selectedPieceId = p.id
                        }
                    }) {
                        pieceSliceView(col: p.col, row: p.row, cols: p.cols, rows: p.rows, targetW: pieceTargetW, targetH: pieceTargetH)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isSelected ? Color(red: 1.0, green: 0.84, blue: 0.31) : Color.white.opacity(0.8), lineWidth: isSelected ? 3.5 : 1.5)
                            )
                            .scaleEffect(isSelected ? 1.14 : 1.0)
                            .rotationEffect(.degrees(isSelected ? 0 : slot.angle))
                            .shadow(color: isSelected ? Color.yellow.opacity(0.8) : Color.black.opacity(0.55), radius: isSelected ? 12 : 6, x: 0, y: 4)
                    }
                    .buttonStyle(BouncyButtonStyle(scaleAmount: 0.94))
                    .position(x: slot.x, y: slot.y)
                }
            }
        }
    }
    
    // MARK: - Puzzle Board
    @ViewBuilder
    private func boardView(width: CGFloat, height: CGFloat) -> some View {
        let (cols, rows) = difficulty.grid
        let cellW = width / CGFloat(cols)
        let cellH = height / CGFloat(rows)
        
        ZStack {
            // Board frame background
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.08, green: 0.03, blue: 0.15).opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.32), lineWidth: 3)
                )
            
            // Ghost guide image
            if showHint {
                Image("CLZPuzzleImage")
                    .resizable()
                    .aspectRatio(1366.0 / 1024.0, contentMode: .fit)
                    .opacity(0.20)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            // Grid Slots
            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { r in
                    HStack(spacing: 0) {
                        ForEach(0..<cols, id: \.self) { c in
                            let pieceId = r * cols + c
                            let isPlaced = placedPieces.contains(pieceId)
                            let isSelected = selectedPieceId == pieceId
                            
                            ZStack {
                                Rectangle()
                                    .strokeBorder(
                                        isSelected ? Color(red: 1.0, green: 0.84, blue: 0.31) : Color.white.opacity(0.28),
                                        style: StrokeStyle(lineWidth: isSelected ? 3.5 : 1.5, dash: [4, 4])
                                    )
                                    .background(isSelected ? Color.yellow.opacity(0.22) : Color.clear)
                                
                                if isPlaced {
                                    pieceSliceView(col: c, row: r, cols: cols, rows: rows, targetW: cellW, targetH: cellH)
                                        .transition(.scale)
                                }
                            }
                            .frame(width: cellW, height: cellH)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let sel = selectedPieceId, sel == pieceId {
                                    snapPiece(pieceId)
                                }
                            }
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(width: width, height: height)
        .shadow(color: Color.black.opacity(0.45), radius: 18, x: 0, y: 10)
    }
    
    // MARK: - Piece Image Slice
    @ViewBuilder
    private func pieceSliceView(col: Int, row: Int, cols: Int, rows: Int, targetW: CGFloat, targetH: CGFloat) -> some View {
        GeometryReader { _ in
            let fullW = targetW * CGFloat(cols)
            let fullH = targetH * CGFloat(rows)
            let offsetX = -CGFloat(col) * targetW
            let offsetY = -CGFloat(row) * targetH
            
            Image("CLZPuzzleImage")
                .resizable()
                .frame(width: fullW, height: fullH)
                .offset(x: offsetX, y: offsetY)
        }
        .frame(width: targetW, height: targetH)
        .clipped()
    }
    
    // MARK: - Scatter Positioning Algorithm
    private func computeScatterSlot(index: Int, total: Int, stageSize: CGSize, boardRect: CGRect) -> (x: CGFloat, y: CGFloat, angle: Double) {
        let isLandscape = stageSize.width >= stageSize.height * 1.05
        let tilts: [Double] = [-5, 4, -3, 6, -4, 5, -6, 3, 5, -4, 4, -5, 3, -6, 5, -3, 6, -5, 4, -4]
        let rot = tilts[index % tilts.count]
        
        let boardX0 = boardRect.minX
        let boardX1 = boardRect.maxX
        let boardY0 = boardRect.minY
        let boardY1 = boardRect.maxY
        let boardW = boardRect.width
        let boardH = boardRect.height
        
        if isLandscape {
            if total <= 6 {
                if index < 3 {
                    let y = boardY0 + (CGFloat(index) + 0.5) * (boardH / 3)
                    let x = max(48, boardX0 * 0.48 + (index % 2 == 0 ? -8 : 8))
                    return (x, y, rot)
                } else {
                    let i = index - 3
                    let y = boardY0 + (CGFloat(i) + 0.5) * (boardH / 3)
                    let x = min(stageSize.width - 48, boardX1 + (stageSize.width - boardX1) * 0.52 + (i % 2 == 0 ? 8 : -8))
                    return (x, y, rot)
                }
            } else if total <= 12 {
                if index < 4 {
                    let y = boardY0 + (CGFloat(index) + 0.5) * (boardH / 4)
                    let x = max(44, boardX0 * 0.48 + (index % 2 == 0 ? -12 : 12))
                    return (x, y, rot)
                } else if index < 8 {
                    let i = index - 4
                    let y = boardY0 + (CGFloat(i) + 0.5) * (boardH / 4)
                    let x = min(stageSize.width - 44, boardX1 + (stageSize.width - boardX1) * 0.52 + (i % 2 == 0 ? 12 : -12))
                    return (x, y, rot)
                } else if index < 10 {
                    let i = index - 8
                    let x = boardX0 + CGFloat(i + 1) * (boardW / 3)
                    let y = max(38, boardY0 * 0.48)
                    return (x, y, rot)
                } else {
                    let i = index - 10
                    let x = boardX0 + CGFloat(i + 1) * (boardW / 3)
                    let y = min(stageSize.height - 38, boardY1 + (stageSize.height - boardY1) * 0.52)
                    return (x, y, rot)
                }
            } else {
                if index < 6 {
                    let col = index % 2
                    let row = index / 2
                    let x = max(40, col == 0 ? boardX0 * 0.30 : boardX0 * 0.72)
                    let y = boardY0 + (CGFloat(row) + 0.5) * (boardH / 3) + CGFloat(col * 16 - 8)
                    return (x, y, rot)
                } else if index < 12 {
                    let i = index - 6
                    let col = i % 2
                    let row = i / 2
                    let margin = stageSize.width - boardX1
                    let x = min(stageSize.width - 40, boardX1 + (col == 0 ? margin * 0.28 : margin * 0.70))
                    let y = boardY0 + (CGFloat(row) + 0.5) * (boardH / 3) + CGFloat(col * 16 - 8)
                    return (x, y, rot)
                } else if index < 16 {
                    let i = index - 12
                    let x = boardX0 + (CGFloat(i) + 0.5) * (boardW / 4)
                    let y = max(36, boardY0 * 0.48 + (i % 2 == 0 ? -6 : 6))
                    return (x, y, rot)
                } else {
                    let i = index - 16
                    let x = boardX0 + (CGFloat(i) + 0.5) * (boardW / 4)
                    let y = min(stageSize.height - 36, boardY1 + (stageSize.height - boardY1) * 0.52 + (i % 2 == 0 ? 6 : -6))
                    return (x, y, rot)
                }
            }
        } else {
            // Portrait
            if total <= 6 {
                if index < 3 {
                    let x = boardX0 + (CGFloat(index) + 0.5) * (boardW / 3)
                    let y = max(40, boardY0 * 0.50 + (index % 2 == 0 ? -6 : 6))
                    return (x, y, rot)
                } else {
                    let i = index - 3
                    let x = boardX0 + (CGFloat(i) + 0.5) * (boardW / 3)
                    let y = min(stageSize.height - 40, boardY1 + (stageSize.height - boardY1) * 0.50 + (i % 2 == 0 ? 6 : -6))
                    return (x, y, rot)
                }
            } else if total <= 12 {
                if index < 4 {
                    let x = boardX0 + (CGFloat(index) + 0.5) * (boardW / 4)
                    let y = max(38, boardY0 * 0.42 + (index % 2 == 0 ? -8 : 8))
                    return (x, y, rot)
                } else if index < 8 {
                    let i = index - 4
                    let x = boardX0 + (CGFloat(i) + 0.5) * (boardW / 4)
                    let y = min(stageSize.height - 38, boardY1 + (stageSize.height - boardY1) * 0.58 + (i % 2 == 0 ? 8 : -8))
                    return (x, y, rot)
                } else if index < 10 {
                    let i = index - 8
                    let x = max(36, boardX0 * 0.45)
                    let y = boardY0 + CGFloat(i + 1) * (boardH / 3)
                    return (x, y, rot)
                } else {
                    let i = index - 10
                    let x = min(stageSize.width - 36, boardX1 + (stageSize.width - boardX1) * 0.55)
                    let y = boardY0 + CGFloat(i + 1) * (boardH / 3)
                    return (x, y, rot)
                }
            } else {
                if index < 8 {
                    let row = index / 4
                    let col = index % 4
                    let x = boardX0 + (CGFloat(col) + 0.5) * (boardW / 4)
                    let y = max(34, row == 0 ? boardY0 * 0.32 : boardY0 * 0.72)
                    return (x, y, rot)
                } else if index < 16 {
                    let i = index - 8
                    let row = i / 4
                    let col = i % 4
                    let margin = stageSize.height - boardY1
                    let x = boardX0 + (CGFloat(col) + 0.5) * (boardW / 4)
                    let y = min(stageSize.height - 34, boardY1 + (row == 0 ? margin * 0.30 : margin * 0.70))
                    return (x, y, rot)
                } else if index < 18 {
                    let i = index - 16
                    let x = max(36, boardX0 * 0.45)
                    let y = boardY0 + CGFloat(i + 1) * (boardH / 3)
                    return (x, y, rot)
                } else {
                    let i = index - 18
                    let x = min(stageSize.width - 36, boardX1 + (stageSize.width - boardX1) * 0.55)
                    let y = boardY0 + CGFloat(i + 1) * (boardH / 3)
                    return (x, y, rot)
                }
            }
        }
    }
    
    // MARK: - Actions
    private func snapPiece(_ pieceId: Int) {
        HapticManager.shared.buttonTap()
        placedPieces.insert(pieceId)
        selectedPieceId = nil
        
        if placedPieces.count >= difficulty.totalPieces {
            withAnimation(.spring()) {
                showCelebration = true
            }
        }
    }
    
    // MARK: - Celebration Overlay
    @ViewBuilder
    private func celebrationOverlay(screenSize: CGSize) -> some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image("YouDidIt2Cropped")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 280)
                
                Text("Puzzle Complete!")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(AppTheme.primaryPurple)
                
                Text("Great job solving the Child Life Zone puzzle on \(difficulty.rawValue) mode!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
                
                Button(action: {
                    HapticManager.shared.buttonTap()
                    placedPieces.removeAll()
                    showCelebration = false
                }) {
                    Text("Play Again")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(AppTheme.primaryPurple)
                        .clipShape(Capsule())
                }
                .buttonStyle(BouncyButtonStyle(scaleAmount: 0.95))
                
                Button(action: {
                    HapticManager.shared.lightTap()
                    onDismiss()
                }) {
                    Text("Back to Games")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.3), radius: 24)
            .frame(maxWidth: 420)
        }
    }
}
