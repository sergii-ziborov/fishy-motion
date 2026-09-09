import SwiftUI

struct WorldsView: View {
    @Environment(AppModel.self) private var model
    @State private var world: WorldID = .coral

    var body: some View {
        ZStack {
            OceanBackdrop(asset: world.backgroundAsset, dim: 0.18)
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
                    Text("Worlds")
                        .font(.fmDisplay(24))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "star.fill")
                        .foregroundStyle(Palette.gold)
                        .frame(width: 42, height: 42)
                        .background(Color.white.opacity(0.16), in: Circle())
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                TabView(selection: $world) {
                    ForEach(WorldID.allCases) { item in
                        worldMap(item)
                            .tag(item)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                worldFooter
                    .padding(.horizontal, 24)
                    .padding(.bottom, 18)
            }
        }
        .onAppear {
            world = WorldID.allCases.first(where: { model.progress.isUnlocked($0) && model.progress.clearedCount(in: $0) < 12 }) ?? .coral
        }
    }

    private func worldMap(_ item: WorldID) -> some View {
        let levels = LevelCatalog.levels(for: item)
        let unlocked = model.progress.isUnlocked(item)
        return GeometryReader { geo in
            ZStack {
                ForEach(Array(levels.enumerated()), id: \.element.id) { index, level in
                    let point = nodePoint(index: index, count: levels.count, in: geo.size)
                    if index > 0 {
                        let prev = nodePoint(index: index - 1, count: levels.count, in: geo.size)
                        Path { path in
                            path.move(to: prev)
                            path.addLine(to: point)
                        }
                        .stroke(.white.opacity(0.85), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    }
                }
                ForEach(Array(levels.enumerated()), id: \.element.id) { index, level in
                    let point = nodePoint(index: index, count: levels.count, in: geo.size)
                    let stars = model.progress.stars(for: level)
                    let open = unlocked && (index == 0 || model.progress.stars(for: levels[index - 1]) > 0 || stars > 0)
                    Button {
                        if open { model.play(world: item, index: level.index) }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(open ? Palette.ocean : Color.white.opacity(0.18))
                                .frame(width: 44, height: 44)
                                .overlay(Circle().stroke(.white, lineWidth: 3))
                            if open {
                                Text("\(level.number)")
                                    .font(.fmBody(16))
                                    .foregroundStyle(.white)
                            } else {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .position(point)
                    .accessibilityIdentifier("level-\(item.rawValue)-\(level.index)")
                    .disabled(!open)
                }
            }
        }
        .padding(.horizontal, 12)
    }

    private var worldFooter: some View {
        let levels = LevelCatalog.levels(for: world)
        let stars = levels.reduce(0) { $0 + model.progress.stars(for: $1) }
        let cap = levels.count * 3
        return VStack(spacing: 4) {
            Text(world.title)
                .font(.fmDisplay(20))
                .foregroundStyle(.white)
            Label("\(stars)/\(cap)", systemImage: "star.fill")
                .font(.fmBody(14))
                .foregroundStyle(Palette.gold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.14), in: Capsule())
    }

    private func nodePoint(index: Int, count: Int, in size: CGSize) -> CGPoint {
        let t = count <= 1 ? 0 : Double(index) / Double(count - 1)
        let x = size.width * (0.50 + 0.28 * sin(t * .pi * 3.1))
        let y = size.height * (0.90 - 0.80 * t)
        return CGPoint(x: x, y: y)
    }
}
