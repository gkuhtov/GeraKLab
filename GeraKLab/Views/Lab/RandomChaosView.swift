import SwiftUI

public struct RandomChaosView: View {
    @Binding public var isPresented: Bool

    // Состояния барабанов
    @State private var objectIndex: Int = 0
    @State private var actionIndex: Int = 0
    @State private var conditionIndex: Int = 0

    @State private var isSpinning: Bool = true
    @State private var countdown: Int = 3
    @State private var isCountdownActive: Bool = false
    @State private var isExecuting: Bool = false

    private let personality = PersonalityEngine.shared

    // Списки для барабанов
    private let objects = [
        ("🎙️", "Микрофон"),
        ("⚡", "Гироскоп"),
        ("🔦", "Вспышка"),
        ("📺", "Матрица экрана"),
        ("📸", "Камера лица")
    ]

    private let actions = [
        "Аварийный разгон до 1000°C",
        "Ультразвуковой замер крика",
        "Тест на сотрясение процессора",
        "Слеповой стробоскоп",
        "Детектор дикого пиздежа"
    ]

    private let conditions = [
        "Ори матом громче 85 дБ",
        "Тряси телефон как бешеный",
        "Не моргай 7 секунд в объектив",
        "Зажми экран всеми 5 пальцами",
        "Шепчи оскорбления прямо в ухо"
    ]

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    public var body: some View {
        ZStack {
            // Тревожный красный бэкграунд с перегрузкой
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Шапка тревоги
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("🚨 НЕОБРАТИМЫЙ СИНТЕЗ")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(LabTheme.alertRed)
                            .tracking(2)

                        Text("Случайный пиздец")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // Без кнопки закрытия во время крутки/таймера!
                    if !isSpinning && !isCountdownActive {
                        Button {
                            personality.say("Слился, лаборант? Ну и вали на главную!", emotion: .mocking)
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)

                Spacer()

                // Слот-машина: 3 стеклянных барабана
                VStack(spacing: 14) {
                    // Барабан 1: Объект
                    slotCard(
                        title: "ДАТЧИК / ЖЕЛЕЗО",
                        content: "\(objects[objectIndex].0) \(objects[objectIndex].1)",
                        color: LabTheme.cyanBeam
                    )

                    // Барабан 2: Действие
                    slotCard(
                        title: "ДЕЙСТВИЕ",
                        content: actions[actionIndex],
                        color: LabTheme.hazardOrange
                    )

                    // Барабан 3: Условие
                    slotCard(
                        title: "УСЛОВИЕ РАЗЪЁБА",
                        content: conditions[conditionIndex],
                        color: LabTheme.alertRed
                    )
                }
                .padding(.horizontal, 20)

                Spacer()

                // Блок обратного отсчета или запуска
                VStack(spacing: 12) {
                    if isCountdownActive {
                        VStack(spacing: 6) {
                            Text("\(countdown)")
                                .font(.system(size: 64, weight: .black, design: .monospaced))
                                .foregroundColor(LabTheme.alertRed)
                                .scaleEffect(1.2)
                                .animation(.spring(response: 0.2), value: countdown)

                            Text("ПРИГОТОВИТЬСЯ К АВАРИИ!")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundColor(.white)
                        }
                    } else if isExecuting {
                        Text("💥 ОПЫТ АКТИВЕН! ДЕЙСТВУЙ!")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(LabTheme.toxicGreen)
                    } else {
                        Text("Синтез цепной реакции...")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .frame(height: 100)

                Spacer()
            }
        }
        .onAppear {
            startChaosRoulette()
        }
    }

    // Карточка барабана
    @ViewBuilder
    private func slotCard(title: String, content: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .foregroundColor(color)
                .tracking(1.5)

            Text(content)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .liquidGlass(cornerRadius: 18, borderOpacity: 0.35)
    }

    // Запуск рулетки с последовательной остановкой
    private func startChaosRoulette() {
        isSpinning = true
        isCountdownActive = false
        isExecuting = false

        // Быстрая анимация перебора значений
        let timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { t in
            if isSpinning {
                objectIndex = Int.random(in: 0..<objects.count)
                actionIndex = Int.random(in: 0..<actions.count)
                conditionIndex = Int.random(in: 0..<conditions.count)
            } else {
                t.invalidate()
            }
        }

        // Фиксация барабанов по очереди
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            // Барабан 1 зафиксирован
            personality.say("Так, выпало железо... держись крепче!", emotion: .panic)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            // Барабан 2 зафиксирован
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // Барабан 3 зафиксирован, крутка окончена
            isSpinning = false
            startCountdown()
        }
    }

    // Таймер 3..2..1..СТАРТ
    private func startCountdown() {
        isCountdownActive = true
        countdown = 3
        personality.say("Три... два... один... пошла жара, выполняй!", emotion: .aggressive)

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if countdown > 1 {
                countdown -= 1
            } else {
                t.invalidate()
                isCountdownActive = false
                isExecuting = true
            }
        }
    }
}
