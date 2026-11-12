import SwiftUI

public struct AboutView: View {
    public var onBackToHome: () -> Void
    public var onSettingsTapped: () -> Void
    
    public init(onBackToHome: @escaping () -> Void, onSettingsTapped: @escaping () -> Void) {
        self.onBackToHome = onBackToHome
        self.onSettingsTapped = onSettingsTapped
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height
            let isIPad = UIDevice.current.userInterfaceIdiom == .pad || min(proxy.size.width, proxy.size.height) >= 600
            
            VStack(spacing: 0) {
                // Top Header Bar matching Home screen
                HomeHeaderView(
                    availableWidth: proxy.size.width,
                    availableHeight: proxy.size.height,
                    safeAreaTop: proxy.safeAreaInsets.top,
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
                        onSettingsTapped()
                    }
                )
                .zIndex(2)
                
                // Content Body
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Upper Section: White Background
                        VStack(spacing: 0) {
                            if isLandscape {
                                HStack(alignment: .center, spacing: isIPad ? 48 : 32) {
                                    plateImageView
                                        .frame(maxWidth: proxy.size.width * (isIPad ? 0.44 : 0.40))
                                    
                                    infoTextView(isIPad: isIPad)
                                        .frame(maxWidth: proxy.size.width * (isIPad ? 0.54 : 0.52))
                                }
                                .padding(.horizontal, isIPad ? 40 : 24)
                                .padding(.vertical, isIPad ? 28 : 18)
                                .frame(maxWidth: isIPad ? 1060 : 760)
                            } else {
                                VStack(alignment: .center, spacing: isIPad ? 22 : 16) {
                                    plateImageView
                                        .frame(maxWidth: isIPad ? min(proxy.size.width * 0.52, 420) : 260)
                                    
                                    infoTextView(isIPad: isIPad)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: isIPad ? min(proxy.size.width * 0.88, 660) : .infinity)
                                }
                                .padding(.horizontal, isIPad ? 32 : 20)
                                .padding(.vertical, isIPad ? 24 : 16)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        
                        // Lower Section: Gradient Background with Sponsor Card
                        VStack(spacing: isIPad ? 18 : 14) {
                            Text("Thank You to Our Sponsor")
                                .font(.custom("Roboto-Medium", size: isIPad ? 32 : 22))
                                .foregroundColor(Color(hex: "325b72"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            childsPlayCard
                                .frame(maxWidth: isIPad ? (isLandscape ? 920 : min(proxy.size.width * 0.90, 780)) : .infinity)
                        }
                        .padding(.horizontal, isIPad ? 36 : 20)
                        .padding(.top, isIPad ? 32 : 24)
                        .padding(.bottom, isIPad ? 52 : 40)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "ecebee"), Color(hex: "bdd9ea")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                }
            }
            .background(Color.white)
            .ignoresSafeArea(.all)
        }
    }
    
    // MARK: - Subviews
    private var plateImageView: some View {
        Group {
            if let uiImg = UIImage(named: "AboutRileyWagon") {
                Image(uiImage: uiImg)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image("ButtonAbout")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
    }
    
    private func infoTextView(isIPad: Bool) -> some View {
        VStack(alignment: isIPad ? .leading : .center, spacing: isIPad ? 14 : 10) {
            Text("About Riley")
                .font(.custom("Roboto-Medium", size: isIPad ? 36 : 24))
                .foregroundColor(Color(hex: "325b72"))
            
            Text("Riley Children’s Health is Indiana’s largest pediatric healthcare system, with over 50 locations across the state. Our expert doctors, caring nurses, and scientists work together to deliver world-class care and innovative research—helping every child heal, feel supported, and thrive.")
                .font(.custom("Arial", size: isIPad ? 19 : 14.5))
                .foregroundColor(Color(hex: "475569"))
                .lineSpacing(isIPad ? 6 : 4)
                .padding(.bottom, isIPad ? 22 : 14)
            
            Link(destination: URL(string: "https://www.rileychildrens.org")!) {
                Text("Visit Our Website")
                    .font(.custom("Roboto-Medium", size: isIPad ? 17 : 15))
                    .foregroundColor(.white)
                    .tracking(0.4)
                    .shadow(color: Color.black.opacity(0.35), radius: 1, x: 0, y: 1)
                    .padding(.horizontal, isIPad ? 36 : 26)
                    .padding(.vertical, isIPad ? 13 : 11)
                    .background(pillButtonBackground)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var pillButtonBackground: some View {
        Capsule()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "941262"),
                        Color(hex: "7b0350"),
                        Color(hex: "630240")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.55),
                                Color.white.opacity(0.20)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color(hex: "4e0434").opacity(0.40), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
    }
    
    private var childsPlayCard: some View {
        Link(destination: URL(string: "https://www.childsplaycharity.org/")!) {
            Group {
                if let uiImg = UIImage(named: "AboutChildsPlay") {
                    Image(uiImage: uiImg)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.green)
                        .overlay(Text("Child's Play").foregroundColor(.white).bold())
                }
            }
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(AboutScaleButtonStyle())
    }
}

public struct AboutScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
