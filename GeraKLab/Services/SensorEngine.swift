import AVFoundation
import UIKit

@Observable
public final class SensorEngine: NSObject {
    public static let shared = SensorEngine()

    public var currentDecibels: Float = 0.0
    public var isListening: Bool = false

    private var audioRecorder: AVAudioRecorder?
    private var levelTimer: Timer?
    private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    private var tempFileURL: URL?

    private override init() {
        super.init()
        impactFeedback.prepare()
        notificationFeedback.prepare()
    }

    /// Старт замера уровня шума через микрофон
    public func startAudioMetering(onPeakReached: ((Float) -> Void)? = nil) {
        let audioSession = AVAudioSession.sharedInstance()

        // Запрос разрешения у пользователя перед запуском
        audioSession.requestRecordPermission { [weak self] granted in
            guard granted else {
                print("[SensorEngine] Доступ к микрофону отклонен пользователем")
                return
            }

            DispatchQueue.main.async {
                self?.setupAndStartRecording(onPeakReached: onPeakReached)
            }
        }
    }

    private func setupAndStartRecording(onPeakReached: ((Float) -> Void)?) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            // Используем реальный файл во временной директории приложения вместо /dev/null
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("geraklab_metering.caf")
            self.tempFileURL = fileURL

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            guard let recorder = audioRecorder else { return }

            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
            recorder.record()
            isListening = true

            levelTimer?.invalidate()
            levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let recorder = self.audioRecorder, recorder.isRecording else { return }
                recorder.updateMeters()

                let power = recorder.averagePower(forChannel: 0)
                let normalizedDb = max(0, min(120, power + 100))

                DispatchQueue.main.async {
                    self.currentDecibels = normalizedDb
                    if normalizedDb > 85 {
                        onPeakReached?(normalizedDb)
                    }
                }
            }
        } catch {
            print("[SensorEngine] Ошибка инициализации микрофона: \(error)")
        }
    }

    /// Остановка прослушивания
    public func stopAudioMetering() {
        levelTimer?.invalidate()
        levelTimer = nil

        if let recorder = audioRecorder {
            recorder.stop()
            audioRecorder = nil
        }

        isListening = false
        currentDecibels = 0.0

        // Очищаем временный аудиофайл
        if let fileURL = tempFileURL {
            try? FileManager.default.removeItem(at: fileURL)
            tempFileURL = nil
        }

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// Серия тактильных ударов (Taptic взрыв)
    public func triggerExplosionHaptics() {
        notificationFeedback.notificationOccurred(.error)

        for index in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.08) { [weak self] in
                self?.impactFeedback.impactOccurred(intensity: 1.0)
            }
        }
    }

    /// Одиночный щелчок Taptic
    public func triggerClick() {
        impactFeedback.impactOccurred(intensity: 0.6)
    }
}
