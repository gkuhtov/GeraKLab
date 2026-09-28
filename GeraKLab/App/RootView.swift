import SwiftUI

public struct RootView: View {
    @State private var selectedTab: TabItem = .home
    @State private var showRandomChaos: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            LabBackgroundView()
                .ignoresSafeArea()

            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .lab:
                    Text("🧪 Каталог и Верстак Опытов")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                case .random:
                    Color.clear
                case .favorites:
                    Text("⭐ Золотая коллекция грехов")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                case .history:
                    Text("🕘 Журнал катастроф и позора")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Нижняя панель
            VStack {
                Spacer()
                CustomLiquidTabBar(
                    selectedTab: $selectedTab,
                    onDiceTriggered: {
                        showRandomChaos = true
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showRandomChaos) {
            RandomChaosView(isPresented: $showRandomChaos)
        }
    }
}

private struct LabBackgroundView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LabTheme.backgroundDark

            Circle()
                .fill(LabTheme.cyanBeam.opacity(0.18))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: animate ? -90 : 70, y: animate ? -220 : -140)

            Circle()
                .fill(LabTheme.hazardOrange.opacity(0.12))
                .frame(width: 280, height: 280)
                .blur(radius: 75)
                .offset(x: animate ? 100 : -50, y: animate ? 250 : 180)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}
