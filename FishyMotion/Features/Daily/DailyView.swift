import SwiftUI

struct DailyView: View {
    @Environment(AppModel.self) private var model
    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "Daily Puzzle") { model.goHome() }
            VStack(spacing: 18) {
                Spacer(minLength: 12)
                Image(systemName: "gift.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.98, green: 0.32, blue: 0.32), Color(red: 0.95, green: 0.72, blue: 0.18)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.25), radius: 10, y: 6)

                Text("A new challenge every day!")
                    .font(.fmBody(18))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                FMButton(title: "Play", kind: .ocean) {
                    model.playDaily()
                }
                .padding(.horizontal, 36)
                .accessibilityIdentifier("daily-play-button")

                Label(countdown, systemImage: "clock")
                    .font(.fmBody(14))
                    .foregroundStyle(Palette.muted)
                Spacer(minLength: 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .fillScreenTop()
        .background { OceanBackdrop(asset: "SunkenRuinsBackground", dim: 0.35) }
        .onReceive(timer) { now = $0 }
    }

    private var countdown: String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let next = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(86_400)
        let s = max(0, Int(next.timeIntervalSince(now)))
        return String(format: "%02d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60)
    }
}
