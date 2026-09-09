import SwiftUI

struct ResultView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if let outcome = model.lastOutcome {
            ZStack {
                OceanBackdrop(asset: outcome.world.backgroundAsset, dim: 0.28)
                VStack(spacing: 18) {
                    Spacer()
                    StarRow(stars: outcome.stars, size: 36)
                    Text("Correct!")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundStyle(Palette.success)
                        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                        .accessibilityIdentifier("result-title")
                    Text(outcome.lie.explanation)
                        .font(.fmBody(18))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)

                    ZStack {
                        Circle()
                            .stroke(Palette.aqua.opacity(0.55), lineWidth: 4)
                            .frame(width: 168, height: 168)
                        TimelineView(.animation) { timeline in
                            CreatureView(
                                theme: outcome.theme,
                                heading: 0.18,
                                wiggle: 0.35,
                                time: timeline.date.timeIntervalSinceReferenceDate,
                                ring: .odd
                            )
                            .frame(width: 150, height: 150)
                        }
                    }
                    .padding(.vertical, 8)

                    FMButton(
                        title: outcome.isDaily ? "Home" : "Next Level",
                        kind: .success
                    ) {
                        if outcome.isDaily {
                            model.goHome()
                        } else {
                            model.nextLevel()
                        }
                    }
                    .padding(.horizontal, 36)
                    .accessibilityIdentifier("next-level-button")

                    HStack(spacing: 10) {
                        quiet("Replay", icon: "arrow.counterclockwise") { model.retry() }
                        quiet("Worlds", icon: "map.fill") { model.screen = .worlds }
                        quiet("Home", icon: "house.fill") { model.goHome() }
                    }
                    .padding(.horizontal, 28)
                    Spacer()
                }
            }
        } else {
            Palette.deep.onAppear { model.goHome() }
        }
    }

    private func quiet(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .font(.fmBody(12))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
