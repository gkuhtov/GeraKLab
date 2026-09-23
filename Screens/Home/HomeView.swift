import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var labEngine: LabEngine

    var body: some View {
        Group {
            if labEngine.isLoading {
                loadingView
            } else if let error = labEngine.errorMessage {
                errorView(error)
            } else if let config = labEngine.config {
                content(config)
            } else {
                loadingView
            }
        }
        .task {
            labEngine.load()
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        ZStack {
            Color(hex: "#08080C")
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .tint(Color(hex: "#20E0D0"))
                    .scaleEffect(1.15)

                Text("ЗАГРУЗКА ЛАБОРАТОРИИ")
                    .font(.system(
                        size: 12,
                        weight: .semibold,
                        design: .rounded
                    ))
                    .tracking(1.2)
                    .foregroundStyle(
                        Color(hex: "#A7A7B3")
                    )
            }
        }
    }

    // MARK: - Error

    private func errorView(_ error: String) -> some View {
        ZStack {
            Color(hex: "#08080C")
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        Color(hex: "#FF4FA3")
                    )

                Text("ОШИБКА ЛАБОРАТОРИИ")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(
                        Color(hex: "#A7A7B3")
                    )
                    .multilineTextAlignment(.center)
            }
            .padding(28)
        }
    }

    // MARK: - Content

    private func content(_ config: AppConfig) -> some View {
        let theme = LabTheme(config.appearance)

        return NavigationStack {
            ZStack {
                theme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        header(config, theme: theme)

                        statusCard(config, theme: theme)

                        experimentsSection(
                            config,
                            theme: theme
                        )
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(
                theme.background,
                for: .navigationBar
            )
            .toolbarBackground(
                .visible,
                for: .navigationBar
            )
        }
        .tint(theme.accent)
    }

    // MARK: - Header

    private func header(
        _ config: AppConfig,
        theme: LabTheme
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {

            Text(config.home.title)
                .font(.system(
                    size: 34,
                    weight: .bold,
                    design: .rounded
                ))
                .foregroundStyle(theme.text)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(config.home.subtitle)
                .font(.system(
                    size: 15,
                    weight: .regular,
                    design: .rounded
                ))
                .foregroundStyle(theme.secondaryText)
                .lineLimit(2)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Status

    private func statusCard(
        _ config: AppConfig,
        theme: LabTheme
    ) -> some View {
        HStack(spacing: 14) {

            ZStack {
                Circle()
                    .fill(
                        theme.secondaryAccent
                            .opacity(0.14)
                    )
                    .frame(width: 44, height: 44)

                Circle()
                    .fill(theme.secondaryAccent)
                    .frame(width: 9, height: 9)
                    .shadow(
                        color: theme.secondaryAccent
                            .opacity(0.7),
                        radius: 7
                    )
            }

            VStack(alignment: .leading, spacing: 4) {

                Text(config.home.status.title)
                    .font(.system(
                        size: 12,
                        weight: .bold,
                        design: .rounded
                    ))
                    .tracking(0.6)
                    .foregroundStyle(theme.secondaryAccent)

                Text(config.home.status.description)
                    .font(.system(
                        size: 14,
                        weight: .regular,
                        design: .rounded
                    ))
                    .foregroundStyle(theme.secondaryText)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(
                cornerRadius: theme.cornerRadius,
                style: .continuous
            )
            .fill(theme.surface.opacity(theme.glassOpacity))
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: theme.cornerRadius,
                style: .continuous
            )
            .stroke(
                theme.secondaryAccent.opacity(0.14),
                lineWidth: 1
            )
        )
    }

    // MARK: - Experiments

    private func experimentsSection(
        _ config: AppConfig,
        theme: LabTheme
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(
                config.home.sections.first(
                    where: { $0.id == "experiments" }
                )?.title
                ?? "ДОСТУПНЫЕ ИССЛЕДОВАНИЯ"
            )
            .font(.system(
                size: 12,
                weight: .bold,
                design: .rounded
            ))
            .tracking(0.8)
            .foregroundStyle(theme.secondaryText)

            LazyVStack(spacing: 12) {

                ForEach(
                    config.experiments.filter(\.enabled)
                ) { experiment in

                    NavigationLink {
                        ExperimentView(
                            experiment: experiment
                        )
                    } label: {
                        experimentCard(
                            experiment,
                            theme: theme
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func experimentCard(
        _ experiment: Experiment,
        theme: LabTheme
    ) -> some View {
        HStack(spacing: 14) {

            ZStack {
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
                .fill(
                    theme.accent.opacity(0.12)
                )
                .frame(width: 50, height: 50)

                Text(experiment.icon)
                    .font(.system(size: 25))
            }

            VStack(alignment: .leading, spacing: 4) {

                Text(experiment.title)
                    .font(.system(
                        size: 16,
                        weight: .semibold,
                        design: .rounded
                    ))
                    .foregroundStyle(theme.text)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(experiment.subtitle)
                    .font(.system(
                        size: 13,
                        weight: .regular,
                        design: .rounded
                    ))
                    .foregroundStyle(theme.secondaryText)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(
                    size: 12,
                    weight: .bold
                ))
                .foregroundStyle(
                    theme.accent.opacity(0.8)
                )
        }
        .padding(14)
        .frame(
            maxWidth: .infinity,
            minHeight: 78
        )
        .background(
            RoundedRectangle(
                cornerRadius: theme.cornerRadius,
                style: .continuous
            )
            .fill(theme.surface.opacity(theme.glassOpacity))
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: theme.cornerRadius,
                style: .continuous
            )
            .stroke(
                theme.accent.opacity(0.10),
                lineWidth: 1
            )
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(LabEngine())
}
