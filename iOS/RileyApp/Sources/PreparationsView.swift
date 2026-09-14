import SwiftUI

// MARK: - Procedure Item Model
public struct ProcedureItem: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let imageName: String
    public let description: String
    
    public init(id: String, title: String, subtitle: String? = nil, imageName: String, description: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.description = description
    }
}

// MARK: - Preparations View
public struct PreparationsView: View {
    @Environment(\.presentationMode) var presentationMode
    public var onBackToHome: (() -> Void)?
    public var onOpenGames: (() -> Void)?
    
    @State private var searchText: String = ""
    @State private var selectedTab: RibbonTab = .procedures
    @State private var currentScrollIndex: Int = 0
    @State private var selectedProcedure: ProcedureItem? = nil
    @State private var isShowingIVGame: Bool = false
    
    public enum RibbonTab {
        case procedures
        case education
    }
    
    // Procedure items corresponding to the asset cards
    private let allProcedures: [ProcedureItem] = [
        ProcedureItem(
            id: "ng-tube",
            title: "Nasogastric Tube",
            subtitle: "( NG Tube )",
            imageName: "ButtonNGTube",
            description: "An NG tube is a thin, flexible, soft tube that gently passes through the nose into the stomach. It helps give nutrition, medicine, or fluids to help your body feel better and stay strong."
        ),
        ProcedureItem(
            id: "port-access",
            title: "Port Access",
            subtitle: nil,
            imageName: "ButtonPortAccess",
            description: "A port is a tiny, special medical disc placed safely under the skin. Accessing the port with a gentle, quick touch lets doctors and nurses give medicines and take blood samples easily without multiple pokes."
        ),
        ProcedureItem(
            id: "burn-dressing",
            title: "Burn Dressing Change",
            subtitle: nil,
            imageName: "ButtonBurnDress",
            description: "Carefully cleaning and changing protective bandages helps delicate skin heal quickly, stay clean, and feel comfortable."
        ),
        ProcedureItem(
            id: "iv-start",
            title: "Intravenous Start",
            subtitle: "( IV Start )",
            imageName: "ButtonIVStart",
            description: "An IV is a very small, flexible plastic straw placed into a vein to give your body healing fluids and medicines while you relax."
        )
    ]
    
