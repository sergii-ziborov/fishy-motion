import Foundation

struct Pose: Equatable, Sendable {
    var x: Double
    var y: Double
    var heading: Double

    var point: SIMD2<Double> { SIMD2(x, y) }

    func distance(to other: Pose) -> Double {
        hypot(x - other.x, y - other.y)
    }

    func headingDelta(to other: Pose) -> Double {
        var d = heading - other.heading
        while d > .pi { d -= 2 * .pi }
        while d < -.pi { d += 2 * .pi }
        return d
    }
}

struct MotionParams: Equatable, Sendable {
    var speed: Double
    var phase: Double
    var corner: Double
    var amplitude: Double
    var surge: Double
    var pauseDuration: Double
    var reverse: Bool
}

struct Fish: Equatable, Sendable, Identifiable {
    var id: Int
    var slot: SIMD2<Double>
    var isOdd: Bool
}

struct School: Equatable, Sendable {
    var fish: [Fish]
    var oddIndex: Int
    var pattern: PatternKind
    var lie: LieKind
    var period: Double
    var magnitude: Double
    var group: MotionParams
    var odd: MotionParams
    var theme: ThemeID

    var count: Int { fish.count }

    func poses(at time: Double) -> [Pose] {
        fish.map { creature in
            let params = creature.isOdd ? odd : group
            let center = Motion.centroid(pattern: pattern, period: period, params: params, time: time)
            let c = Darwin.cos(center.heading)
            let s = Darwin.sin(center.heading)
            let dx = creature.slot.x * c - creature.slot.y * s
            let dy = creature.slot.x * s + creature.slot.y * c
            return Pose(x: center.x + dx, y: center.y + dy, heading: center.heading)
        }
    }

    func tellTime(samples: Int = 64) -> Double {
        var bestT = period * 0.45
        var best = 0.0
        let window = max(period * 2, 2.4)
        for i in 0..<samples {
            let t = window * Double(i) / Double(samples)
            let score = Detectability.separation(school: self, at: t)
            if score > best {
                best = score
                bestT = t
            }
        }
        return bestT
    }
}

enum Motion {
    static func baseParams(pattern: PatternKind, period: Double) -> MotionParams {
        switch pattern {
        case .loop:
            MotionParams(speed: 0.55, phase: 0, corner: 0.055, amplitude: 0.18, surge: 0, pauseDuration: 0, reverse: false)
        case .weave:
            MotionParams(speed: 0.22, phase: 0, corner: 0.05, amplitude: 0.12, surge: 0, pauseDuration: 0, reverse: false)
        case .circle:
            MotionParams(speed: 1, phase: 0, corner: 0.05, amplitude: 0.22, surge: 0, pauseDuration: 0, reverse: false)
        case .figureEight:
            MotionParams(speed: 1, phase: 0, corner: 0.05, amplitude: 0.20, surge: 0, pauseDuration: 0, reverse: false)
        case .bob:
            MotionParams(speed: 1, phase: 0, corner: 0.05, amplitude: 0.16, surge: 0, pauseDuration: 0, reverse: false)
        case .surge:
            MotionParams(speed: 0.20, phase: 0, corner: 0.05, amplitude: 0.10, surge: 0.55, pauseDuration: 0, reverse: false)
        }
    }

    static func apply(lie: LieKind, magnitude: Double, period: Double, base: MotionParams) -> MotionParams {
        var params = base
        let m = min(1, max(0.5, magnitude))
        switch lie {
        case .turnsEarlier:
            params.corner = base.corner + 0.085 * m
        case .turnsLater:
            params.corner = max(0.012, base.corner - 0.038 * m)
        case .slower:
            params.speed = base.speed * (1 - 0.34 * m)
        case .faster:
            params.speed = base.speed * (1 + 0.34 * m)
        case .holdsSpeed:
            params.surge = 0
        case .pauses:
            params.pauseDuration = 0.42 * m * max(period, 2)
        case .oppositeTurn:
            params.reverse = true
        case .phaseLead:
            params.phase = -0.42 * m * period
        }
        return params
    }

    static func centroid(pattern: PatternKind, period: Double, params: MotionParams, time: Double) -> Pose {
        let t = effectiveTime(time + params.phase, period: period, pause: params.pauseDuration)
        let signed = params.reverse ? -1.0 : 1.0
        switch pattern {
        case .loop:
            let distance = signed * params.speed * t
            return loopPose(distance: distance, corner: params.corner)
        case .weave:
            return weavePose(time: t, period: period, params: params, sign: signed)
        case .circle:
            return circlePose(time: t, period: period, params: params, sign: signed)
        case .figureEight:
            return eightPose(time: t, period: period, params: params, sign: signed)
        case .bob:
            return bobPose(time: t, period: period, params: params)
        case .surge:
            return surgePose(time: t, period: period, params: params, sign: signed)
        }
    }

