import SwiftUI

// MARK: - Home Header View
public struct HomeHeaderView: View {
    public let availableWidth: CGFloat
    public let availableHeight: CGFloat
    public let safeAreaTop: CGFloat
    public let showBackButton: Bool
    public let showHomeButton: Bool
    public let showSettingsButton: Bool
    public let onBackTapped: () -> Void
    public let onHomeTapped: () -> Void
    public let onSettingsTapped: () -> Void
    
    public init(
        availableWidth: CGFloat,
        availableHeight: CGFloat,
        safeAreaTop: CGFloat = 0,
        showBackButton: Bool = true,
        showHomeButton: Bool = false,
        showSettingsButton: Bool = true,
        onBackTapped: @escaping () -> Void = {},
        onHomeTapped: @escaping () -> Void = {},
        onSettingsTapped: @escaping () -> Void
    ) {
        self.availableWidth = availableWidth
        self.availableHeight = availableHeight
        self.safeAreaTop = safeAreaTop
        self.showBackButton = showBackButton
        self.showHomeButton = showHomeButton
        self.showSettingsButton = showSettingsButton
        self.onBackTapped = onBackTapped
        self.onHomeTapped = onHomeTapped
        self.onSettingsTapped = onSettingsTapped
    }
    
    private var isLandscape: Bool {
        availableWidth > availableHeight
    }
    
    /// Responsive header height based on screen dimensions, orientation, and safe area top inset
    private var headerHeight: CGFloat {
        let baseH = isLandscape 
            ? min(max(availableHeight * 0.15, 86), 118)
            : min(max(availableHeight * 0.115, 70), 96)
        return baseH + safeAreaTop
    }
    
    /// Height of the centered banner logo (increased by 20% again)
    private var bannerHeight: CGFloat {
        if isLandscape {
            return min(max(availableHeight * 0.166, 96), 130)
        } else {
            return min(max(availableHeight * 0.127, 78), 106)
        }
    }
    
    /// Size of the circular glass buttons
    private var buttonSize: CGFloat {
        if isLandscape {
            return min(max(bannerHeight * 0.58, 48), 58)
        } else {
            return min(max(bannerHeight * 0.56, 40), 50)
        }
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            // Centered Header Banner
            Image("HeaderBanner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: bannerHeight)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .accessibilityLabel(Text("Riley Children's Health Indiana University Health"))
            
            // Left & Right Action Buttons
            HStack(alignment: .center, spacing: 0) {
                // Left Back Button (curved return arrow matching screenshot)
                if showBackButton {
                    HeaderIconButton(
                        systemIconName: "arrowshape.turn.up.backward.fill",
                        title: "Back",
                        size: buttonSize,
                        action: onBackTapped
                    )
                } else {
                    Spacer().frame(width: buttonSize, height: buttonSize)
                }
                
                Spacer()
                
                // Right Action Buttons
                HStack(spacing: 12) {
                    if showHomeButton {
                        HeaderIconButton(
                            systemIconName: "house.fill",
                            title: "Home",
                            size: buttonSize,
                            action: onHomeTapped
                        )
                    }
                    if showSettingsButton {
                        HeaderIconButton(
                            systemIconName: "gearshape.fill",
                            title: "Settings",
                            size: buttonSize,
                            action: onSettingsTapped
                        )
                    }
                }
            }
        }
        .padding(.horizontal, isLandscape ? 24 : 16)
        .padding(.top, safeAreaTop > 0 ? safeAreaTop + 8 : (isLandscape ? 16 : 12))
        .frame(width: availableWidth, height: headerHeight, alignment: .top)
    }
}
