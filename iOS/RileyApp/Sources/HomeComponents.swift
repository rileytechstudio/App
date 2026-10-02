import SwiftUI

// MARK: - Bouncy Button Style
public struct BouncyButtonStyle: ButtonStyle {
    public var scaleAmount: CGFloat = 0.94
    
    public init(scaleAmount: CGFloat = 0.94) {
        self.scaleAmount = scaleAmount
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Category Card Button
public struct CategoryCardButton: View {
    public let imageName: String
    public let title: String
    public let width: CGFloat
    public let action: () -> Void
    
    public init(imageName: String, title: String, width: CGFloat, action: @escaping () -> Void) {
        self.imageName = imageName
        self.title = title
        self.width = width
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            Image(imageName)
                .resizable()
                .aspectRatio(AppTheme.cardAspectRatio, contentMode: .fit)
                .frame(width: width)
        }
        .buttonStyle(BouncyButtonStyle())
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text("Opens \(title)"))
    }
}

// MARK: - Footer Pill Button
public struct FooterPillButton: View {
    public let imageName: String
    public let title: String
    public let width: CGFloat
    public let action: () -> Void
    
    public init(imageName: String = "", title: String, width: CGFloat, action: @escaping () -> Void) {
        self.imageName = imageName
        self.title = title
        self.width = width
        self.action = action
    }
    
    public var body: some View {
        let pillHeight = width * 0.29
        let fontSize = max(pillHeight * 0.36, 12)
        
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            ZStack {
                // Glass Base Material
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.88),
                                Color.white.opacity(0.74)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(.ultraThinMaterial, in: Capsule())
                
                // Specular Glass Border
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.85),
                                Color.white.opacity(0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                
                // Bold Apple Liquid Glass Label
                Text(title.uppercased())
                    .font(.system(size: fontSize, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 76/255, green: 51/255, blue: 170/255))
                    .tracking(0.8)
                    .shadow(color: Color.white.opacity(0.6), radius: 0, x: 0, y: 1)
            }
            .frame(width: width, height: pillHeight)
            .shadow(color: Color(red: 28/255, green: 14/255, blue: 56/255).opacity(0.18), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(BouncyButtonStyle(scaleAmount: 0.94))
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text("Opens \(title) information"))
    }
}

// MARK: - Header Icon Button (Apple Liquid Glass)
public struct HeaderIconButton: View {
    public let imageName: String
    public let systemIconName: String?
    public let title: String
    public let size: CGFloat
    public let action: () -> Void
    
    public init(
        imageName: String = "",
        systemIconName: String? = nil,
        title: String,
        size: CGFloat,
        action: @escaping () -> Void
    ) {
        self.imageName = imageName
        self.systemIconName = systemIconName
        self.title = title
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.88),
                                Color.white.opacity(0.74)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(.ultraThinMaterial, in: Circle())
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.85),
                                Color.white.opacity(0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                
                Image(systemName: resolvedIconSymbol)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.50, height: size * 0.50)
                    .foregroundColor(Color(red: 0.22, green: 0.21, blue: 0.23))
                    .shadow(color: Color.white.opacity(0.4), radius: 0, x: 0, y: 1)
            }
            .frame(width: size, height: size)
            .shadow(color: Color(red: 28/255, green: 14/255, blue: 56/255).opacity(0.18), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(BouncyButtonStyle(scaleAmount: 0.92))
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text("Activates \(title)"))
    }
    
    private var resolvedIconSymbol: String {
        if let systemIconName = systemIconName, !systemIconName.isEmpty {
            return systemIconName
        }
        let lower = (title + " " + imageName).lowercased()
        if lower.contains("back") {
            return "arrowshape.turn.up.backward.fill"
        } else if lower.contains("home") {
            return "house.fill"
        } else if lower.contains("setting") {
            return "gearshape.fill"
        }
        return "arrowshape.turn.up.backward.fill"
    }
}

// MARK: - Destination Detail Sheet
public struct DestinationDetailSheet: View {
    public let destination: HomeDestination
    @Environment(\.presentationMode) var presentationMode
    
    public init(destination: HomeDestination) {
        self.destination = destination
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                AppTheme.primaryPurple
                    .opacity(0.08)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Image(systemName: destination.iconName)
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(AppTheme.primaryPurple)
                        .padding(.top, 40)
                    
                    Text(destination.rawValue)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(AppTheme.primaryPurple)
                    
                    Text(destination.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                    
                    if destination == .about {
                        VStack(spacing: 16) {
                            Text("Generously Supported By")
                                .font(.headline)
                                .foregroundColor(AppTheme.darkPurple)
                            HStack(spacing: 20) {
                                Text("🎮 Child's Play")
                                    .font(.subheadline)
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                Text("☕ Dunkin' Joy in Childhood")
                                    .font(.subheadline)
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Back to Home")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppTheme.primaryPurple)
                            .cornerRadius(16)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitle(Text(destination.rawValue), displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
