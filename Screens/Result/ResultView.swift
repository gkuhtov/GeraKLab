import SwiftUI

struct ResultView: View {

    let result: ExperimentResult

    var body: some View {
        VStack(spacing: 10) {
            Text(result.title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            Text(result.value)
                .font(.system(size: 48, weight: .bold))

            Text(result.description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
