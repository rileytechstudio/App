import SwiftUI

@main
struct RileyHospitalApp: App {
    var body: some Scene {
        WindowGroup {
            HomeScreenView()
                .statusBar(hidden: false)
        }
    }
}
