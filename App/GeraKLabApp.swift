import SwiftUI

@main
struct GeraKLabApp: App {

    @StateObject private var labEngine = LabEngine()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(labEngine)
        }
    }
}
