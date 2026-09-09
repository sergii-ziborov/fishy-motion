import Foundation

enum LevelCatalog {
    static func levels(for world: WorldID) -> [LevelDef] {
        switch world {
        case .coral: coral
        case .ruins: ruins
        case .trench: trench
        case .crystal: crystal
        case .alien: alien
        }
    }

    static func level(world: WorldID, index: Int) -> LevelDef {
        let list = levels(for: world)
        return list[min(max(0, index), list.count - 1)]
    }

    static func next(after context: PlayContext) -> (WorldID, Int)? {
        let list = levels(for: context.world)
        let nextIndex = context.levelIndex + 1
        if nextIndex < list.count {
            return (context.world, nextIndex)
        }
        if let worldIndex = WorldID.allCases.firstIndex(of: context.world),
           worldIndex + 1 < WorldID.allCases.count
        {
            return (WorldID.allCases[worldIndex + 1], 0)
        }
        return nil
    }

    static func dailyLevel(seed: UInt64, world: WorldID, index: Int) -> LevelDef {
        var rng = SeededRNG(seed: seed)
        let base = level(world: world, index: index)
        let lies: [LieKind] = [.turnsEarlier, .slower, .pauses, .phaseLead, .holdsSpeed, .faster, .turnsLater, .oppositeTurn]
        let patterns: [PatternKind] = [.loop, .weave, .circle, .bob, .surge, .figureEight]
        let lie = rng.pick(lies)
        let pattern = patternMatching(lie, fallback: rng.pick(patterns))
        return LevelDef(
            world: world,
            index: index,
            name: "Daily current",
            blurb: "Same fish. One of them is lying today.",
            pattern: pattern,
            lie: lie,
            fishCount: 6,
            period: 3.1,
            magnitude: 0.88,
            hints: 2
        )
    }

