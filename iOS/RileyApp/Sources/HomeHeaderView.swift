import SwiftUI

// MARK: - Home Header View
public struct HomeHeaderView: View {
    public let availableWidth: CGFloat
    public let availableHeight: CGFloat
    public let safeAreaTop: CGFloat
    public let onSettingsTapped: () -> Void
    public let onHomeTapped: () -> Void
    
    public init(
        availableWidth: CGFloat,
        availableHeight: CGFloat,
        safeAreaTop: CGFloat = 0,
        onSettingsTapped: @escaping () -> Void,
        onHomeTapped: @escaping () -> Void = {}
    ) {
        self.availableWidth = availableWidth
        self.availableHeight = availableHeight
        self.safeAreaTop = safeAreaTop
        self.onSettingsTapped = onSettingsTapped
        self.onHomeTapped = onHomeTapped
    }
    
    private var isLandscape: Bool {
        availableWidth > availableHeight
    }
    
    /// Responsive header height based on screen dimensions, orientation, and safe area top inset
    private var headerHeight: CGFloat {
        let baseH = isLandscape 
            ? min(max(availableHeight * 0.17, 96), 148)
            : min(max(availableHeight * 0.13, 76), 118)
        return baseH + safeAreaTop
    }
    
    /// Height of the top-left banner logo
    private var bannerHeight: CGFloat {
        if isLandscape {
            return min(max(availableHeight * 0.155, 88), 136)
        } else {
            return min(max(availableHeight * 0.115, 68), 108)
        }
    }
    
    /// Size of the circular Settings button
    private var settingButtonSize: CGFloat {
        if isLandscape {
            return min(max(bannerHeight * 0.65, 56), 80)
        } else {
            return min(max(bannerHeight * 0.62, 46), 66)
        }
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Top-left Riley Children's Health logo banner
            Image("TopLBannerLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: bannerHeight)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .accessibilityLabel(Text("Riley Children's Health Indiana University Health"))
            
            Spacer(minLength: 16)
            
            // Top-right circular Settings button (Apple glass translucent effect)
            Button(action: onSettingsTapped) {
                Image("TopRSetting")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: settingButtonSize, height: settingButtonSize)
                    .background(Circle().fill(.ultraThinMaterial))
                    .contentShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel(Text("Settings"))
        }
        .padding(.horizontal, isLandscape ? 24 : 16)
        .padding(.top, safeAreaTop > 0 ? safeAreaTop + 8 : (isLandscape ? 16 : 12))
        .frame(width: availableWidth, height: headerHeight, alignment: .top)
    }
}
