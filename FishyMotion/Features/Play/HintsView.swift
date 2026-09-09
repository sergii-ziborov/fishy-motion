import SwiftUI

struct HintsView: View {
    @Environment(AppModel.self) private var model

    private let rows: [(String, String)] = [
        ("clock.fill", "Watch the timing"),
        ("arrow.right", "Check the direction"),
        ("hare.fill", "Look at the speed"),
        ("pause.fill", "Notice the pauses")
    ]

    var body: some View {
        ZStack {
            OceanBackdrop(asset: "CoralReefBackground", dim: 0.5)
            VStack(spacing: 0) {
                ScreenHeader(title: "Hints") {
                    if model.session != nil {
                        model.screen = .play
                    } else {
                        model.goHome()
                    }
                }
                VStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                        HStack(spacing: 14) {
                            Image(systemName: row.0)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Palette.oceanDeep)
                                .frame(width: 36, height: 36)
                                .background(Palette.aqua, in: Circle())
                            Text(row.1)
                                .font(.fmBody(18))
                                .foregroundStyle(Palette.navy)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        if index < rows.count - 1 {
                            Divider()
                        }
                    }
                }
                .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(20)
                Spacer()
            }
        }
    }
}
