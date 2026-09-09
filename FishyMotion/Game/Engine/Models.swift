import Foundation

enum PatternKind: String, Codable, CaseIterable, Sendable {
    case weave
    case loop
    case circle
    case figureEight
    case bob
    case surge
}

enum LieKind: String, Codable, CaseIterable, Sendable, Identifiable {
    case turnsEarlier
    case turnsLater
    case slower
    case faster
    case holdsSpeed
    case pauses
    case oppositeTurn
    case phaseLead

    var id: String { rawValue }

    var title: String {
        switch self {
        case .turnsEarlier: "Turns earlier"
        case .turnsLater: "Turns later"
        case .slower: "Moves slower"
        case .faster: "Moves faster"
        case .holdsSpeed: "Holds a steady speed"
        case .pauses: "Pauses unexpectedly"
        case .oppositeTurn: "Turns the other way"
        case .phaseLead: "Leads the cycle"
        }
    }

    var explanation: String {
        switch self {
        case .turnsEarlier: "This one turned earlier."
        case .turnsLater: "This one turned later."
        case .slower: "This one moved a bit slower."
        case .faster: "This one moved a bit faster."
        case .holdsSpeed: "The others surged. This one kept a steady speed."
        case .pauses: "This one paused while the others kept going."
        case .oppositeTurn: "This one turned the other way."
        case .phaseLead: "This one was ahead of the others in the same cycle."
        }
    }

    var blurb: String {
        switch self {
        case .turnsEarlier: "Same path. The corner comes too soon."
        case .turnsLater: "Same path. The corner comes too late."
        case .slower: "Same route, smaller steps."
        case .faster: "Same route, bigger steps."
        case .holdsSpeed: "The school pulses. One fish does not."
        case .pauses: "A hitch at the top of the motion."
        case .oppositeTurn: "The school agrees on a direction. One fish does not."
        case .phaseLead: "Same wave, earlier in the beat."
        }
    }

    var symbol: String {
        switch self {
        case .turnsEarlier: "arrow.uturn.left"
        case .turnsLater: "arrow.uturn.right"
        case .slower: "tortoise.fill"
        case .faster: "hare.fill"
        case .holdsSpeed: "equal.circle.fill"
        case .pauses: "pause.circle.fill"
        case .oppositeTurn: "arrow.triangle.2.circlepath"
        case .phaseLead: "forward.fill"
        }
    }
}

enum ThemeID: String, Codable, CaseIterable, Sendable, Identifiable {
    case classic
    case robots
    case ghosts
    case toys
    case jellyfish
    case koi

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: "Classic"
        case .robots: "Robots"
        case .ghosts: "Ghosts"
        case .toys: "Toys"
        case .jellyfish: "Jellyfish"
        case .koi: "Koi Pond"
        }
    }

    var subtitle: String {
        switch self {
        case .classic: "Same blue tang. Same fins. Watch the motion."
        case .robots: "A conveyor of identical machines. One skips a beat."
        case .ghosts: "They drift together. One lies."
        case .toys: "Wind-up swimmers on the same spring."
        case .jellyfish: "Bells pulse as one. Almost."
        case .koi: "The markings match. The swim does not."
        }
    }

    var starsToUnlock: Int {
        switch self {
        case .classic: 0
        case .robots: 10
        case .ghosts: 18
        case .toys: 26
        case .jellyfish: 34
        case .koi: 44
        }
    }
}

enum WorldID: String, Codable, CaseIterable, Identifiable, Sendable {
    case coral
    case ruins
    case trench
    case crystal
    case alien

    var id: String { rawValue }

    var title: String {
        switch self {
        case .coral: "Coral Reef"
        case .ruins: "Sunken Ruins"
        case .trench: "Deep Sea"
        case .crystal: "Crystal Cave"
        case .alien: "Alien Ocean"
        }
    }

    var subtitle: String {
        switch self {
        case .coral: "Soft light. Honest turns."
        case .ruins: "Columns force a path. One fish cuts it."
        case .trench: "Dark water. Smaller tells."
        case .crystal: "Reflections help if you look twice."
        case .alien: "Same rules. Stranger water."
        }
    }

    var backgroundAsset: String {
        switch self {
        case .coral: "CoralReefBackground"
        case .ruins: "SunkenRuinsBackground"
        case .trench: "DeepTrenchBackground"
        case .crystal: "CrystalCaveBackground"
        case .alien: "AlienOceanBackground"
        }
    }

