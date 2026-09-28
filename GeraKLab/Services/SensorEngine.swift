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

    public func startAudioMetering(onPeakReached: ((Float) -> Void)? = nil) {
        guard !isListening else { return }

        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { [weak self] granted in
            guard granted else { return }
            DispatchQueue.main.async {
                self?.beginRecording(onPeakReached: onPeakReached)
            }
        }
    }

    private func beginRecording(onPeakReached: ((Float) -> Void)?) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers, .allowBluetooth])
            try session.setActive(true)

            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("meter_buffer.m4a")
            self.tempFileURL = fileURL

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 22050.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            guard let recorder = audioRecorder else { return }

            recorder.isMeteringEnabled = true
            if recorder.record() {
                isListening = true
            }

            levelTimer?.invalidate()
            levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let rec = self.audioRecorder, rec.isRecording else { return }
                rec.updateMeters()

                let power = rec.averagePower(forChannel: 0)
                let normalized = max(0, min(120, power + 100))

                DispatchQueue.main.async {
                    self.currentDecibels = normalized
                    if normalized > 85 {
                        onPeakReached?(normalized)
                    }
                }
            }
        } catch {
            print("[SensorEngine] Ошибка старта микрофона: \(error)")
        }
    }

    public func stopAudioMetering() {
        levelTimer?.invalidate()
        levelTimer = nil

        if let rec = audioRecorder {
            rec.stop()
            audioRecorder = nil
        }

        isListening = false
        currentDecibels = 0.0

        if let fileURL = tempFileURL {
            try? FileManager.default.removeItem(at: fileURL)
            tempFileURL = nil
        }
    }

    public func triggerExplosionHaptics() {
        DispatchQueue.main.async {
            self.notificationFeedback.notificationOccurred(.error)
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.09) {
                    self.impactFeedback.impactOccurred(intensity: 1.0)
                }
            }
        }
    }

    public func triggerClick() {
        DispatchQueue.main.async {
            self.impactFeedback.impactOccurred(intensity: 0.7)
        }
    }
}
