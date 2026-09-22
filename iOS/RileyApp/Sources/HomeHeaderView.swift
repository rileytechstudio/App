import SwiftUI

// MARK: - Home Header View
public struct HomeHeaderView: View {
    public let availableWidth: CGFloat
    public let availableHeight: CGFloat
    public let onSettingsTapped: () -> Void
    public let onHomeTapped: () -> Void
    
    public init(
        availableWidth: CGFloat,
        availableHeight: CGFloat,
        onSettingsTapped: @escaping () -> Void,
        onHomeTapped: @escaping () -> Void
    ) {
        self.availableWidth = availableWidth
        self.availableHeight = availableHeight
        self.onSettingsTapped = onSettingsTapped
        self.onHomeTapped = onHomeTapped
    }
    
    /// Responsive header height based on screen dimensions and orientation
    private var headerHeight: CGFloat {
        let isLandscape = availableWidth > availableHeight
        if isLandscape {
            // Sleek Apple glass header height
            return min(max(availableHeight * 0.082, 54), 64)
        } else {
            // Compact portrait header
            return min(max(availableHeight * 0.075, 50), 60)
        }
    }
    
    /// Size of the circular Settings & Home buttons
    private var iconButtonSize: CGFloat {
        return min(max(headerHeight * 0.72, 36), 44)
    }
    
    /// Horizontal padding for icons
    private var iconTrailingPadding: CGFloat {
        return 20
    }
    
    /// Spacing between Settings and Home button
    private var iconSpacing: CGFloat {
        return 12
    }
    
    public var body: some View {
        ZStack(alignment: .trailing) {
            // Background fill with translucent glass tint
            Color(red: 248.0 / 255.0, green: 168.0 / 255.0, blue: 98.0 / 255.0)
                .opacity(0.85)
            
            // Header Banner Background Image
            Image("HeaderBanner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: availableWidth, height: headerHeight)
                .opacity(0.94)
                .accessibilityLabel(Text("Riley Hospital for Children Header Banner"))
            
            // Apple Glass Specular Sheen Overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.30),
                    Color.white.opacity(0.06),
                    Color.black.opacity(0.04)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)
            
            // Top-right Action Buttons (Settings & Home)
            HStack(spacing: iconSpacing) {
                HeaderIconButton(
                    imageName: "IconSettings",
                    title: "Settings",
                    size: iconButtonSize,
                    action: onSettingsTapped
                )
                
                HeaderIconButton(
                    imageName: "IconHome",
                    title: "Home",
                    size: iconButtonSize,
                    action: onHomeTapped
                )
            }
            .padding(.trailing, iconTrailingPadding)
        }
        .frame(width: availableWidth, height: headerHeight)
        .overlay(
            VStack {
                Spacer()
                Divider()
                    .background(Color.white.opacity(0.45))
            }
        )
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}