    static func effectiveTime(_ time: Double, period: Double, pause: Double) -> Double {
        guard pause > 0, period > 0 else { return time }
        let pauseAt = 0.42 * period
        let cycle = period + pause
        let wrapped = time - floor(time / cycle) * cycle
        if wrapped < pauseAt { return floor(time / cycle) * period + wrapped }
        if wrapped < pauseAt + pause { return floor(time / cycle) * period + pauseAt }
        return floor(time / cycle) * period + (wrapped - pause)
    }

    static func loopPose(distance: Double, corner: Double) -> Pose {
        let left = 0.20
        let right = 0.80
        let top = 0.30
        let bottom = 0.70
        let maxCorner = min((right - left) / 2 - 0.02, (bottom - top) / 2 - 0.02)
        let c = min(max(corner, 0.01), maxCorner)
        let h = right - left - 2 * c
        let v = bottom - top - 2 * c
        let arc = 0.5 * Double.pi * c
        let lengths = [h, arc, v, arc, h, arc, v, arc]
        let peri = lengths.reduce(0, +)
        var d = distance.truncatingRemainder(dividingBy: peri)
        if d < 0 { d += peri }

        var acc = 0.0
        for (index, length) in lengths.enumerated() {
            if d <= acc + length + 1e-9 {
                let u = length < 1e-9 ? 0 : (d - acc) / length
                return loopSegment(index, u: u, left: left, right: right, top: top, bottom: bottom, c: c, h: h, v: v)
            }
            acc += length
        }
        return Pose(x: left + c, y: top, heading: 0)
    }

    private static func loopSegment(
        _ index: Int,
        u: Double,
        left: Double,
        right: Double,
        top: Double,
        bottom: Double,
        c: Double,
        h: Double,
        v: Double
    ) -> Pose {
        let uu = min(1, max(0, u))
        switch index {
        case 0:
            return Pose(x: left + c + uu * h, y: top, heading: 0)
        case 1:
            let ang = -Double.pi / 2 + uu * Double.pi / 2
            return Pose(x: right - c + c * Darwin.cos(ang), y: top + c + c * Darwin.sin(ang), heading: uu * Double.pi / 2)
        case 2:
            return Pose(x: right, y: top + c + uu * v, heading: Double.pi / 2)
        case 3:
            let ang = uu * Double.pi / 2
            return Pose(x: right - c + c * Darwin.cos(ang), y: bottom - c + c * Darwin.sin(ang), heading: Double.pi / 2 + uu * Double.pi / 2)
        case 4:
            return Pose(x: right - c - uu * h, y: bottom, heading: Double.pi)
        case 5:
            let ang = Double.pi / 2 + uu * Double.pi / 2
            return Pose(x: left + c + c * Darwin.cos(ang), y: bottom - c + c * Darwin.sin(ang), heading: Double.pi + uu * Double.pi / 2)
        case 6:
            return Pose(x: left, y: bottom - c - uu * v, heading: 3 * Double.pi / 2)
        default:
            let ang = Double.pi + uu * Double.pi / 2
            return Pose(x: left + c + c * Darwin.cos(ang), y: top + c + c * Darwin.sin(ang), heading: 3 * Double.pi / 2 + uu * Double.pi / 2)
        }
    }

    static func weavePose(time: Double, period: Double, params: MotionParams, sign: Double) -> Pose {
        let traveled = sign * params.speed * time
        let (x, vx) = pingPong(traveled, lo: 0.22, hi: 0.78)
        let omega = 2 * Double.pi / max(period, 0.5)
        let y = 0.50 + params.amplitude * Darwin.sin(omega * time)
        let dy = params.amplitude * omega * Darwin.cos(omega * time)
        return Pose(x: x, y: y, heading: atan2(dy, vx * params.speed * sign))
    }

    static func circlePose(time: Double, period: Double, params: MotionParams, sign: Double) -> Pose {
        let omega = sign * 2 * Double.pi / max(period, 0.5) * params.speed
        let ang = omega * time - Double.pi / 2
        let r = 0.12 + params.amplitude
        return Pose(
            x: 0.50 + r * Darwin.cos(ang),
            y: 0.50 + r * Darwin.sin(ang),
            heading: ang + Double.pi / 2
        )
    }

    static func eightPose(time: Double, period: Double, params: MotionParams, sign: Double) -> Pose {
        let omega = sign * 2 * Double.pi / max(period, 0.5) * params.speed
        let a = omega * time
        let ax = 0.22
        let ay = params.amplitude
        let x = 0.50 + ax * Darwin.sin(a)
        let y = 0.50 + ay * Darwin.sin(2 * a)
        let dx = ax * Darwin.cos(a) * omega
        let dy = 2 * ay * Darwin.cos(2 * a) * omega
        return Pose(x: x, y: y, heading: atan2(dy, dx))
    }

