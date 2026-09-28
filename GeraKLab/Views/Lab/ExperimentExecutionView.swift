import SwiftUI

public struct ExperimentExecutionView: View {
    public let experiment: ExperimentItem
    @Environment(\.dismiss) private var dismiss

    private let sensor = SensorEngine.shared
    private let motion = MotionEngine.shared
    private let strobe = FlashlightEngine.shared
    private let personality = PersonalityEngine.shared
    private let history = HistoryManager.shared

    @State private var timeRemaining: Int = 7
    @State private var isFinished: Bool = false
    @State private var experimentTimer: Timer?

    // Метрики
    @State private var peakValue: Double = 0.0
    @State private var screenTouchCount: Int = 0
    @State private var strobeScreenFlash: Bool = false

    public init(experiment: ExperimentItem) {
        self.experiment = experiment
    }

    private var hardwareMode: HardwareMode {
        let hw = experiment.requiredHardware.lowercased()
        if hw.contains("гироскоп") || hw.contains("акселерометр") || hw.contains("процессор") {
            return .motion
        } else if hw.contains("вспышка") || hw.contains("камера") || hw.contains("оптика") {
            return .flashlight
        } else if hw.contains("экран") || hw.contains("матриц") || hw.contains("сенсор") {
            return .touchscreen
        } else {
            return .microphone
        }
    }

    private enum HardwareMode {
        case microphone
        case motion
        case flashlight
        case touchscreen
    }