    private var filteredProcedures: [ProcedureItem] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return allProcedures
        } else {
            return allProcedures.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.subtitle?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    public init(onBackToHome: (() -> Void)? = nil, onOpenGames: (() -> Void)? = nil) {
        self.onBackToHome = onBackToHome
        self.onOpenGames = onOpenGames
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            let isLandscape = screenSize.width > screenSize.height
            
            // Scaled sizing metrics
            let headerHeight: CGFloat = isLandscape ? min(max(screenSize.height * 0.14, 60), 125) : min(max(screenSize.height * 0.10, 54), 88)
            let iconButtonSize: CGFloat = min(max(headerHeight * 0.62, 34), 60)
            let cardWidth: CGFloat = min(max(screenSize.width * 0.72, 280), 840)
            let bottomBarHeight: CGFloat = min(max(screenSize.height * 0.09, 48), 85)
            
            ZStack(alignment: .bottom) {
                // Background Layer
                AppTheme.primaryPurple
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Top Header with Back, Banner, Settings, Home
                    topHeaderBar(
                        width: screenSize.width,
                        height: headerHeight,
                        iconSize: iconButtonSize
                    )
                    
                    // MARK: - Search Bar
                    searchBarView(availableWidth: screenSize.width)
                        .padding(.vertical, isLandscape ? 10 : 8)
                    
                    // MARK: - Procedures / Education Ribbon
                    ribbonBarView(availableWidth: screenSize.width)
                    
                    // MARK: - Scrollable Procedure Cards with Arrows
                    ZStack(alignment: .trailing) {
                        scrollableCardsList(cardWidth: cardWidth, availableHeight: screenSize.height)
                        
                        // Purple Fade overlay at bottom of procedure cards (overlayed over buttons, under arrows)
                        purpleFadeOverlay(height: min(max(screenSize.height * 0.28, 140), 220))
                        
                        // Floating Arrow Buttons on the Right Side (overlayed ON TOP of purple fade)
                        arrowButtonsOverlay(screenHeight: screenSize.height)
                            .padding(.trailing, min(max(screenSize.width * 0.05, 12), 48))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Bottom clearance space for bottomBar
                    Spacer(minLength: bottomBarHeight)
                }
                
                // MARK: - Bottom Navigation Bar (5 Tabs) - Permanently anchored to bottom of screen
                bottomBarView(availableWidth: screenSize.width, height: bottomBarHeight)
            }
            .sheet(item: $selectedProcedure) { item in
                procedureDetailSheet(for: item)
            }
            .fullScreenCover(isPresented: $isShowingIVGame) {
                IVGameView(onDismiss: {
                    isShowingIVGame = false
                })
            }
        }
    }
    
    // MARK: - Top Header Bar
    @ViewBuilder
    private func topHeaderBar(width: CGFloat, height: CGFloat, iconSize: CGFloat) -> some View {
        ZStack {
            // Header Banner Background
            Image("HeaderBanner")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .clipped()
            
            // Header Action Buttons
            HStack {
                // Back Button (Left)
                HeaderIconButton(
                    imageName: "IconBack",
                    title: "Back to Home",
                    size: iconSize,
                    action: {
                        HapticManager.shared.lightTap()
                        if let onBackToHome = onBackToHome {
                            onBackToHome()
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
                .padding(.leading, min(max(width * 0.03, 12), 36))
                
                Spacer()
                
                // Settings & Home Buttons (Right)
                HStack(spacing: min(max(width * 0.015, 8), 18)) {
                    HeaderIconButton(
                        imageName: "IconSettings",
                        title: "Settings",
                        size: iconSize,
                        action: {
                            HapticManager.shared.buttonTap()
                        }
                    )
                    
                    HeaderIconButton(
                        imageName: "IconHome",
                        title: "Home",
                        size: iconSize,
                        action: {
                            HapticManager.shared.lightTap()
                            if let onBackToHome = onBackToHome {
                                onBackToHome()
                            } else {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    )
                }
                .padding(.trailing, min(max(width * 0.03, 12), 36))
            }
        }
        .frame(width: width, height: height)
        .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Search Bar View
    @ViewBuilder
    private func searchBarView(availableWidth: CGFloat) -> some View {
        let barWidth = min(max(availableWidth * 0.45, 280), 540)
        
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.gray)
                .font(.system(size: 15, weight: .medium))
            
            TextField("Search", text: $searchText)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.black)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.gray)
                        .font(.system(size: 14))
                }
            }
            
            Image(systemName: "mic.fill")
                .foregroundColor(Color.gray)
                .font(.system(size: 15, weight: .medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(width: barWidth, height: 38)
        .background(Color.white.opacity(0.92))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 1)
    }
    
    // MARK: - Procedures / Education Ribbon
    @ViewBuilder
    private func ribbonBarView(availableWidth: CGFloat) -> some View {
        let ribbonImageName = (selectedTab == .procedures) ? "RibbonProceduresSelected" : "RibbonEducationSelected"
        
        ZStack {
            Image(ribbonImageName)
                .resizable()
                .aspectRatio(AppTheme.ribbonAspectRatio, contentMode: .fit)
                .frame(width: availableWidth)
            
            // Invisible tap hit areas for the two tabs
            HStack(spacing: 0) {
                Button(action: {
                    selectedTab = .procedures
                    HapticManager.shared.lightTap()
                }) {
                    Color.clear
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Procedures Tab")
                
                Button(action: {
                    selectedTab = .education
                    HapticManager.shared.lightTap()
                }) {
                    Color.clear
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Education Tab")
            }
        }
        .frame(width: availableWidth)
    }
    
    // MARK: - Scrollable Cards List
    @ViewBuilder
    private func scrollableCardsList(cardWidth: CGFloat, availableHeight: CGFloat) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    Spacer(minLength: 16)
                    
                    ForEach(Array(filteredProcedures.enumerated()), id: \.element.id) { index, item in
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            if item.id == "iv-start" {
                                isShowingIVGame = true
                            } else {
                                selectedProcedure = item
                            }
                        }) {
                            Image(item.imageName)
                                .resizable()
                                .aspectRatio(AppTheme.procedureCardAspectRatio, contentMode: .fit)
                                .frame(width: cardWidth)
                        }
                        .buttonStyle(BouncyButtonStyle(scaleAmount: 0.96))
                        .id(item.id)
                        .accessibilityLabel("\(item.title) procedure information")
                    }
                    
                    Spacer(minLength: 40)
                }
                .frame(maxWidth: .infinity)
            }
            .onChange(of: currentScrollIndex) { newIndex in
                if newIndex >= 0 && newIndex < filteredProcedures.count {
                    withAnimation(.easeInOut(duration: 0.38)) {
                        proxy.scrollTo(filteredProcedures[newIndex].id, anchor: .center)
                    }
                }
            }
        }
    }
    
    // MARK: - Purple Fade Overlay along Bottom of Screen (Overlayed on buttons, under arrows)
    @ViewBuilder
    private func purpleFadeOverlay(height: CGFloat) -> some View {
        VStack {
            Spacer()
            LinearGradient(
                colors: [
                    Color.clear,
                    AppTheme.primaryPurple.opacity(0.18),
                    AppTheme.primaryPurple.opacity(0.55),
                    AppTheme.primaryPurple.opacity(0.88),
                    AppTheme.primaryPurple
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height)
            .allowsHitTesting(false)
        }
    }
    
    // MARK: - Floating Arrow Buttons Overlay
    @ViewBuilder
    private func arrowButtonsOverlay(screenHeight: CGFloat) -> some View {
        let maxIndex = max(filteredProcedures.count - 1, 0)
        let showUpArrow = currentScrollIndex > 0
        let showDownArrow = currentScrollIndex < maxIndex
        let arrowMargin: CGFloat = 24
        
        VStack {
            // Up Arrow Button (Visible when scrolled down)
            if showUpArrow {
                Button(action: {
                    if currentScrollIndex > 0 {
                        currentScrollIndex -= 1
                        HapticManager.shared.buttonTap()
                    }
                }) {
                    Image("IconArrowUp")
                        .resizable()
                        .aspectRatio(AppTheme.arrowAspectRatio, contentMode: .fit)
                        .frame(width: 46, height: 60)
                        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(BouncyButtonStyle(scaleAmount: 0.88))
                .accessibilityLabel("Scroll Up to previous procedure")
                .transition(.opacity.combined(with: .scale))
            } else {
                Color.clear
                    .frame(width: 46, height: 60)
            }
            
            Spacer()
            
            // Down Arrow Button (Visible when there is more content below)
            if showDownArrow {
                Button(action: {
                    if currentScrollIndex < maxIndex {
                        currentScrollIndex += 1
                        HapticManager.shared.buttonTap()
                    }
                }) {
                    Image("IconArrowDown")
                        .resizable()
                        .aspectRatio(AppTheme.arrowAspectRatio, contentMode: .fit)
                        .frame(width: 46, height: 60)
                        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(BouncyButtonStyle(scaleAmount: 0.88))
                .accessibilityLabel("Scroll Down to next procedure")
                .transition(.opacity.combined(with: .scale))
            } else {
                Color.clear
                    .frame(width: 46, height: 60)
            }
        }
        .padding(.vertical, arrowMargin)
        .frame(maxHeight: .infinity)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentScrollIndex)
    }
    
    // MARK: - Bottom Navigation Bar (5 Tabs)
    @ViewBuilder
    private func bottomBarView(availableWidth: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Image("BottomBarPreparations")
                .resizable()
                .aspectRatio(AppTheme.bottomBarAspectRatio, contentMode: .fit)
                .frame(width: availableWidth)
            
            // Tap zones for bottom bar tabs
            HStack(spacing: 0) {
                // Preparations Tab (Current)
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Preparations tab, currently active")
                
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
                
                // Games Tab
                Button(action: {
                    HapticManager.shared.buttonTap()
                    if let onOpenGames = onOpenGames {
                        onOpenGames()
                    }
                }) {
                    Color.clear
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Games tab")
            }
        }
        .frame(width: availableWidth, height: height)
    }
    
    // MARK: - Procedure Detail Sheet
    @ViewBuilder
    private func procedureDetailSheet(for item: ProcedureItem) -> some View {
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
                            
                            if let subtitle = item.subtitle {
                                Text(subtitle)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            Text("What to Expect")
                                .font(.title3.bold())
                                .foregroundColor(AppTheme.darkPurple)
                            
                            Text(item.description)
                                .font(.body)
                                .lineSpacing(6)
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Your Child Life specialist is here to support you.", systemImage: "heart.fill")
                                    .foregroundColor(AppTheme.primaryPurple)
                                Label("Ask as many questions as you like!", systemImage: "sparkles")
                                    .foregroundColor(AppTheme.cardTeal)
                            }
                            .font(.subheadline)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal, 28)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitle(Text(item.title), displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                selectedProcedure = nil
            })
        }
    }
}

// MARK: - Xcode Previews
struct PreparationsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iPad Landscape (Matches Screenshot)
            PreparationsView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro - Landscape")
                .previewInterfaceOrientation(.landscapeLeft)
            
            // iPad Portrait
            PreparationsView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro - Portrait")
                .previewInterfaceOrientation(.portrait)
            
            // iPhone 16 Pro
            PreparationsView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 16 Pro"))
                .previewDisplayName("iPhone 16 Pro")
                .previewInterfaceOrientation(.portrait)
        }
    }
}
