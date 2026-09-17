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
            // In landscape, proportionally scale up to 135pt on large iPad, min 64pt
            return min(max(availableHeight * 0.15, 64), 135)
        } else {
            // In portrait, keep compact header between 56pt and 90pt
            return min(max(availableHeight * 0.11, 56), 95)
        }
    }
    
    /// Size of the circular Settings & Home buttons
    private var iconButtonSize: CGFloat {
        return min(max(headerHeight * 0.62, 34), 62)
    }
    
    /// Horizontal padding for icons
    private var iconTrailingPadding: CGFloat {
        return min(max(availableWidth * 0.03, 12), 36)
    }
    
    /// Spacing between Settings and Home button
    private var iconSpacing: CGFloat {
        return min(max(availableWidth * 0.015, 8), 18)
    }
    
    public var body: some View {
        ZStack(alignment: .trailing) {
            // Background fill
            Color(red: 248.0 / 255.0, green: 168.0 / 255.0, blue: 98.0 / 255.0)
            
            // Header Banner Background Image
            Image("HeaderBanner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: availableWidth, height: headerHeight)
                .accessibilityLabel(Text("Riley Hospital for Children Header Banner"))
            
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
        .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)
    }
}
