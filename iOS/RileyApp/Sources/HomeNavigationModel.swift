import SwiftUI

// MARK: - Navigation Destinations
public enum HomeDestination: String, Identifiable, CaseIterable {
    case preparations = "Preparations"
    case glossary = "Glossary"
    case anatomyExplorer = "Anatomy Explorer"
    case gallery = "Gallery"
    case games = "Games"
    case about = "About"
    case legal = "Legal"
    case settings = "Settings"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .preparations: return "cross.case.fill"
        case .glossary: return "character.book.closed.fill"
        case .anatomyExplorer: return "figure.stand"
        case .gallery: return "photo.on.rectangle.angled"
        case .games: return "gamecontroller.fill"
        case .about: return "info.circle.fill"
        case .legal: return "doc.text.fill"
        case .settings: return "gearshape.fill"
        }
    }
    
    public var description: String {
        switch self {
        case .preparations:
            return "Helpful guides, preparation tips, and what to expect during your hospital visit."
        case .glossary:
            return "Friendly explanations of medical words and hospital terminology for kids and families."
        case .anatomyExplorer:
            return "Interactive anatomical exploration and educational models."
        case .gallery:
            return "Photos and stories from around Riley Hospital for Children."
        case .games:
            return "Fun and engaging games for patients during their stay."
        case .about:
            return "About Riley Hospital for Children and our supporting partners."
        case .legal:
            return "Legal notices, terms of use, and medical disclaimers."
        case .settings:
            return "Application preferences, audio settings, and accessibility options."
        }
    }
}

// MARK: - Navigation State
public final class HomeNavigationState: ObservableObject {
    @Published public var activeDestination: HomeDestination? = nil
    
    public init() {}
    
    public func navigate(to destination: HomeDestination) {
        HapticManager.shared.buttonTap()
        activeDestination = destination
    }
    
    public func resetToHome() {
        HapticManager.shared.lightTap()
        activeDestination = nil
    }
}
