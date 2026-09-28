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

    private override init() {
        super.init()
        impactFeedback.prepare()
        notificationFeedback.prepare()
    }

    /// Старт замера уровня шума через микрофон
    public func startAudioMetering(onPeakReached: ((Float) -> Void)? = nil) {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)

            let url = URL(fileURLWithPath: "/dev/null")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isListening = true

            levelTimer?.invalidate()
            levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let recorder = self.audioRecorder else { return }
                recorder.updateMeters()
                
                // Перевод среднего уровня из dBFS (-160...0) в условные dB (0...120)
                let power = recorder.averagePower(forChannel: 0)
                let normalizedDb = max(0, power + 100)
                
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
        audioRecorder?.stop()
        audioRecorder = nil
        isListening = false
        currentDecibels = 0.0
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
