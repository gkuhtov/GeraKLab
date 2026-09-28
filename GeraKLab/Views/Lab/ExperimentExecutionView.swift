import SwiftUI

public struct ExperimentExecutionView: View {
    public let experiment: ExperimentItem
    @Environment(\.dismiss) private var dismiss

    private let sensor = SensorEngine.shared
    private let personality = PersonalityEngine.shared
    private let history = HistoryManager.shared

    @State private var timeRemaining: Int = 7
    @State private var timerActive: Bool = false
    @State private var isFinished: Bool = false
    @State private var peakDecibels: Float = 0.0

    public init(experiment: ExperimentItem) {
        self.experiment = experiment
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()

            VStack(spacing: 24) {
                // Шапка опыта
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("АКТИВНЫЙ ЭКСПЕРИМЕНТ")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(experiment.accentColor)
                            .tracking(2)
                        Text(experiment.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button {
                        stopExperiment()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)

                Spacer()

                // Центральный индикатор
                VStack(spacing: 16) {
                    Text(experiment.emoji)
                        .font(.system(size: 64))
                        .frame(width: 110, height: 110)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(experiment.accentColor.opacity(Double(sensor.currentDecibels) / 100.0), lineWidth: 4)
                                .scaleEffect(1.0 + CGFloat(sensor.currentDecibels) / 250.0)
                        )
                        .animation(.easeOut(duration: 0.1), value: sensor.currentDecibels)

                    VStack(spacing: 6) {
                        Text("УРОВЕНЬ ШУМА: \(Int(sensor.currentDecibels)) дБ")
                            .font(.system(size: 15, weight: .black, design: .monospaced))
                            .foregroundColor(sensor.currentDecibels > 85 ? LabTheme.alertRed : LabTheme.cyanBeam)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.1))
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        LinearGradient(
                                            colors: [LabTheme.cyanBeam, LabTheme.toxicGreen, LabTheme.alertRed],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * CGFloat(min(1.0, sensor.currentDecibels / 100.0)))
                            }
                        }
                        .frame(height: 10)
                        .padding(.horizontal, 40)
                    }
                }

                Spacer()

                // Таймер
                VStack(spacing: 8) {
                    if !isFinished {
                        Text("ДО ВЗРЫВА: \(timeRemaining) СЕК")
                            .font(.system(size: 16, weight: .heavy, design: .monospaced))
                            .foregroundColor(timeRemaining <= 3 ? LabTheme.alertRed : .white)

                        Text("Ори в микрофон или тряси телефон!")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    } else {
                        VStack(spacing: 6) {
                            Text("💥 ЭКСПЕРИМЕНТ ОКОНЧЕН!")
                                .font(.system(size: 18, weight: .black))
                                .foregroundColor(LabTheme.hazardOrange)
                            Text("Пиковый шум: \(Int(peakDecibels)) дБ • Записано в катастрофы")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .liquidGlass(cornerRadius: 20, borderOpacity: 0.3)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .onAppear {
            startExperiment()
        }
        .onDisappear {
            stopExperiment()
        }
    }

    private func startExperiment() {
        timerActive = true
        isFinished = false
        timeRemaining = 7
        peakDecibels = 0.0

        // Реплика старта
        personality.say("Эксперимент запущен! Ну-ка покажи, на что способны твои связки!", emotion: .aggressive)

        // Мягкий старт сенсора без резких переключений сессии
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.sensor.startAudioMetering { peak in
                if peak > self.peakDecibels {
                    self.peakDecibels = peak
                }
                self.sensor.triggerClick()
            }
        }

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if timeRemaining > 1 {
                timeRemaining -= 1
                if timeRemaining == 3 {
                    personality.say("Три секунды осталось! Дави до упора!", emotion: .panic)
                }
            } else {
                t.invalidate()
                finishExperiment()
            }
        }
    }

    private func finishExperiment() {
        isFinished = true
        timerActive = false
        sensor.stopAudioMetering()
        sensor.triggerExplosionHaptics()

        history.recordDisaster(
            title: experiment.title,
            emoji: experiment.emoji,
            peakDecibels: peakDecibels,
            hardware: experiment.requiredHardware
        )

        if peakDecibels > 85 {
            personality.say("Нихуя себе ты заорал! Аж динамик чуть не выбило. Зачёт!", emotion: .mocking)
        } else {
            personality.say("И это всё, на что ты способен? Позор лаборанта.", emotion: .aggressive)
        }
    }

    private func stopExperiment() {
        sensor.stopAudioMetering()
    }
}
