import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            OceanBackdrop(asset: "CoralReefBackground", dim: 0.22)
            VStack(spacing: 18) {
                Spacer(minLength: 24)
                title
                playCircle
                    .padding(.vertical, 8)
                VStack(spacing: 12) {
                    stackButton("Worlds", id: "worlds-button") { model.screen = .worlds }
                    stackButton("Daily Puzzle", id: "daily-button") { model.screen = .daily }
                    stackButton("Collection", id: "collection-button") { model.screen = .collection }
                    stackButton("Settings", id: "settings-button") { model.screen = .settings }
                }
                .padding(.horizontal, 28)

                HStack(spacing: 0) {
                    dock("trophy.fill", "collection-dock") { model.screen = .collection }
                    dock("calendar", "daily-dock") { model.screen = .daily }
                    dock("gearshape.fill", "settings-dock") { model.screen = .settings }
                }
                .padding(6)
                .background(Color.white.opacity(0.12), in: Capsule())
                .padding(.horizontal, 36)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
        }
    }

    private var title: some View {
        VStack(spacing: -4) {
            Text("Fishy")
            Text("Motion")
        }
        .font(.system(size: 52, weight: .heavy, design: .rounded))
        .foregroundStyle(.white)
        .shadow(color: Palette.oceanDeep.opacity(0.7), radius: 0, x: 0, y: 3)
        .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("home-title")
        .accessibilityLabel("Fishy Motion")
    }

    private var playCircle: some View {
        Button {
            model.playTapped()
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.40, green: 0.78, blue: 1.0), Palette.ocean],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 108, height: 108)
                    .shadow(color: Palette.ocean.opacity(0.45), radius: 16, y: 8)
                Circle()
                    .stroke(.white.opacity(0.85), lineWidth: 6)
                    .frame(width: 108, height: 108)
                Image(systemName: "play.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(x: 4)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("play-button")
        .accessibilityLabel("Play")
    }

    private func stackButton(_ title: String, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.fmBody(20))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Palette.ocean, Palette.oceanDeep],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    in: Capsule()
                )
                .overlay(Capsule().stroke(.white.opacity(0.28), lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
    }

    private func dock(_ icon: String, _ id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
    }
}
