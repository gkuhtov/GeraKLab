import SwiftUI

public struct CustomLiquidTabBar: View {
    @Binding public var selectedTab: TabItem
    @State private var diceRotation: Double = 0
    @State private var diceScale: CGFloat = 1.0

    public init(selectedTab: Binding<TabItem>) {
        self._selectedTab = selectedTab
    }

    public var body: some View {
        ZStack(alignment: .top) {
            // Монолитная подложка жидкого стекла с выступом
            LiquidGlassTabBarShape()
                .fill(.ultraThinMaterial)
                .background(
                    LiquidGlassTabBarShape()
                        .fill(LabTheme.glassFill)
                )
                .overlay(
                    LiquidGlassTabBarShape()
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0.35), location: 0.0),
                                    .init(color: Color.white.opacity(0.04), location: 0.5),
                                    .init(color: LabTheme.cyanBeam.opacity(0.25), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
                .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 12)
                .frame(height: 68)

            // Кнопки навигации
            HStack(spacing: 0) {
                tabButton(for: .home)
                tabButton(for: .lab)

                // Центральная кость 🎲, сидящая прямо в куполе
                centerDiceButton()
                    .offset(y: -24)

                tabButton(for: .favorites)
                tabButton(for: .history)
            }
            .padding(.horizontal, 12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    // Обычная кнопка вкладки
    @ViewBuilder
    private func tabButton(for item: TabItem) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedTab = item
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: item.iconName)
                    .font(.system(size: 20, weight: selectedTab == item ? .bold : .medium))
                    .foregroundColor(selectedTab == item ? LabTheme.toxicGreen : Color.white.opacity(0.45))
                    .scaleEffect(selectedTab == item ? 1.15 : 1.0)

                Text(item.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(selectedTab == item ? .white : Color.white.opacity(0.45))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // Триггер случайного события (Кость 🎲)
    @ViewBuilder
    private func centerDiceButton() -> some View {
        Button {
            // Эффект удара по кубику с вибро и кувырком
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                diceRotation += 360
                diceScale = 0.85
                selectedTab = .random
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    diceScale = 1.0
                }
            }
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [LabTheme.hazardOrange, LabTheme.alertRed],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)
                    .shadow(color: LabTheme.hazardOrange.opacity(0.6), radius: 14, x: 0, y: 4)

                Image(systemName: "dice.fill")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(diceRotation))
                    .scaleEffect(diceScale)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}
