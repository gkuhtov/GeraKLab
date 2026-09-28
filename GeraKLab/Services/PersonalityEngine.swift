import SwiftUI

@Observable
public final class PersonalityEngine {
    public static let shared = PersonalityEngine()

    public var currentSpeech: String = "Че встал? Выбирай эксперимент или телефон мне отдай."
    public var currentEmotion: VoiceEmotion = .mocking

    private let voice = VoiceEngine.shared
    private let sound = SoundManager.shared
    private let audioRoute = AudioRouteManager.shared

    private var idleTimer: Timer?

    private init() {
        resetIdleTimer()
    }

    public func say(_ text: String, emotion: VoiceEmotion = .neutral, cue: LabSoundCue? = nil) {
        currentSpeech = text
        currentEmotion = emotion

        if let cue = cue {
            sound.playCue(cue, fallbackText: text, emotion: emotion)
        } else {
            voice.speak(text, emotion: emotion)
        }

        resetIdleTimer()
    }

    public func triggerDicePanic() {
        let panicPhrases = [
            "Кость брошена! Назад дороги нет, щас что-то ёбнет!",
            "Случайный выбор? Ну держись, железо уже воет!",
            "Аварийный протокол активирован! Смотри на барабаны!"
        ]
        if let phrase = panicPhrases.randomElement() {
            say(phrase, emotion: .panic, cue: .sirenAlarm)
        }
    }

    public func userDidInteract() {
        resetIdleTimer()
    }

    private func resetIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: 14.0, repeats: false) { [weak self] _ in
            self?.triggerIdleBanter()
        }
    }

    private func triggerIdleBanter() {
        let banters = [
            "Ты уснул там? Жми на кнопку, пока батарея не сдохла!",
            "Экран щас протрешь пальцем. Запускай разъёб!",
            "Я тут стою, процессор грею вхолостую. Ну-ка шевелись!"
        ]
        if let randomText = banters.randomElement() {
            say(randomText, emotion: .aggressive)
        }
    }
}
