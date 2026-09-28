import AVFoundation
import SwiftUI

public enum LabEmotion {
    case neutral     // Обычный циничный профессор
    case whisper     // Зловещий/заговорщический шепот прямо в уши
    case panic       // Истеричный визг при нажатии на 🎲 или перегрузке
    case aggressive  // Быкование и мат, когда тупишь
    case mocking     // Издевательский смех над фейлом
}

public final class VoiceEngine: NSObject, AVSpeechSynthesizerDelegate {
    public static let shared = VoiceEngine()

    private let synthesizer = AVSpeechSynthesizer()
    private let routeManager = AudioRouteManager.shared

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Воспроизвести фразу с конкретной эмоцией и матом
    public func speak(_ text: String, emotion: LabEmotion = .neutral) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")

        // Адаптация тембра, скорости и громкости под эмоцию и аудиоканал
        switch emotion {
        case .whisper:
            utterance.pitchMultiplier = 0.8
            utterance.rate = 0.42
            utterance.volume = routeManager.currentDestination == .headphones ? 0.35 : 0.6

        case .panic:
            utterance.pitchMultiplier = 1.35
            utterance.rate = 0.58
            utterance.volume = 1.0

        case .aggressive:
            utterance.pitchMultiplier = 0.95
            utterance.rate = 0.52
            utterance.volume = 0.95

        case .mocking:
            utterance.pitchMultiplier = 1.15
            utterance.rate = 0.46
            utterance.volume = 0.85

        case .neutral:
            utterance.pitchMultiplier = 1.0
            utterance.rate = 0.48
            utterance.volume = 0.8
        }

        synthesizer.speak(utterance)
    }

    public func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
