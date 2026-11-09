import SwiftUI

public struct AboutView: View {
    public var onBackToHome: () -> Void
    public var onSettingsTapped: () -> Void
    
    @State private var activePartnerSheet: String? = nil
    
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
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 0) {
                        // Upper Section: White Background
                        VStack(spacing: 0) {
                            if isLandscape {
                                HStack(alignment: .center, spacing: isIPad ? 44 : 32) {
                                    plateImageView
                                        .frame(maxWidth: proxy.size.width * (isIPad ? 0.42 : 0.40))
                                    
                                    infoTextView(isIPad: isIPad)
                                        .frame(maxWidth: proxy.size.width * (isIPad ? 0.54 : 0.52))
                                }
                                .padding(.horizontal, isIPad ? 40 : 24)
                                .padding(.vertical, isIPad ? 24 : 18)
                            } else {
                                VStack(alignment: .center, spacing: isIPad ? 24 : 18) {
                                    plateImageView
                                        .frame(maxWidth: isIPad ? min(proxy.size.width * 0.50, 400) : 280)
                                    
                                    infoTextView(isIPad: isIPad)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: isIPad ? min(proxy.size.width * 0.85, 620) : .infinity)
                                }
                                .padding(.horizontal, isIPad ? 36 : 20)
                                .padding(.vertical, isIPad ? 24 : 18)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        
                        // Lower Section: Sky Blue Background (#bddaeb) with Partner Cards
                        VStack(spacing: 0) {
                            if isLandscape {
                                HStack(spacing: isIPad ? 44 : 24) {
                                    childsPlayCard
                                    dunkinJoyCard
                                }
                                .padding(.horizontal, isIPad ? 40 : 24)
                                .padding(.vertical, isIPad ? 24 : 18)
                                .frame(maxWidth: isIPad ? 900 : 680)
                            } else {
                                if isIPad {
                                    HStack(spacing: 32) {
                                        childsPlayCard
                                        dunkinJoyCard
                                    }
                                    .padding(.horizontal, 36)
                                    .padding(.vertical, 24)
                                    .frame(maxWidth: 760)
                                } else {
                                    VStack(spacing: 16) {
                                        childsPlayCard
                                        dunkinJoyCard
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 20)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "bddaeb"))
                    }
                }
            }
            .background(Color.white)
            .ignoresSafeArea(.all)
        }
        .sheet(item: Binding<PartnerModalItem?>(
            get: { activePartnerSheet.map { PartnerModalItem(name: $0) } },
            set: { activePartnerSheet = $0?.name }
        )) { item in
            partnerDetailSheet(partner: item.name)
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
        VStack(alignment: .leading, spacing: isIPad ? 14 : 12) {
            Text("About Riley")
                .font(.custom("Roboto-Regular", size: isIPad ? 34 : 26))
                .foregroundColor(Color(hex: "325b72"))
            
            Text("Riley Children’s Health is Indiana’s largest pediatric healthcare system, with over 50 locations across the state. Our expert doctors, caring nurses, and scientists work together to deliver world-class care and innovative research—helping every child heal, feel supported, and thrive.")
                .font(.custom("Arial", size: isIPad ? 18 : 14.5))
                .foregroundColor(Color(hex: "4a5568"))
                .lineSpacing(isIPad ? 5 : 4)
                .padding(.bottom, isIPad ? 26 : 14)
            
            HStack {
                Spacer()
                Link(destination: URL(string: "https://www.rileychildrens.org")!) {
                    Text("Visit Our Website")
                        .font(.custom("Roboto-Regular", size: isIPad ? 17 : 15))
                        .foregroundColor(.white)
                        .tracking(0.5)
                        .shadow(color: Color.black.opacity(0.35), radius: 1, x: 0, y: 1)
                        .padding(.horizontal, isIPad ? 32 : 26)
                        .padding(.vertical, isIPad ? 13 : 11)
                        .background(pillButtonBackground)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
        }
    }
    
    private var pillButtonBackground: some View {
        Capsule()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "921a30"),
                        Color(hex: "7a1526"),
                        Color(hex: "620c1c")
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
            .shadow(color: Color(hex: "620c1c").opacity(0.36), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
    }
    
    private var childsPlayCard: some View {
        Button(action: { activePartnerSheet = "childs-play" }) {
            Group {
                if let uiImg = UIImage(named: "AboutChildsPlay") {
                    Image(uiImage: uiImg)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.green)
                        .overlay(Text("Child's Play").foregroundColor(.white).bold())
                }
            }
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(AboutScaleButtonStyle())
    }
    
    private var dunkinJoyCard: some View {
        Button(action: { activePartnerSheet = "dunkin-joy" }) {
            Group {
                if let uiImg = UIImage(named: "AboutDunkinJoy") {
                    Image(uiImage: uiImg)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.purple)
                        .overlay(Text("Dunkin' Joy").foregroundColor(.white).bold())
                }
            }
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(AboutScaleButtonStyle())
    }
    
    @ViewBuilder
    private func partnerDetailSheet(partner: String) -> some View {
        NavigationView {
            VStack(spacing: 20) {
                if partner == "childs-play" {
                    Text("Child's Play Charity")
                        .font(.title2.bold())
                    Text("Child's Play is a gaming industry charity dedicated to improving the lives of children in pediatric hospitals worldwide through the power of play.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Link("Visit childsplaycharity.org", destination: URL(string: "https://www.childsplaycharity.org/")!)
                        .font(.headline)
                        .foregroundColor(AppTheme.primaryPurple)
                } else {
                    Text("Dunkin' Joy in Childhood Foundation")
                        .font(.title2.bold())
                    Text("The Dunkin' Joy in Childhood Foundation provides joy to kids battling illness through grants that fund joyful experiences, arts, gaming, and animal-assisted therapy.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Link("Visit joyinchildhoodfoundation.org", destination: URL(string: "https://www.joyinchildhoodfoundation.org")!)
                        .font(.headline)
                        .foregroundColor(AppTheme.primaryPurple)
                }
                Spacer()
            }
            .padding(.top, 40)
            .navigationBarItems(trailing: Button("Done") {
                activePartnerSheet = nil
            })
        }
    }
}

private struct PartnerModalItem: Identifiable {
    let name: String
    var id: String { name }
}

public struct AboutScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
