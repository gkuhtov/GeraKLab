import SwiftUI

public struct LabView: View {
    @State private var selectedFilter: String = "Все"
    @State private var showWorkbench: Bool = false
    @State private var activeExperiment: ExperimentItem?
    private let personality = PersonalityEngine.shared

    private let filters = ["Все", "Для компании с пивом", "На выживание железа", "Ультразвуковой разъёб", "Камера и LiDAR"]

    private let experiments: [ExperimentItem] = [
        ExperimentItem(id: "beer_roulette", title: "Алко-рулетка с детонатором", subtitle: "Кто последний убрал палец — тот пьёт штрафную", emoji: "🍺", requiredHardware: "Экран + Taptic", accentColor: LabTheme.hazardOrange),
        ExperimentItem(id: "ultrasound_purge", title: "Ультразвуковая прочистка ушей", subtitle: "Частоты от 15 кГц до паники кота", emoji: "🦇", requiredHardware: "Динамики", accentColor: LabTheme.alertRed),
        ExperimentItem(id: "speaker_water_test", title: "Выдувание пыли из динамика", subtitle: "Низкочастотный бас-тест на пределе", emoji: "💨", requiredHardware: "НЧ-динамик", accentColor: LabTheme.cyanBeam),
        ExperimentItem(id: "polygraph_extreme", title: "Детектор пиздежа 18+", subtitle: "Сканирует палец и жестко глумится над ответом", emoji: "🫀", requiredHardware: "Камера + Пульс"),
        ExperimentItem(id: "shake_bomb", title: "Тряси или пизданёт", subtitle: "Таймер тикает, пока телефон в движении", emoji: "💣", requiredHardware: "Акселерометр", accentColor: LabTheme.hazardOrange)
    ]

    public init() {}

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Шапка лаборатории
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("🧪 ЛАБОРАТОРИЯ ХАОСА")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(LabTheme.toxicGreen)
                            .tracking(2)
                        Text("Каталог опытов")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.top, 54)

                // Кнопка верстака: «Собрать свой пиздец»
                Button {
                    personality.say("Решил сам конструктор собрать? Ну крути тумблеры, гений.", emotion: .neutral)
                    showWorkbench = true
                } label: {
                    HStack(spacing: 12) {
                        Text("🛠️")
                            .font(.system(size: 28))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("СОБРАТЬ СВОЙ ПИЗДЕЦ")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(.white)
                            Text("Настрой датчики, таймеры взрыва и мат под себя")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(LabTheme.hazardOrange)
                    }
                    .padding(16)
                    .liquidGlass(cornerRadius: 22, borderOpacity: 0.35)
                }
                .buttonStyle(.plain)

                // Горизонтальные трэш-фильтры
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filters, id: \.self) { filter in
                            Button {
                                personality.userDidInteract()
                                selectedFilter = filter
                            } label: {
                                Text(filter)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(selectedFilter == filter ? .black : .white.opacity(0.8))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == filter ? LabTheme.toxicGreen : Color.white.opacity(0.08))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                // Список карточек каталога
                VStack(spacing: 14) {
                    ForEach(experiments) { exp in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center, spacing: 14) {
                                Text(exp.emoji)
                                    .font(.system(size: 32))
                                    .frame(width: 52, height: 52)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exp.title)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(exp.subtitle)
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                Spacer()
                            }

                            HStack {
                                Label(exp.requiredHardware, systemImage: "cpu")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white.opacity(0.45))
                                Spacer()
                                Button {
                                    activeExperiment = exp
                                } label: {
                                    Text("ТЕСТ")
                                        .font(.system(size: 11, weight: .black))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(exp.accentColor)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(16)
                        .liquidGlass(cornerRadius: 22, borderOpacity: 0.25)
                        .onTapGesture {
                            activeExperiment = exp
                        }
                    }
                }

                Spacer().frame(height: 110)
            }
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showWorkbench) {
            WorkbenchView()
        }
        .fullScreenCover(item: $activeExperiment) { item in
            ExperimentExecutionView(experiment: item)
        }
    }
}