    var starsToUnlock: Int {
        switch self {
        case .coral: 0
        case .ruins: 8
        case .trench: 16
        case .crystal: 26
        case .alien: 38
        }
    }

    var suggestedTheme: ThemeID {
        switch self {
        case .coral, .ruins: .classic
        case .trench: .jellyfish
        case .crystal: .ghosts
        case .alien: .robots
        }
    }
}

struct LevelDef: Identifiable, Equatable, Sendable {
    var world: WorldID
    var index: Int
    var name: String
    var blurb: String
    var pattern: PatternKind
    var lie: LieKind
    var fishCount: Int
    var period: Double
    var magnitude: Double
    var hints: Int

    var id: String { "\(world.rawValue)-\(index)" }
    var number: Int { index + 1 }
}

struct PlayContext: Equatable, Sendable {
    var world: WorldID
    var levelIndex: Int
    var seed: UInt64
    var isDaily: Bool
    var theme: ThemeID

    var level: LevelDef {
        if isDaily {
            return LevelCatalog.dailyLevel(seed: seed, world: world, index: levelIndex)
        }
        return LevelCatalog.level(world: world, index: levelIndex)
    }
}

struct ProgressState: Codable, Equatable, Sendable {
    var starsByLevel: [String: Int]
    var seenLies: Set<LieKind>
    var unlockedThemes: Set<ThemeID>
    var selectedTheme: ThemeID
    var soundEnabled: Bool
    var musicEnabled: Bool
    var hapticsEnabled: Bool
    var reduceMotion: Bool
    var tutorialSeen: Bool
    var lastDailyClaim: String?
    var totalSolves: Int

    static let fresh = ProgressState(
        starsByLevel: [:],
        seenLies: [],
        unlockedThemes: Set(ThemeID.allCases),
        selectedTheme: .classic,
        soundEnabled: true,
        musicEnabled: true,
        hapticsEnabled: true,
        reduceMotion: false,
        tutorialSeen: false,
        lastDailyClaim: nil,
        totalSolves: 0
    )

    var totalStars: Int { starsByLevel.values.reduce(0, +) }

    func stars(for level: LevelDef) -> Int {
        starsByLevel[level.id] ?? 0
    }

    func isUnlocked(_ world: WorldID) -> Bool {
        totalStars >= world.starsToUnlock
    }

    func isThemeUnlocked(_ theme: ThemeID) -> Bool {
        unlockedThemes.contains(theme) || totalStars >= theme.starsToUnlock
    }

    func clearedCount(in world: WorldID) -> Int {
        LevelCatalog.levels(for: world).filter { (starsByLevel[$0.id] ?? 0) > 0 }.count
    }

    func nextPlayable() -> (WorldID, Int) {
        for world in WorldID.allCases where isUnlocked(world) {
            let levels = LevelCatalog.levels(for: world)
            if let index = levels.firstIndex(where: { (starsByLevel[$0.id] ?? 0) == 0 }) {
                return (world, index)
            }
        }
        return (.coral, 0)
    }

    mutating func record(level: LevelDef, stars: Int, lie: LieKind) {
        let key = level.id
        starsByLevel[key] = max(starsByLevel[key] ?? 0, stars)
        seenLies.insert(lie)
        totalSolves += 1
        for theme in ThemeID.allCases where totalStars >= theme.starsToUnlock {
            unlockedThemes.insert(theme)
        }
    }
}

struct RoundOutcome: Equatable, Sendable {
    var stars: Int
    var points: Int
    var time: TimeInterval
    var hintsUsed: Int
    var attempts: Int
    var lie: LieKind
    var world: WorldID
    var levelIndex: Int
    var isDaily: Bool
    var oddIndex: Int
    var theme: ThemeID
}

enum StarRating {
    static func stars(firstTry: Bool, hintsUsed: Int) -> Int {
        if firstTry && hintsUsed == 0 { return 3 }
        if hintsUsed == 0 { return 2 }
        return 1
    }

    static func points(stars: Int, time: TimeInterval, hintsUsed: Int, firstTry: Bool) -> Int {
        var total = 80 + stars * 40
        if firstTry { total += 50 }
        if hintsUsed == 0 { total += 30 }
        if time < 12 { total += 20 }
        return total
    }
}
