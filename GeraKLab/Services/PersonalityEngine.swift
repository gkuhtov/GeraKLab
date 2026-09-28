import SwiftUI

@Observable
public final class PersonalityEngine {
    public static let shared = PersonalityEngine()

    public var currentSpeech: String = "Готов к разъёбу. Не тупи только."
    public var currentEmotion: LabEmotion = .neutral
    public var isSpeaking: Bool = false

    private var idleTimer: Timer?
    private let voice = VoiceEngine.shared

    private init() {
        startIdleTimer()
    }

    /// Сброс таймера бездействия при любом тапе пользователя
    public func userDidInteract() {
        resetIdleTimer()
    }

    /// Наезд при бездействии (если залип на 12 секунд)
    private func triggerIdleNag() {
        let idlePhrases = [
            "Слышь, олень, ты экран включил, чтоб своё табло разглядывать? Тыкай давай, блять!",
            "У нас тут опыты или конкурс аутистов? Нажми хоть что-нибудь, реактор стынет!",
            "Эй, лаборант хуев, ты там уснул стоя? Не беси меня, жми на кнопки!",
            "Заебал тупить в экран. Шевели пальцами, пока я тебе телефон не перегрузил!"
        ]
        let phrase = idlePhrases.randomElement() ?? idlePhrases[0]
        say(phrase, emotion: .aggressive)
    }

    /// Реакция на нажатие кубика 🎲 (Паника и визг)
    public func triggerDicePanic() {
        let panicPhrases = [
            "Ты ебанутый?! Нахуя ты это нажал, щас всё нахуй разнесет!",
            "Тормози, дебил! Ты запустил аварийный сброс, нам пиздец!",
            "Сука-а-а! Я же просил не трогать рандом! Держи трубу крепче!",
            "Пиздец. Ну всё, тормоза отказали, пошла моча по трубам!"
        ]
        let phrase = panicPhrases.randomElement() ?? panicPhrases[0]
        say(phrase, emotion: .panic)
    }

    /// Озвучить фразу
    public func say(_ text: String, emotion: LabEmotion = .neutral) {
        currentSpeech = text
        currentEmotion = emotion
        isSpeaking = true

        voice.speak(text, emotion: emotion)
        resetIdleTimer()

        // Сбрасываем статус говорения через ориентировочное время фразы
        let duration = Double(text.count) * 0.07 + 1.2
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isSpeaking = false
        }
    }

    private func startIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: 12.0, repeats: false) { [weak self] _ in
            self?.triggerIdleNag()
        }
    }

    private func resetIdleTimer() {
        idleTimer?.invalidate()
        startIdleTimer()
    }
}
