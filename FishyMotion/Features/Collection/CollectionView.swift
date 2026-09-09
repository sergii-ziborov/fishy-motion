import SwiftUI

struct CollectionView: View {
    @Environment(AppModel.self) private var model

    private let slots: [ThemeID?] = [
        .classic, .toys, .koi, .robots,
        .ghosts, .jellyfish, nil, nil
    ]

    var body: some View {
        ZStack {
            OceanBackdrop(asset: "CrystalCaveBackground", dim: 0.45)
            VStack(spacing: 0) {
                HStack {
                    Button { model.goHome() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 42, height: 42)
                            .background(Color.white.opacity(0.16), in: Circle())
                    }
                    .accessibilityIdentifier("back-button")
                    Spacer()
                    Text("Collection")
                        .font(.fmDisplay(24))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(countLabel)
                        .font(.fmBody(16))
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(minWidth: 42, alignment: .trailing)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(Array(slots.enumerated()), id: \.offset) { _, theme in
                        cell(theme)
                    }
                }
                .padding(16)

                Button {
                    model.screen = .fishpedia
                } label: {
                    Label("Open Fishpedia", systemImage: "book.fill")
                        .font(.fmBody(15))
                        .foregroundStyle(Palette.aqua)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("fishpedia-button")
                Spacer()
            }
        }
    }

    private var countLabel: String {
        let unlocked = ThemeID.allCases.filter { model.progress.isThemeUnlocked($0) }.count
        return "\(unlocked)/\(ThemeID.allCases.count)"
    }

    @ViewBuilder
    private func cell(_ theme: ThemeID?) -> some View {
        let unlocked = theme.map { model.progress.isThemeUnlocked($0) } ?? false
        Button {
            if let theme, unlocked { model.selectTheme(theme) }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.white.opacity(0.16), lineWidth: 1)
                    )
                    .aspectRatio(1, contentMode: .fit)
                if let theme, unlocked {
                    TimelineView(.animation) { timeline in
                        CreatureView(
                            theme: theme,
                            heading: 0.15,
                            wiggle: 0.2,
                            time: timeline.date.timeIntervalSinceReferenceDate
                        )
                        .padding(8)
                    }
                } else if let theme {
                    CreatureView(theme: theme, heading: 0.12, wiggle: 0)
                        .padding(8)
                        .opacity(0.55)
                        .overlay {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white.opacity(0.45))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(theme.map { "theme-\($0.rawValue)" } ?? "theme-locked")
        .disabled(!unlocked)
    }
}
