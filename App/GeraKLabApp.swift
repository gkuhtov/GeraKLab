import SwiftUI

@main
struct GeraKLabApp: App {

    @StateObject private var labEngine = LabEngine()

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color(hex: "#08080C")
                    .ignoresSafeArea()

                HomeView()
                    .environmentObject(labEngine)
            }
        }
    }
}
