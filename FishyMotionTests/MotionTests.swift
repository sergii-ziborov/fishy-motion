import Foundation
import Testing
@testable import FishyMotion

struct MotionTests {
    @Test("Exactly one fish is odd, and every fish shares the theme")
    func oneOddSameLook() {
        let level = LevelCatalog.level(world: .coral, index: 1)
        let school = SchoolBuilder.build(level: level, seed: 42, theme: .classic)
        #expect(school.fish.filter(\.isOdd).count == 1)
        #expect(school.fish[school.oddIndex].isOdd)
        #expect(school.theme == .classic)
        #expect(Set(school.fish.map(\.id)).count == school.count)
    }

    @Test("Forced odd index is respected")
    func forcedOdd() {
        let level = LevelCatalog.level(world: .coral, index: 0)
        let school = SchoolBuilder.build(level: level, seed: 9, theme: .robots, forceOdd: 0)
        #expect(school.oddIndex == 0)
        #expect(school.theme == .robots)
    }

    @Test("The same seed always picks the same liar")
    func seedStable() {
        let level = LevelCatalog.level(world: .ruins, index: 3)
        let a = SchoolBuilder.build(level: level, seed: 1_001, theme: .classic)
        let b = SchoolBuilder.build(level: level, seed: 1_001, theme: .classic)
        #expect(a.oddIndex == b.oddIndex)
        #expect(a.poses(at: 1.3) == b.poses(at: 1.3))
    }

    @Test("Odd motion actually diverges from the group")
    func lieChangesParams() {
        let base = Motion.baseParams(pattern: .loop, period: 3.2)
        let early = Motion.apply(lie: .turnsEarlier, magnitude: 1, period: 3.2, base: base)
        let late = Motion.apply(lie: .turnsLater, magnitude: 1, period: 3.2, base: base)
        let slow = Motion.apply(lie: .slower, magnitude: 1, period: 3.2, base: base)
        #expect(early.corner > base.corner)
        #expect(late.corner < base.corner)
        #expect(slow.speed < base.speed)
        #expect(Motion.apply(lie: .oppositeTurn, magnitude: 1, period: 3, base: base).reverse)
        #expect(Motion.apply(lie: .holdsSpeed, magnitude: 1, period: 3, base: Motion.baseParams(pattern: .surge, period: 3)).surge == 0)
    }

    @Test("Poses stay on the arena")
    func posesOnArena() {
        let level = LevelCatalog.level(world: .coral, index: 1)
        let school = SchoolBuilder.build(level: level, seed: 3, theme: .classic)
        for i in 0..<20 {
            let t = Double(i) * 0.25
            for pose in school.poses(at: t) {
                #expect(pose.x > 0.02 && pose.x < 0.98)
                #expect(pose.y > 0.02 && pose.y < 0.98)
                #expect(pose.heading.isFinite)
            }
        }
    }

    @Test("Every catalog level has a readable tell")
    func catalogIsFair() {
        var failures: [String] = []
        for world in WorldID.allCases {
            for level in LevelCatalog.levels(for: world) {
                let school = SchoolBuilder.build(level: level, seed: 77, theme: .classic)
                let sep = Detectability.maxSeparation(school: school)
                if sep < Detectability.minimumSeparation {
                    failures.append("\(level.id) sep=\(String(format: "%.3f", sep)) lie=\(level.lie.rawValue)")
                }
            }
        }
        #expect(failures.isEmpty, "Unreadable levels: \(failures.joined(separator: ", "))")
    }

    @Test("Stars prefer a clean first look over speed")
    func starPolicy() {
        #expect(StarRating.stars(firstTry: true, hintsUsed: 0) == 3)
        #expect(StarRating.stars(firstTry: false, hintsUsed: 0) == 2)
        #expect(StarRating.stars(firstTry: true, hintsUsed: 1) == 1)
        #expect(StarRating.points(stars: 3, time: 20, hintsUsed: 0, firstTry: true) >
                StarRating.points(stars: 1, time: 4, hintsUsed: 2, firstTry: false))
    }

    @Test("World unlocks are star gates")
    func unlocks() {
        var progress = ProgressState.fresh
        #expect(progress.isUnlocked(.coral))
        #expect(!progress.isUnlocked(.ruins))
        progress.starsByLevel["coral-0"] = 3
        progress.starsByLevel["coral-1"] = 3
        progress.starsByLevel["coral-2"] = 3
        #expect(progress.totalStars == 9)
        #expect(progress.isUnlocked(.ruins))
        #expect(!progress.isUnlocked(.trench))
    }

    @Test("Daily stamp is stable for a given day")
    func dailyStable() {
        let date = Date(timeIntervalSince1970: 1_778_025_600)
        let a = LevelCatalog.daily(on: date, unlocked: WorldID.allCases)
        let b = LevelCatalog.daily(on: date, unlocked: WorldID.allCases)
        #expect(a == b)
    }

    @Test("Nearest fish prefers the closest center")
    @MainActor
    func nearestFish() throws {
        let context = PlayContext(world: .coral, levelIndex: 0, seed: 5, isDaily: false, theme: .classic)
        let session = PlaySession(context: context, forceOdd: 0)
        let poses = session.school.poses(at: 0.4)
        let odd = poses[0]
        let found = session.nearestFish(normalized: SIMD2(odd.x, odd.y), time: 0.4)
        #expect(found == 0)
    }

    @Test("Recording a solve unlocks the lie in the collection")
    func recordsLie() {
        var progress = ProgressState.fresh
        let level = LevelCatalog.level(world: .coral, index: 1)
        progress.record(level: level, stars: 3, lie: .turnsEarlier)
        #expect(progress.seenLies.contains(.turnsEarlier))
        #expect(progress.stars(for: level) == 3)
        progress.record(level: level, stars: 1, lie: .turnsEarlier)
        #expect(progress.stars(for: level) == 3)
    }
}
