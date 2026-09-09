import SwiftUI

struct PlayView: View {
    @Environment(AppModel.self) private var model
    @State private var showPause = false

    var body: some View {
        if let session = model.session {
            TimelineView(.animation) { timeline in
                let now = timeline.date
                let raw = session.displayTime(now: now)
                let time = model.progress.reduceMotion ? raw * 0.45 : raw
                let poses = session.school.poses(at: time)
                let hinting = session.hintUntil.map { now < $0 } ?? false
                content(session: session, time: time, poses: poses, hinting: hinting, now: now)
            }
        } else {
            Palette.deep.onAppear { model.goHome() }
        }
    }

    @ViewBuilder
    private func content(
        session: PlaySession,
        time: Double,
        poses: [Pose],
        hinting: Bool,
        now: Date
    ) -> some View {
        ZStack {
            OceanBackdrop(asset: session.context.world.backgroundAsset, dim: 0.12)

            VStack(spacing: 8) {
                hud(session: session)
                SchoolStage(
                    world: session.context.world,
                    school: session.school,
                    poses: poses,
                    time: time,
                    picked: session.pickedIndex,
                    oddIndex: session.school.oddIndex,
                    phase: session.phase,
                    hintIndex: hinting ? session.school.oddIndex : nil
                ) { index in
                    handleTap(index, session: session, now: now)
                }
                .padding(.horizontal, 8)
                .frame(maxHeight: .infinity)
            }
            .padding(.bottom, 12)

            if session.phase == .missed {
                missOverlay(session: session)
            }
            if showPause {
                pauseOverlay
            }

            if model.uiTesting {
                testHarness(session: session, now: now)
            }
        }
        .onChange(of: session.phase) { _, phase in
            if phase == .correct {
                if model.progress.hapticsEnabled { Feedback.success() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    if model.session?.phase == .correct {
                        model.finishRound()
                    }
                }
            } else if phase == .missed {
                if model.progress.hapticsEnabled { Feedback.miss() }
            }
        }
    }

    private func hud(session: PlaySession) -> some View {
        HStack {
            Button {
                showPause = true
            } label: {
                Image(systemName: "pause.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.16), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 2))
            }
            .accessibilityIdentifier("pause-button")

            Spacer()
            VStack(spacing: 4) {
                Text("Level \(session.level.number)")
                    .font(.fmDisplay(22))
                    .foregroundStyle(.white)
                    .accessibilityIdentifier("prompt-title")
                StarRow(stars: 0, size: 18)
            }
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func missOverlay(session: PlaySession) -> some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 16) {
                StarRow(stars: 0, size: 28)
                Text("Not quite!")
                    .font(.fmDisplay(36))
                    .foregroundStyle(Palette.danger)
                Text("All these fish move the same.\nLook closer!")
                    .font(.fmBody(16))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                FMButton(title: "Try Again", kind: .ocean, icon: nil) {
                    session.phase = .watching
                    session.pickedIndex = nil
                }
                .accessibilityIdentifier("try-again-button")
                Button {
                    if model.progress.hapticsEnabled { Feedback.hint() }
                    session.useHint(now: Date())
                } label: {
                    Label("Hint \(session.hintsLeft)", systemImage: "lightbulb.fill")
                        .font(.fmBody(18))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.12), in: Capsule())
                }
                .buttonStyle(.plain)
                .disabled(session.hintsLeft == 0)
                .accessibilityIdentifier("hint-button")
            }
            .padding(24)
            .background(Palette.navyCard.opacity(0.94), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(22)
        }
    }

    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 14) {
                Text("Paused")
                    .font(.fmDisplay(28))
                    .foregroundStyle(.white)
                FMButton(title: "Resume", kind: .ocean) { showPause = false }
                FMButton(title: "Hints", kind: .quiet, icon: "lightbulb.fill") {
                    showPause = false
                    model.screen = .hints
                }
                FMButton(title: "Retry", kind: .quiet, icon: "arrow.counterclockwise") {
                    showPause = false
                    model.retry()
                }
                FMButton(title: "Home", kind: .quiet, icon: "house.fill") {
                    showPause = false
                    model.goHome()
                }
            }
            .padding(24)
            .background(Palette.navyCard, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(28)
        }
    }

    private func testHarness(session: PlaySession, now: Date) -> some View {
        VStack {
            Spacer()
            HStack {
                ForEach(0..<session.school.count, id: \.self) { index in
                    Button("fish-\(index)") {
                        handleTap(index, session: session, now: now)
                    }
                    .font(.system(size: 1))
                    .foregroundStyle(.clear)
                    .accessibilityIdentifier("fish-\(index)")
                    .accessibilityLabel("Fish \(index + 1)")
                }
            }
            .frame(height: 8)
        }
        .allowsHitTesting(true)
    }

    private func handleTap(_ index: Int, session: PlaySession, now: Date) {
        guard session.phase == .watching || session.phase == .missed else { return }
        if model.progress.hapticsEnabled { Feedback.tap() }
        session.tapFish(index: index, now: now)
    }
}
