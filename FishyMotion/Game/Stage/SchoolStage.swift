import SwiftUI

struct SchoolStage: View {
    var world: WorldID
    var school: School
    var poses: [Pose]
    var time: Double
    var picked: Int?
    var oddIndex: Int
    var phase: PlaySession.Phase
    var hintIndex: Int?
    var onTap: (Int) -> Void

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                Image(world.backgroundAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .overlay(Palette.deep.opacity(0.18))
                    .accessibilityHidden(true)

                BubbleField(time: time)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)

                ForEach(Array(poses.enumerated()), id: \.offset) { index, pose in
                    let x = pose.x * size.width
                    let y = pose.y * size.height
                    Button {
                        onTap(index)
                    } label: {
                        CreatureView(
                            theme: school.theme,
                            heading: pose.heading,
                            wiggle: Darwin.sin(time * 10 + Double(index)),
                            highlighted: picked == index,
                            dimmed: shouldDim(index),
                            ring: ring(for: index)
                        )
                        .frame(width: fishSize(in: size), height: fishSize(in: size))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .ignore)
                    .accessibilityIdentifier("fish-\(index)")
                    .accessibilityLabel(accessibilityName(index))
                    .accessibilityAddTraits(.isButton)
                    .position(x: x, y: y)
                }
            }
            .accessibilityElement(children: .contain)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func fishSize(in size: CGSize) -> CGFloat {
        min(size.width, size.height) * (school.count >= 8 ? 0.16 : 0.19)
    }

    private func shouldDim(_ index: Int) -> Bool {
        switch phase {
        case .explaining, .complete, .correct:
            return index != oddIndex
        case .missed:
            return false
        case .watching:
            return false
        }
    }

    private func ring(for index: Int) -> CreatureView.RingKind {
        if hintIndex == index { return .hint }
        switch phase {
        case .correct, .explaining, .complete:
            return index == oddIndex ? .odd : .none
        case .missed:
            return index == picked ? .miss : .none
        case .watching:
            return .none
        }
    }

    private func nearest(to point: SIMD2<Double>) -> Int? {
        var best: (Int, Double)?
        for (index, pose) in poses.enumerated() {
            let d = hypot(pose.x - point.x, pose.y - point.y)
            if d < 0.15, best == nil || d < best!.1 {
                best = (index, d)
            }
        }
        return best?.0
    }

    private func accessibilityName(_ index: Int) -> String {
        if phase == .watching {
            return "Fish \(index + 1)"
        }
        return index == oddIndex ? "Odd fish" : "Fish \(index + 1)"
    }
}

struct BubbleField: View {
    var time: Double

    var body: some View {
        Canvas { context, size in
            for i in 0..<14 {
                let seed = Double(i) * 17.13
                let x = (0.08 + 0.84 * fract(seed * 0.37)) * size.width
                let speed = 18.0 + Double(i % 5) * 8
                let y = size.height - (time * speed + seed * 40).truncatingRemainder(dividingBy: size.height + 40)
                let r = 2.0 + Double(i % 4)
                let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                context.opacity = 0.28
                context.fill(Path(ellipseIn: rect), with: .color(.white))
            }
        }
        .allowsHitTesting(false)
    }

    private func fract(_ value: Double) -> Double {
        value - floor(value)
    }
}

struct ExplanationStrip: View {
    var lie: LieKind

    var body: some View {
        VStack(spacing: 10) {
            Text(lie.explanation)
                .font(.fmDisplay(20))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("explanation-copy")
            HStack(alignment: .center, spacing: 16) {
                mini(title: "Others", offset: 0)
                Image(systemName: "arrow.right")
                    .foregroundStyle(Palette.aqua)
                mini(title: "The odd one", offset: 0.45, odd: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func mini(title: String, offset: Double, odd: Bool = false) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(odd ? Palette.gold : Palette.aqua)
                        .frame(width: 18, height: 8)
                        .offset(x: CGFloat(i == 2 ? offset * 10 : 0))
                }
            }
            Text(title)
                .font(.fmBody(11))
                .foregroundStyle(Palette.muted)
        }
    }
}
