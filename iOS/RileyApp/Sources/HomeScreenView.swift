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
        ZStack {
            // Full-bleed background photo edge-to-edge across entire physical display (zero white border)
            Image("HomeScreenBG")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .ignoresSafeArea(.all)
            
            GeometryReader { geometry in
                let screenSize = geometry.size
                let isLandscape = screenSize.width > screenSize.height
                let isWideScreen = screenSize.width >= 620 || isLandscape
                let shouldUseMockupGrid = (layoutMode == .forceMockupLayout) || isWideScreen
                
                // Main Content Structure
                VStack(spacing: 0) {
                    // Top Responsive Header respecting iOS status bar
                    HomeHeaderView(
                        availableWidth: screenSize.width,
                        availableHeight: screenSize.height,
                        safeAreaTop: geometry.safeAreaInsets.top,
                        showBackButton: false,
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
        }
        .ignoresSafeArea(.all)
        .fullScreenCover(item: $navState.activeDestination) { destination in
            if destination == .preparations {
                PreparationsView(
                    onBackToHome: {
                        navState.resetToHome()
                    },
                    onOpenGames: {
                        navState.navigate(to: .games)
                    },
                    onOpenAnatomy: {
                        navState.navigate(to: .anatomyExplorer)
                    },
                    onOpenGallery: {
                        navState.navigate(to: .gallery)
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
            } else if destination == .settings {
                SettingsView(
                    onBack: {
                        navState.resetToHome()
                    },
                    onHomeTapped: {
                        navState.resetToHome()
                    }
                )
            } else if destination == .anatomyExplorer {
                AnatomyExplorerView(
                    onBackToHome: {
                        navState.resetToHome()
                    },
                    onSettingsTapped: {
                        navState.navigate(to: .settings)
                    }
                )
            } else if destination == .games {
                GamesView(
                    onBackToHome: {
                        navState.resetToHome()
                    },
                    onSettingsTapped: {
                        navState.navigate(to: .settings)
                    },
                    onOpenPreparations: {
                        navState.navigate(to: .preparations)
                    },
                    onOpenAnatomy: {
                        navState.navigate(to: .anatomyExplorer)
                    },
                    onOpenGallery: {
                        navState.navigate(to: .gallery)
                    }
                )
            } else {
                DestinationDetailSheet(destination: destination)
            }
        }
    }
    
    // MARK: - Landscape & Tablet Layout (Matches Mockup)
    @ViewBuilder
    private func landscapeMockupLayout(screenSize: CGSize) -> some View {
        let isLandscape = screenSize.width > screenSize.height
        
        // Responsive Metrics Calculations matching increased header banner
        let headerApproxHeight: CGFloat = isLandscape ? min(max(screenSize.height * 0.17, 96), 148) : min(max(screenSize.height * 0.13, 76), 118)
        let availableHeight = max(screenSize.height - headerApproxHeight, 200)
        
        // Horizontal padding
        let hPadding: CGFloat = min(max(screenSize.width * 0.05, 24), 80)
        let cardSpacing: CGFloat = min(max(screenSize.width * 0.035, 24), 48)
        
        // Width calculation for balanced tablet sizing (target ~320pt - 345pt)
        let widthForTwoCards = (screenSize.width - (hPadding * 2) - cardSpacing) / 2.0
        let maxCardWidthByHeight = (availableHeight * 0.62) / (2.0 / AppTheme.cardAspectRatio + 0.58 / AppTheme.footerAspectRatio)
        
        // Balanced tablet button sizing: decreased by 5% (was 345 : 325)
        let maxAllowedWidth: CGFloat = (isLandscape ? 345 : 325) * 0.95
        let cardWidth: CGFloat = min(widthForTwoCards, maxCardWidthByHeight, maxAllowedWidth) * 0.95
        let footerWidth: CGFloat = min(cardWidth * 0.58, 185)
        
        // Dynamic vertical spacing between Row 1 and Row 2
        let vSpacing: CGFloat = min(max(availableHeight * 0.04, 18), 32)
        
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Top flexible spacer allowing main buttons to sit lower and centered on the device
                Spacer(minLength: min(max(availableHeight * 0.08, 20), 100))
                
                // Row 1: Anatomy Explorer, Gallery (Matching Mockup Screenshot)
                HStack(spacing: cardSpacing) {
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
                .frame(maxWidth: .infinity)
                
                Spacer().frame(height: vSpacing)
                
                // Row 2: Games, Preparations (Matching Mockup Screenshot)
                HStack(spacing: cardSpacing) {
                    CategoryCardButton(
                        imageName: "ButtonGames",
                        title: "Games",
                        width: cardWidth,
                        action: { navState.navigate(to: .games) }
                    )
                    
                    CategoryCardButton(
                        imageName: "ButtonPreparations",
                        title: "Preparations",
                        width: cardWidth,
                        action: { navState.navigate(to: .preparations) }
                    )
                }
                .frame(maxWidth: .infinity)
                
                // Bottom flexible spacer to About & Legal buttons
                Spacer(minLength: min(max(availableHeight * 0.06, 18), 70))
                
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
        let headerApproxHeight: CGFloat = min(max(screenSize.height * 0.09, 52), 70)
        let availableHeight = max(screenSize.height - headerApproxHeight, 200)
        let hPadding: CGFloat = min(max(screenSize.width * 0.05, 16), 28)
        let spacing: CGFloat = min(max(screenSize.width * 0.035, 12), 20)
        
        // 2-column card width decreased by 5% (was up to 160pt)
        let cardWidth = min((screenSize.width - (hPadding * 2) - spacing) / 2.0, 152) * 0.95
        let footerWidth = min(cardWidth * 0.82, 120)
        
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Top flexible spacer allowing main buttons to sit lower and centered on mobile
                Spacer(minLength: min(max(availableHeight * 0.07, 20), 60))
                
                // Row 1: Anatomy Explorer, Gallery (Matching Mockup Screenshot)
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
                
                // Row 2: Games, Preparations (Matching Mockup Screenshot)
                HStack(spacing: spacing) {
                    CategoryCardButton(
                        imageName: "ButtonGames",
                        title: "Games",
                        width: cardWidth,
                        action: { navState.navigate(to: .games) }
                    )
                    
                    CategoryCardButton(
                        imageName: "ButtonPreparations",
                        title: "Preparations",
                        width: cardWidth,
                        action: { navState.navigate(to: .preparations) }
                    )
                }
                
                // Flexible spacer pushing About & Legal near bottom on mobile
                Spacer(minLength: 24)
                
                // Row 3: About, Legal
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
