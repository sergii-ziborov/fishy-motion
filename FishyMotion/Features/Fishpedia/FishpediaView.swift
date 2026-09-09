import SwiftUI

struct FishpediaView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "Fishpedia") { model.screen = .collection }
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    headerCard
                    ForEach(LieKind.allCases) { lie in
                        lieCard(lie)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .fillScreenTop()
        .background { OceanBackdrop(asset: "CoralReefBackground", dim: 0.55) }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Blue Tang")
                .font(.fmDisplay(26))
                .foregroundStyle(.white)
            Text("Calm and coordinated most of the time. The odd one never changes its look — only its timing.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Palette.muted)
            CreatureView(theme: model.progress.selectedTheme, heading: 0.1, wiggle: 0.2)
                .frame(height: 90)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func lieCard(_ lie: LieKind) -> some View {
        let seen = model.progress.seenLies.contains(lie)
        return VStack(alignment: .leading, spacing: 6) {
            Label(seen ? lie.title : "Unknown move", systemImage: lie.symbol)
                .font(.fmBody(16))
                .foregroundStyle(.white)
            Text(seen ? lie.blurb : "Clear a level that uses this lie to read the note.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Palette.muted)
            if seen {
                Text(lie.explanation)
                    .font(.fmScript(15))
                    .foregroundStyle(Palette.aqua)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
