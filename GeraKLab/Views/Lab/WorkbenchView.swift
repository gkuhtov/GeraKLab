import SwiftUI

public struct WorkbenchView: View {
    @Environment(\.dismiss) private var dismiss
    private let personality = PersonalityEngine.shared

    @State private var selectedSensor: String = "Микрофон"
    @State private var explosionDelay: Double = 5.0
    @State private var triggerDecibels: Double = 80.0
    @State private var toxicityLevel: Double = 90.0

    private let sensors = ["Микрофон", "Taptic Engine", "Вспышка", "Гироскоп", "Камера"]

    public init() {}

    public var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Шапка верстака
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🛠️ ВЕРСТАК БЕЗУМИЯ")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundColor(LabTheme.hazardOrange)
                                .tracking(2)
                            Text("Собрать свой пиздец")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    .padding(.top, 24)

                    // Выбор железа
                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. КАКОЙ ДАТЧИК НАСИЛУЕМ?")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(sensors, id: \.self) { sensor in
                                    Button {
                                        selectedSensor = sensor
                                        personality.say("Выбрал \(sensor)? Ну посмотрим, выдержит ли труба.", emotion: .mocking)
                                    } label: {
                                        Text(sensor)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(selectedSensor == sensor ? .black : .white)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(selectedSensor == sensor ? LabTheme.toxicGreen : Color.white.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .liquidGlass(cornerRadius: 20, borderOpacity: 0.25)

                    // Задержка до взрыва
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("ТАЙМЕР ДО ВЗРЫВА")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                            Text("\(Int(explosionDelay)) сек")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(LabTheme.hazardOrange)
                        }

                        Slider(value: $explosionDelay, in: 2...15, step: 1)
                            .tint(LabTheme.hazardOrange)
                    }
                    .padding(16)
                    .liquidGlass(cornerRadius: 20, borderOpacity: 0.25)

                    // Порог срабатывания
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("ПОРОГ СРАБАТЫВАНИЯ (ДБ / УСКОРЕНИЕ)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                            Text("\(Int(triggerDecibels)) дБ")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(LabTheme.cyanBeam)
                        }

                        Slider(value: $triggerDecibels, in: 40...110, step: 5)
                            .tint(LabTheme.cyanBeam)
                    }
                    .padding(16)
                    .liquidGlass(cornerRadius: 20, borderOpacity: 0.25)

                    // Градус токсичности
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("ГРАДУС МАТА И ТОКСИЧНОСТИ")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                            Text("\(Int(toxicityLevel))%")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(LabTheme.alertRed)
                        }

                        Slider(value: $toxicityLevel, in: 10...100, step: 10)
                            .tint(LabTheme.alertRed)
                    }
                    .padding(16)
                    .liquidGlass(cornerRadius: 20, borderOpacity: 0.25)

                    // Кнопка сохранения и теста
                    Button {
                        personality.say("Конфиг собран к хуям! Щас бахнет!", emotion: .panic)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("💥 ЗАПУСТИТЬ КАСТОМНЫЙ РАЗЪЁБ")
                                .font(.system(size: 15, weight: .heavy))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .background(LabTheme.toxicGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}
