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
                                HStack(alignment: .center, spacing: isIPad ? 52 : 36) {
                                    plateImageView
                                        .frame(maxWidth: proxy.size.width * (isIPad ? 0.44 : 0.42))
                                    
                                    infoTextView(isIPad: isIPad)
                                        .frame(maxWidth: proxy.size.width * (isIPad ? 0.52 : 0.50))
                                }
                                .padding(.horizontal, isIPad ? 56 : 40)
                                .padding(.vertical, isIPad ? 36 : 24)
                            } else {
                                VStack(alignment: .center, spacing: isIPad ? 28 : 20) {
                                    plateImageView
                                        .frame(maxWidth: isIPad ? min(proxy.size.width * 0.55, 460) : 320)
                                    
                                    infoTextView(isIPad: isIPad)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: isIPad ? min(proxy.size.width * 0.85, 680) : .infinity)
                                }
                                .padding(.horizontal, isIPad ? 40 : 24)
                                .padding(.vertical, isIPad ? 28 : 20)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        
                        // Lower Section: Sky Blue Background (#bddaeb) with Partner Cards
                        VStack(spacing: 0) {
                            if isLandscape {
                                HStack(spacing: isIPad ? 56 : 28) {
                                    childsPlayCard
                                    dunkinJoyCard
                                }
                                .padding(.horizontal, isIPad ? 60 : 40)
                                .padding(.vertical, isIPad ? 36 : 24)
                                .frame(maxWidth: isIPad ? 1200 : 960)
                            } else {
                                if isIPad {
                                    HStack(spacing: 40) {
                                        childsPlayCard
                                        dunkinJoyCard
                                    }
                                    .padding(.horizontal, 48)
                                    .padding(.vertical, 32)
                                    .frame(maxWidth: 960)
                                } else {
                                    VStack(spacing: 20) {
                                        childsPlayCard
                                        dunkinJoyCard
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 24)
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
        VStack(alignment: .leading, spacing: isIPad ? 16 : 12) {
            Text("About Riley")
                .font(.custom("Roboto-Regular", size: isIPad ? 36 : 28.6))
                .foregroundColor(Color(hex: "325b72"))
            
            Text("Riley Children’s Health is Indiana’s largest pediatric healthcare system, with over 50 locations across the state. Our expert doctors, caring nurses, and scientists work together to deliver world-class care and innovative research—helping every child heal, feel supported, and thrive.")
                .font(.custom("Arial", size: isIPad ? 19 : 15.4))
                .foregroundColor(Color(hex: "4a5568"))
                .lineSpacing(isIPad ? 6 : 4)
                .padding(.bottom, isIPad ? 26 : 14)
            
            HStack {
                Spacer()
                Link(destination: URL(string: "https://www.rileychildrens.org")!) {
                    Text("Visit Our Website")
                        .font(.custom("Arial", size: isIPad ? 17.5 : 15.4))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, isIPad ? 32 : 24)
                        .padding(.vertical, isIPad ? 14 : 10)
                        .background(Color(hex: "7a1526"))
                        .cornerRadius(9)
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                }
                Spacer()
            }
        }
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
                    Link("Visit childsplaycharity.org", destination: URL(string: "https://childsplaycharity.org")!)
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
