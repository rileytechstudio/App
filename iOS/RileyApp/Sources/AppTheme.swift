import SwiftUI

// MARK: - App Theme Colors & Styling
public enum AppTheme {
    /// Deep Riley Purple matching Background.jpg (#5931ba)
    public static let primaryPurple = Color(red: 89/255, green: 49/255, blue: 186/255)
    
    /// Darker rich purple for gradients
    public static let darkPurple = Color(red: 65/255, green: 30/255, blue: 140/255)
    
    /// Vibrant purple for highlights
    public static let accentPurple = Color(red: 110/255, green: 60/255, blue: 210/255)
    
    /// Warm orange matching the header banner background
    public static let headerOrange = Color(red: 247/255, green: 177/255, blue: 106/255)
    
    /// Teal accent matching the category cards
    public static let cardTeal = Color(red: 0/255, green: 191/255, blue: 196/255)
    
    /// Card aspect ratio (Width : Height ≈ 1480 : 660 = 2.24)
    public static let cardAspectRatio: CGFloat = 1480.0 / 660.0
    
    /// Footer pill aspect ratio (Width : Height ≈ 1480 : 430 = 3.44)
    public static let footerAspectRatio: CGFloat = 1480.0 / 430.0
    
    /// Header banner aspect ratio (Width : Height = 1366 : 157 ≈ 8.70)
    public static let headerAspectRatio: CGFloat = 1366.0 / 157.0
    
    /// Icon button aspect ratio (Square 1:1)
    public static let iconAspectRatio: CGFloat = 1.0
    
    /// Procedure card aspect ratio (Width : Height ≈ 1310 : 415 = 3.15)
    public static let procedureCardAspectRatio: CGFloat = 1310.0 / 415.0
    
    /// Ribbon bar aspect ratio (Width : Height ≈ 1366 : 93 = 14.69)
    public static let ribbonAspectRatio: CGFloat = 1366.0 / 93.0
    
    /// Bottom bar aspect ratio (Width : Height ≈ 1366 : 92 = 14.85)
    public static let bottomBarAspectRatio: CGFloat = 1366.0 / 92.0
    
    /// Arrow button aspect ratio (Width : Height = 80 : 106 ≈ 0.75)
    public static let arrowAspectRatio: CGFloat = 80.0 / 106.0
}

// MARK: - Haptic Feedback Manager
public final class HapticManager {
    public static let shared = HapticManager()
    
    private init() {}
    
    public func buttonTap() {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred()
        #endif
    }
    
    public func lightTap() {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.prepare()
        impact.impactOccurred()
        #endif
    }
    
    public func successNotification() {
        #if os(iOS)
        let notification = UINotificationFeedbackGenerator()
        notification.prepare()
        notification.notificationOccurred(.success)
        #endif
    }
}
