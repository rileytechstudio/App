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
            
            VStack(spacing: 0) {
                // Top Header
                HStack(spacing: 12) {
                    Button(action: onBackToHome) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "1e293b"))
                            .frame(width: 42, height: 42)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "e2e8f0"), lineWidth: 1.5)
                            )
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Title")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "1e293b"))
                        Text("Subtitle")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "718096"))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: onSettingsTapped) {
                            if let uiImg = UIImage(named: "AboutSettingsButton") ?? UIImage(named: "IconSettings") {
                                Image(uiImage: uiImg)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 42, height: 42)
                            } else {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 42, height: 42)
                                    .background(AppTheme.primaryPurple)
                                    .clipShape(Circle())
                            }
                        }
                        
                        Button(action: onBackToHome) {
                            if let uiImg = UIImage(named: "AboutHomeButton") ?? UIImage(named: "IconHome") {
                                Image(uiImage: uiImg)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 42, height: 42)
                            } else {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 42, height: 42)
                                    .background(AppTheme.primaryPurple)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: isLandscape ? 58 : 54)
                .background(
                    ZStack {
                        Color.white.opacity(0.82)
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.08),
                                Color.black.opacity(0.02)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                )
                .overlay(
                    VStack {
                        Spacer()
                        Divider()
                            .background(Color.white.opacity(0.65))
                    }
                )
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                .zIndex(2)
                
                // Content Body
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 0) {
                        // Upper Section: White Background
                        VStack(spacing: 0) {
                            if isLandscape {
                                HStack(alignment: .center, spacing: 36) {
                                    plateImageView
                                        .frame(maxWidth: proxy.size.width * 0.42)
                                    
                                    infoTextView
                                        .frame(maxWidth: proxy.size.width * 0.50)
                                }
                                .padding(.horizontal, 40)
                                .padding(.vertical, 24)
                            } else {
                                VStack(alignment: .center, spacing: 20) {
                                    plateImageView
                                        .frame(maxWidth: 320)
                                    
                                    infoTextView
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        
                        // Lower Section: Rich Purple Background with Partner Cards
                        VStack(spacing: 0) {
                            if isLandscape {
                                HStack(spacing: 28) {
                                    childsPlayCard
                                    dunkinJoyCard
                                }
                                .padding(.horizontal, 40)
                                .padding(.vertical, 24)
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
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.primaryPurple)
                    }
                }
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.bottom)
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
    
    private var infoTextView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About Riley")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(Color(hex: "2d3748"))
            
            Text("Riley Children’s Health is Indiana’s largest pediatric healthcare system, with over 50 locations across the state. Our expert doctors, caring nurses, and scientists work together to deliver world-class care and innovative research—helping every child heal, feel supported, and thrive.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "4a5568"))
                .lineSpacing(4)
                .padding(.bottom, 8)
            
            Link(destination: URL(string: "https://www.rileychildrens.org")!) {
                Text("Visit Our Website")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .background(Color(hex: "474749"))
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
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
