import SwiftUI

public struct ExperimentExecutionView: View {
    public let experiment: ExperimentItem
    @Environment(\.dismiss) private var dismiss

    private let sensor = SensorEngine.shared
    private let motion = MotionEngine.shared
    private let strobe = FlashlightEngine.shared
    private let personality = PersonalityEngine.shared
    private let history = HistoryManager.shared

    @State private var timeRemaining: Int = 6
    @State private var isFinished: Bool = false
    @State private var hasFailed: Bool = false
    @State private var runTimer: Timer?

    // Метрики
    @State private var peakScore: Double = 0.0
    @State private var sustainSeconds: Double = 0.0
    @State private var touchHits: Int = 0
    @State private var isRedLightActive: Bool = false
    @State private var proximityEngaged: Bool = false
    @State private var strobeFlash: Bool = false

    public init(experiment: ExperimentItem) {
        self.experiment = experiment
    }

    public var body: some View {
        ZStack {
            if experiment.resolvedMechanic == "strobe_touch" && strobeFlash {
                Color.white.ignoresSafeArea()
            } else if experiment.resolvedMechanic == "red_light_green_light" && isRedLightActive {
                Color.red.opacity(0.85).ignoresSafeArea()
            } else {
                Color.black.opacity(0.95).ignoresSafeArea()
            }

            VStack(spacing: 20) {
                // Шапка
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(experiment.requiredHardware.uppercased())
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
                .padding(.horizontal, 22)
                .padding(.top, 24)

                Spacer()

                // Центральный иллюминатор
                centralIlluminatorView

                Spacer()

                // Нижний блок статуса
                footerView
                    .padding(.horizontal, 20)

                Spacer()
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if experiment.resolvedMechanic == "strobe_touch" && !isFinished && !hasFailed {
                        touchHits += 1
                        sensor.triggerClick()
                    }
                }
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                startSelectedFlow()
            }
        }
        .onDisappear {
            stopAllEngines()
        }
    }

    // MARK: - Центральный Liquid Glass иллюминатор
    @ViewBuilder
    private var centralIlluminatorView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(experiment.accentColor.opacity(0.3), lineWidth: 3)
                    .frame(width: 140, height: 140)

                switch experiment.resolvedMechanic {
                case "nitro_freeze":
                    Text(hasFailed ? "💥" : "🧪")
                        .font(.system(size: 64))
                        .scaleEffect(hasFailed ? 1.3 : 1.0)
                case "red_light_green_light":
                    Text(isRedLightActive ? "🛑" : "🟢")
                        .font(.system(size: 68))
                case "core_balance":
                    Circle()
                        .fill(isCoreInZone ? LabTheme.toxicGreen : LabTheme.alertRed)
                        .frame(width: 28, height: 28)
                        .offset(x: CGFloat(motion.roll * 120.0), y: CGFloat(motion.pitch * 120.0))
                case "proximity_facepalm":
                    Text(proximityEngaged ? "🧠" : "🤦‍♂️")
                        .font(.system(size: 64))
                case "strobe_touch":
                    Text("🖐️")
                        .font(.system(size: 64))
                        .scaleEffect(max(0.85, 1.0 - CGFloat(touchHits) * 0.015))
                case "shake_gforce":
                    Text("⚡")
                        .font(.system(size: 64))
                        .rotationEffect(.degrees(motion.currentGForce * 22.0))
                default:
                    Text(experiment.emoji)
                        .font(.system(size: 64))
                        .overlay(
                            Circle()
                                .stroke(experiment.accentColor.opacity(Double(sensor.currentDecibels) / 100.0), lineWidth: 4)
                                .scaleEffect(1.0 + CGFloat(sensor.currentDecibels) / 240.0)
                        )
                }
            }
            .frame(width: 140, height: 140)
            .liquidGlass(cornerRadius: 70, borderOpacity: 0.35)

            // Текстовая метрика датчика
            sensorMetricLabel
        }
    }

    private var isCoreInZone: Bool {
        let dist = sqrt(pow(motion.roll * 120.0, 2) + pow(motion.pitch * 120.0, 2))
        return dist < 50.0
    }

    @ViewBuilder
    private var sensorMetricLabel: some View {
        switch experiment.resolvedMechanic {
        case "nitro_freeze":
            Text(hasFailed ? "ВЗРЫВ ОТ ДРОЖИ!" : "НЕ ДЫШАТЬ И НЕ ДВИГАТЬСЯ!")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(hasFailed ? LabTheme.alertRed : LabTheme.toxicGreen)
        case "red_light_green_light":
            Text(isRedLightActive ? "СТОЯТЬ!" : "ТРЯСИ ТЕЛЕФОН!")
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(isRedLightActive ? LabTheme.alertRed : LabTheme.toxicGreen)
        case "core_balance":
            Text(isCoreInZone ? "ЯДРО СТАБИЛЬНО" : "УГРОЗА ВЗРЫВА!")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(isCoreInZone ? LabTheme.toxicGreen : LabTheme.alertRed)
        case "proximity_facepalm":
            Text(proximityEngaged ? "КОНТАКТ УСТАНОВЛЕН" : "ПРИЖМИ К ТЕЛУ/ЛБУ")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(proximityEngaged ? LabTheme.toxicGreen : LabTheme.hazardOrange)
        case "strobe_touch":
            Text("УДАРОВ: \(touchHits)")
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(touchHits >= 25 ? LabTheme.toxicGreen : LabTheme.hazardOrange)
        case "shake_gforce":
            Text("ПЕРЕГРУЗКА: \(String(format: "%.1f", motion.currentGForce)) G")
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(motion.currentGForce > 3.0 ? LabTheme.alertRed : LabTheme.hazardOrange)
        default:
            Text("ШУМ: \(Int(sensor.currentDecibels)) дБ")
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(sensor.currentDecibels > 85 ? LabTheme.alertRed : LabTheme.cyanBeam)
        }
    }

    // MARK: - Нижняя плашка
    private var footerView: some View {
        VStack(spacing: 8) {
            if !isFinished {
                Text("ДО ВЗРЫВА: \(timeRemaining) СЕК")
                    .font(.system(size: 17, weight: .heavy, design: .monospaced))
                    .foregroundColor(timeRemaining <= 2 ? LabTheme.alertRed : .white)

                Text(experiment.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            } else {
                VStack(spacing: 4) {
                    Text(hasFailed ? "💥 ПРОВАЛ!" : "🎉 ОПЫТ СДАН!")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(hasFailed ? LabTheme.alertRed : LabTheme.toxicGreen)
                    Text("Занесено в журнал катастроф")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .liquidGlass(cornerRadius: 22, borderOpacity: 0.3)
    }

    // MARK: - Логика
    private func startSelectedFlow() {
        timeRemaining = 6
        isFinished = false
        hasFailed = false
        peakScore = 0.0
        sustainSeconds = 0.0
        touchHits = 0

        switch experiment.resolvedMechanic {
        case "nitro_freeze":
            personality.say("Нитроглицерин! Замри, блять, и не дыши!", emotion: .whisper)
            sensor.startAudioMetering()
            motion.startTracking()
        case "red_light_green_light":
            personality.say("Тряси только на зелёный! На красный — стоп!", emotion: .aggressive)
            motion.startTracking()
        case "core_balance":
            personality.say("Удерживай ядро реактора в центре!", emotion: .panic)
            motion.startTracking()
        case "proximity_facepalm":
            personality.say("Приложи дисплей ко лбу, охлаждаем процессор!", emotion: .mocking)
            UIDevice.current.isProximityMonitoringEnabled = true
            NotificationCenter.default.addObserver(forName: UIDevice.proximityStateDidChangeNotification, object: nil, queue: .main) { _ in
                proximityEngaged = UIDevice.current.proximityState
                if proximityEngaged { sensor.triggerClick() }
            }
        case "strobe_touch":
            personality.say("Вспышка стробит! Долби по экрану!", emotion: .aggressive)
            strobe.startStrobe(interval: 0.08)
        case "shake_gforce":
            personality.say("Тряси телефон со всей дури!", emotion: .panic)
            motion.startTracking { g in
                if g > peakScore { peakScore = g }
                sensor.triggerClick()
            }
        default:
            personality.say("Заори в микрофон так, чтоб уши заложило!", emotion: .aggressive)
            sensor.startAudioMetering { peak in
                if Double(peak) > peakScore { peakScore = Double(peak) }
                sensor.triggerClick()
            }
        }

        runTimer?.invalidate()
        runTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard !isFinished && !hasFailed else { return }
            self.tickChecks()
        }

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if self.isFinished || self.hasFailed {
                t.invalidate()
                return
            }
            if self.timeRemaining > 1 {
                self.timeRemaining -= 1
            } else {
                t.invalidate()
                self.finishFlow(failed: false)
            }
        }
    }

    private func tickChecks() {
        switch experiment.resolvedMechanic {
        case "nitro_freeze":
            if motion.currentGForce > 1.35 || sensor.currentDecibels > 68 {
                finishFlow(failed: true)
            }
        case "red_light_green_light":
            if timeRemaining == 4 || timeRemaining == 2 {
                isRedLightActive = true
            } else {
                isRedLightActive = false
            }
            if isRedLightActive && motion.currentGForce > 1.4 {
                finishFlow(failed: true)
            }
        case "strobe_touch":
            strobeFlash.toggle()
        default:
            break
        }
    }

    private func finishFlow(failed: Bool) {
        isFinished = true
        hasFailed = failed
        stopAllEngines()
        sensor.triggerExplosionHaptics()

        history.recordDisaster(
            title: experiment.title,
            emoji: experiment.emoji,
            peakDecibels: Float(peakScore),
            hardware: experiment.requiredHardware
        )

        if failed {
            personality.say("Провал! Руки из одного места растут.", emotion: .aggressive)
        } else {
            personality.say("Опыт сдан! Железо чудом уцелело.", emotion: .mocking)
        }
    }

    private func stopAllEngines() {
        runTimer?.invalidate()
        runTimer = nil
        sensor.stopAudioMetering()
        motion.stopTracking()
        strobe.stopStrobe()
        strobeFlash = false
        UIDevice.current.isProximityMonitoringEnabled = false
    }
}
