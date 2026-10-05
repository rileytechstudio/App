import SwiftUI

public struct GamesView: View {
    public var onBackToHome: () -> Void
    public var onSettingsTapped: (() -> Void)? = nil
    public var onOpenPreparations: (() -> Void)? = nil
    public var onOpenAnatomy: (() -> Void)? = nil
    public var onOpenGallery: (() -> Void)? = nil
    public var onOpenMaskGame: (() -> Void)? = nil
    public var onOpenCLZPuzzle: (() -> Void)? = nil
    
    // Background scroll offset animation state
    @State private var patternOffset: CGPoint = .zero
    @State private var selectedGameItem: GameItem? = nil
    @State private var isShowingCLZPuzzle: Bool = false
    
    public init(
        onBackToHome: @escaping () -> Void,
        onSettingsTapped: (() -> Void)? = nil,
        onOpenPreparations: (() -> Void)? = nil,
        onOpenAnatomy: (() -> Void)? = nil,
        onOpenGallery: (() -> Void)? = nil,
        onOpenMaskGame: (() -> Void)? = nil,
        onOpenCLZPuzzle: (() -> Void)? = nil
    ) {
        self.onBackToHome = onBackToHome
        self.onSettingsTapped = onSettingsTapped
        self.onOpenPreparations = onOpenPreparations
        self.onOpenAnatomy = onOpenAnatomy
        self.onOpenGallery = onOpenGallery
        self.onOpenMaskGame = onOpenMaskGame
        self.onOpenCLZPuzzle = onOpenCLZPuzzle
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            let bottomBarHeight: CGFloat = min(max(screenSize.height * 0.09, 48), 85)
            
            ZStack(alignment: .top) {
                // Base background color
                AppTheme.primaryPurple
                    .ignoresSafeArea()
                
                // Animated Scrolling Background Pattern Layer
                scrollingPatternLayer(size: screenSize)
                    .ignoresSafeArea()
                
                // Content Layer with Header pinned strictly to top, Buttons in middle, Bottom Bar at bottom
                VStack(spacing: 0) {
                    HomeHeaderView(
                        availableWidth: screenSize.width,
                        availableHeight: screenSize.height,
                        safeAreaTop: geometry.safeAreaInsets.top,
                        showBackButton: true,
                        showHomeButton: true,
                        showSettingsButton: true,
                        onBackTapped: {
                            HapticManager.shared.lightTap()
                            onBackToHome()
                        },
                        onHomeTapped: {
                            HapticManager.shared.lightTap()
                            onBackToHome()
                        },
                        onSettingsTapped: {
                            HapticManager.shared.buttonTap()
                            onSettingsTapped?()
                        }
                    )
                    .zIndex(10)
                    
                    // Games Buttons Interactive Area
                    gamesContentArea(availableWidth: screenSize.width, availableHeight: screenSize.height, bottomBarHeight: bottomBarHeight)
                        .zIndex(15)
                    
                    // Fixed Bottom Navigation Bar (4 Tabs)
                    bottomBarView(availableWidth: screenSize.width, height: bottomBarHeight)
                        .zIndex(20)
                }
                .frame(width: screenSize.width, height: screenSize.height, alignment: .top)
            }
            .ignoresSafeArea(.all)
            .onAppear {
                startSlowBackgroundScroll()
            }
        }
    }
    
    // MARK: - Animated Scrolling Background Pattern
    private func scrollingPatternLayer(size: CGSize) -> some View {
        GeometryReader { _ in
            if let pattern = UIImage(named: "GamesBackgroundPattern") {
                Image(uiImage: pattern)
                    .resizable(resizingMode: .tile)
                    .frame(width: size.width + 1366, height: size.height + 1024)
                    .offset(x: patternOffset.x, y: patternOffset.y)
                    .opacity(0.95)
                    .allowsHitTesting(false)
            }
        }
        .clipped()
    }
    
    private func startSlowBackgroundScroll() {
        withAnimation(.linear(duration: 74).repeatForever(autoreverses: false)) {
            // Smooth continuous drift down and to the left matching Settings speed (23 px/s)
            patternOffset = CGPoint(x: -1366, y: 1024)
        }
    }
    
    // MARK: - Games Buttons Interactive Area
    @ViewBuilder
    private func gamesContentArea(availableWidth: CGFloat, availableHeight: CGFloat, bottomBarHeight: CGFloat) -> some View {
        let cardWidth = min(availableWidth * 0.84, 680)
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {
                Spacer(minLength: 16)
                
                // Mask Decoration Game Card
                Button(action: {
                    HapticManager.shared.buttonTap()
                    if let onOpenMaskGame = onOpenMaskGame {
                        onOpenMaskGame()
                    } else {
                        selectedGameItem = GameItem(
                            id: "mask-decoration",
                            title: "Mask Decoration Game",
                            imageName: "ButtonMaskDecoration",
                            description: "Decorate your anesthesia mask with colorful scents and fun stickers before your surgery or procedure!"
                        )
                    }
                }) {
                    Image("ButtonMaskDecoration")
                        .resizable()
                        .aspectRatio(AppTheme.procedureCardAspectRatio, contentMode: .fit)
                        .frame(width: cardWidth)
                }
                .buttonStyle(BouncyButtonStyle(scaleAmount: 0.96))
                .accessibilityLabel("Mask Decoration Game button")
                
                // Child Life Zone Puzzle Card
                Button(action: {
                    HapticManager.shared.buttonTap()
                    if let onOpenCLZPuzzle = onOpenCLZPuzzle {
                        onOpenCLZPuzzle()
                    } else {
                        isShowingCLZPuzzle = true
                    }
                }) {
                    Image("ButtonCLZPuzzle")
                        .resizable()
                        .aspectRatio(AppTheme.procedureCardAspectRatio, contentMode: .fit)
                        .frame(width: cardWidth)
                }
                .buttonStyle(BouncyButtonStyle(scaleAmount: 0.96))
                .accessibilityLabel("Child Life Zone Puzzle button")
                
                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity, minHeight: max(0, availableHeight - 120 - bottomBarHeight))
        }
        .sheet(item: $selectedGameItem) { item in
            GameDetailSheet(item: item)
        }
        .fullScreenCover(isPresented: $isShowingCLZPuzzle) {
            CLZPuzzleView(onDismiss: {
                isShowingCLZPuzzle = false
            })
        }
    }
    
    // MARK: - Bottom Navigation Bar (4 Tabs)
    @ViewBuilder
    private func bottomBarView(availableWidth: CGFloat, height: CGFloat) -> some View {
        let horizontalPadding: CGFloat = min(max(availableWidth * 0.005, 3), 6)
        let tabSpacing: CGFloat = min(max(availableWidth * 0.005, 3), 6)
        
        ZStack {
            // Ultra-thin liquid glass frosted background matching top header aesthetic
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .background(.ultraThinMaterial)
            
            Image("Bottom_Toolbar_Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: availableWidth, height: height)
                .clipped()
                .opacity(0.35)
            
            // Specular glass top rim border matching Apple liquid glass
            VStack {
                Rectangle()
                    .fill(Color.white.opacity(0.35))
                    .frame(height: 1)
                Spacer()
            }
            
            HStack(spacing: tabSpacing) {
                // Preparations Tab
                Button(action: {
                    HapticManager.shared.buttonTap()
                    onOpenPreparations?()
                }) {
                    Image("Isolated_Preparations_Not_Selected")
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: height - 4)
                        .padding(.vertical, 2)
                }
                .accessibilityLabel("Preparations tab")
                
                // Anatomy Explorer Tab
                Button(action: {
                    HapticManager.shared.buttonTap()
                    onOpenAnatomy?()
                }) {
                    Image("Isolated_Anat_Explorer_Not_Selected")
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: height - 4)
                        .padding(.vertical, 2)
                }
                .accessibilityLabel("Anatomy Explorer tab")
                
                // Gallery Tab
                Button(action: {
                    HapticManager.shared.buttonTap()
                    onOpenGallery?()
                }) {
                    Image("Isolated_Gallery_Not_Selected")
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: height - 4)
                        .padding(.vertical, 2)
                }
                .accessibilityLabel("Gallery tab")
                
                // Games Tab (Current Active)
                Image("Isolated_Games_Selected")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: height - 4)
                    .padding(.vertical, 2)
                    .accessibilityLabel("Games tab, currently active")
            }
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: 1366)
        }
        .frame(width: availableWidth, height: height)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: -2)
    }
}

// MARK: - Game Item Model
public struct GameItem: Identifiable {
    public let id: String
    public let title: String
    public let imageName: String
    public let description: String
    
    public init(id: String, title: String, imageName: String, description: String) {
        self.id = id
        self.title = title
        self.imageName = imageName
        self.description = description
    }
}

// MARK: - Game Detail Sheet
public struct GameDetailSheet: View {
    public let item: GameItem
    @Environment(\.presentationMode) var presentationMode
    
    public init(item: GameItem) {
        self.item = item
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                AppTheme.primaryPurple
                    .opacity(0.06)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Image(item.imageName)
                            .resizable()
                            .aspectRatio(AppTheme.procedureCardAspectRatio, contentMode: .fit)
                            .frame(maxWidth: 500)
                            .padding(.top, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text(item.title)
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundColor(AppTheme.primaryPurple)
                            
                            Text(item.description)
                                .font(.body)
                                .foregroundColor(.primary.opacity(0.85))
                                .lineSpacing(4)
                            
                            if item.id == "clz-puzzle" {
                                HStack(spacing: 10) {
                                    Text("🧩")
                                        .font(.title2)
                                    Text("Interactive puzzle game coming soon!")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppTheme.primaryPurple)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(AppTheme.primaryPurple)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
