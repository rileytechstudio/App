import SwiftUI

// MARK: - Xcode Previews Across Devices and Orientations
struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 1. iPad Pro 12.9" (Landscape) - Matches mockup
            HomeScreenView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro 12.9 - Landscape")
                .previewInterfaceOrientation(.landscapeLeft)
            
            // 2. iPad Pro 12.9" (Portrait)
            HomeScreenView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro 12.9 - Portrait")
                .previewInterfaceOrientation(.portrait)
            
            // 3. iPhone 16 Pro (Portrait)
            HomeScreenView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 16 Pro"))
                .previewDisplayName("iPhone 16 Pro - Portrait")
                .previewInterfaceOrientation(.portrait)
            
            // 4. iPhone 16 Pro (Landscape)
            HomeScreenView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 16 Pro"))
                .previewDisplayName("iPhone 16 Pro - Landscape")
                .previewInterfaceOrientation(.landscapeLeft)
            
            // 5. iPhone SE (Compact)
            HomeScreenView()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
                .previewDisplayName("iPhone SE - Compact")
                .previewInterfaceOrientation(.portrait)
        }
    }
}