    static func daily(on date: Date = Date(), unlocked: [WorldID]) -> (WorldID, Int, UInt64) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let day = calendar.ordinality(of: .day, in: .era, for: date) ?? 1
        let seed = UInt64(day) &* 1_000_003 &+ 29
        var rng = SeededRNG(seed: seed)
        let worlds = unlocked.isEmpty ? [WorldID.coral] : unlocked
        let world = worlds[rng.nextInt(in: 0...(worlds.count - 1))]
        let count = max(levels(for: world).count, 1)
        let index = rng.nextInt(in: 0...(count - 1))
        return (world, index, seed)
    }

    private static func patternMatching(_ lie: LieKind, fallback: PatternKind) -> PatternKind {
        switch lie {
        case .turnsEarlier, .turnsLater, .oppositeTurn: .loop
        case .holdsSpeed: .surge
        case .pauses: .bob
        case .slower, .faster, .phaseLead: fallback == .surge ? .weave : fallback
        }
    }

    private static func make(
        _ world: WorldID,
        _ index: Int,
        _ name: String,
        _ blurb: String,
        pattern: PatternKind,
        lie: LieKind,
        magnitude: Double = 1.0,
        fish: Int = 6,
        period: Double = 3.2,
        hints: Int = 2
    ) -> LevelDef {
        LevelDef(
            world: world,
            index: index,
            name: name,
            blurb: blurb,
            pattern: pattern,
            lie: lie,
            fishCount: fish,
            period: period,
            magnitude: magnitude,
            hints: hints
        )
    }

    private static let coral: [LevelDef] = [
        make(.coral, 0, "First current", "Watch the school. One fish is slower.", pattern: .weave, lie: .slower, magnitude: 1.0, period: 3.4, hints: 3),
        make(.coral, 1, "Early turn", "They turn together. One jumps the corner.", pattern: .loop, lie: .turnsEarlier, magnitude: 1.0, period: 3.6, hints: 3),
        make(.coral, 2, "A hitch", "The bob is even. Then it isn’t.", pattern: .bob, lie: .pauses, magnitude: 1.0, period: 2.8, hints: 2),
        make(.coral, 3, "Ahead of the beat", "Same circle. One is early.", pattern: .circle, lie: .phaseLead, magnitude: 0.95, period: 3.2, hints: 2),
        make(.coral, 4, "No surge", "The school pulses. One holds speed.", pattern: .surge, lie: .holdsSpeed, magnitude: 1.0, period: 3.0, hints: 2),
        make(.coral, 5, "Late corner", "The others lean in. This one overshoots.", pattern: .loop, lie: .turnsLater, magnitude: 0.95, period: 3.5, hints: 2),
        make(.coral, 6, "Quick one", "Same weave. One is in a hurry.", pattern: .weave, lie: .faster, magnitude: 0.92, period: 3.2, hints: 2),
        make(.coral, 7, "Other way", "The loop agrees. One disagrees.", pattern: .loop, lie: .oppositeTurn, magnitude: 0.95, period: 3.6, hints: 2),
        make(.coral, 8, "Eight shape", "A figure eight, slightly led.", pattern: .figureEight, lie: .phaseLead, magnitude: 0.88, period: 3.4, hints: 2),
        make(.coral, 9, "Soft lag", "Still slower. Less obvious.", pattern: .circle, lie: .slower, magnitude: 0.78, period: 3.1, hints: 2),
        make(.coral, 10, "Tight corner", "The early turn is smaller now.", pattern: .loop, lie: .turnsEarlier, magnitude: 0.72, period: 3.3, hints: 1),
        make(.coral, 11, "Reef exam", "A quiet pause in a busy bob.", pattern: .bob, lie: .pauses, magnitude: 0.70, period: 2.7, hints: 1),
    ]

    private static let ruins: [LevelDef] = [
        make(.ruins, 0, "Column walk", "The stones force a loop. One cuts it.", pattern: .loop, lie: .turnsEarlier, magnitude: 0.92, period: 3.4, hints: 2),
        make(.ruins, 1, "Slow mosaic", "A weave between pillars.", pattern: .weave, lie: .slower, magnitude: 0.88, period: 3.2, hints: 2),
        make(.ruins, 2, "Held pace", "The school surges in the arch.", pattern: .surge, lie: .holdsSpeed, magnitude: 0.95, period: 3.0, hints: 2),
        make(.ruins, 3, "Wrong door", "Everyone turns with the ruin. One doesn’t.", pattern: .loop, lie: .oppositeTurn, magnitude: 0.90, period: 3.5, hints: 2),
        make(.ruins, 4, "Late step", "A delayed corner on the floor.", pattern: .loop, lie: .turnsLater, magnitude: 0.85, period: 3.4, hints: 2),
        make(.ruins, 5, "Circle of stone", "One leads the orbit.", pattern: .circle, lie: .phaseLead, magnitude: 0.82, period: 3.1, hints: 2),
        make(.ruins, 6, "Hitch in the nave", "A pause under the arch.", pattern: .bob, lie: .pauses, magnitude: 0.82, period: 2.8, hints: 2),
        make(.ruins, 7, "Faster ghost", "Same eight, quicker fish.", pattern: .figureEight, lie: .faster, magnitude: 0.80, period: 3.3, hints: 1),
        make(.ruins, 8, "Quiet lag", "The weave is almost honest.", pattern: .weave, lie: .slower, magnitude: 0.70, fish: 6, period: 3.1, hints: 1),
        make(.ruins, 9, "Rush hour", "A faster loop through rubble.", pattern: .loop, lie: .faster, magnitude: 0.74, period: 3.2, hints: 1),
        make(.ruins, 10, "Steady liar", "Surge again, smaller tell.", pattern: .surge, lie: .holdsSpeed, magnitude: 0.72, period: 2.9, hints: 1),
        make(.ruins, 11, "Last column", "Early turn, eight fish.", pattern: .loop, lie: .turnsEarlier, magnitude: 0.68, fish: 8, period: 3.4, hints: 1),
    ]

    private static let trench: [LevelDef] = [
        make(.trench, 0, "Dark pulse", "Bells should pulse together.", pattern: .bob, lie: .pauses, magnitude: 0.88, period: 2.9, hints: 2),
        make(.trench, 1, "Cold orbit", "A slow circle in indigo.", pattern: .circle, lie: .slower, magnitude: 0.82, period: 3.2, hints: 2),
        make(.trench, 2, "Lead current", "Someone is early in the eight.", pattern: .figureEight, lie: .phaseLead, magnitude: 0.80, period: 3.3, hints: 2),
        make(.trench, 3, "Wall turn", "The trench walls make a loop.", pattern: .loop, lie: .turnsLater, magnitude: 0.78, period: 3.5, hints: 2),
        make(.trench, 4, "No pulse", "A surge with one honest machine.", pattern: .surge, lie: .holdsSpeed, magnitude: 0.80, period: 3.0, hints: 2),
        make(.trench, 5, "Against the wall", "Opposite turn in the dark.", pattern: .loop, lie: .oppositeTurn, magnitude: 0.78, period: 3.5, hints: 1),
        make(.trench, 6, "Quick flicker", "Faster weave.", pattern: .weave, lie: .faster, magnitude: 0.72, period: 3.1, hints: 1),
        make(.trench, 7, "Early flake", "A smaller early corner.", pattern: .loop, lie: .turnsEarlier, magnitude: 0.68, fish: 8, period: 3.3, hints: 1),
        make(.trench, 8, "Hitch again", "Pause, eight bodies.", pattern: .bob, lie: .pauses, magnitude: 0.66, fish: 8, period: 2.7, hints: 1),
        make(.trench, 9, "Lagging light", "Slow circle, tighter.", pattern: .circle, lie: .slower, magnitude: 0.64, fish: 8, period: 3.0, hints: 1),
        make(.trench, 10, "Phase flake", "Lead the eight, barely.", pattern: .figureEight, lie: .phaseLead, magnitude: 0.62, period: 3.2, hints: 1),
        make(.trench, 11, "Bottom exam", "Late turn in a crowd.", pattern: .loop, lie: .turnsLater, magnitude: 0.60, fish: 8, period: 3.4, hints: 1),
    ]

    private static let crystal: [LevelDef] = [
        make(.crystal, 0, "Glass loop", "Corners shine if you watch.", pattern: .loop, lie: .turnsEarlier, magnitude: 0.80, period: 3.4, hints: 2),
        make(.crystal, 1, "Prism bob", "A hitch in the sparkle.", pattern: .bob, lie: .pauses, magnitude: 0.78, period: 2.8, hints: 2),
        make(.crystal, 2, "Steady facet", "The others surge. One does not.", pattern: .surge, lie: .holdsSpeed, magnitude: 0.78, period: 3.0, hints: 2),
        make(.crystal, 3, "Mirror eight", "Someone leads the knot.", pattern: .figureEight, lie: .phaseLead, magnitude: 0.74, period: 3.3, hints: 2),
        make(.crystal, 4, "Wrong facet", "Opposite turn on crystal.", pattern: .circle, lie: .oppositeTurn, magnitude: 0.76, period: 3.1, hints: 1),
        make(.crystal, 5, "Slow gleam", "A slower weave.", pattern: .weave, lie: .slower, magnitude: 0.70, period: 3.1, hints: 1),
        make(.crystal, 6, "Late spark", "Late corner, eight fish.", pattern: .loop, lie: .turnsLater, magnitude: 0.66, fish: 8, period: 3.4, hints: 1),
        make(.crystal, 7, "Quick vein", "Faster orbit.", pattern: .circle, lie: .faster, magnitude: 0.66, period: 3.0, hints: 1),
        make(.crystal, 8, "Held again", "Surge, smaller pulse.", pattern: .surge, lie: .holdsSpeed, magnitude: 0.64, fish: 8, period: 2.9, hints: 1),
        make(.crystal, 9, "Soft hitch", "A shorter pause.", pattern: .bob, lie: .pauses, magnitude: 0.60, fish: 8, period: 2.6, hints: 1),
        make(.crystal, 10, "Early gleam", "Early turn, quieter.", pattern: .loop, lie: .turnsEarlier, magnitude: 0.58, fish: 8, period: 3.3, hints: 1),
        make(.crystal, 11, "Last facet", "Lead the eight in a crowd.", pattern: .figureEight, lie: .phaseLead, magnitude: 0.58, fish: 8, period: 3.2, hints: 1),
    ]

    private static let alien: [LevelDef] = [
        make(.alien, 0, "Machine cycle", "Identical bodies. One skips the surge.", pattern: .surge, lie: .holdsSpeed, magnitude: 0.86, period: 3.0, hints: 2),
        make(.alien, 1, "Wrong orbit", "Opposite turn on the discs.", pattern: .loop, lie: .oppositeTurn, magnitude: 0.80, period: 3.4, hints: 2),
        make(.alien, 2, "Early servo", "A corner too soon.", pattern: .loop, lie: .turnsEarlier, magnitude: 0.76, period: 3.3, hints: 2),
        make(.alien, 3, "Lagging unit", "Slow weave over terraces.", pattern: .weave, lie: .slower, magnitude: 0.72, period: 3.1, hints: 1),
        make(.alien, 4, "Hitch in the line", "A pause in the bob.", pattern: .bob, lie: .pauses, magnitude: 0.70, period: 2.7, hints: 1),
        make(.alien, 5, "Lead drone", "Phase lead on a circle.", pattern: .circle, lie: .phaseLead, magnitude: 0.68, fish: 8, period: 3.0, hints: 1),
        make(.alien, 6, "Late servo", "Late corner, eight units.", pattern: .loop, lie: .turnsLater, magnitude: 0.64, fish: 8, period: 3.3, hints: 1),
        make(.alien, 7, "Fast unit", "Faster eight.", pattern: .figureEight, lie: .faster, magnitude: 0.64, period: 3.2, hints: 1),
        make(.alien, 8, "Held cycle", "Surge again.", pattern: .surge, lie: .holdsSpeed, magnitude: 0.62, fish: 8, period: 2.9, hints: 1),
        make(.alien, 9, "Against the disc", "Opposite, smaller.", pattern: .circle, lie: .oppositeTurn, magnitude: 0.60, fish: 8, period: 3.1, hints: 1),
        make(.alien, 10, "Quiet lag", "Slow loop in a crowd.", pattern: .loop, lie: .slower, magnitude: 0.58, fish: 8, period: 3.3, hints: 1),
        make(.alien, 11, "Final current", "A last early turn.", pattern: .loop, lie: .turnsEarlier, magnitude: 0.56, fish: 8, period: 3.4, hints: 1),
    ]
}
