import SwiftUI

struct CreatureView: View {
    var theme: ThemeID
    var heading: Double
    var wiggle: Double
    var highlighted: Bool = false
    var dimmed: Bool = false
    var ring: RingKind = .none

    enum RingKind { case none, odd, miss, hint }

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            var local = context
            local.translateBy(x: center.x, y: center.y)
            local.rotate(by: .radians(heading))
            if dimmed {
                local.opacity = 0.42
            }
            drawRing(local, size: size)
            switch theme {
            case .classic: drawClassic(local, size: size)
            case .robots: drawRobot(local, size: size)
            case .ghosts: drawGhost(local, size: size)
            case .toys: drawToy(local, size: size)
            case .jellyfish: drawJelly(local, size: size)
            case .koi: drawKoi(local, size: size)
            }
        }
        .scaleEffect(highlighted ? 1.08 : 1)
        .animation(.easeInOut(duration: 0.18), value: highlighted)
        .allowsHitTesting(false)
    }

    private func drawRing(_ context: GraphicsContext, size: CGSize) {
        guard ring != .none else { return }
        let color: Color = {
            switch ring {
            case .odd: Palette.success
            case .miss: Palette.danger
            case .hint: Palette.gold
            case .none: .clear
            }
        }()
        let rect = CGRect(x: -size.width * 0.48, y: -size.height * 0.48, width: size.width * 0.96, height: size.height * 0.96)
        context.stroke(
            Path(ellipseIn: rect),
            with: .color(color.opacity(0.95)),
            lineWidth: size.width * 0.06
        )
    }

    private func drawClassic(_ context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        var ctx = context

        var tail = Path()
        tail.move(to: CGPoint(x: -w * 0.18, y: 0))
        tail.addLine(to: CGPoint(x: -w * 0.48, y: -h * 0.22 + wiggle * h * 0.08))
        tail.addLine(to: CGPoint(x: -w * 0.40, y: 0))
        tail.addLine(to: CGPoint(x: -w * 0.48, y: h * 0.22 + wiggle * h * 0.08))
        tail.closeSubpath()
        ctx.fill(tail, with: .color(Color(red: 1.0, green: 0.78, blue: 0.18)))

        var dorsal = Path()
        dorsal.move(to: CGPoint(x: -w * 0.02, y: -h * 0.10))
        dorsal.addLine(to: CGPoint(x: w * 0.08, y: -h * 0.42))
        dorsal.addLine(to: CGPoint(x: w * 0.18, y: -h * 0.08))
        dorsal.closeSubpath()
        ctx.fill(dorsal, with: .color(Color(red: 1.0, green: 0.72, blue: 0.16)))

        let body = Path(ellipseIn: CGRect(x: -w * 0.28, y: -h * 0.22, width: w * 0.62, height: h * 0.44))
        ctx.fill(body, with: .color(Color(red: 0.16, green: 0.48, blue: 0.95)))
        let belly = Path(ellipseIn: CGRect(x: -w * 0.16, y: -h * 0.06, width: w * 0.42, height: h * 0.22))
        ctx.fill(belly, with: .color(Color(red: 0.40, green: 0.72, blue: 1.0).opacity(0.55)))

        var pec = Path()
        pec.addEllipse(in: CGRect(x: w * 0.00, y: h * 0.02, width: w * 0.16, height: h * 0.10))
        ctx.fill(pec, with: .color(Color(red: 1.0, green: 0.76, blue: 0.20).opacity(0.9)))

        drawEye(ctx, origin: CGPoint(x: w * 0.22, y: -h * 0.04), radius: w * 0.075)
    }

    private func drawRobot(_ context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        var propeller = Path()
        propeller.addRoundedRect(
            in: CGRect(x: -w * 0.48, y: -h * 0.04 + wiggle * h * 0.04, width: w * 0.18, height: h * 0.08),
            cornerSize: CGSize(width: 4, height: 4)
        )
        context.fill(propeller, with: .color(Color(red: 0.55, green: 0.85, blue: 0.95)))

        let body = Path(roundedRect: CGRect(x: -w * 0.28, y: -h * 0.18, width: w * 0.58, height: h * 0.36), cornerRadius: h * 0.12)
        context.fill(body, with: .color(Color(red: 0.55, green: 0.62, blue: 0.72)))
        context.stroke(body, with: .color(Color.white.opacity(0.35)), lineWidth: 1.5)
        let visor = Path(roundedRect: CGRect(x: w * 0.08, y: -h * 0.10, width: w * 0.18, height: h * 0.16), cornerRadius: 6)
        context.fill(visor, with: .color(Color(red: 0.20, green: 0.95, blue: 0.85)))
    }

    private func drawGhost(_ context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        var body = Path()
        body.addEllipse(in: CGRect(x: -w * 0.22, y: -h * 0.28, width: w * 0.44, height: h * 0.42))
        body.move(to: CGPoint(x: -w * 0.22, y: 0))
        body.addLine(to: CGPoint(x: -w * 0.22, y: h * 0.28 + wiggle * h * 0.05))
        body.addQuadCurve(to: CGPoint(x: -w * 0.07, y: h * 0.18), control: CGPoint(x: -w * 0.16, y: h * 0.12))
        body.addQuadCurve(to: CGPoint(x: w * 0.07, y: h * 0.28 + wiggle * h * 0.04), control: CGPoint(x: 0, y: h * 0.12))
        body.addQuadCurve(to: CGPoint(x: w * 0.22, y: h * 0.16), control: CGPoint(x: w * 0.14, y: h * 0.32))
        body.addLine(to: CGPoint(x: w * 0.22, y: 0))
        context.fill(body, with: .color(Color(red: 0.72, green: 0.88, blue: 1.0).opacity(0.78)))
        drawEye(context, origin: CGPoint(x: -w * 0.07, y: -h * 0.08), radius: w * 0.05, pupil: 0.45)
        drawEye(context, origin: CGPoint(x: w * 0.07, y: -h * 0.08), radius: w * 0.05, pupil: 0.45)
    }

    private func drawToy(_ context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        var tail = Path()
        tail.move(to: CGPoint(x: -w * 0.16, y: 0))
        tail.addLine(to: CGPoint(x: -w * 0.44, y: -h * 0.16 + wiggle * h * 0.06))
        tail.addLine(to: CGPoint(x: -w * 0.44, y: h * 0.16 + wiggle * h * 0.06))
        tail.closeSubpath()
        context.fill(tail, with: .color(Color(red: 0.82, green: 0.42, blue: 0.22)))
        let body = Path(ellipseIn: CGRect(x: -w * 0.24, y: -h * 0.20, width: w * 0.56, height: h * 0.40))
        context.fill(body, with: .color(Color(red: 0.93, green: 0.72, blue: 0.38)))
        let key = Path(ellipseIn: CGRect(x: -w * 0.04, y: -h * 0.28, width: w * 0.10, height: h * 0.10))
        context.stroke(key, with: .color(Color(red: 0.75, green: 0.55, blue: 0.18)), lineWidth: 2)
        drawEye(context, origin: CGPoint(x: w * 0.18, y: -h * 0.04), radius: w * 0.06)
    }

    private func drawJelly(_ context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let bell = Path(ellipseIn: CGRect(x: -w * 0.26, y: -h * 0.32, width: w * 0.52, height: h * 0.40))
        context.fill(bell, with: .color(Color(red: 0.72, green: 0.55, blue: 0.98).opacity(0.85)))
        for i in 0..<4 {
            let x = -w * 0.16 + CGFloat(i) * w * 0.11
            var t = Path()
            t.move(to: CGPoint(x: x, y: h * 0.02))
            t.addQuadCurve(
                to: CGPoint(x: x + wiggle * w * 0.04, y: h * 0.36),
                control: CGPoint(x: x + (i.isMultiple(of: 2) ? -1 : 1) * w * 0.06, y: h * 0.18)
            )
            context.stroke(t, with: .color(Color(red: 0.82, green: 0.70, blue: 1.0).opacity(0.8)), lineWidth: 2)
        }
        drawEye(context, origin: CGPoint(x: -w * 0.07, y: -h * 0.14), radius: w * 0.045, pupil: 0.5)
        drawEye(context, origin: CGPoint(x: w * 0.07, y: -h * 0.14), radius: w * 0.045, pupil: 0.5)
    }

    private func drawKoi(_ context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        var tail = Path()
        tail.move(to: CGPoint(x: -w * 0.18, y: 0))
        tail.addLine(to: CGPoint(x: -w * 0.46, y: -h * 0.20 + wiggle * h * 0.07))
        tail.addLine(to: CGPoint(x: -w * 0.38, y: 0))
        tail.addLine(to: CGPoint(x: -w * 0.46, y: h * 0.20 + wiggle * h * 0.07))
        tail.closeSubpath()
        context.fill(tail, with: .color(Color(red: 0.95, green: 0.42, blue: 0.22)))

        let body = Path(ellipseIn: CGRect(x: -w * 0.26, y: -h * 0.20, width: w * 0.60, height: h * 0.40))
        context.fill(body, with: .color(Color(red: 0.96, green: 0.94, blue: 0.90)))
        let patch = Path(ellipseIn: CGRect(x: -w * 0.02, y: -h * 0.14, width: w * 0.22, height: h * 0.18))
        context.fill(patch, with: .color(Color(red: 0.93, green: 0.32, blue: 0.20)))
        let patch2 = Path(ellipseIn: CGRect(x: -w * 0.18, y: 0.00, width: w * 0.14, height: h * 0.12))
        context.fill(patch2, with: .color(Color(red: 0.93, green: 0.32, blue: 0.20)))
        drawEye(context, origin: CGPoint(x: w * 0.22, y: -h * 0.04), radius: w * 0.065)
    }

    private func drawEye(_ context: GraphicsContext, origin: CGPoint, radius: CGFloat, pupil: CGFloat = 0.55) {
        let white = Path(ellipseIn: CGRect(x: origin.x - radius, y: origin.y - radius, width: radius * 2, height: radius * 2))
        context.fill(white, with: .color(.white))
        let pr = radius * pupil
        let pupilPath = Path(ellipseIn: CGRect(x: origin.x - pr + radius * 0.12, y: origin.y - pr, width: pr * 2, height: pr * 2))
        context.fill(pupilPath, with: .color(.black))
        let spark = Path(ellipseIn: CGRect(x: origin.x + radius * 0.15, y: origin.y - radius * 0.35, width: radius * 0.35, height: radius * 0.35))
        context.fill(spark, with: .color(.white))
    }
}
