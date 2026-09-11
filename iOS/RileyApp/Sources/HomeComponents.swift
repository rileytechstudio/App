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
                .aspectRatio(AppTheme.footerAspectRatio, contentMode: .fit)
                .frame(width: width)
        }
        .buttonStyle(BouncyButtonStyle(scaleAmount: 0.92))
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text("Opens \(title) information"))
    }
}

// MARK: - Header Icon Button
public struct HeaderIconButton: View {
    public let imageName: String
    public let title: String
    public let size: CGFloat
    public let action: () -> Void
    
    public init(imageName: String, title: String, size: CGFloat, action: @escaping () -> Void) {
        self.imageName = imageName
        self.title = title
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            Image(imageName)
                .resizable()
                .aspectRatio(AppTheme.iconAspectRatio, contentMode: .fit)
                .frame(width: size, height: size)
        }
        .buttonStyle(BouncyButtonStyle(scaleAmount: 0.90))
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text("Activates \(title)"))
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