    static func bobPose(time: Double, period: Double, params: MotionParams) -> Pose {
        let omega = 2 * Double.pi / max(period, 0.5) * params.speed
        let y = 0.50 + params.amplitude * Darwin.sin(omega * time)
        let dy = params.amplitude * omega * Darwin.cos(omega * time)
        return Pose(x: 0.50, y: y, heading: atan2(dy, 0.18))
    }

    static func surgePose(time: Double, period: Double, params: MotionParams, sign: Double) -> Pose {
        let omega = 2 * Double.pi / max(period, 0.5)
        let distance = sign * (params.speed * time + params.surge * params.speed * period / omega * (1 - Darwin.cos(omega * time)))
        let (x, vx) = pingPong(distance, lo: 0.22, hi: 0.78)
        let y = 0.50 + 0.04 * Darwin.sin(omega * time)
        return Pose(x: x, y: y, heading: vx >= 0 ? 0 : Double.pi)
    }

    static func pingPong(_ value: Double, lo: Double, hi: Double) -> (Double, Double) {
        let span = hi - lo
        guard span > 0 else { return (lo, 1) }
        let cycle = 2 * span
        var u = value.truncatingRemainder(dividingBy: cycle)
        if u < 0 { u += cycle }
        if u <= span {
            return (lo + u, 1)
        }
        return (hi - (u - span), -1)
    }

    static func slots(count: Int) -> [SIMD2<Double>] {
        let scale = count >= 8 ? 0.085 : 0.10
        switch count {
        case 4:
            return [
                SIMD2(-scale, 0),
                SIMD2(scale, 0),
                SIMD2(0, -scale * 0.8),
                SIMD2(0, scale * 0.8)
            ]
        case 8:
            return [
                SIMD2(-scale * 1.2, -scale * 0.85),
                SIMD2(0, -scale * 0.85),
                SIMD2(scale * 1.2, -scale * 0.85),
                SIMD2(-scale * 1.2, 0),
                SIMD2(scale * 1.2, 0),
                SIMD2(-scale * 1.2, scale * 0.85),
                SIMD2(0, scale * 0.85),
                SIMD2(scale * 1.2, scale * 0.85)
            ]
        default:
            return [
                SIMD2(-scale * 1.15, -scale * 0.7),
                SIMD2(0, -scale * 0.85),
                SIMD2(scale * 1.15, -scale * 0.7),
                SIMD2(-scale * 1.15, scale * 0.7),
                SIMD2(0, scale * 0.85),
                SIMD2(scale * 1.15, scale * 0.7)
            ]
        }
    }
}

enum SchoolBuilder {
    static func build(level: LevelDef, seed: UInt64, theme: ThemeID, forceOdd: Int? = nil) -> School {
        var rng = SeededRNG(seed: seed &+ UInt64(level.index) &* 17)
        let count = max(4, min(8, level.fishCount))
        let odd = forceOdd.map { min(max(0, $0), count - 1) } ?? rng.nextInt(in: 0...(count - 1))
        let slots = Motion.slots(count: count)
        let fish = (0..<count).map { index in
            Fish(id: index, slot: slots[index], isOdd: index == odd)
        }
        let group = Motion.baseParams(pattern: level.pattern, period: level.period)
        let oddParams = Motion.apply(lie: level.lie, magnitude: level.magnitude, period: level.period, base: group)
        return School(
            fish: fish,
            oddIndex: odd,
            pattern: level.pattern,
            lie: level.lie,
            period: level.period,
            magnitude: level.magnitude,
            group: group,
            odd: oddParams,
            theme: theme
        )
    }
}

enum Detectability {
    static let minimumSeparation = 0.058

    static func separation(school: School, at time: Double) -> Double {
        let poses = school.poses(at: time)
        guard school.oddIndex < poses.count else { return 0 }
        let odd = poses[school.oddIndex]
        let others = poses.indices.filter { $0 != school.oddIndex }.map { poses[$0] }
        guard !others.isEmpty else { return 0 }
        let midX = median(others.map(\.x))
        let midY = median(others.map(\.y))
        let midH = median(others.map(\.heading))
        let pos = hypot(odd.x - midX, odd.y - midY)
        var dHead = odd.heading - midH
        while dHead > .pi { dHead -= 2 * .pi }
        while dHead < -.pi { dHead += 2 * .pi }
        return pos + abs(dHead) * 0.09
    }

    static func maxSeparation(school: School, duration: Double? = nil, samples: Int = 56) -> Double {
        let window = duration ?? max(school.period * 2.2, 2.6)
        var best = 0.0
        for i in 0..<samples {
            let t = window * Double(i) / Double(samples)
            best = max(best, separation(school: school, at: t))
        }
        return best
    }

    static func median(_ values: [Double]) -> Double {
        let sorted = values.sorted()
        guard !sorted.isEmpty else { return 0 }
        return sorted[sorted.count / 2]
    }
}