    public var body: some View {
        ZStack {
            // Эффект мигания экрана для стробоскопа
            if hardwareMode == .flashlight && strobeScreenFlash {
                Color.white.ignoresSafeArea()
            } else {
                Color.black.opacity(0.95).ignoresSafeArea()
            }

            VStack(spacing: 20) {
                // Шапка опыта
                headerView
                    .padding(.horizontal, 22)
                    .padding(.top, 24)

                Spacer()

                // Центральный интерактивный блок по типу железа
                sensorVisualView

                Spacer()

                // Нижний блок статуса и таймера
                statusFooterView
                    .padding(.horizontal, 20)

                Spacer()
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if hardwareMode == .touchscreen && !isFinished {
                        screenTouchCount += 1
                        sensor.triggerClick()
                    }
                }
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                startSelectedExperiment()
            }
        }
        .onDisappear {
            stopAllEngines()
        }
    }

    // MARK: - Шапка
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(modeBadgeTitle)
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(experiment.accentColor)
                    .tracking(2)
                Text(experiment.title)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()
            Button {
                stopAllEngines()
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
    }

    private var modeBadgeTitle: String {
        switch hardwareMode {
        case .microphone: return "🎙️ АКУСТИЧЕСКИЙ ПЕРЕГРУЗ"
        case .motion: return "⚡ СОТРЯСЕНИЕ G-FORCE"
        case .flashlight: return "🔦 ВЫЖИГАЮЩИЙ СТРОБОСКОП"
        case .touchscreen: return "📺 СЖАТИЕ МАТРИЦЫ"
        }
    }

    // MARK: - Центральный визуальный датчик
    @ViewBuilder
    private var sensorVisualView: some View {
        switch hardwareMode {
        case .microphone:
            microphoneMeterView
        case .motion:
            motionGForceView
        case .flashlight:
            strobeWarningView
        case .touchscreen:
            touchCompressionView
        }
    }

    // 1. Микрофон
    private var microphoneMeterView: some View {
        VStack(spacing: 16) {
            Text(experiment.emoji)
                .font(.system(size: 68))
                .frame(width: 120, height: 120)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(experiment.accentColor.opacity(Double(sensor.currentDecibels) / 100.0), lineWidth: 4)
                        .scaleEffect(1.0 + CGFloat(sensor.currentDecibels) / 240.0)
                )

            VStack(spacing: 8) {
                Text("УРОВЕНЬ ШУМА: \(Int(sensor.currentDecibels)) дБ")
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(sensor.currentDecibels > 85 ? LabTheme.alertRed : LabTheme.cyanBeam)

                customProgressBar(value: Double(sensor.currentDecibels), max: 110.0)
            }
        }
    }

    // 2. Гироскоп / G-Force
    private var motionGForceView: some View {
        VStack(spacing: 16) {
            Text("⚡")
                .font(.system(size: 68))
                .frame(width: 120, height: 120)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .rotationEffect(.degrees(motion.currentGForce * 25.0))
                .animation(.spring(response: 0.15), value: motion.currentGForce)

            VStack(spacing: 8) {
                Text("ПЕРЕГРУЗКА: \(String(format: "%.1f", motion.currentGForce)) G")
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .foregroundColor(motion.currentGForce > 3.0 ? LabTheme.alertRed : LabTheme.hazardOrange)

                customProgressBar(value: motion.currentGForce, max: 6.0)
            }
        }
    }

    // 3. Стробоскоп
    private var strobeWarningView: some View {
        VStack(spacing: 16) {
            Text("🔦")
                .font(.system(size: 68))
                .frame(width: 120, height: 120)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(LabTheme.alertRed, lineWidth: strobeScreenFlash ? 6 : 2)
                        .scaleEffect(strobeScreenFlash ? 1.2 : 1.0)
                )
                .animation(.easeInOut(duration: 0.08), value: strobeScreenFlash)

            Text("ЧАСТОТА ВСПЫШЕК: 15 Гц")
                .font(.system(size: 15, weight: .black, design: .monospaced))
                .foregroundColor(LabTheme.alertRed)
        }
    }

    // 4. Сжатие экрана
    private var touchCompressionView: some View {
        VStack(spacing: 16) {
            Text("🖐️")
                .font(.system(size: 68))
                .frame(width: 120, height: 120)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .scaleEffect(max(0.85, 1.0 - CGFloat(screenTouchCount) * 0.02))

            VStack(spacing: 8) {
                Text("ТАПОВ И ДАВЛЕНИЯ: \(screenTouchCount)")
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(screenTouchCount > 25 ? LabTheme.alertRed : LabTheme.toxicGreen)

                customProgressBar(value: Double(screenTouchCount), max: 35.0)
            }
        }
    }

    private func customProgressBar(value: Double, max: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.12))
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [LabTheme.cyanBeam, LabTheme.hazardOrange, LabTheme.alertRed],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(min(1.0, Swift.max(0.05, value / max))))
            }
        }
        .frame(height: 12)
        .padding(.horizontal, 36)
    }

    // MARK: - Нижний блок
    private var statusFooterView: some View {
        VStack(spacing: 10) {
            if !isFinished {
                Text("ДО ВЗРЫВА: \(timeRemaining) СЕК")
                    .font(.system(size: 17, weight: .heavy, design: .monospaced))
                    .foregroundColor(timeRemaining <= 3 ? LabTheme.alertRed : .white)

                Text(actionPromptText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            } else {
                VStack(spacing: 6) {
                    Text("💥 ОПЫТ ЗАВЕРШЁН!")
                        .font(.system(size: 19, weight: .black))
                        .foregroundColor(LabTheme.hazardOrange)
                    Text("Пиковый результат: \(formattedPeak) • Занесено в каталог катастроф")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .liquidGlass(cornerRadius: 22, borderOpacity: 0.35)
    }

    private var actionPromptText: String {
        switch hardwareMode {
        case .microphone: return "Ори в микрофон во всю глотку!"
        case .motion: return "Тряси телефон как бешеный! Выжимай G-Force!"
        case .flashlight: return "Смотри в объектив и не моргай!"
        case .touchscreen: return "Долби по экрану всеми пальцами сразу!"
        }
    }

    private var formattedPeak: String {
        switch hardwareMode {
        case .microphone: return "\(Int(peakValue)) дБ"
        case .motion: return "\(String(format: "%.1f", peakValue)) G"
        case .flashlight: return "15 Гц выдержки"
        case .touchscreen: return "\(Int(peakValue)) ударов"
        }
    }

    // MARK: - Логика запуска испытания
    private func startSelectedExperiment() {
        timeRemaining = 7
        isFinished = false
        peakValue = 0.0
        screenTouchCount = 0

        // Запуск персонажа под конкретный тест
        switch hardwareMode {
        case .microphone:
            personality.say("Акустический тест! Ну-ка заори так, чтоб мембрана лопнула!", emotion: .aggressive)
            sensor.startAudioMetering { peak in
                if Double(peak) > peakValue { peakValue = Double(peak) }
                sensor.triggerClick()
            }
        case .motion:
            personality.say("Тест на сотрясение процессора! Тряси телефон как ненормальный!", emotion: .panic)
            motion.startTracking { g in
                if g > peakValue { peakValue = g }
                sensor.triggerClick()
            }
        case .flashlight:
            personality.say("Стробоскоп на полную! Береги сетчатку, лаборант!", emotion: .panic)
            strobe.startStrobe(frequency: 0.08)
            // Мигание экраном
            Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { t in
                if isFinished { t.invalidate() } else { strobeScreenFlash.toggle() }
            }
        case .touchscreen:
            personality.say("Тест матрицы! Зажимай экран всеми пальцами и дави!", emotion: .aggressive)
        }

        // Таймер 7 секунд
        experimentTimer?.invalidate()
        experimentTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if self.timeRemaining > 1 {
                self.timeRemaining -= 1
                if self.timeRemaining == 3 {
                    self.personality.say("Три секунды! Жми на предел!", emotion: .panic)
                }
            } else {
                t.invalidate()
                self.completeExperiment()
            }
        }
    }

    private func completeExperiment() {
        isFinished = true
        stopAllEngines()
        sensor.triggerExplosionHaptics()

        if hardwareMode == .touchscreen {
            peakValue = Double(screenTouchCount)
        }

        history.recordDisaster(
            title: experiment.title,
            emoji: experiment.emoji,
            peakDecibels: Float(peakValue),
            hardware: experiment.requiredHardware
        )

        // Финальные вердикты профессора
        switch hardwareMode {
        case .microphone:
            if peakValue > 80 {
                personality.say("Нихуя ты глотку сорвал! Динамик чудом уцелел. Зачёт!", emotion: .mocking)
            } else {
                personality.say("Слабовато орал. Твой кот громче мурлычет.", emotion: .aggressive)
            }
        case .motion:
            if peakValue > 3.0 {
                personality.say("Отличная тряска! Процессор чуть из сокета не вылетел!", emotion: .mocking)
            } else {
                personality.say("Ты его гладил, что ли? Трясти надо было, бездарь!", emotion: .aggressive)
            }
        case .flashlight:
            personality.say("Светодиод раскалился докрасна. Лабораторный ожог зафиксирован.", emotion: .mocking)
        case .touchscreen:
            if screenTouchCount > 20 {
                personality.say("Стекло трещало знатно! Олеофобке пиздец, зачёт!", emotion: .mocking)
            } else {
                personality.say("Пальцы устали? Слабак, иди эспандер крути.", emotion: .aggressive)
            }
        }
    }

    private func stopAllEngines() {
        experimentTimer?.invalidate()
        experimentTimer = nil
        sensor.stopAudioMetering()
        motion.stopTracking()
        strobe.stopStrobe()
        strobeScreenFlash = false
    }
}
