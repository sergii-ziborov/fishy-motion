import SwiftUI

struct TutorialView: View {
    @Environment(AppModel.self) private var model
    @State private var page = 0

    private let pages: [(String, String, String)] = [
        ("eye.fill", "Watch how they move", "A small school follows one visible rule. Give it a moment."),
        ("person.3.fill", "They look the same", "Color is not a clue. Size is not a clue. The liar is in the motion."),
        ("hand.tap.fill", "Tap the odd one", "After you answer, the game shows what was different.")
    ]

    var body: some View {
        ZStack {
            OceanBackdrop(asset: "CoralReefBackground", dim: 0.5)
            VStack(spacing: 22) {
                ScreenHeader(title: "How to play") { model.goHome() }

                Spacer()

                let item = pages[page]
                Image(systemName: item.0)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(Palette.aqua)
                    .frame(width: 88, height: 88)
                    .background(Color.white.opacity(0.10), in: Circle())

                Text(item.1)
                    .font(.fmDisplay(28))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(item.2)
                    .font(.fmBody(16))
                    .foregroundStyle(Palette.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                demoSchool
                    .frame(height: 180)
                    .padding(.horizontal, 20)

                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == page ? Palette.play : Color.white.opacity(0.25))
                            .frame(width: index == page ? 22 : 8, height: 8)
                    }
                }

                FMButton(
                    title: page == pages.count - 1 ? "Start swimming" : "Next",
                    kind: .play,
                    icon: page == pages.count - 1 ? "play.fill" : "arrow.right"
                ) {
                    if page == pages.count - 1 {
                        model.finishTutorial()
                    } else {
                        page += 1
                    }
                }
                .padding(.horizontal, 28)
                .accessibilityIdentifier("tutorial-next")
            }
            .padding(.bottom, 24)
        }
    }

    private var demoSchool: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let level = LevelCatalog.level(world: .coral, index: 0)
            let school = SchoolBuilder.build(level: level, seed: 7, theme: .classic, forceOdd: 2)
            let poses = school.poses(at: t)
            SchoolStage(
                world: .coral,
                school: school,
                poses: poses,
                time: t,
                picked: page == 2 ? 2 : nil,
                oddIndex: 2,
                phase: page == 2 ? .correct : .watching,
                hintIndex: nil,
                onTap: { _ in }
            )
        }
    }
}
