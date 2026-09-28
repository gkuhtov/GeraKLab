import SwiftUI

public struct HomeView: View {
    private let personality = PersonalityEngine.shared
    @State private var showSettings: Bool = false

    private let dailyExperiment = ExperimentItem(
        id: "daily_overclock",
        title: "Разгон процессора через микрофон",
        subtitle: "Ори матом на частоте 44 кГц для экстренного охлаждения",
        emoji: "🎙️",
        requiredHardware: "Микрофон + Динамик",
        accentColor: LabTheme.hazardOrange
    )

    private let quickExperiments: [ExperimentItem] = [
        ExperimentItem(id: "polygraph", title: "Детектор пиздежа", subtitle: "Анализ пульса", emoji: "🫀", requiredHardware: "Камера"),
        ExperimentItem(id: "shockwave", title: "Ультразвуковой визг", subtitle: "Прочистка ушей", emoji: "🔊", requiredHardware: "Динамик", accentColor: LabTheme.alertRed),
        ExperimentItem(id: "quake", title: "Сейсмо-разнос", subtitle: "Тест гироскопа", emoji: "⚡", requiredHardware: "Taptic Engine", accentColor: LabTheme.cyanBeam),
        ExperimentItem(id: "strobe", title: "Слеповой стробоскоп", subtitle: "Реакция зрачков", emoji: "🔦", requiredHardware: "Вспышка")
    ]

    private let freshExperiments: [ExperimentItem] = [
        ExperimentItem(id: "lidar_ghost", title: "Охота на призраков в комнате", subtitle: "Поиск аномалий сканером", emoji: "👻", requiredHardware: "LiDAR / AR", accentColor: LabTheme.cyanBeam),
        ExperimentItem(id: "screen_fry", title: "Прожарка пикселей", subtitle: "Калибровка белого шума", emoji: "📺", requiredHardware: "Экран", accentColor: LabTheme.hazardOrange)
    ]

    public init() {}

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                // Шапка
                headerSection

                // Плавающее облако наездов персонажа
                personalityStatusBubble

                // 🎯 Эксперимент дня
                dailyExperimentCard

                // 🔥 Быстрые эксперименты
                quickSection

                // 🆕 Новинки
                freshSection

                // 👀 Ты ещё не пробовал
                untriedSection

                Spacer().frame(height: 110)
            }
            .padding(.horizontal, 20)
            .padding(.top, 54)
        }
        .onTapGesture {
            personality.userDidInteract()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    // MARK: - Шапка GERAKLAB
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("GERAKLAB")
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .tracking(2)

                Spacer()

                Button {
                    personality.userDidInteract()
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }

            Text("42 из 54 возможностей доступно")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(LabTheme.toxicGreen.opacity(0.85))
        }
    }

    // MARK: - Облако базара персонажа
    private var personalityStatusBubble: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("🧑‍🔬")
                .font(.system(size: 28))
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("ПРОФЕССОР РАЗЪЁБА")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(LabTheme.hazardOrange)
                    .tracking(1)

                Text(personality.currentSpeech)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
                    .lineLimit(3)
            }

            Spacer()
        }
        .padding(14)
        .liquidGlass(cornerRadius: 18, borderOpacity: 0.3)
    }

    // MARK: - 🎯 Эксперимент дня
    private var dailyExperimentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🎯 ЭКСПЕРИМЕНТ ДНЯ")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(LabTheme.toxicGreen)
                    .tracking(1)
                Spacer()
                Text("ГОТОВ К ЗАПУСКУ")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LabTheme.toxicGreen)
                    .clipShape(Capsule())
            }

            HStack(alignment: .center, spacing: 16) {
                Text(dailyExperiment.emoji)
                    .font(.system(size: 44))
                    .frame(width: 72, height: 72)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(dailyExperiment.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Text(dailyExperiment.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.65))
                }
            }

            HStack {
                Label(dailyExperiment.requiredHardware, systemImage: "cpu")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(LabTheme.toxicGreen)
            }
        }
        .padding(18)
        .liquidGlass(cornerRadius: 26, borderOpacity: 0.4)
    }

    // MARK: - 🔥 Быстрые эксперименты
    private var quickSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔥 БЫСТРЫЕ ЭКСПЕРИМЕНТЫ")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(.white.opacity(0.7))
                .tracking(1)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(quickExperiments) { item in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(item.emoji)
                                .font(.system(size: 28))
                                .frame(width: 46, height: 46)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                Text(item.requiredHardware)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .frame(width: 140, alignment: .leading)
                        .padding(14)
                        .liquidGlass(cornerRadius: 20, borderOpacity: 0.25)
                    }
                }
            }
        }
    }

    // MARK: - 🆕 Новинки
    private var freshSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🆕 НОВИНКИ ЛАБОРАТОРИИ")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(.white.opacity(0.7))
                .tracking(1)

            VStack(spacing: 12) {
                ForEach(freshExperiments) { item in
                    HStack(spacing: 14) {
                        Text(item.emoji)
                            .font(.system(size: 26))
                            .frame(width: 48, height: 48)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)

                            Text(item.subtitle)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .padding(14)
                    .liquidGlass(cornerRadius: 20, borderOpacity: 0.2)
                }
            }
        }
    }

    // MARK: - 👀 Ты ещё не пробовал
    private var untriedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("👀 ТЫ ЕЩЁ НЕ ПРОБОВАЛ")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(.white.opacity(0.7))
                .tracking(1)

            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("☢️")
                        .font(.system(size: 32))
                    Text("Детектор радиации бананов")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("Калибровка матрицы")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(LabTheme.toxicGreen)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .liquidGlass(cornerRadius: 22, borderOpacity: 0.25)

                VStack(alignment: .leading, spacing: 8) {
                    Text("🥶")
                        .font(.system(size: 32))
                    Text("Крио-заморозка аккумулятора")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("Ударные волны")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(LabTheme.hazardOrange)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .liquidGlass(cornerRadius: 22, borderOpacity: 0.25)
            }
        }
    }
}
