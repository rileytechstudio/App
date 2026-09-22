import SwiftUI

// MARK: - Layout Mode
public enum HomeLayoutMode {
    /// Automatically switches between 3-column landscape/tablet layout and 2-column compact phone layout
    case autoAdaptive
    /// Forces the exact 3-column top row layout from the mockup across all screen sizes with proportional scaling
    case forceMockupLayout
}

// MARK: - Main Home Screen View
public struct HomeScreenView: View {
    @StateObject private var navState = HomeNavigationState()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    public var layoutMode: HomeLayoutMode
    public var showHospitalOverlay: Bool
    
    public init(layoutMode: HomeLayoutMode = .autoAdaptive, showHospitalOverlay: Bool = true) {
        self.layoutMode = layoutMode
        self.showHospitalOverlay = showHospitalOverlay
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            let isLandscape = screenSize.width > screenSize.height
            let isWideScreen = screenSize.width >= 620 || isLandscape
            let shouldUseMockupGrid = (layoutMode == .forceMockupLayout) || isWideScreen
            
            ZStack(alignment: .top) {
                // MARK: Background Layer
                backgroundLayer(screenSize: screenSize)
                    .ignoresSafeArea()
                
                // MARK: Main Content Structure
                VStack(spacing: 0) {
                    // Top Responsive Header
                    HomeHeaderView(
                        availableWidth: screenSize.width,
                        availableHeight: screenSize.height,
                        onSettingsTapped: {
                            navState.navigate(to: .settings)
                        },
                        onHomeTapped: {
                            navState.resetToHome()
                        }
                    )
                    
                    // Main Interactive Body
                    if shouldUseMockupGrid {
                        landscapeMockupLayout(screenSize: screenSize)
                    } else {
                        portraitCompactLayout(screenSize: screenSize)
                    }
                }
            }
            .fullScreenCover(item: $navState.activeDestination) { destination in
                if destination == .preparations {
                    PreparationsView(
                        onBackToHome: {
                            navState.resetToHome()
                        },
                        onOpenGames: {
                            navState.navigate(to: .games)
                        }
                    )
                } else if destination == .about {
                    AboutView(
                        onBackToHome: {
                            navState.resetToHome()
                        },
                        onSettingsTapped: {
                            navState.navigate(to: .settings)
                        }
                    )
                } else {
                    DestinationDetailSheet(destination: destination)
                }
            }
        }
    }
    
    // MARK: - Background Layer
    @ViewBuilder
    private func backgroundLayer(screenSize: CGSize) -> some View {
        ZStack {
            // Base Canva background image
            Image("Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: screenSize.width, height: screenSize.height)
                .clipped()
            
            // Subtle hospital architecture gradient overlay matching Simon Family Tower photo depth
            if showHospitalOverlay {
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppTheme.primaryPurple.opacity(0.3),
                        AppTheme.darkPurple.opacity(0.65),
                        AppTheme.primaryPurple.opacity(0.85)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Subtle hospital building silhouette / lighting accent
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.08),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 50,
                    endRadius: max(screenSize.width, screenSize.height) * 0.7
                )
            }
        }
    }
    
    // MARK: - Landscape & Tablet Layout (Matches Mockup)
    @ViewBuilder
    // MARK: - Landscape & Tablet Layout (Matches Mockup)
    @ViewBuilder
    private func landscapeMockupLayout(screenSize: CGSize) -> some View {
        let isLandscape = screenSize.width > screenSize.height
        
        // Responsive Metrics Calculations
        let headerApproxHeight: CGFloat = isLandscape ? min(max(screenSize.height * 0.15, 64), 135) : min(max(screenSize.height * 0.11, 56), 95)
        let availableHeight = max(screenSize.height - headerApproxHeight, 200)
        
        // Horizontal padding: 3.5% - 5.5% of width
        let hPadding: CGFloat = min(max(screenSize.width * 0.04, 20), 56)
        // Spacing between cards: 2.5% - 3.5% of width
        let cardSpacing: CGFloat = min(max(screenSize.width * 0.03, 18), 46)
        
        // Width calculation for 3 cards across
        let widthForThreeCards = (screenSize.width - (hPadding * 2) - (cardSpacing * 2)) / 3.0
        
        // Height constraint: ensure 2 rows of cards + footer + spacings fit vertically
        let maxCardWidthByHeight = (availableHeight * 0.76) / (2.0 / AppTheme.cardAspectRatio + 0.65 / AppTheme.footerAspectRatio)
        
        // Allow cards to comfortably scale up to 380pt on iPad Pro (previously capped at 300pt)
        let cardWidth: CGFloat = min(widthForThreeCards, maxCardWidthByHeight, 380)
        let footerWidth: CGFloat = min(cardWidth * 0.65, 215)
        
        // Dynamic vertical spacing between Row 1 and Row 2
        let vSpacing: CGFloat = min(max(availableHeight * 0.045, 18), 38)
        
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer(minLength: min(max(availableHeight * 0.04, 10), 36))
                
                // Row 1: Preparations, Glossary, Anatomy Explorer
                HStack(spacing: cardSpacing) {
                    CategoryCardButton(
                        imageName: "ButtonPreparations",
                        title: "Preparations",
                        width: cardWidth,
                        action: { navState.navigate(to: .preparations) }
                    )
                    
                    CategoryCardButton(
                        imageName: "ButtonGlossary",
                        title: "Glossary",
                        width: cardWidth,
                        action: { navState.navigate(to: .glossary) }
                    )
                    
                    CategoryCardButton(
                        imageName: "ButtonAnatomyExplorer",
                        title: "Anatomy Explorer",
                        width: cardWidth,
                        action: { navState.navigate(to: .anatomyExplorer) }
                    )
                }
                .frame(maxWidth: .infinity)
                
                Spacer().frame(height: vSpacing)
                
                // Row 2: Gallery, Games (Centered horizontally)
                HStack(spacing: cardSpacing) {
                    CategoryCardButton(
                        imageName: "ButtonGallery",
                        title: "Gallery",
                        width: cardWidth,
                        action: { navState.navigate(to: .gallery) }
                    )
                    
                    CategoryCardButton(
                        imageName: "ButtonGames",
                        title: "Games",
                        width: cardWidth,
                        action: { navState.navigate(to: .games) }
                    )
                }
                .frame(maxWidth: .infinity)
                
                // Flexible spacer pushing About & Legal buttons right near the bottom of the page
                Spacer(minLength: min(max(availableHeight * 0.08, 24), 140))
                
                // Row 3 (Bottom): About, Legal (Side by side, centered)
                HStack(spacing: cardSpacing * 0.8) {
                    FooterPillButton(
                        imageName: "ButtonAbout",
                        title: "About",
                        width: footerWidth,
                        action: { navState.navigate(to: .about) }
                    )
                    
                    FooterPillButton(
                        imageName: "ButtonLegal",
                        title: "Legal",
                        width: footerWidth,
                        action: { navState.navigate(to: .legal) }
                    )
                }
                .frame(maxWidth: .infinity)
                
                Spacer().frame(height: min(max(availableHeight * 0.035, 12), 28))
            }
            .padding(.horizontal, hPadding)
            .frame(minHeight: availableHeight)
        }
    }
    
    // MARK: - Portrait Compact Layout (Mobile Phones)
    @ViewBuilder
    private func portraitCompactLayout(screenSize: CGSize) -> some View {
        let headerApproxHeight: CGFloat = min(max(screenSize.height * 0.11, 56), 95)
        let availableHeight = max(screenSize.height - headerApproxHeight, 200)
        let hPadding: CGFloat = min(max(screenSize.width * 0.05, 16), 28)
        let spacing: CGFloat = min(max(screenSize.width * 0.035, 12), 20)
        
        // 2-column card width
        let cardWidth = (screenSize.width - (hPadding * 2) - spacing) / 2.0
        let singleCardWidth = min(cardWidth * 1.15, screenSize.width - (hPadding * 2))
        let footerWidth = min(cardWidth * 0.85, 140)
        
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer(minLength: 16)
                
                // Row 1: Preparations, Glossary
                HStack(spacing: spacing) {
                    CategoryCardButton(
                        imageName: "ButtonPreparations",
                        title: "Preparations",
                        width: cardWidth,
                        action: { navState.navigate(to: .preparations) }
                    )
                    
                    CategoryCardButton(
                        imageName: "ButtonGlossary",
                        title: "Glossary",
                        width: cardWidth,
                        action: { navState.navigate(to: .glossary) }
                    )
                }
                
                Spacer().frame(height: spacing * 1.2)
                
                // Row 2: Anatomy Explorer, Gallery
                HStack(spacing: spacing) {
                    CategoryCardButton(
                        imageName: "ButtonAnatomyExplorer",
                        title: "Anatomy Explorer",
                        width: cardWidth,
                        action: { navState.navigate(to: .anatomyExplorer) }
                    )
                    
                    CategoryCardButton(
                        imageName: "ButtonGallery",
                        title: "Gallery",
                        width: cardWidth,
                        action: { navState.navigate(to: .gallery) }
                    )
                }
                
                Spacer().frame(height: spacing * 1.2)
                
                // Row 3: Games (Centered)
                CategoryCardButton(
                    imageName: "ButtonGames",
                    title: "Games",
                    width: singleCardWidth,
                    action: { navState.navigate(to: .games) }
                )
                
                // Flexible spacer pushing About & Legal near bottom on mobile
                Spacer(minLength: 24)
                
                // Row 4: About, Legal
                HStack(spacing: spacing) {
                    FooterPillButton(
                        imageName: "ButtonAbout",
                        title: "About",
                        width: footerWidth,
                        action: { navState.navigate(to: .about) }
                    )
                    
                    FooterPillButton(
                        imageName: "ButtonLegal",
                        title: "Legal",
                        width: footerWidth,
                        action: { navState.navigate(to: .legal) }
                    )
                }
                
                Spacer().frame(height: 16)
            }
            .padding(.horizontal, hPadding)
            .frame(minHeight: availableHeight)
        }
    }
}
