import Foundation
import SwiftUI

enum Screen: Equatable {
    case home
    case tutorial
    case play
    case result
    case worlds
    case collection
    case daily
    case settings
    case fishpedia
    case hints
}

@MainActor
@Observable
final class AppModel {
    var screen: Screen = .home
    var progress: ProgressState
    var session: PlaySession?
    var lastOutcome: RoundOutcome?

    private let store: ProgressStore

    init(store: ProgressStore = ProgressStore()) {
        self.store = store
        var loaded = store.load()
        loaded.unlockedThemes.formUnion(ThemeID.allCases)
        if ProcessInfo.processInfo.arguments.contains(where: {
            $0 == "ui-testing" || $0 == "auto-play" || $0 == "-auto-play"
        }) {
            loaded.tutorialSeen = true
        }
        self.progress = loaded
    }

    var uiTesting: Bool {
        ProcessInfo.processInfo.arguments.contains("ui-testing")
    }

    func playTapped() {
        if !progress.tutorialSeen {
            screen = .tutorial
            return
        }
        let next = progress.nextPlayable()
        startPlay(world: next.0, index: next.1, daily: false)
    }

    func finishTutorial() {
        progress.tutorialSeen = true
        saveProgress()
        startPlay(world: .coral, index: 0, daily: false)
    }

    func playDaily() {
        let unlocked = WorldID.allCases.filter { progress.isUnlocked($0) }
        let pick = LevelCatalog.daily(unlocked: unlocked)
        startPlay(world: pick.0, index: pick.1, daily: true, seed: pick.2)
    }

    func play(world: WorldID, index: Int) {
        guard progress.isUnlocked(world) else { return }
        startPlay(world: world, index: index, daily: false)
    }

    func retry() {
        guard let session else { return }
        startPlay(
            world: session.context.world,
            index: session.context.levelIndex,
            daily: session.context.isDaily,
            seed: session.context.isDaily ? session.context.seed : nil
        )
    }

    func nextLevel() {
        guard let session else {
            screen = .home
            return
        }
        if session.context.isDaily {
            goHome()
            return
        }
        if let next = LevelCatalog.next(after: session.context), progress.isUnlocked(next.0) {
            startPlay(world: next.0, index: next.1, daily: false)
        } else {
            screen = .worlds
            self.session = nil
        }
    }

    func finishRound() {
        guard let session else { return }
        guard session.phase == .correct || session.phase == .explaining || session.phase == .complete else { return }
        session.phase = .complete
        let firstTry = session.attempts <= 1
        let stars = StarRating.stars(firstTry: firstTry, hintsUsed: session.hintsUsed)
        let points = StarRating.points(
            stars: stars,
            time: session.elapsed,
            hintsUsed: session.hintsUsed,
            firstTry: firstTry
        )
        let level = session.context.level
        if !session.context.isDaily {
            progress.record(level: level, stars: stars, lie: session.school.lie)
        } else {
            progress.seenLies.insert(session.school.lie)
            let stamp = DailyStamp.today
            if progress.lastDailyClaim != stamp {
                progress.lastDailyClaim = stamp
                progress.totalSolves += 1
            }
        }
        store.save(progress)
        lastOutcome = RoundOutcome(
            stars: stars,
            points: points,
            time: session.elapsed,
            hintsUsed: session.hintsUsed,
            attempts: session.attempts,
            lie: session.school.lie,
            world: session.context.world,
            levelIndex: session.context.levelIndex,
            isDaily: session.context.isDaily,
            oddIndex: session.school.oddIndex,
            theme: session.context.theme
        )
        if progress.hapticsEnabled {
            Feedback.success()
        }
        screen = .result
    }

    func selectTheme(_ theme: ThemeID) {
        guard progress.isThemeUnlocked(theme) else { return }
        progress.selectedTheme = theme
        saveProgress()
    }

    func saveProgress() {
        store.save(progress)
    }

    func resetProgress() {
        progress = .fresh
        if uiTesting { progress.tutorialSeen = true }
        store.save(progress)
    }

    func goHome() {
        session = nil
        lastOutcome = nil
        screen = .home
    }

    private func startPlay(world: WorldID, index: Int, daily: Bool, seed: UInt64? = nil) {
        let context = PlayContext(
            world: world,
            levelIndex: index,
            seed: seed ?? UInt64.random(in: 1...UInt64.max),
            isDaily: daily,
            theme: progress.selectedTheme
        )
        let forceOdd = uiTesting ? 0 : nil
        session = PlaySession(context: context, forceOdd: forceOdd)
        lastOutcome = nil
        screen = .play
    }
}

enum DailyStamp {
    static var today: String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let c = calendar.dateComponents([.year, .month, .day], from: Date())
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }
}

@MainActor
@Observable
final class PlaySession {
    let context: PlayContext
    let school: School
    let startedAt: Date
    var phase: Phase = .watching
    var pickedIndex: Int?
    var hintsUsed: Int = 0
    var attempts: Int = 0
    var tapTime: Double = 0
    var hintUntil: Date?
    var frozenTime: Double = 0
    var elapsed: TimeInterval = 0

    enum Phase: Equatable {
        case watching
        case correct
        case missed
        case explaining
        case complete
    }

    init(context: PlayContext, forceOdd: Int? = nil) {
        self.context = context
        self.school = SchoolBuilder.build(
            level: context.level,
            seed: context.seed,
            theme: context.theme,
            forceOdd: forceOdd
        )
        self.startedAt = Date()
    }

    var level: LevelDef { context.level }
    var hintsLeft: Int { max(0, level.hints - hintsUsed) }
    var tellTime: Double { school.tellTime() }

    func displayTime(now: Date) -> Double {
        switch phase {
        case .watching:
            return now.timeIntervalSince(startedAt)
        case .correct, .missed, .complete:
            return frozenTime
        case .explaining:
            return tellTime + Darwin.sin(now.timeIntervalSince(startedAt) * 0.85) * (school.period * 0.22)
        }
    }

    func tapFish(index: Int, now: Date) {
        guard phase == .watching || phase == .missed else { return }
        let t = now.timeIntervalSince(startedAt)
        elapsed = t
        frozenTime = t
        pickedIndex = index
        attempts += 1
        if index == school.oddIndex {
            phase = .correct
        } else {
            phase = .missed
        }
    }

    func useHint(now: Date) {
        guard hintsLeft > 0, phase == .watching || phase == .missed else { return }
        hintsUsed += 1
        hintUntil = now.addingTimeInterval(1.6)
        if phase == .missed {
            phase = .watching
            pickedIndex = nil
        }
    }

    func beginExplanation() {
        guard phase == .correct else { return }
        phase = .explaining
    }

    func completeFromExplanation() {
        guard phase == .explaining || phase == .correct else { return }
        phase = .complete
    }

    func nearestFish(normalized: SIMD2<Double>, time: Double) -> Int? {
        let poses = school.poses(at: time)
        var best: (Int, Double)?
        for (index, pose) in poses.enumerated() {
            let d = hypot(pose.x - normalized.x, pose.y - normalized.y)
            if d < 0.14, best == nil || d < best!.1 {
                best = (index, d)
            }
        }
        return best?.0
    }
}
